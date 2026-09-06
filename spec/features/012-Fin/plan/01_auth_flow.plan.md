# Plan: Arquitectura de Autenticación, Estado y Rutas

## 1. Organización del Código (`lib/`)
```text
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart       # Instancia Dio e interceptores
│   │   └── auth_interceptor.dart # Manejo de cabeceras Bearer y 401
│   ├── router/
│   │   └── app_router.dart       # Configuración go_router y redirección de guardia
│   └── storage/
│       └── secure_storage.dart   # Persistencia local (flutter_secure_storage / shared_preferences)
├── features/
│   └── auth/
│       ├── data/
│       │   ├── models/user_model.dart
│       │   └── repositories/auth_repository.dart
│       ├── presentation/
│       │   ├── bloc/
│       │   │   ├── auth_bloc.dart
│       │   │   ├── auth_event.dart
│       │   │   └── auth_state.dart
│       │   └── pages/
│       │       └── login_page.dart
│   └── home/
│       └── presentation/pages/home_page.dart # Pantalla inicial según rol