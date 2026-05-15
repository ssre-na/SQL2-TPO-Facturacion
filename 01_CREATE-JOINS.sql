CREATE DATABASE IF NOT EXISTS facturacion_TPO;
USE facturacion_TPO;

CREATE TABLE E01_CLIENTE (
    nro_cliente INT PRIMARY KEY,
    nombre VARCHAR(45) NOT NULL,
    apellido VARCHAR(45) NOT NULL,
    direccion VARCHAR(45),
    activo TINYINT DEFAULT 1
);
CREATE TABLE E01_TELEFONO (
    codigo_area INT,
    nro_telefono INT,
    tipo CHAR(1),
    nro_cliente INT,
    PRIMARY KEY (codigo_area, nro_telefono),
    FOREIGN KEY (nro_cliente) REFERENCES E01_CLIENTE(nro_cliente)
);
CREATE TABLE E01_PRODUCTO (
    codigo_producto INT PRIMARY KEY,
    marca VARCHAR(45),
    nombre VARCHAR(45),
    descripcion VARCHAR(45),
    precio FLOAT,
    stock INT
);
CREATE TABLE E01_FACTURA (
    nro_factura INT PRIMARY KEY,
    fecha DATE,
    total_sin_iva DOUBLE,
    iva DOUBLE DEFAULT 21.0,
    total_con_iva DOUBLE,
    nro_cliente INT,
    FOREIGN KEY (nro_cliente) REFERENCES E01_CLIENTE(nro_cliente)
);
CREATE TABLE E01_DETALLE_FACTURA (
    nro_factura INT,
    codigo_producto INT,
    nro_item INT,
    cantidad FLOAT,
    PRIMARY KEY (nro_factura, codigo_producto),
    FOREIGN KEY (nro_factura) REFERENCES E01_FACTURA(nro_factura),
    FOREIGN KEY (codigo_producto) REFERENCES E01_PRODUCTO(codigo_producto)
);

-- 1. Obtener los datos de los clientes junto con sus teléfonos.
SELECT C.*, T.codigo_area, T.nro_telefono 
FROM E01_CLIENTE C 
JOIN E01_TELEFONO T ON C.nro_cliente = T.nro_cliente;

-- 2. Obtener el/los teléfono/s y el número de cliente del cliente con nombre “Jacob” y apellido “Cooper”.
SELECT nro_cliente, codigo_area, nro_telefono 
FROM E01_TELEFONO 
WHERE nro_cliente IN 
	(SELECT nro_cliente 
	FROM E01_CLIENTE 
	WHERE nombre = 'Jacob' 
	AND apellido = 'Cooper');

-- 3. Mostrar cada teléfono junto con los datos del cliente.
SELECT T.*, C.nombre, C.apellido 
FROM E01_TELEFONO T 
JOIN E01_CLIENTE C ON T.nro_cliente = C.nro_cliente;

-- 4. Obtener todos los clientes que tengan registrada al menos una factura.
SELECT DISTINCT C.* 
FROM E01_CLIENTE C 
JOIN E01_FACTURA F ON C.nro_cliente = F.nro_cliente;

-- 5. Identificar todos los clientes que no tengan registrada ninguna factura.
SELECT C.* 
FROM E01_CLIENTE C 
LEFT JOIN E01_FACTURA F ON C.nro_cliente = F.nro_cliente 
WHERE F.nro_factura IS NULL;

-- 6. Devolver todos los clientes, con la cantidad de facturas que tienen registradas (si no tienen considerar cantidad en 0)
SELECT C.nro_cliente, C.nombre, C.apellido, COUNT(F.nro_factura) as cant_facturas 
FROM E01_CLIENTE C 
LEFT JOIN E01_FACTURA F ON C.nro_cliente = F.nro_cliente 
GROUP BY C.nro_cliente;

-- 7. Listar los datos de todas las facturas que hayan sido compradas por el cliente de nombre "Kai" y apellido "Bullock".
SELECT F.* 
FROM E01_FACTURA F 
JOIN E01_CLIENTE C ON F.nro_cliente = C.nro_cliente 
WHERE C.nombre = 'Kai' AND C.apellido = 'Bullock';

-- 8. Seleccionar los productos que han sido facturados al menos 1 vez.
SELECT DISTINCT P.* 
FROM E01_PRODUCTO P 
JOIN E01_DETALLE_FACTURA DF ON P.codigo_producto = DF.codigo_producto;

-- 9. Listar los datos de todas las facturas que contengan productos de las marcas “Ipsum”.
SELECT DISTINCT marca 
FROM E01_PRODUCTO 
WHERE marca LIKE '%Ipsum%';

SELECT DISTINCT F.*, P.marca AS marca_producto
FROM E01_FACTURA F 
JOIN E01_DETALLE_FACTURA DF ON F.nro_factura = DF.nro_factura
JOIN E01_PRODUCTO P ON DF.codigo_producto = P.codigo_producto
WHERE P.marca LIKE '%Ipsum%';

-- 10. Mostrar nombre y apellido de cada cliente junto con lo que gastó en total, con IVA incluido.
SELECT C.nombre, C.apellido, ROUND(SUM(F.total_con_iva), 2) as gasto_total 
FROM E01_CLIENTE C 
JOIN E01_FACTURA F ON C.nro_cliente = F.nro_cliente 
GROUP BY C.nro_cliente;