const { emailQueue } = require('../services/queueService');

// Procesar jobs de envío de emails de bienvenida
emailQueue.process('sendWelcomeEmail', async (job) => {
  const { email, nombre } = job.data;
  
  console.log(`\n📧 [Job #${job.id}] Iniciando envío de email de bienvenida...`);
  console.log(`   👤 Destinatario: ${nombre} (${email})`);
  
  try {
    // Simular la latencia de red (3 segundos)
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, 3000);
    });
    
    console.log(`✅ [Job #${job.id}] Email de bienvenida enviado exitosamente a ${email}`);
    return { success: true, email, nombre };
  } catch (error) {
    console.error(`❌ [Job #${job.id}] Error al enviar email: ${error.message}`);
    throw error;
  }
});

// Manejo de eventos de la cola
emailQueue.on('error', (error) => {
  console.error(`🔴 Error en la cola de emails: ${error.message}`);
});

emailQueue.on('completed', (job) => {
  console.log(`✨ [Job #${job.id}] Completado satisfactoriamente\n`);
});

emailQueue.on('failed', (job, error) => {
  console.error(`💥 [Job #${job.id}] Falló después de ${job.attemptsMade} intento(s): ${error.message}\n`);
});

console.log('🚀 Worker de emails iniciado y escuchando...');
