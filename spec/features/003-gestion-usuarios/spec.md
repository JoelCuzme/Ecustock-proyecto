# # 003 · Gestión de Usuarios — Especificación

_Definición funcional y técnica de la administración de personal dentro de EcuStock._[cite: 1]

## Casos de Uso

1. **Crear Colaborador:** Un administrador registra un nuevo usuario en el sistema ingresando su nombre, correo, contraseña y seleccionando un rol específico[cite: 1].
2. **Consultar Lista de Personal:** Permite ver qué colaboradores están registrados y cuál es su respectivo nivel de acceso (rol)[cite: 1].

## Diseño de Pantallas
- **Pantalla de Lista:** Lista de tarjetas (*Cards*) con el nombre, correo y una etiqueta visual (*Badge*) de color que distinga el rol (`Administrativo` = Verde, `Bodega` = Azul)[cite: 1].
- **Pantalla de Registro:** Inputs de texto validados para nombre, correo, contraseña, y un componente desplegable (*Dropdown*) para seleccionar estrictamente el rol[cite: 1].

## Arquitectura de Archivos (Flutter)
- `lib/data/models/usuario_model.dart` -> Modelo de datos del usuario[cite: 1].
- `lib/presentation/screens/usuarios/usuarios_list_screen.dart` -> Vista de visualización de personal[cite: 1].
- `lib/presentation/screens/usuarios/usuario_form_screen.dart` -> Formulario de creación de cuentas[cite: 1].