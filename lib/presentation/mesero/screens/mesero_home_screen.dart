// lib/presentation/mesero/screens/mesero_home_screen.dart
import 'package:flutter/material.dart';
import 'comandas_screen.dart';
import '../widgets/vista_mesas.dart';

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
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          VistaMesas(), // Componente refactorizado que maneja sus propios streams
          ComandasScreen(),
          Center(
            child: Text(
              'Ajustes (En construcción)', 
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chair_alt), label: 'Mesas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Comandas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.indigo, 
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Sala Principal', 
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Pizza Planeta', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Activo', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black54), onPressed: () {}),
      ],
    );
  }
}