# Guía de Clase: Flujo de Autenticación JWT y Arquitectura Cliente-Servidor

Esta guía repasa los fundamentos para entender el intercambio de información segura:
1. **Petición del Cliente:** Flutter envía un payload JSON con `email` y `password`.
2. **Validación en Backend:** Node.js compara los datos (usando `bcryptjs` para la contraseña encriptada en MariaDB).
3. **Firma del JWT:** Si coincide, se genera un token asimétrico o simétrico que viaja de regreso en formato JSON.
4. **Consumo de Endpoints Protegidos:** El cliente envía el token en cada cabecera. El servidor lo decodifica mediante un middleware de autenticación para comprobar la identidad del usuario en cada petición.