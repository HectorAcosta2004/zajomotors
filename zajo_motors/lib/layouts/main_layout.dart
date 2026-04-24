import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const MainLayout({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(title: Text(title), centerTitle: true),

      body: body,
    );
  }
}
