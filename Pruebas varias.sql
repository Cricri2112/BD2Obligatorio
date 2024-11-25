
SELECT *
FROM Habitacion

SELECT *
FROM Reserva
WHERE habitacionNombre = 'El Solarium'

SELECT *
FROM Reserva r
ORDER BY r.reservaID DESC

DECLARE @Insert INT
EXEC @Insert = SP_EJ4A @NombreHabitacion = 'El Solarium',@GatoID = 31,@ReservaFechaFin= '2024-11-30'
PRINT @Insert

DECLARE @Insert2 INT
EXEC @Insert2 = SP_EJ4A @NombreHabitacion = 'El Solarium',@GatoID = 30,@ReservaFechaFin= '2024-11-28'
PRINT @Insert2

SELECT COUNT(r.gatoID), h.habitacionNombre, h.habitacionCapacidad, h.habitacionEstado
FROM Reserva r
JOIN Habitacion h ON h.habitacionNombre = r.habitacionNombre
WHERE GETDATE() BETWEEN r.reservaFechaInicio AND r.reservaFechaFin
GROUP BY h.habitacionNombre, h.habitacionCapacidad, h.habitacionEstado

SELECT *
FROM Reserva r
ORDER BY r.reservaID DESC

DELETE 
FROM Reserva
WHERE GETDATE() BETWEEN reservaFechaInicio AND reservaFechaFin

UPDATE Habitacion
SET habitacionEstado = 'DISPONIBLE'
WHERE habitacionNombre = 'La Caja'


DECLARE @PruebaFuncion BIT 
EXEC @PruebaFuncion = dbo.F_EJ4B 'BAÑO'
PRINT @PruebaFuncion

DECLARE @PruebaFuncion2 BIT 
EXEC @PruebaFuncion2 = dbo.F_EJ4B 'ALIMENTACION_ESPECIAL'
PRINT @PruebaFuncion2

SELECT rs.servicioNombre, 
        (SELECT SUM(rs2.cantidad)
        FROM Reserva_Servicio rs2
        JOIN Reserva r ON r.reservaID = rs2.reservaID
        WHERE YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) -1 AND
             rs2.servicioNombre = rs.servicioNombre) AS Anterior,
        (SELECT SUM(rs2.cantidad)
        FROM Reserva_Servicio rs2
        JOIN Reserva r ON r.reservaID = rs2.reservaID
        WHERE YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) AND
             rs2.servicioNombre = rs.servicioNombre) AS Actual
FROM Reserva_Servicio rs
GROUP BY rs.servicioNombre


SELECT *
FROM ReservaLog

INSERT INTO Reserva
VALUES (16, 'La Caja', GETDATE(), '2024-11-30', 490)

UPDATE Reserva
SET reservaMonto = 800
WHERE reservaID = 93

update Reserva
set gatoID = 23
where reservaID = 64

select *
from reservalog



SELECT *
FROM Reserva
ORDER BY reservaID DESC

select *
from Habitacion

INSERT INTO Reserva 
VALUES (16, 'El Rascador', '2024-11-23', '2024-11-28', 480),
		(4, 'El Árbol', '2024-11-15', '2024-11-30', 800),
		(31,'El Mirador', '2024-11-25', '2024-11-28', 280),
		(7, 'La Cueva', '2024-11-18', '2024-11-19', 200)

SELECT *
FROM Reserva r
ORDER BY reservaID DESC

SELECT *
FROM  ReservaLog

EXEC SP_EJ4A 'El Rascador', 26, '2024-11-29' 


SELECT *
FROM View_Ej6


INSERT INTO Reserva 
VALUES (1, 'El Rascador', '2024-10-17', '2024-10-20', 1200),
		(2, 'El Rascador', '2024-10-01', '2024-10-05', 1200),
		(3,'El Rascador', '2024-10-15', '2024-10-22', 1200),
		(4, 'El Rascador', '2024-10-18', '2024-10-19', 1200),
		(5, 'El Rascador', '2024-10-18', '2024-10-22', 1200),		
		(7, 'El Rascador', '2024-10-18', '2024-10-22', 1200),
		(8, 'El Rascador', '2024-10-18', '2024-10-22', 1200),		
		(9, 'El Rascador', '2024-11-18', '2024-11-22', 1200),		
		(10, 'El Rascador', '2024-11-18', '2024-11-22', 1200),		
		(11, 'El Rascador', '2024-11-18', '2024-11-22', 1200),
		(12, 'El Rascador', '2024-11-18', '2024-11-22', 1200),
		(13, 'El Rascador', '2024-11-18', '2024-11-22', 1200),
		(14, 'El Rascador', '2024-11-18', '2024-11-22', 1200),
		(15, 'El Rascador', '2024-11-18', '2024-11-22', 1200)

SELECT *
FROM Reserva r
ORDER BY r.reservaID DESC

INSERT INTO Reserva_Servicio 
VALUES(74, 'CONTROL_PARASITOS', 2),

--CREATE TABLE Propietario (
--    propietarioDocumento CHAR(30) PRIMARY KEY,
--    propietarioNombre VARCHAR(100) NOT NULL,
--    propietarioTelefono VARCHAR(20) NULL,
--    propietarioEmail VARCHAR(100) NULL,
--    CONSTRAINT CHK_Propietario_TelefonoEmail CHECK (propietarioTelefono IS NOT NULL OR propietarioEmail IS NOT NULL) );
--GO