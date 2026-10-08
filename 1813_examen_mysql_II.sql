USE coworking;

-- 1. Creacion de una vista  VW_EstadoEspacios que muestre donde se veran: 
-- Espacio, Estado(Libre/Ocupado), Proxima reserva

-- Vista VW_EstadoEspacios
-- Aqui mostramos los espacios que solo estan disponibles,
-- si el estado se encuentra ya sea libre o ocupado AHORA en el rango
-- de fecha inicio y fecha fin y si existen proximas reservas
-- y en caso de no existir devuelve sin reservas proximas, mostrando la 
-- fecha, si esta en estado Pendiente o Confirmada

CREATE OR REPLACE VIEW VW_EstadoEspacios AS
SELECT
    e.nombre AS Espacio,
-- El EXISTS se va a detener cuando enuentre una reserva activa
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM reservas r
            WHERE r.espacio_id = e.id
              AND r.estado IN ('Pendiente', 'Confirmada')
              AND NOW() >= r.fecha_inicio
              AND NOW() <  r.fecha_fin
        ) THEN 'Ocupado'
        ELSE 'Libre'
    END AS Estado,
-- En el caso de que no exista en ese momento una reservva proxima se tomara como NULL
-- y para evitar espacios vacios se mostrara un mensaje
    COALESCE(
        (
            SELECT DATE_FORMAT(MIN(r.fecha_inicio), '%Y-%m-%d %H:%i')
            FROM reservas r
            WHERE r.espacio_id = e.id
              AND r.estado IN ('Pendiente', 'Confirmada')
              AND r.fecha_inicio > NOW()
        ),
        'Sin reservas próximas'
    ) AS Proxima_Reserva
FROM espacios e
WHERE e.estado = 'Disponible';

-- 2 Crea un procedimiento  sp_GenerarReporteDiario que devuelva:
-- Total de reservas hoy, Usuarios activos en el día y Ingresos del día

-- Se crea un procedimiento sp_GenerarReporteDiario
-- donde se vera las reservas de hoy agarrando los datos desde la tablas reservas, 
-- en el caso de haber reservas que fueron canceladas
-- no se mostraran. Se mostraran las personas que esten activos en ese dia agarrando
-- los datos desde la tabla asistencias. Se mostraran los ingresos en el dia o 
-- el dinero que entro ese dia agarrando los datos de la tabla pagos. Evitando 
-- que se muestre algun otro dato que no sea del dia de hoy se crea la variable mañana

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_GenerarReporteDiario$$
CREATE PROCEDURE sp_GenerarReporteDiario()
BEGIN
    DECLARE v_hoy    DATETIME;   -- hoy 00:00:00
    DECLARE v_manana DATETIME;   -- mañana 00:00:00

    SET v_hoy    = CAST(CURDATE() AS DATETIME);
    SET v_manana = v_hoy + INTERVAL 1 DAY;

    SELECT
-- Reservas del día (no muestra las que fueron canceladas)
        (SELECT COUNT(*)
           FROM reservas
          WHERE fecha_inicio >= v_hoy
            AND fecha_inicio <  v_manana
            AND estado <> 'Cancelada') AS Total_Reservas_Hoy,

-- Personas que estuvieron activas en el edificio hoy
        (SELECT COUNT(DISTINCT usuario_id)
           FROM asistencias
          WHERE tipo = 'Edificio'
            AND fecha_entrada >= v_hoy
            AND fecha_entrada <  v_manana) AS Usuarios_Activos_Hoy,

-- Ingresos de hoy
        (SELECT COALESCE(SUM(monto), 0)
           FROM pagos
          WHERE estado = 'Aplicado'
            AND fecha_pago >= v_hoy
            AND fecha_pago <  v_manana) AS Ingresos_Hoy;
END$$

DELIMITER ;

-- 3. Consulta simulada

SELECT CONCAT(
           'Ahora mismo hay ',
           COUNT(DISTINCT usuario_id),
           ' personas en el coworking'
       ) AS Mensaje
FROM accesos
WHERE estado_intento = 'Permitido'
  AND fecha_hora_salida IS NULL
  AND fecha_hora_entrada >= CURDATE();


