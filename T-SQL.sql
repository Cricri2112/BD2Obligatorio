USE CatHotel

/*
Escribir un procedimiento almacenado para reservar una habitación. 
Se debe actualizar el estado de DISPONIBLE a LLENA si se alcanzó la capacidad de la 
habitación con la reserva en cuestión 
No permitir realizar la reserva si el estado de la habitación es LLENA o LIMPIANDO. 
Se debe retornar el número de reserva asignado (cero sino se logró reservar) 
*/



CREATE OR ALTER PROCEDURE SP_EJ4A
	@NombreHabitacion CHAR(30), 
	@GatoID INT,
	@ReservaFechaFin DATE 
AS
BEGIN

DECLARE @Estado VARCHAR(20) = 'Sin asignar'
DECLARE @GatoEncontrado BIT = 0
DECLARE @VerifFecha INT = DATEDIFF(DAY, GETDATE(), @ReservaFechaFin)
DECLARE @MontoReserva DECIMAL(7,2) = 0
													--+1 porque se cuenta el día que ingresa para el cobro
SELECT @Estado = h.habitacionEstado, @MontoReserva = (H.habitacionPrecio*(@VerifFecha+1))
FROM Habitacion h
WHERE h.habitacionNombre = @NombreHabitacion 

SELECT @GatoEncontrado = 1
FROM Gato g
WHERE g.gatoID = @GatoID

IF(@Estado = 'LLENA' OR @Estado = 'LIMPIANDO' OR @Estado = 'Sin asignar' OR @GatoEncontrado = 0 OR @VerifFecha < 0)
	RETURN 0

DECLARE @ReservaID INT = 0

BEGIN TRY
	BEGIN TRANSACTION 

		INSERT INTO Reserva (gatoID, habitacionNombre,reservaFechaInicio,reservaFechaFin,reservaMonto)
			VALUES (@GatoID, @NombreHabitacion, GETDATE(), @ReservaFechaFin, @MontoReserva)

		SELECT @ReservaID = MAX(r.reservaID)
		FROM Reserva r

		UPDATE Habitacion 
		SET habitacionEstado = 'LLENA'
		WHERE habitacionNombre = @NombreHabitacion AND
			  habitacionCapacidad <= (SELECT COUNT(r.gatoID)
									  FROM Reserva r
									  WHERE r.habitacionNombre = @NombreHabitacion AND
										    GETDATE() BETWEEN r.reservaFechaInicio AND r.reservaFechaFin)

	COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION 
END CATCH

RETURN @ReservaID
END

SELECT *
FROM Reserva r
ORDER BY r.reservaID DESC

DECLARE @Algo1 INT
EXEC @Algo1 = SP_EJ4A @NombreHabitacion = 'La Caja',@GatoID = 31,@ReservaFechaFin= '2024-11-18'
PRINT @Algo1

EXEC @Algo1 = SP_EJ4A @NombreHabitacion = 'La Caja',@GatoID = 30,@ReservaFechaFin= '2024-11-19'
PRINT @Algo1

EXEC @Algo1 = SP_EJ4A @NombreHabitacion = 'La Caja',@GatoID = 27,@ReservaFechaFin= '2024-11-18'
PRINT @Algo1

EXEC @Algo1 = SP_EJ4A @NombreHabitacion = 'La Caja',@GatoID = 20,@ReservaFechaFin= '2024-11-25'
PRINT @Algo1

EXEC @Algo1 = SP_EJ4A @NombreHabitacion = 'La Caja',@GatoID = 19,@ReservaFechaFin= '2024-11-25'
PRINT @Algo1

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


/*
Mediante una función que reciba un nombre de servicio, devolver un booleano indicando si
este año el servicio fue contratado más veces que el año pasado 
*/

CREATE OR ALTER FUNCTION F_EJ4B (
	@NombreServicio CHAR(30)
)
RETURNS Bit
BEGIN
	DECLARE @Res Bit = 0

	SELECT @Res = 1
	FROM Reserva r
	LEFT JOIN Reserva_Servicio rs on rs.reservaID = r.reservaID
	WHERE rs.servicioNombre = @NombreServicio AND
		YEAR(GETDATE()) = YEAR(r.reservaFechaInicio)
	HAVING ISNULL(SUM(rs.cantidad), 0) > (
		SELECT ISNULL(SUM(rs.cantidad), 0)
		FROM Reserva r
		JOIN Reserva_Servicio rs on rs.reservaID = r.reservaID
		WHERE rs.servicioNombre = @NombreServicio AND
			YEAR(GETDATE())-1 = YEAR(r.reservaFechaInicio)
	)

	RETURN @Res
END

declare @Algo bit 
exec @Algo = dbo.F_EJ4B 'BAÑO'
PRINT @Algo

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

--5. Escribir los siguientes disparadores (por supuesto: considerando modificaciones múltiples) 

/*
a. Cada vez que se crea una nueva reserva se debe crear un registro de auditoria con todos
		los datos ingresados en una tabla ReservaLog (definir su estructura libremente). Y
		adicionalmente cada vez que se modifica el campo monto de una reserva: debe registrar
		monto previo y nuevo monto en la tabla ReservaLog.
		En todos los casos se debe grabar fecha-hora de registro, usuario(login), nombre de equipo
		desde el que se realizó la modificación.
*/

-- Decidimos no implementar Foreign Keys en esta tabla porque al crearse un log DESPUES de hacer un insert / update de monto de una reserva
-- correctamente, los atributos referenciales como ReservaID o GatoID van a estar correctos, y seria mas eficiente esta tabla sin referencias
CREATE TABLE ReservaLog(
	LogId int IDENTITY(1,1) PRIMARY KEY,
	Fecha Date NOT NULL DEFAULT GETDATE(),
	Usuario nvarchar(100) DEFAULT SUSER_NAME(),
	Equipo nvarchar(100) DEFAULT HOST_NAME(),
	Accion nvarchar(50) NOT NULL,
	ReservaID INT NOT NULL,
  GatoID INT NOT NULL,
  HabitacionNombre CHAR(30) NOT NULL,
  ReservaFechaInicio DATE NOT NULL,
  ReservaFechaFin DATE NOT NULL,
  ReservaMonto DECIMAL(7,2) NOT NULL,
	NuevaReservaMonto DECIMAL(7,2) DEFAULT NULL
)


CREATE OR ALTER TRIGGER TR_EJ5A ON Reserva
AFTER INSERT, UPDATE
AS
BEGIN
SET NOCOUNT ON
	IF exists(select 1 from deleted) BEGIN
		IF UPDATE(ReservaMonto)
		INSERT INTO ReservaLog(Accion, ReservaID, GatoID, HabitacionNombre, ReservaFechaInicio, ReservaFechaFin, ReservaMonto, NuevaReservaMonto)
		SELECT 'UPDATE DEL MONTO', d.*, i.reservaMonto
		FROM inserted i, deleted d
	END

	ELSE BEGIN
		INSERT INTO ReservaLog(Accion, ReservaID, GatoID, HabitacionNombre, ReservaFechaInicio, ReservaFechaFin, ReservaMonto)
		SELECT 'INSERT', i.*
		FROM inserted i
	END

END

insert into Reserva
values (16, 'La Caja', getdate(), '2024-11-25', 630)

update Reserva
set reservaMonto = 5465
where reservaID = 64

update Reserva
set gatoID = 23
where reservaID = 64

select *
from reservalog


/*
b. Antes de insertar una nueva reserva, se debe controlar posibles solapamientos de reservas
		(un gato no podría estar alojado simultáneamente 2 veces en el hotel).
		Se debe dar de alta las reservas válidas y simplemente ignorar las reservas solapadas 
*/

CREATE OR ALTER TRIGGER TR_EJ5B ON Reserva
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON

INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
SELECT i.gatoID, i.habitacionNombre, i.reservaFechaInicio, i.reservaFechaFin, i.reservaMonto
FROM inserted i
WHERE i.gatoID NOT IN (
		SELECT r.gatoID 
		FROM Reserva r
		WHERE i.reservaFechaInicio <= r.reservaFechaFin AND 
			  i.reservaFechaFin >= r.reservaFechaInicio
		)
END

INSERT INTO Reserva 
VALUES (5, 'El Rascador', '2024-11-17', '2024-11-20', 1200),
		(4, 'El Rascador', '2024-11-15', '2024-11-18', 1200),
		(12,'El Rascador', '2024-11-15', '2024-11-22', 1200),
		(7, 'El Rascador', '2024-11-18', '2024-11-19', 1200),
		(6, 'El Rascador', '2024-11-18', '2024-11-22', 1200)

SELECT *
FROM Reserva r
ORDER BY reservaID DESC

SELECT *
FROM  ReservaLog

EXEC SP_EJ4A 'El Rascador', 26, '2024-11-29' 

/*
6. Crear una vista que liste el monto total a facturar por propietario por las reservas y servicios del 
mes pasado. Se debe listar el nombre del propietario, el monto total de sus reservas, el monto total 
de servicios adicionales que contrató y la suma de ambos montos (monto a facturar) 
*/
CREATE OR ALTER FUNCTION F_MontoReservasMesAnterior (
	@DocPropietario CHAR(30) 
)
RETURNS INT 
BEGIN
	DECLARE @res DECIMAL(10,2)
		SELECT @res = ISNULL(SUM(r.reservaMonto),0)
		FROM Reserva r
		JOIN Gato g ON g.gatoID = r.gatoID
		WHERE g.propietarioDocumento = @DocPropietario AND
			  MONTH(GETDATE())-1 = MONTH(r.reservaFechaInicio) AND
			  YEAR(GETDATE()) = YEAR(r.reservaFechaInicio)
	RETURN @res
END

CREATE OR ALTER FUNCTION F_MontoServiciosMesAnterior (
	@DocPropietario CHAR(30) 
)
RETURNS INT 
BEGIN
	DECLARE @res DECIMAL(10,2)
		SELECT @res = ISNULL(SUM(rs.cantidad*s.servicioPrecio),0)
		FROM Reserva_Servicio rs
		JOIN Servicio s ON s.servicioNombre = rs.servicioNombre
		JOIN Reserva r ON r.reservaID = rs.reservaID
		JOIN Gato g ON g.gatoID = r.gatoID
		WHERE g.propietarioDocumento = @DocPropietario AND
			  MONTH(GETDATE())-1 = MONTH(r.reservaFechaInicio) AND
			  YEAR(GETDATE()) = YEAR(r.reservaFechaInicio)
	RETURN @res
END

CREATE OR ALTER VIEW View_Ej6
AS
SELECT p.propietarioNombre, 
	    dbo.F_MontoReservasMesAnterior(p.propietarioDocumento) AS MontoReservas,
		dbo.F_MontoServiciosMesAnterior(p.propietarioDocumento) AS MontoServicios,
		dbo.F_MontoReservasMesAnterior(p.propietarioDocumento) + dbo.F_MontoServiciosMesAnterior(p.propietarioDocumento) 
			AS MontoAFacturar		
FROM Propietario p

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