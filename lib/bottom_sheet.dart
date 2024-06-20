//**bottom_sheet.dart */
//bottom sheet - onTap - tempSelectedIndex - <List> tempSelectedLecture - <Function> tempAppointments - 임시 일정 표시 - onSave - <List> selectedLecture - 변동사항 확인 - <변수> addLecture - <Function> updateAppointments - 실제 일정 추가
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'api_data.dart';
import 'user_account.dart';

Map<String, int?> tempSelectedIndex = {};
List<LectureInfo> tempSelectedLecture = []; // 임시로 선택된 강의 목록(저장 전)
List<LectureInfo> selectedLecture = []; // 저장 누른 강의 목록


void showMyBottomSheet(BuildContext context, List<LectureInfo> lectureInfos, MeetingDataSource dataSource) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: MyBottomSheetContent(lectureInfos: lectureInfos, dataSource: dataSource)
      );
    },
  );
}

//**일정 데이터 로직 */
class MeetingDataSource extends CalendarDataSource {
  List<Appointment> permanentAppointments = []; //보여지는 캘린더 현재 일정
  List<Appointment> temporaryAppointments = [];
  List<LectureInfo> lectures = [];

  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  //실제 일정 추가
  void addLecture(LectureInfo lectureInfo) {
    selectedLecture.removeWhere((existingLecture) => existingLecture.semiType == lectureInfo.semiType);
    permanentAppointments.clear(); //같은 유형은 기존 선택값 삭제(selectedLecture, permanentAppointments)
    selectedLecture.add(lectureInfo);
    updateAppointments();
    saveAppointments();
  }

  void updateAppointments() { //캘린더화된 일정 추가 로직(permanantAppointment 추가)
    for (var lecture in selectedLecture) {
      final Appointment newAppointment = Appointment(
        startTime: lecture.startDateTime,
        endTime: lecture.endDateTime,
        subject: "${lecture.lecture}\n\n${lecture.professor}\n${lecture.room}",
        color: Colors.blue,
      );
      permanentAppointments.add(newAppointment);
    }
    updateDisplayAppointments();
  }

  //임시 선택 강의 -일정 표시
  void tempAppointments() {
    for (var lecture in tempSelectedLecture) {
      final Appointment newAppointment = Appointment(
        startTime: lecture.startDateTime,
        endTime: lecture.endDateTime,
        subject: "",
        color: Colors.grey,
      );
      temporaryAppointments.add(newAppointment);
    }
    updateDisplayAppointments();
    temporaryAppointments.clear();
  }

  //기존 + 임시 일정 화면 결합
  void updateDisplayAppointments() {
    appointments = List<Appointment>.from(permanentAppointments)..addAll(temporaryAppointments);
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }



  //임시 일정 표시 초기화 로직
  void clearTemporaryAppointments() {
    temporaryAppointments.clear();
    updateDisplayAppointments();
    saveAppointments();
  }

  //일정 삭제 로직
  void deleteAppointment(Appointment appointment) {
    final lecture = selectedLecture.singleWhere(
      (lecture) => lecture.startDateTime == appointment.startTime
        && lecture.endDateTime == appointment.endTime
        && lecture.lecture == appointment.subject.split('\n\n')[0],
    );
    selectedLecture.remove(lecture);
    permanentAppointments.remove(appointment);
    appointments?.remove(appointment);
    updateDisplayAppointments();
    saveAppointments();
  }


  //일정 로컬 데이터 저장
  Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(selectedLecture.map((l) => l.toJson()).toList());
    await prefs.setString('lectures', json);
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('lectures');
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      selectedLecture = list.map((item) => LectureInfo.fromJson(item)).toList();
      updateAppointments();
    }
  }

}



//**바텀 시트 */
class MyBottomSheetContent extends StatefulWidget {
  final List<LectureInfo> lectureInfos;
  final MeetingDataSource dataSource;

  const MyBottomSheetContent({super.key, required this.lectureInfos, required this.dataSource});

  @override
  State<MyBottomSheetContent> createState() => _MyBottomSheetContentState();
}


//**바텀 시트 속성 */
class _MyBottomSheetContentState extends State<MyBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, List<LectureInfo>> sortedLectures;
  late MeetingDataSource dataSource; // 상태 변수로 추가
  


  @override
  void initState() {
    super.initState();
    sortedLectures = {};
    for (var lecture in widget.lectureInfos) {
      sortedLectures.putIfAbsent(lecture.semiType, () => []).add(lecture);
    }


    _tabController = TabController(length: sortedLectures.keys.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
        dataSource.clearTemporaryAppointments();
        setState(() {
          tempSelectedIndex.clear();
          tempSelectedLecture.clear();
        });
      }
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataSource = Provider.of<MeetingDataSource>(context); // didChangeDependencies에서 초기화
  }



  @override
  void dispose() {
    dataSource.clearTemporaryAppointments(); 

    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }




  //**바텀 시트 화면 */
  @override
  Widget build(BuildContext context) {
    //final userInfo = Provider.of<UserInfoProvider>(context).userInfo;  // userInfo 가져오기

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 275,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  if (_tabController.index > 0) {
                    _tabController.animateTo(_tabController.index - 1);
                  }
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    sortedLectures.keys.isNotEmpty
                      ? sortedLectures.keys.elementAt(_tabController.index)
                      : "삼단메뉴 > 하단 팁 아이콘을 참고해주세요!", // sortedLectures가 비어 있을 경우 대체 텍스트
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  if (_tabController.index < _tabController.length - 1) {
                    _tabController.animateTo(_tabController.index + 1);
                  }
                },
              ),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: sortedLectures.keys.map((semiType) {
                final scrollController = ScrollController();

                return Scrollbar(
                  controller: scrollController, // ScrollController를 지정합니다.
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    itemCount: sortedLectures[semiType]!.length,
                    itemBuilder: (context, index){
                      final lecture = sortedLectures[semiType]![index];
                      final isSelected = selectedLecture.contains(lecture);

                      return Container(
                        width: 140,
                        margin: const EdgeInsets.fromLTRB(10, 7, 10, 5),
                        //padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                              width: 3)),
                        child: ListTile(
                          title: Text(lecture.lecture),
                          subtitle: Text(
                            lecture.type == '독강'
                            ? '\n${lecture.professor}\n${lecture.room}\n${lecture.department} ${lecture.section}'
                            : '\n${lecture.professor}\n${lecture.room}',
                          ),
                          tileColor: tempSelectedIndex[semiType] == index ? Colors.grey[200] : null,
                          
                          onTap: () {
                            setState(() {
                              if (tempSelectedIndex[semiType] == index) {
                                tempSelectedIndex[semiType] = null; // 이미 선택된 것 다시 누르면 선택 취소
                                tempSelectedLecture.clear(); // 선택된 강의 목록을 비움
                              } else {
                                tempSelectedIndex[semiType] = index;
                                tempSelectedLecture.clear(); // 먼저 기존 선택된 강의 목록을 비움
                                tempSelectedLecture.add(lecture); // 새로운 강의만 목록에 추가
                              }
                              final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
                                dataSource.tempAppointments();
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: (){
                final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
                final userInfo = Provider.of<UserInfoProvider>(context, listen: false).userInfo;


                setState(() {
                  for (var lecture in tempSelectedLecture) {
                    dataSource.addLecture(lecture); // 임시 선택 강의를 최종 선택 강의로 추가(실제 일정 추가 로직)
                  }
                  tempSelectedIndex.clear();
                  tempSelectedLecture.clear(); // 임시 선택된 강의 목록 초기화
                }); // UI 갱신



                //독강 여부(학과 비교)
                bool isDepartmentMatched = true;
                for (var lecture in selectedLecture) {
                  if (lecture.department != userInfo.department || lecture.section != userInfo.section) {
                    isDepartmentMatched = false;
                    break;
                  }
                }


                //독강 알림
                if (!isDepartmentMatched) {
                  Fluttertoast.showToast(
                    msg: "해당 강의는 독강 수강신청이 필요한 강의입니다!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER, 
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                  );
                }
              }, 
              child: const Text("저장"),
            ),
          ),
        ],
      ),
    );
  }

}



//**예시 리스트 */
//List<Appointment> getAppointments() {
  //List<Appointment> meetings = <Appointment>[];
  //final DateTime startTime = DateTime(2024, 3, 4, 9, 00);
  //final DateTime endTime = startTime.add(const Duration(hours: 2));

  //meetings.add(
    //Appointment(
      //startTime: startTime,
      //endTime: endTime,
      //subject: 'Board Meeting',
      //color: Colors.blue
      //));

  //return meetings;
//}

