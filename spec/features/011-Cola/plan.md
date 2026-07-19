# Plan de Implementación: Cola de Trabajo y Worker Asíncrono (Ecustock)

## Contexto
Se requiere optimizar el backend del sistema de inventarios y facturación "Ecustock". Específicamente, se necesita delegar la tarea pesada de envío de correos electrónicos de bienvenida tras el registro de un usuario a un proceso en segundo plano (asíncrono) para liberar el hilo principal de ejecución de Node.js.

## Arquitectura de la Solución
1. **Infraestructura**: Utilizaremos la librería `bull` conectada a una instancia local de Redis (`redis://127.0.0.1:6379`).
2. **Servicio de Cola (`src/services/queueService.js`)**: Encargado de inicializar la cola de Bull (`emails`) y exponer una función limpia para añadir trabajos (`addEmailJob`).
3. **Controlador (`src/controllers/usuarioController.js`)**: Se modificará el endpoint de creación de usuario para encolar el trabajo con los datos esenciales (`email` y `nombre`) inmediatamente después de registrar el usuario en la BD, respondiendo un HTTP 201 al cliente sin esperar al envío del email.
4. **Worker Autónomo (`src/workers/emailWorker.js`)**: Un proceso independiente que procesará las tareas `sendWelcomeEmail`, simulando una espera de red de 3 segundos mediante un timer y mostrando logs claros en consola.

## Estrategia de Entrega
- Instalación de dependencias de forma segura.
- Creación de módulos de servicios y workers respetando la arquitectura limpia del proyecto.
- Inyección del Job en el flujo existente del controlador.