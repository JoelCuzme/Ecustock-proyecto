# Lista de Tareas para la IA - Implementación de Worker

- [ ] **Fase 1: Preparación del Entorno**
  - [ ] Instalar el paquete de npm `bull`.
  - [ ] Verificar o asumir que la configuración base de Redis utilizará `process.env.REDIS_URL` o el fallback `redis://127.0.0.1:6379`.

- [ ] **Fase 2: Creación del Módulo de Colas**
  - [ ] Crear el archivo `src/services/queueService.js`.
  - [ ] Implementar la inicialización de la cola y la función de encolado `addEmailJob` con opciones de reintento (`attempts: 3`, `backoff: 5000`).

- [ ] **Fase 3: Integración en el Controlador**
  - [ ] Modificar `src/controllers/usuarioController.js`.
  - [ ] Importar la función `addEmailJob`.
  - [ ] Localizar el flujo de éxito del método `crearUsuario` e inyectar el bloque de encolado asíncrono protegiéndolo con un `try/catch` interno para logs de fallos de cola.

- [ ] **Fase 4: Desarrollo del Worker**
  - [ ] Crear el directorio `src/workers/` si no existe.
  - [ ] Crear el archivo `src/workers/emailWorker.js`.
  - [ ] Desarrollar el consumidor `.process` para `'sendWelcomeEmail'` con la simulación de retraso de 3 segundos y logs detallados en la terminal.

- [ ] **Fase 5: Verificación de Estructura**
  - [ ] Asegurarse de que el proyecto compila correctamente sin errores de sintaxis y que no se rompieron otras rutas del backend.
