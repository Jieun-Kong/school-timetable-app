const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * 스케줄링된 알림을 보내는 함수입니다.
 */
exports.sendScheduledNotifications = functions.pubsub.schedule("30 20 * * *")
    .timeZone("Asia/Seoul")
    .onRun(async () => {
      const startOfDay = new Date();
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date();
      endOfDay.setHours(23, 59, 59, 999);

      const startTimestamp = admin.firestore.Timestamp.fromDate(startOfDay);
      const endTimestamp = admin.firestore.Timestamp.fromDate(endOfDay);

      const notificationsSnapshot = await admin.firestore()
          .collection("scheduled_notifications")
          .where("scheduledTime", ">=", startTimestamp)
          .where("scheduledTime", "<=", endTimestamp)
          .get();

      console.log(
          // eslint-disable-next-line new-cap
          `현재 시간대: ${Intl.DateTimeFormat().resolvedOptions().timeZone}`);
      console.log(
          `startTimestamp: ${startTimestamp.toDate().toISOString()}, 
        endTimestamp: ${endTimestamp.toDate().toISOString()}`);
      console.log(
          `Firestore 쿼리 조건: scheduledTime >= ${startTimestamp}, 
        scheduledTime <= ${endTimestamp}`);
      notificationsSnapshot.forEach((doc) => {
        console.log(`문서 ID: ${doc.id}, 
        scheduledTime: ${doc.data().scheduledTime.toDate().toISOString()}`);
      });
      if (notificationsSnapshot.empty) {
        console.log("오늘 발송할 예정된 알림이 없습니다.");
      } else {
        console.log(`전달된 문서 수: ${notificationsSnapshot.size}`);
      }

      // 각 userId에 대해 알림 보내기
      const promises = [];
      notificationsSnapshot.docs.forEach((doc) => {
        const {userId} = doc.data(); // userId를 통해 FCM 토큰을 조회합니다.

        // Firestore에서 사용자의 FCM 토큰을 조회하는 함수
        const fetchUserToken = async (userId) => {
          const userTokenRef =
            admin.firestore().collection("userTokens").doc(userId);
          const userTokenDoc = await userTokenRef.get();
          if (!userTokenDoc.exists) {
            console.log("해당 사용자를 찾을 수 없습니다.");
            return null;
          }
          return userTokenDoc.data().fcmToken; // 사용자의 FCM 토큰 반환
        };

        promises.push((async () => {
          const token = await fetchUserToken(userId);
          if (token) {
            const message = {
              notification: {
                body: "지금 바로 셔틀버스를 신청하세요!",
              },
              token: token,
            };
            return admin.messaging().send(message);
          } else {
            console.log(`유효한 FCM 토큰이 없는 사용자: ${userId}`);
          }
        })());
      });

      // 작업 완료
      try {
        await Promise.all(promises);
        console.log("모든 알림을 성공적으로 보냈습니다.");
      } catch (error) {
        console.error(`알림을 보내는데 실패했습니다: ${error}`);
      }

      return null;
    });
