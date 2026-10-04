// lib/presentation/admin/screens/admin_menu_screen.dart
import 'package:flutter/material.dart';
import '../widgets/admin_productos_tab.dart';
import '../widgets/admin_mesas_tab.dart';
import '../widgets/admin_usuarios_tab.dart'; // <-- Importamos la nueva pestaña

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // <-- Cambiamos de 2 a 3
      child: Column(
        children: [
          const Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              tabs: [
                Tab(icon: Icon(Icons.fastfood), text: 'Catálogo'),
                Tab(icon: Icon(Icons.table_restaurant), text: 'Mesas'),
                Tab(icon: Icon(Icons.people), text: 'Usuarios'), // <-- Nueva pestaña
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const AdminProductosTab(),
                const AdminMesasTab(),
                const AdminUsuariosTab(), // <-- Renderizamos el nuevo tab
              ],
            ),
          ),
        ],
      ),
    );
  }
}