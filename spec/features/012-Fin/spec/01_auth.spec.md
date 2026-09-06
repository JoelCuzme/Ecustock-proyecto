# Spec: Autenticación y Control de Sesión - EcuStock

## 1. Requerimientos Funcionales
- **Endpoint consumido:** `POST /api/v1/auth/login`[cite: 1].
- **Credenciales:** Correo electrónico (`correo`) y contraseña (`password`)[cite: 1].
- **Carga Útil JWT esperada en respuesta:**
  - `sub`: Identificador único (`id_usuario`)[cite: 1].
  - `name`: Nombre del usuario[cite: 1].
  - `role`: Rol asignado (`Ventas` o `Bodega`)[cite: 1].
  - `exp`: Timestamp de expiración[cite: 1].
- **Políticas de Registro:** No contempla autorregistro. Sistema corporativo cerrado; acceso restringido por roles asignados administrativamente[cite: 1].

## 2. Validaciones del Formulario (Front-end Flutter)
- **Correo:** Obligatorio, no vacío, formato regex válido (`^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`).
- **Contraseña:** Obligatoria, mínimo 6 caracteres.
- **Feedback visual:** Mensajes de error bajo el `TextFormField` y SnackBar en fallos de autenticación (401/500).

## 3. Comportamiento de Navegación y Respuestas HTTP
- **HTTP 200/201:** Almacena tokens/sesión y redirige al dashboard según el rol[cite: 1].
- **HTTP 401 Unauthorized:** Muestra mensaje descriptivo ("Credenciales inválidas o sesión expirada")[cite: 1].
- **Cierre de sesión (Logout):** Purga tokens y datos del usuario de la memoria/almacenamiento local y fuerza redirección a `/login`[cite: 1].
- **Protección de rutas:** Si no hay token válido, cualquier intento de acceder a rutas protegidas (`/productos`, `/facturacion`, `/movimientos`) redirige automáticamente a `/login`[cite: 1].