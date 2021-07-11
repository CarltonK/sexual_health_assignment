import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthProvider? _authProvider;
  Future? getUserFuture;

  int _index = 0;
  PageController? _controller;

  final List<Widget> _pages = [
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  final List<IconData> _iconsList = [
    Icons.home,
    Icons.receipt_long,
    Icons.person,
    Icons.access_alarm,
  ];

  _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Container(),
      elevation: 0,
      actions: [
        GlobalCircleButton(
          color: Colors.black,
          icon: Icons.exit_to_app,
          tooltip: 'Exit',
          onPressed: () => dialogExitApp(context, _exitApp),
        ),
      ],
    );
  }

  _bottomBar() {
    return AnimatedBottomNavigationBar(
      icons: _iconsList,
      backgroundColor: Theme.of(context).primaryColor,
      activeColor: Colors.white,
      inactiveColor: Colors.black54,
      activeIndex: _index,
      onTap: _pageSwitcher,
      notchSmoothness: NotchSmoothness.smoothEdge,
      gapLocation: GapLocation.center,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      splashSpeedInMilliseconds: 200,
    );
  }

  _body() {
    return FutureBuilder(
      future: getUserFuture,
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return GlobalLoader();
          case ConnectionState.none:
            return Center(child: GlobalInfoDialog(message: 'There is no user'));
          case ConnectionState.done:
            return Provider<UserModel>(
              create: (context) => snapshot.data,
              child: Consumer<UserModel>(
                builder: (context, value, child) => child!,
                child: PageView.builder(
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _pages[_index];
                  },
                ),
              ),
            );
        }
      },
    );
  }

  _pageSwitcher(int index) {
    setState(() => _index = index);
    _controller!.animateToPage(
      _index,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
    );
  }

  _exitApp() => _authProvider!.signOut();

  _buildPopStack() {
    if (_index != 0) {
      _pageSwitcher(0);
    } else {
      return dialogExitApp(context, _exitApp);
    }
  }

  Future<bool> _onWillPop() {
    return _buildPopStack() ?? false;
  }

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    _authProvider = context.read<AuthProvider>();
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _appBar(),
        backgroundColor: Colors.white,
        body: _body(),
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }
}
