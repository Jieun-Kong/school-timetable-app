import 'package:flutter/material.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => TipScreenState();
}

class TipScreenState extends State<TipScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.white),
              child: const ExpansionTile(
                title: Text('유의사항'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('현재 2~4학년의 수강신청이 마감되었으므로 1학년 시간표만 탑재되어 있습니다. \n\n- 권한 설정: 설정 > 어플리케이션 > 알림 허용\n- 캠퍼스 설정: 삼단메뉴 > 학년 저장\n- 학식 메뉴: 식단표 상단 > 확대 축소 버튼\n- 셔틀 예약: 알림 이후 학사정보 시스템에서 신청 필수'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.white),
              child: const ExpansionTile(
                title: Text('이용방법'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('- 삼단메뉴 > 프로필 탭(보라색) > 학생 정보 기입\n- 기본 배정 강의 외: 편집 버튼 > 각 탭 별로 1개의 강의 선택\n\n학과가 함께 명시된 강의를 다른 학과/반의 강의로 변경할 경우 수강 취소 및 재선택(=독강)의 과정이 필요합니다.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.white),
              child: const ExpansionTile(
                title: Text('추후 업데이트 계획'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('추후 학식 정보(완), 셔틀버스 예약 알림(완), 시간표 플랜B 저장, 각종 예약 링크 모음 등을 순차적으로 업데이트할 계획입니다.\n취미 개발이므로 덜 심심한 만큼 속도가 더뎌질 수 있습니다:)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text(''),
              subtitle: Text('본 앱의 BI는 여기어때 잘난체의 폰트를 포함하고 있습니다. \n\n의견/문의사항: ballwriter@gmail.com'),
            ),
          ],
        ),
      ),
    );
  }
}
