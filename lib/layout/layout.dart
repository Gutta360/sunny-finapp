import 'package:flutter/material.dart';
import 'package:finapp/appdata/docs_upload.dart';
import 'package:finapp/layout/login.dart';
import 'package:finapp/layout/client.dart';
import 'package:finapp/layout/transaction.dart';
import 'package:finapp/layout/calculator.dart';
import 'package:finapp/main.dart';
import 'package:provider/provider.dart';

class LayoutWidget extends StatefulWidget {
  const LayoutWidget({super.key});

  @override
  _LayoutWidgetState createState() => _LayoutWidgetState();
}

class _LayoutWidgetState extends State<LayoutWidget> {
  @override
  Widget build(BuildContext context) {
    final globalData = Provider.of<GlobalData>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.login),
                text: 'Login',
              ),
              Tab(
                icon: Icon(Icons.account_circle),
                text: 'Clients',
              ),
              Tab(
                icon: Icon(Icons.article_outlined),
                text: 'Transactions',
              ),
              Tab(
                icon: Icon(Icons.calculate),
                text: 'Calculator',
              ),
              Tab(
                icon: Icon(Icons.upload),
                text: 'Data',
              ),
            ],
          ),
          title: const Text(
            'Easy Finance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: TabBarView(
          children: [
            //LoginPage(onLoginSuccess: handleLoginSuccess),
            globalData.isUserLoggedIn
                ? _buildAlreadyLoggedInTab(context, globalData)
                : LoginPage(), // Pass callback
            globalData.isUserLoggedIn ? RegisterForm() : _buildDisabledTab(),
            globalData.isUserLoggedIn ? TxnForm() : _buildDisabledTab(),
            globalData.isUserLoggedIn ? TxnSearchForm() : _buildDisabledTab(),
            globalData.isUserLoggedIn ? UploadWidget() : _buildDisabledTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledTab() {
    return const Center(
      child: Text(
        'Please log in to access this tab.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

Widget _buildAlreadyLoggedInTab(BuildContext context, GlobalData globalData) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'You logged in Successfully!!!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 38),
      ElevatedButton(
        onPressed: () {
          globalData.setIsUserLoggedIn(false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LayoutWidget()),
            (Route<dynamic> route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(120, 40),
          textStyle: const TextStyle(fontSize: 15),
        ),
        child: Text('Logout'),
      ),
    ],
  );
}
