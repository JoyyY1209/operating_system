import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
  final List<String> logs;

  const LogsPage({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text("All Logs"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logs[index]),
          );
        },
      ),
    );
  }
}
