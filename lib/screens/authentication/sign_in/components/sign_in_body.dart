import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/screens/screens.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class SignInBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignInBody({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => KeyboardUtil.hideKeyboard(context),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: DeviceConfig.screenHeight! * 0.04),
                  Text('Welcome Back'),
                  SizedBox(height: DeviceConfig.screenHeight! * 0.005),
                  Text(
                    'Sign in with your email and password',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DeviceConfig.screenHeight! * 0.08),
                  SignInForm(scaffoldKey: scaffoldKey),
                  SizedBox(height: DeviceConfig.screenHeight! * 0.08),
                  GlobalMultiInfoActionButton(
                    primaryText: 'Don\'t have an account ?',
                    secondaryText: 'Sign Up',
                    onTap: () => Navigator.of(context).push(
                      SlideLeftTransition(
                        page: SignUpScreen(),
                        routeName: 'sign_up_screen',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
