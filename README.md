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

 Plan de Desarrollo Detallado: Loca Pizza Planeta (Flutter + Supabase)
 
Fase 1: Consolidación de la Capa de Datos y Estado (Fundamentos)
Ya tienes la base, solo falta conectar el flujo de datos hacia la UI.

[ X ] 1.1. Completar Modelos Faltantes: Rellenar producto_model.dart (actualmente vacío en tu estructura) con sus propiedades (id, nombre, precio_g, precio_f, es_recomendado, categoria, etc.) y sus métodos fromJson / toJson.

[ X ] 1.2. Configurar Providers (Estado Global): Implementar la lógica en providers/menu_provider.dart para que llame a MenuRepository.obtenerMenu() y guarde la lista de pizzas en memoria. Esto evitará llamar a la base de datos cada vez que cambies de pantalla.

[ X ] 1.3. Provider del Carrito (Mesero): Crear la lógica temporal en pedidos_provider.dart para ir agregando pizzas al carrito, calculando el total dinámicamente y definiendo la lógica de las pizzas "Mitad y Mitad" (usando el producto_2_id de tu modelo).

Fase 2: Experiencia del Mesero (Punto de Venta)
Construir la interfaz fluida para que los meseros trabajen rápido.

[ ] 2.1. Selección de Mesa: En mesero_home_screen.dart, crear un Grid con las mesas del local. Al pulsar una, se abre la vista de toma de pedidos con el número de mesa seleccionado.

[ ] 2.2. Catálogo de Pizzas: En tomar_pedido_screen.dart, consumir el MenuProvider. Usar el widget categoria_chips.dart para filtrar (Especiales, Clásicas) y mostrar el listado usando producto_tile.dart.

[ ] 2.3. Modal de Detalles: Al hacer clic en un producto_tile, abrir un "Bottom Sheet" para elegir el tamaño (Grande o Familiar) y preguntar si es combinada (mitad y mitad).

[ ] 2.4. Resumen y Envío: En resumen_pedido_screen.dart, mostrar el ticket actual. Al darle "Enviar a Cocina", se ejecutará la función crearPedido que ya tienes en tu PedidosRepository.

Fase 3: Pantalla de Cocina (Tiempo Real)
El corazón de la pizzería: que los cocineros vean los pedidos al instante.

[ ] 3.1. Stream de Pedidos: En admin_pedidos_screen.dart, en lugar de un FutureBuilder (que consulta una sola vez), implementaremos el .stream() de Supabase. Esto hará que cuando un mesero envíe un pedido, aparezca mágicamente en la pantalla de la cocina en menos de 1 segundo, sin recargar.

[ ] 3.2. Tarjetas Kanban: Diseñar el pedido_card_desktop.dart para mostrar: Mesa, Lista de Pizzas (detalles) y Hora del pedido.

[ ] 3.3. Transición de Estados: Agregar botones a las tarjetas para que la cocina cambie el estado en un solo clic: Pendiente ➔ En el horno ➔ Lista. Esto actualizará la fila correspondiente en Supabase.

Fase 4: Panel Administrativo (Gestión y Finanzas)
Control del negocio para el dueño/administrador.

[ ] 4.1. CRUD del Menú (admin_menu_screen.dart): Crear la tabla de administración para listar pizzas. Botones para agregar nuevas, editar precios y un Switch para pausarlas (campo disponible = false cuando se quedan sin ingredientes).

[ ] 4.2. Dashboard de Ventas (admin_dashboard_screen.dart): Consultar Supabase filtrando por estado = 'lista' o estado = 'pagado' y fecha, para mostrar:

Ventas del día.

Ventas de la semana.

Pizzas más vendidas usando tu componente stats_tile.dart.

[ ] 4.3. Cierre de Caja (admin_caja_screen.dart): Resumen final para hacer el cuadre del dinero físico vs el sistema.