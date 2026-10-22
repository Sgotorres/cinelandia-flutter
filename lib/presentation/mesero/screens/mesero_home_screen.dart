// lib/presentation/mesero/screens/mesero_home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/mesero_ajustes_tab.dart';
import '../widgets/mesero_app_bar.dart';
import '../widgets/vista_mesas.dart';
import 'comandas_screen.dart';

class MeseroHomeScreen extends StatefulWidget {
  const MeseroHomeScreen({super.key});

  @override
  State<MeseroHomeScreen> createState() => _MeseroHomeScreenState();
}

class _MeseroHomeScreenState extends State<MeseroHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const MeseroAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          VistaMesas(),
          ComandasScreen(),
          MeseroAjustesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chair_alt), label: 'Mesas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Comandas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Opciones',
          ),
        ],
      ),
    );
  }
}
