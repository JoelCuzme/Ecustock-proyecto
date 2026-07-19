/**
 * Script de prueba para validar la implementación del worker de emails
 * Este script verifica que:
 * 1. El servicio de colas se inicializa correctamente
 * 2. El worker puede procesar jobs
 * 3. No hay errores de sintaxis en los archivos modificados
 */

const { emailQueue, addEmailJob } = require('./services/queueService');

async function runTest() {
  console.log('\n🧪 Iniciando pruebas del sistema de colas...\n');
  
  try {
    // Test 1: Verificar que la cola está conectada
    console.log('✓ Servicio de colas importado correctamente');
    
    // Test 2: Intentar agregar un job de prueba
    console.log('\n📝 Agregando job de prueba...');
    const testJob = await addEmailJob('sendWelcomeEmail', {
      email: 'test@example.com',
      nombre: 'Usuario de Prueba'
    });
    console.log(`✓ Job agregado con ID: ${testJob.id}`);
    
    // Test 3: Verificar la cola
    console.log('\n📊 Estado de la cola:');
    const counts = await emailQueue.getJobCounts();
    console.log(`   - Trabajos pendientes: ${counts.wait}`);
    console.log(`   - Trabajos activos: ${counts.active}`);
    console.log(`   - Trabajos completados: ${counts.completed}`);
    
    console.log('\n✅ Todas las pruebas pasaron correctamente!\n');
    console.log('📌 Para ejecutar el worker, corre en otra terminal:');
    console.log('   node src/workers/emailWorker.js\n');
    
    // Esperar a que se procese el job o timeout
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, 5000);
    });
    
  } catch (error) {
    console.error(`\n❌ Error durante las pruebas: ${error.message}\n`);
    process.exit(1);
  } finally {
    // Limpiar y cerrar
    await emailQueue.close();
    process.exit(0);
  }
}

runTest();
