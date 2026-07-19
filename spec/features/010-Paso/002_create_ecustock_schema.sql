-- Migration: Crear esquema completo de EcuStock para usuarios, roles, permisos, sedes y tokens
-- Ejecutar en la base de datos `ecustock` en MariaDB

CREATE TABLE IF NOT EXISTS roles (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permisos (
  id_permiso INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rol_permiso (
  id_rol INT NOT NULL,
  id_permiso INT NOT NULL,
  PRIMARY KEY (id_rol, id_permiso),
  FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE,
  FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS organizaciones (
  id_organizacion INT AUTO_INCREMENT PRIMARY KEY,
  ruc VARCHAR(20) NOT NULL UNIQUE,
  nombre_comercial VARCHAR(150) NOT NULL,
  direccion_matriz VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sedes (
  id_sede INT AUTO_INCREMENT PRIMARY KEY,
  id_organizacion INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  direccion TEXT NOT NULL,
  codigo_establecimiento VARCHAR(3) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY codigo_establecimiento (codigo_establecimiento),
  FOREIGN KEY (id_organizacion) REFERENCES organizaciones(id_organizacion) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol VARCHAR(50) NOT NULL DEFAULT 'Bodega',
  sede VARCHAR(100) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(500) NOT NULL UNIQUE,
  revoked BOOLEAN NOT NULL DEFAULT FALSE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO roles (nombre, descripcion) VALUES
  ('Administrativo', 'Acceso completo al sistema para administración'),
  ('Bodega', 'Acceso a funciones de bodega y consulta limitada');

INSERT IGNORE INTO permisos (nombre, descripcion) VALUES
  ('administrar_usuarios', 'Crear y listar cuentas de usuarios'),
  ('administrar_sedes', 'Crear y listar sedes de la organización'),
  ('administrar_roles', 'Configurar roles y permisos del sistema');

INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
  SELECT r.id_rol, p.id_permiso
  FROM roles r
  JOIN permisos p ON TRUE
  WHERE r.nombre = 'Administrativo'
    AND p.nombre IN ('administrar_usuarios', 'administrar_sedes', 'administrar_roles');

INSERT IGNORE INTO organizaciones (ruc, nombre_comercial, direccion_matriz)
  VALUES ('0999999999001', 'EcuStock SA', 'Av. Principal 123');

INSERT IGNORE INTO usuarios (nombre, email, password_hash, rol, sede)
  VALUES ('Administrador', 'admin@ecustock.com', '$2b$10$aji6tNjn4xr23ZXdxHO3OeF7KuUKKCtp3S7hlqIxMSvDLweUeQMBi', 'Administrativo', 'Sede Central');
