# # 007 · Manejo de Errores Robusto — Especificación

_Comportamiento funcional e interfaces visuales de alertas para el usuario ante fallos del sistema._

## Casos de Uso

1. **Intento de Operación sin Conexión:** Si el usuario intenta guardar una sede o asignar un rol estando en modo avión o sin señal, la aplicación mostrará un cartel persistente indicando "Sin conexión a Internet".
2. **Campos con Datos Inválidos:** Si el backend rechaza los datos por validación de negocio (ej: un código de barras duplicado o un formato de correo incorrecto), se resaltarán en rojo los inputs específicos en la pantalla de Flutter.
3. **Fallo Crítico del Servidor (500):** Si hay una caída en MariaDB o en el servidor Node.js, la aplicación mostrará una pantalla o modal de error con el mensaje "Lo sentimos, algo salió mal en nuestros servidores. Inténtalo más tarde".

## Diseño de Pantallas
- **Widgets de Alerta Integrados:**
  - `SnackBar` con fondo rojo para errores rápidos y temporales de red.
  - Vistas de marcador de posición (*Placeholders*) en listas vacías por error para que el usuario pueda presionar un botón de "Reintentar".