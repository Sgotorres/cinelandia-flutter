// lib/presentation/admin/screens/admin_menu_screen.dart
import 'package:flutter/material.dart';

import '../widgets/admin_productos_tab.dart';
import '../widgets/admin_mesas_tab.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              tabs: [
                Tab(icon: Icon(Icons.fastfood), text: 'Catálogo de Menú'),
                Tab(
                  icon: Icon(Icons.table_restaurant),
                  text: 'Gestión de Mesas',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AdminProductosTab(), // Llama al widget de Productos
                AdminMesasTab(), // Llama al widget de Mesas
              ],
            ),
          ),
        ],
      ),
    );
  }
}
