-- src/db/init_tables.sql
-- Script MariaDB para crear las tablas roles, sedes y usuarios de EcuStock

CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS sedes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    direccion VARCHAR(255),
    telefono VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol_id INT NULL,
    sede_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES roles (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_usuarios_sede FOREIGN KEY (sede_id) REFERENCES sedes (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Datos iniciales de prueba
INSERT INTO
    roles (nombre, descripcion)
VALUES (
        'Administrador',
        'Rol con permisos completos'
    ),
    (
        'Empleado',
        'Rol con acceso limitado'
    );

INSERT INTO
    sedes (nombre, direccion, telefono)
VALUES (
        'Sede Principal',
        'Av. Principal 123, Quito',
        '+593987654321'
    );

INSERT INTO
    usuarios (
        nombre,
        email,
        password_hash,
        rol_id,
        sede_id
    )
VALUES (
        'Admin EcuStock',
        'admin@ecustock.com',
        '$2b$10$jCA.yeMCeZXRVFSMZi47VeRqVyvu3Smbb.uRV0AcLqg6Yggp4zdTK',
        1,
        1
    );