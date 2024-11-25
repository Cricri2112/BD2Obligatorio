USE CatHotel

/*
Escribir un procedimiento almacenado para reservar una habitaci�n. 
Se debe actualizar el estado de DISPONIBLE a LLENA si se alcanz� la capacidad de la 
habitaci�n con la reserva en cuesti�n 
No permitir realizar la reserva si el estado de la habitaci�n es LLENA o LIMPIANDO. 
Se debe retornar el n�mero de reserva asignado (cero sino se logr� reservar) 
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
													--+1 porque se cuenta el d�a que ingresa para el cobro
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


/*
Mediante una funci�n que reciba un nombre de servicio, devolver un booleano indicando si
este a�o el servicio fue contratado m�s veces que el a�o pasado 
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