// lib/presentation/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import 'admin_pedidos_screen.dart'; // Importamos la nueva pantalla

import 'admin_caja_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const AdminPedidosScreen(), // 1. Monitor de Comandas (El que acabamos de crear)
          const AdminCajaScreen(), // 2. Panel de Caja (AQUÍ PONEMOS LA NUEVA PANTALLA)
          const Center(
            child: Text('Caja en construcción...'),
          ), // 2. Próximo apartado
          const Center(
            child: Text('Menú y Mesas en construcción...'),
          ), // 3. Próximo apartado
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.monitor), label: 'Cocina'),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Caja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Gestión',
          ),
        ],
      ),
    );
  }
}
