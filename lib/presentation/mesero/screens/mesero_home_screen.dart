// lib/presentation/mesero/screens/mesero_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import '../../../providers/auth_provider.dart'; 
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
      // Pasamos el context como solicitaste
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const VistaMesas(),
          const ComandasScreen(),
          _buildAjustesTab(context),
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

  // --- WIDGET PARA LA PESTAÑA DE OPCIONES ---
  Widget _buildAjustesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Opciones de Cuenta',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.redAccent),
            ),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text(
              'Salir al panel de inicio',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // Llamamos a la función logout del AuthProvider
              context.read<AuthProvider>().logout();
            },
          ),
        ),
      ],
    );
  }

  // --- NUEVO APPBAR INTEGRADO ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // Escuchamos los datos del usuario en tiempo real
    final authProvider = context.watch<AuthProvider>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          // Ícono del local más estilizado
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.local_pizza, color: Colors.orange, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Textos rediseñados
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pizza Planeta',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Mesero: ${authProvider.nombreCompleto}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Indicador de conexión a la derecha
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'En línea',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}