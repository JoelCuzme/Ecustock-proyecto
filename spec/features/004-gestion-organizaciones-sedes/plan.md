# # 004 · Gestión de Organizaciones y Sedes — Plan

_Cómo se implementa la administración de la empresa matriz (organización) y sus puntos físicos o bodegas (sedes) en EcuStock. Debe garantizar la trazabilidad de inventarios por ubicación._

## Enfoque

Implementar un módulo para administrar la información de la empresa y sus múltiples sedes o bodegas de almacenamiento[cite: 1]. Un usuario con rol `Administrativo` podrá configurar los datos de la organización (RUC, dirección, teléfono) y registrar múltiples sedes[cite: 1]. Esto permitirá segmentar el stock de los productos según la ubicación física en la que se encuentren de manera lógica dentro de MariaDB[cite: 1].

## Implementación

1. **Estructura de Base de Datos (MariaDB - InnoDB)**[cite: 1]:
   - Tabla `organizaciones`: `id_organizacion` (PK), `ruc`, `nombre_comercial`, `direccion_matriz`[cite: 1].
   - Tabla `sedes`: `id_sede` (PK), `id_organizacion` (FK), `nombre`, `direccion`, `codigo_establecimiento` (ej. 001, 002)[cite: 1].

2. **Endpoints de la API (Backend)**[cite: 1]:
   - `GET /api/v1/sedes` -> Recupera la lista de sedes de la organización[cite: 1].
   - `POST /api/v1/sedes` -> Crea una nueva sede vinculada a la organización (Solo accesible para rol `Administrativo`)[cite: 1].

3. **`lib/data/models/sede_model.dart` (Flutter)**[cite: 1] — Modelo para estructurar las sedes:
   - Atributos: `idSede`, `idOrganizacion`, `nombre`, `direccion`, `codigoEstablecimiento`[cite: 1].
   - Métodos `fromJson` y `toJson`[cite: 1].

4. **`lib/presentation/screens/sedes/sedes_list_screen.dart` (Flutter)**[cite: 1] — Vista donde se listan todas las sedes o bodegas activas[cite: 1].

5. **`lib/presentation/screens/sedes/sede_form_screen.dart` (Flutter)**[cite: 1] — Formulario de registro para nuevas sedes con validación de código de establecimiento (3 dígitos) y dirección obligatoria[cite: 1].

## Decisiones

- **Relación 1-N (Organización -> Sedes):** Se diseña bajo la premisa de que una sola organización (EcuStock) controla múltiples sucursales o bodegas para poder expandir la gestión de stock a futuro[cite: 1].
- **Cierre de inventarios por Sede:** Cada movimiento o transacción se asocia obligatoriamente a una sede física para mantener los reportes cuadraditos en MariaDB[cite: 1].

## Riesgos

- **Inconsistencia de inventario entre sedes:** Si un usuario de la sede A modifica el stock de un producto de la sede B[cite: 1].
  - **Mitigación:** Las peticiones del cliente móvil siempre incluirán el `id_sede` del usuario activo en las cabeceras, y el backend restringirá la modificación de stock cruzado en MariaDB si el usuario no tiene los permisos requeridos[cite: 1].