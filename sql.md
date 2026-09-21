# Estructura de la Base de Datos (Cinelandia-Pedidos)

## Tabla: `configuracion_sistema`
| Columna | Tipo | Atributos |
| :--- | :--- | :--- |
| `clave` | varchar | Primary Key (No-Nullable) |
| `valor` | jsonb | No-Nullable |

## Tabla: `pedidos`
| Columna | Tipo | Atributos |
| :--- | :--- | :--- |
| `id` | int4 | Primary Key (No-Nullable) |
| `mesa` | varchar | No-Nullable |
| `total` | numeric | No-Nullable |
| `estado` | varchar | Nullable |
| `fecha` | timestamp | Nullable |

## Tabla: `productos`
| Columna | Tipo | Atributos |
| :--- | :--- | :--- |
| `id` | int4 | Primary Key (No-Nullable) |
| `nombre` | varchar | No-Nullable |
| `descripcion` | text | Nullable |
| `precio` | numeric | No-Nullable |
| `categoria` | varchar | Nullable |
| `es_recomendado` | bool | Nullable |
| `disponible` | bool | Nullable |
| `precio_g` | numeric | Nullable |
| `precio_f` | numeric | Nullable |

## Tabla: `detalles_pedido`
| Columna | Tipo | Atributos | Relación |
| :--- | :--- | :--- | :--- |
| `id` | int4 | Primary Key (No-Nullable) | |
| `pedido_id` | int4 | Nullable | FK -> `pedidos.id` |
| `producto_id` | int4 | Nullable | FK -> `productos.id` |
| `cantidad` | int4 | No-Nullable | |
| `precio_unitario`| numeric | No-Nullable | |
| `talla` | varchar | Nullable | |
| `producto_2_id` | int4 | Nullable | FK -> `productos.id` |

## Tabla: `usuarios`
| Columna | Tipo | Atributos |
| :--- | :--- | :--- |
| `id` | int4 | Primary Key (No-Nullable) |
| `username` | varchar | No-Nullable |
| `password_hash` | text | No-Nullable |
| `rol` | varchar | Nullable |

## Relaciones (Foreign Keys)
* `detalles_pedido.pedido_id` hace referencia a `pedidos.id`
* `detalles_pedido.producto_id` hace referencia a `productos.id`
* `detalles_pedido.producto_2_id` hace referencia a `productos.id`