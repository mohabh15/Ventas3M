import 'package:flutter/material.dart';
import '../../core/widgets/gradient_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Perfil',
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}