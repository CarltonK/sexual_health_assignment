import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DatabaseProvider? _databaseProvider;
  UserModel? user;
  Duration _duration = Duration(milliseconds: 500);
  TextEditingController? _controller;

  _notificationHandler() async {
    setState(() => _isNotificationEnabled = !_isNotificationEnabled);
    if (!_isNotificationEnabled) {
      await _databaseProvider!.deleteUserToken(user!.uid!);
    } else {
      await _databaseProvider!.updateUserToken(user!.uid!);
    }
  }

  bool _isNotificationEnabled = true;
  bool _isNameVisible = true;
  String? _newName;

  @override
  void initState() {
    super.initState();

    user = context.read<UserModel>();
    _databaseProvider = context.read<DatabaseProvider>();
    _controller = TextEditingController(text: user!.name);
  }

  _nameHandler() {
    setState(() => _isNameVisible = !_isNameVisible);
  }

  _saveName() async {
    if (_newName != null) {
      // Saving the user
      await _databaseProvider!.updateName(user!.uid!, _newName!);
      // TODO: Atm to view changes you have to logout and login back again. The goal is to implement a stream listener
      _nameHandler();
    }
  }

  _buildUserName() {
    return GestureDetector(
      onTap: _nameHandler,
      child: AnimatedSwitcher(
        duration: _duration,
        switchInCurve: Curves.easeInCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: _isNameVisible
            ? Center(
                child: Text(
                  user!.name!,
                  style: Constants.boldHeadlineStyle,
                ),
              )
            : Column(
                children: [
                  TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      _newName = value;
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(10)),
                  GlobalActionButton(
                    action: 'Save',
                    onPressed: _saveName,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenHeight(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalCircleButton(
                icon: _isNotificationEnabled
                    ? Icons.notifications_on
                    : Icons.notifications_off,
                onPressed: _notificationHandler,
                color: Colors.black,
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              _buildUserName(),
            ],
          ),
        ),
      ),
    );
  }
}
