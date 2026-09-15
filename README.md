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
            
Fase 1: Programación de Software (Lógica, Modelos y Conexión)
En esta fase nos olvidamos de lo visual y nos concentramos en que los datos fluyan correctamente entre tu base de datos y la aplicación en Flutter.

Lista de tareas:

[ ] Configurar variables de conexión a tu API o base de datos.

[ ] Crear/adaptar la estructura en usuario_model.dart para la autenticación de roles (Admin/Mesero).

[ ] Adaptar producto_model.dart para manejar el menú y las categorías.

[ ] Adaptar pedido_model.dart y pedido_detalle_model.dart para manejar la lógica de las órdenes.

[ ] Programar las peticiones HTTP (GET, POST, PUT, DELETE) en auth_repository.dart, menu_repository.dart y pedidos_repository.dart.

[ ] Configurar la gestión de estado en auth_provider.dart, menu_provider.dart y pedidos_provider.dart.

¿Qué código de la PWA debes subirme para esta fase?

El archivo cinelandia_bd.sql: Para replicar exactamente los campos de las tablas en los modelos de Flutter.

El archivo backend/index.js: Necesito ver las rutas (endpoints) de tu API (ej. /login, /pedidos, /productos) y qué respuestas envían.

Cualquier consulta específica a la base de datos que tengas en backend/db.js.

Fase 2: Desarrollo (Interfaz Visual y Experiencia de Usuario)
Aquí conectaremos la lógica construida en la Fase 1 con las pantallas de Flutter.

Lista de tareas - Módulo Mesero:

[ ] Construir la pantalla principal de mesas/inicio (mesero_home_screen.dart).

[ ] Programar la vista para armar la orden (tomar_pedido_screen.dart), integrando categoria_chips.dart y producto_tile.dart.

[ ] Configurar el carrito y envío de la orden (resumen_pedido_screen.dart y orden_bottom_bar.dart).

Lista de tareas - Módulo Administrador:

[ ] Construir el panel general de métricas (admin_dashboard_screen.dart y stats_tile.dart).

[ ] Programar la recepción y visualización de órdenes activas (admin_pedidos_screen.dart y pedido_card_desktop.dart).

[ ] Crear la interfaz para agregar, editar o eliminar productos (admin_menu_screen.dart).

[ ] Crear la vista de facturación y cuadre (admin_caja_screen.dart).

¿Qué código de la PWA debes subirme para esta fase?

El archivo frontend/app.js: Especialmente las funciones donde manipulabas el DOM para mostrar los productos, calcular totales y enviar el pedido (para traducir esa misma lógica al estado de Flutter).

El archivo frontend/admin.html: Para analizar la estructura visual que tenías (tablas, botones, menús laterales) y replicar ese diseño usando los widgets de Flutter.

El archivo admin-desktop/main.js: Si tenías lógica específica para el administrador separada allí.

Fase 3: Fase Final (Pruebas, Integración y Cierre)
Esta es la etapa para definir claramente el fin del proyecto, asegurar la calidad y prepararlo para producción.

Lista de tareas:

[ ] Prueba de flujo completo: Iniciar sesión como mesero, tomar un pedido complejo, enviarlo, iniciar sesión como admin y verificar que se reciba correctamente.

[ ] Pruebas de responsividad: Asegurar que el panel de mesero sea cómodo para uso táctil en móviles/tablets, y que el panel de admin aproveche el espacio en pantallas de escritorio.

[ ] Manejo de errores: Configurar alertas si el servidor no responde o si se pierde la conexión a internet.

[ ] Limpieza general de código (revisar analysis_options.yaml).

[ ] Compilar las versiones finales (APK para los meseros, ejecutable de Windows o versión Web para la caja del administrador).