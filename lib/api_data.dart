//**api_data.dart */
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchSheetData(UserInfo userInfo) async {
  const String sheetId = '1Yj9PKcLi4B-dy0pxp4RMraT32YgmymjgqvSXk7eb65M'; // Google 시트 ID
  const String apiKey = 'AIzaSyAdvvt2lZphAeFRRcMIwgXLPXVXLiJOK2g'; // Google API 키
  const String apiUrl = 'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/Sheet1?key=$apiKey';

  //구글시트 링크 https://docs.google.com/spreadsheets/d/1Yj9PKcLi4B-dy0pxp4RMraT32YgmymjgqvSXk7eb65M/edit#gid=0

  final response = await http.get(Uri.parse(apiUrl));

  

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body)['values'];
    // 데이터를 필터링하여 필요한 정보만 추출
    final filteredData = data.where((item) { 
      if (item[5] == '독강') {
        return item[1] == userInfo.grade &&
               item[2] == userInfo.part;
      } else {
        return item[1] == userInfo.grade && 
               item[2] == userInfo.part && 
               item[3] == userInfo.department && 
               item[4] == userInfo.section;
        }
      }).toList();


    // '독강' 데이터를 가장 마지막에 위치하도록 정렬
    filteredData.sort((a, b) {
      if (a[5] == '독강' && b[5] != '독강') {
        return 1;
      } else if (a[5] != '독강' && b[5] == '독강') {
        return -1;
      } else {
        return 0;
      }
    });


    print(filteredData); // 필터링된 데이터 확인용
    return filteredData; 
  } else {
    throw Exception('Failed to load data');
  }
}


//**유저 인포 정의 */
class UserInfo {
  String grade;
  String part;
  String department;
  String section;

  UserInfo({required this.grade, required this.part, required this.department, required this.section});
}


//**수업 정보 정의 */
String date = "2024-03-04";
String startTime = "9:00";
String endTime = "11:00";

DateTime startDateTime = DateTime.parse("$date $startTime");
DateTime endDateTime = DateTime.parse("$date $endTime");


class LectureInfo {
  String department;
  String section;
  String type;
  String semiType;
  String lecture;
  String professor;
  String room;
  DateTime startDateTime;
  DateTime endDateTime;

  LectureInfo({
    required this.department,
    required this.section,
    required this.type,
    required this.semiType,
    required this.lecture,
    required this.professor,
    required this.room,
    required this.startDateTime,
    required this.endDateTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'section': section,
      'type': type,
      'semiType': semiType,
      'lecture': lecture,
      'professor': professor,
      'room': room,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
    };
  }

  factory LectureInfo.fromJson(Map<String, dynamic> json) {
    return LectureInfo(
      department: json['department'] ?? 'Unknown',
      section: json['section'] ?? '--',
      type: json['type'],
      semiType: json['semiType'],
      lecture: json['lecture'],
      professor: json['professor'],
      room: json['room'],
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
    );
  }

}
