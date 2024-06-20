import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Background Message Received: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }



class FirebaseApi {
  DateTime now = DateTime.now();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();



  //**알림 권한 요청, 토큰 생성 */
  //background, firebase
  Future<void> initFirebaseNotifications(String userId) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );
    final fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');
    if (fcmToken != null) {
      await saveTokenToDatabase(fcmToken);
    }
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleForegroundMessage(message);
    });
    initTokenRefreshListner(userId);
  }

  void initTokenRefreshListner(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveOrUpdateToken(userId, newToken);
    }).onError((error) {
      print("토큰 갱신 중 오류 발생: $error");
    });
  }


  //foreground
  Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('mipmap/launcher_icon');
    DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }





  //**사용자 ID, 토큰 관리 */
  Future<void> saveTokenToDatabase(String token) async {
    String userId = await getUserId();

    await _firestore.collection('userTokens').doc(userId).set({
      'fcmToken': token,
      'createdAt': FieldValue.serverTimestamp(), // 토큰 저장 시간
    });
  }

  Future<void> saveOrUpdateToken(String userId, String newToken) async {
    await _firestore.collection('userTokens').doc(userId).set({
      'fcmToken': newToken,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  //**userId 설정 */
  String randomUserId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? randomUserId();
  } 

  //**nofiticationId 설정 */
  String getNotificationId(DateTime selectedDay) {
    String notificationId = DateFormat('yyyyMMdd').format(selectedDay);
    return notificationId;
  }





  //**Firestore 알림 추가*/
  Future<void> addScheduledNotification(DateTime selectedDay) async {
    String userId = await getUserId();
    String notificationId = getNotificationId(selectedDay);

    final tzSelectedDay = tz.TZDateTime.from(selectedDay, tz.getLocation('Asia/Seoul'));
    var tzNotificationTime = tz.TZDateTime(tzSelectedDay.location, tzSelectedDay.year, tzSelectedDay.month, tzSelectedDay.day -2, 20, 30);
    Timestamp firebaseNotificationTime = Timestamp.fromMillisecondsSinceEpoch(tzNotificationTime.millisecondsSinceEpoch);

    try {
      await FirebaseFirestore.instance
          .collection('scheduled_notifications')
          .add({
            'userId': userId,
            'notificationId': notificationId,     //notificationId = selectedDay
            'scheduledTime': firebaseNotificationTime,
            'createdAt': FieldValue.serverTimestamp(),
          });

      saveUserId(userId);
      print("알림이 성공적으로 추가되었습니다.");
    } catch (e) {
      print("알림 추가 중 오류 발생: $e");
    }
  }



  //**Firestore 알림 삭제 */
  Future<void> cancelScheduledNotification(DateTime selectedDay) async {
    String userId = await getUserId();
    String notificationId = getNotificationId(selectedDay);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scheduled_notifications')
          .where('userId', isEqualTo: userId)
          .where('notificationId', isEqualTo: notificationId)
          .get();
          
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      print("알림 예약이 취소되었습니다.");
    } catch (e) {
      print("알림 예약 취소 중 오류 발생: $e");
    }
  }





  //**foreground 상태 알림 구현 */
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'id: 셔틀 예약 알림',
      'name: 셔틀 예약 알림',
      priority: Priority.high,
      importance: Importance.max,
    );

    const notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID
      message.notification?.title, // 알림 제목
      message.notification?.body, // 알림 본문
      notificationDetails,
    );
  }



  //Future<void> addLocalNotification(DateTime selectedDay) async {
    //const androidNotificationDetails = AndroidNotificationDetails(
      //'id: 셔틀 예약 알림',
      //'name: 셔틀 에약 알림',
      //priority: Priority.high,
      //importance: Importance.max,
    //);

    //const notificationDetails = NotificationDetails(
        //android: androidNotificationDetails,
        //iOS: DarwinNotificationDetails(badgeNumber: 1));

    // TZDateTime으로 변환
    //final tzSelectedDay = tz.TZDateTime.from(selectedDay, tz.getLocation('Asia/Seoul'));
    // 선택된 날짜에서 이틀 전의 오후 8시 30분 계산
    //var tzNotificationTime = tz.TZDateTime(tzSelectedDay.location, tzSelectedDay.year, tzSelectedDay.month, tzSelectedDay.day -2, 20, 30);

    // 미래 날짜인지 확인
    //if (tzNotificationTime.isAfter(DateTime.now())) {
      //푸시알림 내용
      //await flutterLocalNotificationsPlugin.zonedSchedule(
          //0, '셔틀 신청 알림', '잠깐! 잊지 말고 셔틀 버스를 신청하세요!', tzNotificationTime, notificationDetails,
          //androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          //uiLocalNotificationDateInterpretation:
              //UILocalNotificationDateInterpretation.absoluteTime);

      //print('TZDateTime :');
      //print(tz.TZDateTime.now(tz.local));
      //print(selectedDay);
      //print(tzSelectedDay);
      //print(tzNotificationTime);
      //print('addLocalNotification completed');
    //} else {
      //print('Error: Must be a date in the future');
      //print(tzNotificationTime);
      //print(selectedDay);
      //print(DateTime.now());
    //}
  //}

}