# Especificaciones Técnicas (Specs) - Colas con Bull y Redis

## 1. Dependencias a Instalar
- `bull` (^4.x o la última versión estable)

## 2. Archivo: `src/services/queueService.js`
Debe exportar:
- `emailQueue`: Instancia de la cola Bull con nombre `'emails'`.
- `addEmailJob(type, payload)`: Función asíncrona que añade una tarea a la cola con 3 intentos de reintento (`attempts: 3`) y un tiempo de espera de retraso exponencial de 5 segundos (`backoff: 5000`).

## 3. Archivo: `src/workers/emailWorker.js`
Debe:
- Inicializar la misma cola `'emails'` apuntando a Redis.
- Procesar el job de tipo `'sendWelcomeEmail'`.
- Extraer `email` y `nombre` desde `job.data`.
- Imprimir logs formateados en consola que indiquen el ID del Job, el inicio del procesamiento, y el éxito final.
- Simular un delay síncrono/asíncrono de 3 segundos (`setTimeout` con Promesa) para emular la latencia de red de un servidor SMTP real.

## 4. Archivo: `src/controllers/usuarioController.js`
Debe:
- Importar `addEmailJob` desde `../services/queueService`.
- Dentro de la función `crearUsuario`, justo después de que la consulta a la base de datos devuelva el usuario creado de forma exitosa, envolver en un bloque `try/catch` seguro la llamada:
  `await addEmailJob('sendWelcomeEmail', { email: created.email, nombre: created.nombre });`
- Asegurar que cualquier error en la cola NO detenga ni tumbe la respuesta HTTP 201 enviada al dispositivo móvil.