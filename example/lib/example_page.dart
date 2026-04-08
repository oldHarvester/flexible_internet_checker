import 'package:flexible_internet_checker/flexible_internet_checker.dart';
import 'package:flutter/material.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final FlexibleInternetChecker _checker =
      FlexibleInternetChecker.createInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _checker.status,
        builder: (context, snapshot) {
          final status = snapshot.data;
          return Center(
            child: Text(
              status?.name ?? '-',
            ),
          );
        },
      ),
    );
  }
}
