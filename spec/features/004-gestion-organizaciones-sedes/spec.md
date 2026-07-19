# # 004 · Gestión de Organizaciones y Sedes — Especificación

_Definición funcional y técnica del control multi-bodega y datos de la empresa en EcuStock._[cite: 1]

## Casos de Uso

1. **Registrar Sede / Bodega:** Un administrador registra una sucursal física ingresando su nombre, dirección y el código de establecimiento asignado por el SRI[cite: 1].
2. **Consultar Ubicaciones:** Permite visualizar qué bodegas de almacenamiento o puntos de distribución están configurados en el sistema[cite: 1].

## Diseño de Pantallas
- **Pantalla de Sedes (Lista):** Una vista de cuadrícula (*Grid*) o lista que muestra el nombre de cada sede, su código (ej. "Sede Central [Est. 001]") y dirección física[cite: 1].
- **Formulario de Sede:** Inputs con validaciones: Nombre comercial, Dirección completa y Código del establecimiento de 3 dígitos (ej. "002")[cite: 1].

## Arquitectura de Archivos (Flutter)
- `lib/data/models/sede_model.dart` -> Modelo de datos de la sede[cite: 1].
- `lib/presentation/screens/sedes/sedes_list_screen.dart` -> Vista de consulta[cite: 1].
- `lib/presentation/screens/sedes/sede_form_screen.dart` -> Formulario de creación[cite: 1].