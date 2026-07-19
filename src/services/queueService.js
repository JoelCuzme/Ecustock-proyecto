const Queue = require('bull');

const REDIS_URL = 'redis://default:gQAAAAAAAtNvAAIgcDE2NGJmZDcyMmY0ZTY0OTY0OWQxMmRhZmU0MDJlY2RmYg==@climbing-kangaroo-185199.upstash.io:6379';

// Inicializar la cola de emails CON configuración segura TLS para Upstash
const emailQueue = new Queue('emails', REDIS_URL, {
  redis: {
    tls: {
      rejectUnauthorized: false // Requerido para conexiones cifradas a Upstash
    },
    maxRetriesPerRequest: null,   // Evita que la conexión se rinda y lance ECONNRESET
    enableReadyCheck: false       // Optimiza la respuesta en instancias serverless/cloud
  }
});

// Función para añadir un trabajo a la cola
async function addEmailJob(type, payload) {
  try {
    const job = await emailQueue.add(type, payload, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 5000
      }
    });
    console.log(`✓ Job encolado con ID: ${job.id}, Tipo: ${type}`);
    return job;
  } catch (error) {
    console.error(`✗ Error al encolar el job: ${error.message}`);
    throw error;
  }
}

module.exports = {
  emailQueue,
  addEmailJob
};