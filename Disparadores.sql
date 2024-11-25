
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
	LogId INT IDENTITY(1,1) PRIMARY KEY,
	Fecha DATETIME NOT NULL DEFAULT GETDATE(),
	Usuario NVARCHAR(100) DEFAULT SUSER_NAME(),
	Equipo NVARCHAR(100) DEFAULT HOST_NAME(),
	Accion NVARCHAR(50) NOT NULL,
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

