# Configuración del Entorno Móvil y Conexión con Backend - Proyecto EcuStock

Este documento detalla la configuración del entorno de desarrollo multiplataforma, versiones de herramientas utilizadas, arquitectura del proyecto y cómo se logró la comunicación con la API local.

---

## 🛠️ 1. Entorno de Desarrollo y Versiones

- **Framework Multiplataforma:** Flutter (Dart)
- **IDE:** Visual Studio Code (Extensiones: Flutter, Dart, Prettier)
- **Java Development Kit (JDK):** Eclipse Temurin JDK 17 (Ubicación: `D:\JAVA17`)
- **Android SDK:** Compile SDK 35 / Min SDK 21 (Ubicación: `D:\AndroidSDK`)
- **Base de Datos:** MariaDB 11.8
- **Backend:** Node.js (Express)

---

## 📐 2. Justificación Técnica de la Elección

Se seleccionó **Flutter** por las siguientes razones:

1. **Compilación Nativa y Alto Rendimiento:** Utiliza el motor gráfico Skia/Impeller permitiendo interfaces fluidas a 60/120 fps.
2. **Desarrollo Multiplataforma:** Permite compartir una única base de código en Dart para Android e iOS.
3. **Productividad:** La función de _Hot Reload_ permite previsualizar cambios en tiempo real sin recompilar la app completa.

---

## 🔧 3. Pasos de Configuración y Diagnóstico

### Diagnóstico de Flutter

Se verificó el estado del entorno ejecutando el comando de diagnóstico:

```bash
flutter doctor


# ecustock

A new Flutter project.

## Configuración del backend

1. Copia `.env.example` a `.env` y reemplaza las credenciales de ejemplo.
2. Configura un `DB_USER` dedicado a la aplicación y una contraseña segura.
3. Genera `JWT_SECRET` con al menos 32 bytes aleatorios; por ejemplo, ejecuta `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"` y guarda el resultado sólo en `.env`.
4. Ejecuta `node spec/features/010-Paso/run_migration.js` y luego `npm start`.

Las migraciones conservan `precio_costo` como `NULL` para productos antiguos, ya que el valor debe cargarse desde una fuente confiable. La API exige completar ese costo antes de actualizar el producto o registrar movimientos de inventario.

El escáner consulta los productos por código de barras y registra ingresos/egresos mediante `POST /api/v1/productos/:id/movimientos`. El backend bloquea la fila con `SELECT ... FOR UPDATE`, rechaza egresos sin stock con `409` y limita el movimiento a los roles `Administrativo` y `Bodega`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
```
