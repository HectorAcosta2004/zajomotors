import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(title: Text(title), centerTitle: true),

      body: body,

      floatingActionButton: floatingActionButton,
    );
  }
}
