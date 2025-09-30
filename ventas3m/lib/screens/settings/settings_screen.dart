import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Configuración del Sistema',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildSettingsCard(
          context,
          'Perfil',
          Icons.person,
          Colors.purple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          context,
          'Gestión de Usuarios',
          Icons.people,
          Colors.blue,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gestión de Usuarios - Próximamente')),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          context,
          'Gestión de Proyectos',
          Icons.folder,
          Colors.green,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gestión de Proyectos - Próximamente')),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          context,
          'Administración',
          Icons.admin_panel_settings,
          Colors.red,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Administración - Próximamente')),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          context,
          'Configuración de la App',
          Icons.app_settings_alt,
          Colors.orange,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuración de la App - Próximamente')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}