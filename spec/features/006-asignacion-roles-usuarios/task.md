# # 006 · Asignación de Roles a Usuarios — Tareas

_Checklist de las tareas técnicas requeridas para completar la asignación de roles._

## Tareas

- [ ] **T01 — Diseñar el Modelo de Asignación de Rol**
  - Crear el archivo `lib/data/models/asignacion_rol_model.dart`.
  - Implementar métodos de mapeo de datos serializables a JSON para enviar al servidor.

- [ ] **T02 — Implementar la Pantalla / Diálogo de Asignación**
  - Crear el archivo `lib/presentation/screens/usuarios/asignar_rol_screen.dart`.
  - Diseñar la interfaz con controles de selección para alternar entre roles operativos ('Administrativo' / 'Bodega').

- [ ] **T03 — Integrar el consumo del Endpoint PATCH**
  - Conectar el botón de confirmación con una petición `PATCH` a `/api/v1/usuarios/{id}/rol` usando `DioClient`.
  - Añadir estados visuales de procesamiento (indicador de carga) y un mensaje emergente (*SnackBar*) que confirme que los permisos del usuario han sido actualizados con éxito.