// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/admin/screens/admin_dashboard_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/providers/auth_provider.dart';
import '../../presentation/mesero/providers/pedidos_provider.dart';
import '../../presentation/mesero/screens/mesero_home_screen.dart';
import '../../presentation/mesero/screens/resumen_pedido_screen.dart';
import '../../presentation/mesero/screens/tomar_pedido_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isRoleLoaded = authProvider.isRoleLoaded;
        final role = authProvider.userRole;
        final location = state.matchedLocation;
        final isLoggingIn = location == AppRoutes.login;

        if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
        if (isLoggedIn && !isRoleLoaded) return null;
        if (isLoggedIn && isLoggingIn) {
          return role == 'admin' ? AppRoutes.admin : AppRoutes.mesero;
        }
        if (location.startsWith(AppRoutes.admin) && role != 'admin') {
          return AppRoutes.mesero;
        }
        if (location.startsWith(AppRoutes.mesero) && role == 'admin') {
          return AppRoutes.admin;
        }

        if (location == AppRoutes.tomarPedido ||
            location == AppRoutes.resumenPedido) {
          final mesaId = context.read<PedidosProvider>().mesaIdSeleccionada;
          if (mesaId == null) return AppRoutes.mesero;
        }
        return null;
      },
      routes: [
        GoRoute(
          name: 'login',
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          name: 'mesero',
          path: AppRoutes.mesero,
          builder: (context, state) => const MeseroHomeScreen(),
          routes: [
            GoRoute(
              name: 'tomar-pedido',
              path: 'tomar-pedido',
              builder: (context, state) => const TomarPedidoScreen(),
            ),
            GoRoute(
              name: 'resumen-pedido',
              path: 'resumen-pedido',
              builder: (context, state) => const ResumenPedidoScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'admin',
          path: AppRoutes.admin,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Ruta no encontrada: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
