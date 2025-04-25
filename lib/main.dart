import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(const SchoolComputerTrackingApp());

class SchoolComputerTrackingApp extends StatelessWidget {
  const SchoolComputerTrackingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      );
}
