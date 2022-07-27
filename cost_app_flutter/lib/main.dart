import 'dart:io';

import 'package:cost_app_flutter/widgets/new_transaction.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

import './widgets/transaction_list.dart';
import './models/transaction.dart';
import './widgets/chart.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();   Linika potrzebna, na mniejszych urządzeniach może się coś zjebać

  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,            Ograniczenie w rotacji telefonem!  aplikacje za działa jedynie jak telefon będzie prosto
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E-Wallet",
      home: MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.purple,
        primarySwatch: Colors.purple,
        buttonColor: Colors.white,
        accentColor: Colors.amber,
        fontFamily: 'OpenSans',
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //String titleInput;

  final List<Transaction> _userTransaction = [
    // Transaction(
    //   id: "t1",
    //   title: "Shoes",
    //   amount: 20,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: "t2",
    //   title: "Jeans",
    //   amount: 40,
    //   date: DateTime.now(),
    // )
  ];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransaction.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime datechoosen) {
    final NewTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: datechoosen,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransaction.add(NewTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((tx) {
        return tx.id == id;
      });
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (bCtx) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(_addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS ? CupertinoNavigationBar(
      middle:Text('Personal Expenses'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        GestureDetector(
          onTap: () =>_startAddNewTransaction(context),
          child: Icon(CupertinoIcons.add), 
          ),
      ],
      ),
    ) :AppBar(
      title: Text("E-Wallet"),
      actions: [
        IconButton(
            onPressed: () => _startAddNewTransaction(context),
            icon: Icon(Icons.add))
      ],
    );

    final txListWidget = Container(
      child: TransactionList(_userTransaction, _deleteTransaction),
      height: (MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).padding.top) *
          0.7,
    );
    final mediaQuery = MediaQuery.of(context);
    final pageBody = SafeArea(child:  SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (isLandscape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Show Chart'),
                Switch(
                  value: _showChart,
                  onChanged: (val) {
                    setState(() {
                      _showChart = val;
                    });
                  },
                ),
              ],
            ),
          if (!isLandscape)
            Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.3,
              child: Chart(_recentTransactions),
            ),
          if (!isLandscape) txListWidget,
          if (isLandscape)
            _showChart
                ? Container(
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.7,
                    child: Chart(_recentTransactions),
                  )
                : txListWidget
        ],
      ),),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(child: pageBody, navigationBar:,)
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}
