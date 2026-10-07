# Guía de Instalación y Configuración del Proyecto Cinelandia

Esta guía detalla los pasos necesarios para configurar el entorno de desarrollo, instalar las dependencias de Flutter y preparar las herramientas necesarias para compilar la aplicación tanto para Windows (Administrador) como para Android (Mesero).

## 1. Instalación de Visual Studio Community 2022
*Nota: No confundir con Visual Studio Code (el editor de texto). Visual Studio es el IDE de Microsoft que contiene las herramientas de compilación de C++ necesarias para crear aplicaciones de escritorio en Windows.*

**Pasos:**
1. Descarga el instalador desde la página oficial: [Visual Studio Community](https://visualstudio.microsoft.com/es/vs/community/)
2. Ejecuta el instalador.
3. En la pestaña **Cargas de trabajo** (Workloads), marca la opción:
   - `Desarrollo para el escritorio con C++` (Desktop development with C++)
4. En el panel derecho de **Detalles de la instalación**, asegúrate de que estén marcadas las siguientes opciones (puedes desmarcar el resto para ahorrar espacio):
   - Herramientas de compilación de MSVC
   - Herramientas de CMake en C++ para Windows
   - Windows 10 SDK (o Windows 11 SDK)
5. Haz clic en **Instalar**.
6. Una vez finalizado, reinicia tu computadora y ejecuta `flutter doctor` en la terminal para confirmar que fue detectado.

## 2. Instalación de Android Studio (Para la App Móvil)
Para compilar la aplicación de los meseros en dispositivos móviles, necesitarás el Android SDK.

**Pasos:**
1. Descarga [Android Studio](https://developer.android.com/studio).
2. Instálalo con las configuraciones por defecto (esto instalará automáticamente el Android SDK).
3. Abre Android Studio, ve a `SDK Manager` y asegúrate de tener instalada la última versión del SDK.
4. Ejecuta `flutter doctor --android-licenses` en tu terminal y acepta las licencias presionando 'y' repetidamente.

## 3. Dependencias del Proyecto en Flutter
Las siguientes dependencias ya están configuradas en tu archivo `pubspec.yaml`. Para descargarlas e instalarlas en el proyecto, simplemente ejecuta el siguiente comando en la terminal (asegúrate de estar en la carpeta raíz del proyecto):

```bash
flutter pub get
```

### Lista de Dependencias Principales a usar:
- **supabase_flutter:** `^2.17.2` - Para la conexión con la base de datos (Autenticación, Realtime, CRUD).
- **provider:** `^6.1.5+1` - Para la gestión del estado (manejar carritos de compras, roles de usuario, etc.).
- **intl:** `^0.20.3` - Para el formateo de monedas (Bs / USD) y fechas de los pedidos.
- **window_manager:** `^0.5.2` - Para controlar las propiedades de la ventana en la aplicación de escritorio de Windows (como hacerla pantalla completa).
- **flutter_dotenv:** `^6.0.1` - Para cargar variables de entorno seguras (URL y API Key de Supabase).

## 4. Archivo de Variables de Entorno (.env)
Debes mantener un archivo llamado `.env` en la raíz del proyecto (al mismo nivel que `pubspec.yaml`) con el siguiente formato exacto, sin corchetes ni espacios adicionales:

```env
SUPABASE_URL=https://utbqvdbfjymffhzjxdcg.supabase.co
SUPABASE_ANON_KEY=TU_CLAVE_PUBLICA_AQUI

## 5. evitar errores fantasmas

flutter pub add connectivity_plus shared_preferences

pegar en terminal