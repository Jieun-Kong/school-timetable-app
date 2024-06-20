import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_api.dart';



class ShuttleBus extends StatefulWidget {
  const ShuttleBus({super.key});

  @override
  State<ShuttleBus> createState() => ShuttleBusState();
}


class ShuttleBusState extends State<ShuttleBus> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<DateTime> markedDays = [];


  //**초기 */
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var seoul = tz.getLocation('Asia/Seoul');
    tz.setLocalLocation(seoul);

    loadMarkedDays();
  }





  //**알림 로드 및 로컬 저장 */
  Future<void> loadMarkedDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
      markedDays = (prefs.getStringList('markedDays') ?? []).map((item) => DateTime.parse(item)).toList();
    });
  }

  Future<void> saveMarkedDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('markedDays', markedDays.map((item) => item.toString()).toList());
    setState(() {});
  }





  //화면 위젯
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('셔틀버스'),
      ),
      body: Padding(padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget> [
            const Text('운행시간',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Padding(padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Image.asset('assets/images/shuttle_bus_time.png')),
            const SizedBox(height: 30),

            const Text('셔틀 예약 알림',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //Todo: 타이틀 옆에 아이콘 넣어서 팝업
            //(동아리, 학과 행사 등 셔틀이 필요한 날을 선택해주세요. 해당 일의 예약 시작시간에 맞춰 알림을 드립니다.)
            TableCalendar(
              //locale: 'ko_KR',
              firstDay: DateTime.now(),
              lastDay: DateTime(2024, 6, 21),
              focusedDay: focusedDay,
              headerStyle: const HeaderStyle(formatButtonVisible: false),

              eventLoader: (day) {
                return markedDays.where((event) => isSameDay(event, day)).toList();
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },

              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  this.focusedDay = selectedDay;
                  this.selectedDay = selectedDay;

                  if (markedDays.contains(selectedDay)) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("알림 삭제"),
                        content: const Text("셔틀 예약 알림을 삭제하시겠습니까?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("예"),
                            onPressed: () {
                              markedDays.remove(selectedDay);
                              saveMarkedDays();
                              FirebaseApi().cancelScheduledNotification(selectedDay);
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("아니오"),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (selectedDay.weekday == DateTime.saturday || selectedDay.weekday == DateTime.sunday || 
                        isSameDay(selectedDay, DateTime(2024, 3, 29)) ||
                        isSameDay(selectedDay, DateTime(2024, 4, 22)) ||
                        isSameDay(selectedDay, DateTime(2024, 4, 23)) ||
                        isSameDay(selectedDay, DateTime(2024, 4, 24)) ||
                        isSameDay(selectedDay, DateTime(2024, 4, 25)) ||
                        isSameDay(selectedDay, DateTime(2024, 4, 26)) ||
                        isSameDay(selectedDay, DateTime(2024, 5, 1)) ||
                        isSameDay(selectedDay, DateTime(2024, 5, 6)) ||
                        isSameDay(selectedDay, DateTime(2024, 6, 6))) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("미운영"),
                          content: const Text("해당일에는 셔틀버스를 운행하지 않습니다."),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("확인"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ]
                        ),
                      );
                  } else {
                    DateTime now = DateTime.now();
                    final tzSelectedDay = tz.TZDateTime.from(selectedDay, tz.getLocation('Asia/Seoul'));
                    var tzNotificationEndTime = tz.TZDateTime(tzSelectedDay.location, tzSelectedDay.year, tzSelectedDay.month, tzSelectedDay.day -1, 20, 00);
                    if (tzNotificationEndTime.isBefore(now) || tzNotificationEndTime.isAtSameMomentAs(now)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("신청 마감"),
                          content: const Text("셔틀 신청이 마감되었습니다.\n이제 예정일을 등록해두고 놓치지 마세요!"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("확인"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                  } else {
                    DateTime now = DateTime.now();
                    final tzSelectedDay = tz.TZDateTime.from(selectedDay, tz.getLocation('Asia/Seoul'));
                    var tzNotificationTime = tz.TZDateTime(tzSelectedDay.location, tzSelectedDay.year, tzSelectedDay.month, tzSelectedDay.day -2, 20, 30);
                    if (tzNotificationTime.isBefore(now) || tzNotificationTime.isAtSameMomentAs(now)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("신청 중"),
                          content: const Text("해당 날짜의 셔틀 신청 기간입니다.\n지금 바로 셔틀을 신청하세요!\n\n> 경인교대 포털시스템, (구)학사정보 시스템"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("확인"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("알림 예약"),
                        content: const Text("알림을 예약하시겠습니까?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("예"),
                            onPressed: () {
                              markedDays.add(selectedDay);
                              saveMarkedDays();
                              FirebaseApi().addScheduledNotification(selectedDay); // Firebase 메시지를 통해 알림 예약
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("아니오"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }}}}
                  //this.focusedDay = selectedDay;
                  //this.selectedDay = selectedDay;
                });
              },
            ),
            const SizedBox(height: 30),

          ]
        )
      )
    );
  }

}