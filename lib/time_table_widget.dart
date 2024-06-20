//**time_table_widget.dart */
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'bottom_sheet.dart';


class TimeTableWidget extends StatefulWidget {
  const TimeTableWidget({super.key});

  @override
  State<TimeTableWidget> createState() => _TimeTableWidgetState();
}



class _TimeTableWidgetState extends State<TimeTableWidget> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget> [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Mon"), Text("Tue"), Text("Wed"), Text("Thu"), Text("Fri")
          ],
        ),
          
        Container(height: 6),
        Expanded(
          child: Consumer<MeetingDataSource>(builder: (context, dataSource, child) {
            return SfCalendar(
              view: CalendarView.workWeek,
              headerHeight: 0,
              viewHeaderHeight: 0,
              showCurrentTimeIndicator: false,
              monthViewSettings: const MonthViewSettings(showTrailingAndLeadingDates: false),
              initialDisplayDate: DateTime(2024, 3, 4 , 9, 00),
              viewNavigationMode: ViewNavigationMode.none,
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 9,
                endHour: 23,
                timeIntervalHeight: ((MediaQuery.of(context).size.height / 16.3).round().toDouble())),
              dataSource: dataSource,

              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('강의 삭제'),
                        content: const Text('강의를 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 다이얼로그 닫기
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
                              dataSource.deleteAppointment(details.appointments!.first);
                              Navigator.of(context).pop(); // 다이얼로그 닫기
                            },
                            child: const Text('삭제'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }),
        ),
      ],
    );
  }
}


// 캘린더 데이터 소스 클래스
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}

