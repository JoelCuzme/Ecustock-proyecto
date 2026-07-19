# # 004 · Gestión de Organizaciones y Sedes — Tareas

_Checklist de las tareas técnicas para configurar las sedes y puntos de almacenamiento._[cite: 1]

## Tareas

- [ ] **T01 — Diseñar el Modelo de Datos Sede**
  - Crear la clase `SedeModel` en `lib/data/models/sede_model.dart`[cite: 1].
  - Agregar mapeo JSON para los campos: `id_sede`, `id_organizacion`, `nombre`, `direccion`, `codigo_establecimiento`[cite: 1].

- [ ] **T02 — Diseñar la Vista de Lista de Sedes**
  - Crear el archivo `lib/presentation/screens/sedes/sedes_list_screen.dart`[cite: 1].
  - Llamar al endpoint `GET /api/v1/sedes` usando `DioClient`[cite: 1].
  - Mostrar la lista de locales de forma atractiva con sus respectivos códigos de establecimiento[cite: 1].

- [ ] **T03 — Diseñar el Formulario de Registro de Sede**
  - Crear el archivo `lib/presentation/screens/sedes/sede_form_screen.dart`[cite: 1].
  - Añadir validaciones: Nombre obligatorio, código de establecimiento con formato exacto de 3 números (ej. '001') y dirección[cite: 1].
  - Enviar los datos con una solicitud `POST` a `/api/v1/sedes`[cite: 1].