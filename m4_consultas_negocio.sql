USE Ventas_Tech_DB;
GO

-- -----------------------------------------------------------------------------
-- Consulta 1:
-- -----------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario * 1.0) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
GO

-- -----------------------------------------------------------------------------
-- Consulta 2: 
-- -----------------------------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

-- -----------------------------------------------------------------------------
-- Consulta 3: 
-- -----------------------------------------------------------------------------
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;
GO

-- -----------------------------------------------------------------------------
-- Consulta 4: 
-- -----------------------------------------------------------------------------
WITH FacturacionPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
),
PromedioGeneral AS (
    SELECT 
        AVG(total_facturado * 1.0) AS promedio_facturacion
    FROM FacturacionPorProducto
)
SELECT 
    f.id_producto,
    f.total_facturado,
    CASE 
        WHEN f.total_facturado >= p.promedio_facturacion THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM FacturacionPorProducto f
CROSS JOIN PromedioGeneral p
ORDER BY f.total_facturado DESC;
GO

-- =============================================================================
-- Bloque de cierre: Hallazgos de negocio
-- =============================================================================
-- 1 Fuerte concentración de ventas: El producto 1 genera más de la mitad de la facturación total ($3600 de $6444), a pesar de tener menos unidades vendidas que otros productos.  
-- 2 Alta retención de clientes: Hay 5 clientes recurrentes que realizaron 2 pedidos cada uno, lo que demuestra una buena fidelización en este período.   
-- 3 Desigualdad en el catálogo: Solo dos productos (el 1 y el 3) logran superar el promedio de facturación, mientras que la mayoría (4 productos) quedan por debajo.   

