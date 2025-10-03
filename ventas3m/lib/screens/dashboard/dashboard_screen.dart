import 'package:flutter/material.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

   @override
   void initState() {
     super.initState();
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: GradientAppBar(
         title: 'Dashboard',
         actions: [
           IconButton(
             icon: const Icon(Icons.settings),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
               );
             },
           ),
         ],
       ),
       body: const SafeArea(
         child: Padding(
           padding: EdgeInsets.all(16.0),
           child: Center(
             child: Text('Dashboard'),
           ),
         ),
       ),
     );
   }
 }