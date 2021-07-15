import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Future? getTestsFuture;
  UserModel? user;
  OrderModel? order;
  String? uid;

  @override
  void initState() {
    super.initState();

    user = context.read<UserModel>();
    getTestsFuture =
        context.read<DatabaseProvider>().getTests(user!.genitalia!);
  }

  _orderTest(String test) async {
    order = OrderModel(
      owner: user!.uid,
      test: test,
    );

    try {
      await context.read<DatabaseProvider>().createOrder(order!);
      await showInfoDialog(context, 'Order created');
    } catch (e) {
      await showInfoDialog(context, e.toString());
    }
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
          child: FutureBuilder(
            future: getTestsFuture,
            builder: (context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return GlobalLoader();
                case ConnectionState.none:
                  return Center(
                    child: GlobalInfoDialog(message: 'There are no tests'),
                  );
                case ConnectionState.done:
                  List<TestModel> tests = snapshot.data;
                  return ListView.builder(
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            tests[index].name!,
                          ),
                          subtitle: Text(
                            tests[index].info!,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _orderTest(tests[index].testId!),
                          ),
                        ),
                      );
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
