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
