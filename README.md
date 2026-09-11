# cinelandia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

lib/
│
├── main.dart                      # Inicialización de Supabase, window_manager y runApp
│
├── core/                          # Utilidades transversales a toda la app
│   ├── constants/
│   │   ├── supabase_constants.dart # URL y Anon Key de Supabase
│   │   └── app_colors.dart        # Paleta de colores (rojo/amarillo pizzería)
│   ├── theme/
│   │   └── app_theme.dart         # Temas claros/oscuros globales
│   └── utils/
│       ├── formatters.dart        # Formato de precios (Bs / USD) y horas
│       └── responsive.dart        # Helper para detectar si es PC o Móvil
│
├── data/                          # Modelos y acceso a Supabase
│   ├── models/
│   │   ├── pedido_model.dart      # id, mesa, mesero, total, estado, created_at
│   │   ├── pedido_detalle_model.dart # id_pedido, id_producto, cantidad, precio, notas
│   │   ├── producto_model.dart    # id, nombre, categoria, precio (sin imagen)
│   │   └── usuario_model.dart     # id, nombre, rol (admin / mesero)
│   └── repositories/
│       ├── auth_repository.dart   # Login de admin y meseros
│       ├── pedidos_repository.dart# Crear pedidos, cambiar estados, stream realtime
│       └── menu_repository.dart   # Obtener lista de pizzas/bebidas para el mesero
│
├── providers/                     # Controladores de estado
│   ├── auth_provider.dart         # Sesión activa y verificación de rol
│   ├── pedidos_provider.dart      # Escucha en tiempo real los pedidos (Realtime)
│   └── menu_provider.dart         # Carga y filtrado de productos por categoría
│
└── presentation/                  # Pantallas y componentes visuales
    │
    ├── auth/                      # Pantalla de acceso
    │   └── login_screen.dart      # Login simple (usuario/contraseña o PIN de mesero)
    │
    ├── admin/                     # EXCLUSIVO PANEL PC (Windows)
    │   ├── screens/
    │   │   ├── admin_dashboard_screen.dart # Pantalla principal con layout de escritorio
    │   │   ├── admin_pedidos_screen.dart   # Tablero tipo Kanban o lista de comandas
    │   │   ├── admin_menu_screen.dart      # CRUD rápido de productos y precios
    │   │   └── admin_caja_screen.dart      # Cierre de caja y ventas del día
    │   └── widgets/
    │       ├── pedido_card_desktop.dart    # Tarjeta de orden con acciones (Entregar/Cobrar)
    │       └── stats_tile.dart             # Métricas de ventas rápidas
    │
    └── mesero/                    # EXCLUSIVO PANEL MÓVIL (Android)
        ├── screens/
        │   ├── mesero_home_screen.dart     # Selección de mesa y pedidos activos
        │   ├── tomar_pedido_screen.dart    # Catálogo táctil simple para añadir ítems
        │   └── resumen_pedido_screen.dart  # Confirmación de la comanda antes de enviar
        └── widgets/
            ├── categoria_chips.dart        # Filtros rápidos (Pizzas, Bebidas, Extras)
            ├── producto_tile.dart          # Ítem táctil con botones (+) y (-)
            └── orden_bottom_bar.dart       # Barra inferior con total y botón "Enviar a Cocina"
