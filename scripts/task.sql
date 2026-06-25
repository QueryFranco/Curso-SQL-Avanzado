CREATE TABLE usuarios (
    usuario_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL
);
CREATE TABLE  pedidos (
pedido_id SERIAL PRIMARY KEY,
usuario_id INT NOT NULL,
fecha TIMESTAMP NOT NULL,
monto DECIMAL(10, 2) NOT NULL,
FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);
-----------------------
INSERT INTO usuarios (nombre, pais) VALUES
('Ana', 'Chile'),
('Bruno', 'Mexico'),
('Carlos', 'Chile');
INSERT INTO pedidos (usuario_id, fecha, monto) VALUES
(1, '2026-01-10', 150),
(1, '2026-02-15', 45),
(2, '2026-01-20', 300),
(3, '2026-03-01', 80),
(2, '2026-03-05', 120);
-----------------------
WITH CTE_tabla_unida AS (
SELECT 
    u.usuario_id,
    u.nombre,
    u.pais,
    p.pedido_id,
    p.fecha,
    p.monto,
    AVG(p.monto) OVER (PARTITION BY u.usuario_id )::float AS monto_promedio_acumulado,
    ROW_NUMBER() OVER (PARTITION BY u.usuario_id ORDER BY p.fecha ASC) AS numero_pedido,
    CASE
        WHEN ROW_NUMBER() OVER (PARTITION BY u.usuario_id ORDER BY p.fecha ASC) = 1 THEN 'Primer Pedido'
        ELSE 'Pedido Posterior'
    END AS tipo_pedido
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.usuario_id
)
SELECT* FROM CTE_tabla_unida
WHERE pais = 'Mexico'
