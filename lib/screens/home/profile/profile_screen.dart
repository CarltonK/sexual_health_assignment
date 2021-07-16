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
  TextEditingController? _controllerName;
  Future? getPastOrders;

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
  String? _newName, _notes;

  @override
  void initState() {
    super.initState();

    user = context.read<UserModel>();
    _databaseProvider = context.read<DatabaseProvider>();
    _controllerName = TextEditingController(text: user!.name);
    getPastOrders = context.read<DatabaseProvider>().getAllOrders(user!.uid!);
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

  _saveNotes(orderId) async {
    if (_notes != null) {
      // Saving the user
      await _databaseProvider!.updateOrderNotes(orderId, _notes!);
      // TODO: Atm to view changes you have to logout and login back again. The goal is to implement a stream listener
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
                    controller: _controllerName,
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

  _addNotes(String orderId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          onChanged: (value) => _notes = value,
        ),
        actions: [
          IconButton(
            onPressed: () => _saveNotes(orderId),
            icon: Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  _deleteOrder(String orderId) async {
    try {
      await _databaseProvider!.deleteOrder(orderId);
      await showInfoDialog(context, 'Order deleted');
    } catch (e) {
      await showInfoDialog(context, e.toString());
    }
  }

  Widget _pastOrdersBuilder() {
    return Expanded(
        child: Container(
      child: FutureBuilder(
        future: getPastOrders,
        builder: (context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              return GlobalLoader();
            case ConnectionState.none:
              return Center(
                child: GlobalInfoDialog(message: 'There are past orders'),
              );
            case ConnectionState.done:
              List<OrderModel> orders = snapshot.data;
              if (orders.length == 0) {
                return GlobalInfoDialog(message: 'There are no past orders');
              }
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Order Number: ${orders[index].orderId!}',
                      ),
                      isThreeLine: true,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ordered At: ${orders[index].orderedAt!.toDate()}',
                          ),
                          if (orders[index].result != null) ...[
                            SizedBox(height: getProportionateScreenHeight(10)),
                            Text(
                              'Result: ${orders[index].result}',
                            ),
                            Text(
                              'Released At: ${orders[index].resultReleasedAt!.toDate()}',
                            ),
                          ],
                          if (orders[index].notes != null) ...[
                            SizedBox(height: getProportionateScreenHeight(10)),
                            Text(
                              'Notes: ${orders[index].notes}',
                            ),
                          ]
                        ],
                      ),
                      leading: IconButton(
                        onPressed: () => _addNotes(orders[index].orderId!),
                        icon: Icon(Icons.edit),
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteOrder(orders[index].orderId!),
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    ));
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
              SizedBox(height: getProportionateScreenHeight(20)),
              Text(
                'My Tests',
                style: Constants.boldHeadlineStyle,
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              _pastOrdersBuilder(),
            ],
          ),
        ),
      ),
    );
  }
}
