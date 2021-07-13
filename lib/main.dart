import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sexual_health_assignment/helpers/helpers.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/screens/screens.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

import 'utilities/utilities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final List<SingleChildWidget> _providers = [
    ChangeNotifierProvider(create: (context) => AuthProvider.instance()),
    Provider(create: (context) => DatabaseProvider())
  ];

  runApp(
    MultiProvider(
      providers: _providers,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Initialize firebase outside build to avoid future builder triggers
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Troglo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<FirebaseApp>(
        future: _initialization,
        builder: (context, snapshot) {
          DeviceConfig().init(context);
          if (snapshot.hasError) {
            return GlobalErrorContained(
              errorMessage: '${snapshot.error.toString()}',
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // Listen for background notifications when FirebaseApp is created
            NotificationHelper _helper = NotificationHelper();
            _helper.onBackgroundMessage();

            return Consumer<AuthProvider>(
              builder: (context, value, child) {
                if (value.status == Status.Authenticated) return HomePage();
                if (value.status == Status.Authenticating)
                  return GlobalLoader();
                return child!;
              },
              child: SignInScreen(),
            );
          }
          return GlobalLoader();
        },
      ),
    );
  }
}
