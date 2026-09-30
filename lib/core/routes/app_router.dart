// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Importaciones de las pantallas de Auth
import '../../presentation/auth/login_screen.dart';

// Importaciones de las pantallas del Mesero
import '../../presentation/mesero/screens/mesero_home_screen.dart';
import '../../presentation/mesero/screens/tomar_pedido_screen.dart';
import '../../presentation/mesero/screens/resumen_pedido_screen.dart';

// Importaciones de las pantallas del Admin
import '../../presentation/admin/screens/admin_dashboard_screen.dart';

// Importación del AuthProvider
import '../../providers/auth_provider.dart';
import '../../presentation/auth/login_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    // Escuchamos el AuthProvider para reaccionar a cambios (ej. login, logout, expiración)
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/login',
      
      // refreshListenable actúa como middleware: cada vez que el authProvider 
      // notifica un cambio, se reevalúa la lógica de redirección.
      refreshListenable: authProvider,
      
      // Lógica de Redirección y Protección de Rutas
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn; 
        final role = authProvider.userRole; 
        final isLoggingIn = state.matchedLocation == '/login';

        // 1. Si no está autenticado y NO está en la pantalla de login -> enviarlo al login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // 2. Si está autenticado y trata de ir al login -> redirigirlo a su respectivo home
        if (isLoggedIn && isLoggingIn) {
          if (role == 'admin') {
            return '/admin';
          }
          return '/mesero';
        }

        // 3. Protección de rutas por rol: Evitar que un mesero entre a las rutas de admin
        final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
        if (isGoingToAdmin && role != 'admin') {
          return '/mesero';
        }

        // Si pasa todas las validaciones, permitimos que siga su camino
        return null; 
      },
      
      // Árbol de Rutas de la Aplicación
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        GoRoute(
          path: '/mesero',
          builder: (context, state) => const MeseroHomeScreen(),
          routes: [ 
            // SUB-RUTAS DEL MESERO
            // La ruta completa será: /mesero/tomar-pedido
            GoRoute(
              path: 'tomar-pedido', 
              builder: (context, state) => const TomarPedidoScreen(),
            ),
            // La ruta completa será: /mesero/resumen-pedido
            GoRoute(
              path: 'resumen-pedido',
              builder: (context, state) => const ResumenPedidoScreen(),
            ),
          ]
        ),
        
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}