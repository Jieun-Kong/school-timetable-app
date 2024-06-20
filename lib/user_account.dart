//**user_account.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_data.dart';
import 'bottom_sheet.dart';



class UserInfoProvider with ChangeNotifier {
  UserInfo _userInfo = UserInfo(grade: 'Grade', part: 'Part', department: 'Department', section: 'Section');

  UserInfo get userInfo => _userInfo;

  void updateUserInfo(String grade, String part, String department, String section, BuildContext context) async {
    _userInfo = UserInfo(grade: grade, part: part, department: department, section: section);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //사용자 정보 저장
    await prefs.setString('grade', grade);
    await prefs.setString('part', part);
    await prefs.setString('department', department);
    await prefs.setString('section', section);

    notifyListeners();
  }



  // 필수 독강 초기 세팅
  Future<void> initialSetting(BuildContext context) async {
    UserInfo userInfo = Provider.of<UserInfoProvider>(context, listen:false).userInfo;
    List<dynamic> rawData = await fetchSheetData(userInfo);

    List<LectureInfo> lectureInfos = rawData.where((item) =>
        item[1] == userInfo.grade &&
        item[2] == userInfo.part &&
        item[3] == userInfo.department &&
        item[4] == userInfo.section &&
        item[5] == '독강'
      ).map<LectureInfo>((item) {
        return LectureInfo(
          department: item[3],
          section: item[4],
          type: item[5],
          semiType: item[6],
          lecture: item[7],
          professor: item[8],
          room: item[9],
          startDateTime: DateTime.parse("${item[13]} ${item[11]}"),
          endDateTime: DateTime.parse("${item[13]} ${item[12]}"),
        );
    }).toList();

    // 초기 세팅 캘린더 추가 (updateAppointments 유사)
    final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
    selectedLecture.clear();
    dataSource.permanentAppointments.clear();
    for (var lecture in lectureInfos) {
      final Appointment newAppointment = Appointment(
        startTime: lecture.startDateTime,
        endTime: lecture.endDateTime,
        subject: "${lecture.lecture}\n\n${lecture.professor}\n${lecture.room}",
        color: Colors.blue,
      );
      selectedLecture.add(lecture);
      dataSource.permanentAppointments.add(newAppointment);
    }
    dataSource.updateDisplayAppointments();
    dataSource.saveAppointments();
  }
}



//**사용자 정보 설정 */
class UserAccountSettingsScreen extends StatefulWidget {
  const UserAccountSettingsScreen({super.key});

  @override
  State<UserAccountSettingsScreen> createState() => _UserAccountSettingsScreenState();
}

class _UserAccountSettingsScreenState extends State<UserAccountSettingsScreen> {
  String selectedGrade = 'Grade';
  String selectedPart = 'Part';
  String selectedDepartment = 'Department';
  String selectedSection = 'Section';

  final List<String> grades = ['1학년', '2학년', '3학년', '4학년'];
  final List<String> parts = ['앞반', '뒷반'];
  final List<String> departments = ['국어교육과', '수학교육과', '사회교육과', '과학교육과', '영어교육과', '음악교육과', '미술교육과', '체육교육과', '생활과학교육과', '윤리교육과', '컴퓨터교육과', '특수교육과', '교육학과', '유아교육과'];
  final List<String> sections = ['1반', '2반'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: '학년'),
              items: grades.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGrade = newValue!;
                });
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: '앞/뒷반'),
              items: parts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPart = newValue!;
                });
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: '학과'),
              items: departments.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDepartment = newValue!;
                });
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: '반'),
              items: sections.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSection = newValue!;
                });
              },
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: Container()),
                ElevatedButton(
                  onPressed: () async {
                    final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
                    
                    // 유저 인포 저장
                    userInfoProvider.updateUserInfo(selectedGrade, selectedPart, selectedDepartment, selectedSection, context);
                    // 캘린더 추가
                    await userInfoProvider.initialSetting(context);

                    Navigator.pop(context);
                  },
                  child: const Text('저장')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
