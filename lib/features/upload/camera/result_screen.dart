import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final String text;
  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("result"),
      backgroundColor: AppTheme.appBarBackgroundColor,
    ),
    body: Container(padding: const EdgeInsets.all(30.0),child: Text(text)),
  );
}
