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
