import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future? getRecentOrders;
  UserModel? user;

  _statusBuilder() {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user!.isSick!) ...[
              Icon(Icons.sentiment_dissatisfied, size: 150, color: Colors.red),
              Text('You\'re currently sick'),
              const SizedBox(height: 10),
              Text('You have ${user!.isSickWith}'),
              const SizedBox(height: 10),
              Text(
                'You have to remain sexually quarantined until ${user!.sickUntil!.toDate()}',
              ),
              const SizedBox(height: 10),
            ] else ...[
              Icon(Icons.sentiment_satisfied, size: 150),
              Text('You\'re currently healthy'),
            ]
          ],
        ),
      ),
    );
  }

  Widget _recentOrdersBuilder() {
    return Expanded(
        child: Container(
      child: FutureBuilder(
        future: getRecentOrders,
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
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Order Number: ${orders[index].orderId!}',
                      ),
                      subtitle: Text(
                          'Ordered At: ${orders[index].orderedAt!.toDate()}'),
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
  void initState() {
    super.initState();

    user = context.read<UserModel>();
    getRecentOrders =
        context.read<DatabaseProvider>().getRecentOrders(user!.uid!);
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
            children: [
              Text(
                'Current Status',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              _statusBuilder(),
              Text(
                'Recent Orders',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              _recentOrdersBuilder(),
            ],
          ),
        ),
      ),
    );
  }
}
