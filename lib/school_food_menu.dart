import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'user_account.dart';


class SchoolFoodMenu extends StatefulWidget {
  const SchoolFoodMenu({super.key});

  @override
  State<SchoolFoodMenu> createState() => SchoolFoodMenuState();
}

class SchoolFoodMenuState extends State<SchoolFoodMenu> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  int _initialIndex = 0;
  late WebViewController _controller1;
  late WebViewController _controller2;
  bool isLoading1 = true;
  bool isLoading2 = true;


  @override
  void initState() {
    super.initState();
    final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    
    if (userInfoProvider.userInfo.grade == '3학년' || userInfoProvider.userInfo.grade == '4학년') {
      setState(() {
        _initialIndex = 1;
      });
    }
    _tabController = TabController(length: 2, vsync: this, initialIndex: _initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
      appBar: AppBar(
        title: const Text('학식'),
        bottom: TabBar(
          controller: _tabController,
            tabs: const <Widget> [
              Tab(text: '인천캠퍼스'),
              Tab(text: '경기캠퍼스'),
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget> [
              tabContent1(),
              tabContent2(),
            ],
          ),
      )
    );
  }


  Widget tabContent1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 13, 8, 8),
          child: Text(
            '이용시간',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/school_food_time.png'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 10, 8, 4),
          child: Text(
            '식단',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 500,
          child: Stack(
            children: <Widget> [
              WebView(
                onWebViewCreated: (WebViewController webViewController) {
                  _controller1 = webViewController;
                },
                onPageFinished: (String url) {
                  setState(() {
                    isLoading1 = false;
                  });
                  _controller1.runJavascript('window.scrollTo(0, 799);');
                },
                //gestureRecognizers: {
                  //Factory<VerticalDragGestureRecognizer>(
                    //() => VerticalDragGestureRecognizer(),
                  //),
                  //Factory<HorizontalDragGestureRecognizer>(
                    //() => HorizontalDragGestureRecognizer(),
                  //),
                //}, 

                initialUrl:'https://www.ginue.ac.kr/kor/CMS/DietMenuMgr/list.do?mCode=MN017&searchDietCategory=2',
                javascriptMode: JavascriptMode.unrestricted,
                    
              ),
            if (isLoading1)
              const Center(child: CircularProgressIndicator())
            ]
          )
        ),
      ]
    );
  }


  Widget tabContent2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 13, 8, 8),
          child: Text(
            '이용시간',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/school_food_time.png'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 10, 8, 4),
          child: Text(
            '식단',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 500,
          child: Stack(
            children: <Widget> [
              WebView(
                onWebViewCreated: (WebViewController webViewController) {
                  _controller2 = webViewController;
                },
                onPageFinished: (String url) {
                  setState(() {
                    isLoading2 = false;
                  });
                  _controller2.runJavascript('window.scrollTo(0, 799);');
                },
                //gestureRecognizers: {
                  //Factory<VerticalDragGestureRecognizer>(
                    //() => VerticalDragGestureRecognizer(),
                  //),
                  //Factory<HorizontalDragGestureRecognizer>(
                    //() => HorizontalDragGestureRecognizer(),
                  //),
                //}, 

                initialUrl:'https://www.ginue.ac.kr/kor/CMS/DietMenuMgr/list.do?mCode=MN017&searchDietCategory=1',
                javascriptMode: JavascriptMode.unrestricted,
                    
              ),
            if (isLoading2)
              const Center(child: CircularProgressIndicator())
            ]
          )
        ),
      ]
    );
  }
}
