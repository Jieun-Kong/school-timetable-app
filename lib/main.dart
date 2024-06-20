//**main.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'api_data.dart';
import 'bottom_sheet.dart';
import 'user_account.dart';
import 'time_table_widget.dart';
import 'tip_screen.dart';
import 'school_food_menu.dart';
import 'shuttle_bus.dart';
import 'firebase_api.dart';
//import 'firebase_options.dart';



//final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
   //FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseApi firebaseApi = FirebaseApi();
    final userId = await firebaseApi.getUserId();
    await FirebaseApi().initFirebaseNotifications(userId);
  await FirebaseApi().initLocalNotifications();

  //시간대 변환
  tz.initializeTimeZones();
  var seoul = tz.getLocation('Asia/Seoul');
  tz.setLocalLocation(seoul);
  initializeDateFormatting('ko_KR', null);


  //**알림 권한 요청 */
  //flutterLocalNotificationsPlugin
    //.resolvePlatformSpecificImplementation<
        //AndroidFlutterLocalNotificationsPlugin>()
    //?.requestNotificationsPermission();
  

  return runApp(
    MultiProvider(providers: [
      Provider<MeetingDataSource>(create: (_) => MeetingDataSource([])),
      ChangeNotifierProvider(create: (context) => UserInfoProvider()),
      ChangeNotifierProvider(create: (context) => LectureInfoProvider()),
      ChangeNotifierProvider(create: (context) => DataSourceProvider()),
    ],
    child: Builder(builder: (context) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          ),
          home: const MyApp()),
      );
    }),
    ),
  );
}

class LectureInfoProvider with ChangeNotifier {
  List<LectureInfo> _lectureInfos = [];

  List<LectureInfo> get lectureInfos => _lectureInfos;

  void updateLectureInfos(List<LectureInfo> newLectureInfos) {
    _lectureInfos = newLectureInfos;
    notifyListeners();
  }
}

class DataSourceProvider with ChangeNotifier {
  final MeetingDataSource _dataSource = MeetingDataSource([]);

  MeetingDataSource get dataSource => _dataSource;

  void addLecture(LectureInfo lecture) {
    _dataSource.addLecture(lecture);
    notifyListeners();
  }
}




//**앱 시작 */
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => MyAppState();
}



class MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2024년 1학기', style: TextStyle(fontSize: 21)),),
      drawer: SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget> [
                  InkWell(
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: ((context) => const UserAccountSettingsScreen())));},
                    child: Consumer<UserInfoProvider>(
                      builder: (context, userInfoProvider, child) {
                        return UserAccountsDrawerHeader(
                          accountName: Text("${userInfoProvider.userInfo.department}  ${userInfoProvider.userInfo.section}"),
                          accountEmail: Text(userInfoProvider.userInfo.grade),
                          //currentAccountPicture: const CircleAvatar(),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('시간표'),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const MyApp()));},
                    ),
                  ListTile(
                    leading: const Icon(Icons.food_bank),
                    title: const Text('학식'),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const SchoolFoodMenu()));},
                  ),
                  ListTile(
                    leading: const Icon(Icons.bus_alert),
                    title: const Text('셔틀'),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ShuttleBus()));},
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            ListTile(
              leading: const Icon(Icons.notification_important),
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const TipScreen()));},
            ),
          ],
        ),
      )),
      body: const TimeTableWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          UserInfo userInfo = Provider.of<UserInfoProvider>(context, listen: false).userInfo;
          List<dynamic> rawData = await fetchSheetData(userInfo);

          List<LectureInfo> lectureInfos = rawData.map<LectureInfo>((item) {
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


          //List<LectureInfo> lectureInfos = [];
          MeetingDataSource dataSource = MeetingDataSource([]);
          showMyBottomSheet(context, lectureInfos, dataSource);
        },
        tooltip: '과목 추가',
        child: const Icon(Icons.edit),
      ),
    );
  }





  //**로컬 데이터 저장 */
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    final dataSource = Provider.of<MeetingDataSource>(context, listen: false);
    dataSource.loadAppointments();
  }

  //유저 인포 저장
  void _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String grade = prefs.getString('grade') ?? 'Grade';
    final String part = prefs.getString('part') ?? 'Part';
    final String department = prefs.getString('department') ?? 'Department';
    final String section = prefs.getString('section') ?? 'Section';
    // UserInfoProvider에 로드한 정보를 업데이트합니다.
    final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    userInfoProvider.updateUserInfo(grade, part, department, section, context);
  }
}
