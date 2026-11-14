-- =============================================================================
-- BASE DE DATOS: TechStore_Clase5
-- =============================================================================

USE TechStore_Clase5;
GO

-- -----------------------------------------------------------------------------
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Unificar las ventas identificadas con los datos de clientes, 
-- productos y categorías para alimentar el modelo principal de Power BI.
-- -----------------------------------------------------------------------------
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;

-- Hallazgo: Se consolidan 26 ventas con cliente registrado por un total de $15,390.00 (las 2 ventas de mostrador sin id_cliente quedan excluidas por el INNER JOIN), donde la categoría 'Computacion' lidera la facturación.
GO

-- -----------------------------------------------------------------------------
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados que nunca compraron, para que el 
-- área de CRM los contacte con una campaña de activación.
-- -----------------------------------------------------------------------------
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Aparece 1 cliente registrado de los 9 totales que nunca compró (Ana Duarte, registrada el 2026-05-02);
GO

-- -----------------------------------------------------------------------------
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo que no registran ninguna venta, 
-- para que el área de Producto evalúe ajustes de precio, promoción o stock.
-- -----------------------------------------------------------------------------
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: Aparece 1 producto de los 8 del catálogo sin ventas registradas ('Disco SSD 1TB'

-- -----------------------------------------------------------------------------
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: Comparar la facturación separando las ventas con cliente 
-- registrado ('Online') de las ventas de mostrador ('Presencial').
-- -----------------------------------------------------------------------------
SELECT 
    canal, 
    SUM(total) AS total_canal
FROM (
    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE id_cliente IS NOT NULL

    UNION ALL

    SELECT 
        fecha_venta, 
        cantidad * precio_unitario AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE id_cliente IS NULL
) AS consolidado
GROUP BY canal;

-- Hallazgo: El canal Online genera $15,390.00 (26 ventas de clientes registrados), mientras que el canal Presencial suma $120.00 (las 2 ventas de mostrador sin cliente identificado).
GO