USE CatHotel

/*
Escribir un procedimiento almacenado para reservar una habitación. 
Se debe actualizar el estado de DISPONIBLE a LLENA si se alcanzó la capacidad de la 
habitación con la reserva en cuestión 
No permitir realizar la reserva si el estado de la habitación es LLENA o LIMPIANDO. 
Se debe retornar el número de reserva asignado (cero sino se logró reservar) 
*/

ALTER PROCEDURE SP_EJ4A
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
