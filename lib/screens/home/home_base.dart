import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/helpers/helpers.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/screens/screens.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthProvider? _authProvider;
  Future? getUserFuture;
  Stream? getUserStream;

  int _index = 0;
  PageController? _controller;

  // ignore: unused_field
  NotificationHelper? _notificationHelper;

  final List<Widget> _pages = [
    MainScreen(),
    TestScreen(),
    ProfileScreen(),
  ];

  final List<IconData> _iconsList = [
    Icons.home,
    Icons.check,
    Icons.person,
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
      gapLocation: GapLocation.end,
      leftCornerRadius: 32,
      rightCornerRadius: 0,
      splashSpeedInMilliseconds: 200,
    );
  }

  // _bodyStream() {
  //   return StreamBuilder(
  //     stream: getUserStream,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Center(child: GlobalInfoDialog(message: '${snapshot.error}'));
  //       } else if (snapshot.connectionState == ConnectionState.waiting) {
  //         return GlobalLoader();
  //       }
  //       return Provider<UserModel>(
  //         create: (context) => snapshot.data as UserModel,
  //         child: Consumer<UserModel>(
  //           builder: (context, value, child) => child!,
  //           child: PageView.builder(
  //             controller: _controller,
  //             physics: NeverScrollableScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               return _pages[_index];
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  _body() {
    // Cost Optimization - Fetch the user once globally to avoid fetching on demand
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

  void popDialog() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    // Page View Controller
    _controller = PageController();

    // Messaging Handler
    _notificationHelper = NotificationHelper();
    _notificationHelper!.onForegroundMessage(context);

    // Globally retrieve auth
    _authProvider = context.read<AuthProvider>();
    // Globally retrieve user future
    getUserFuture =
        context.read<DatabaseProvider>().getUser(_authProvider!.user.uid);
    getUserStream =
        context.read<DatabaseProvider>().streamUser(_authProvider!.user.uid);
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  _navigateToOrders() => Navigator.of(context).push(
        SlideLeftTransition(page: OrderScreen(), routeName: 'orders'),
      );

  @override
  Widget build(BuildContext context) {
    // Handle on back button pressed
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _appBar(),
        backgroundColor: Colors.white,
        body: _body(),
        bottomNavigationBar: _bottomBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _navigateToOrders,
        ),
      ),
    );
  }
}
