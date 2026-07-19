# # 006 · Asignación de Roles a Usuarios — Especificación

_Definición funcional del flujo de reasignación de privilegios de acceso en EcuStock._

## Casos de Uso

1. **Modificar Rol de un Colaborador:** Un usuario administrador visualiza el perfil de un empleado y cambia su rol operativo de `Bodega` a `Administrativo` (o viceversa) para ajustar sus accesos a la UI móvil.

## Diseño de Pantallas
- **Interfaz de Asignación (Modales o Diálogos):** Al mantener presionado o pulsar sobre un usuario en la lista de personal, emerge un componente interactivo de tipo selector de opciones (*Radio Buttons*) con las opciones 'Administrativo' y 'Bodega', acompañado de los botones 'Cancelar' y 'Confirmar Cambio'.

## Arquitectura de Archivos (Flutter)
- `lib/data/models/asignacion_rol_model.dart` -> Modelo de datos de la petición.
- `lib/presentation/screens/usuarios/asignar_rol_screen.dart` -> Componente o pantalla de actualización de rol.
