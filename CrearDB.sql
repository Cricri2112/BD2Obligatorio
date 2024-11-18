USE master
GO

-- Eliminar la base de datos si ya existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CatHotel')
BEGIN
    ALTER DATABASE CatHotel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CatHotel;
END

CREATE DATABASE CatHotel
GO

USE CatHotel
GO
CREATE TABLE Propietario (
    propietarioDocumento CHAR(30) PRIMARY KEY,
    propietarioNombre VARCHAR(100) NOT NULL,
    propietarioTelefono VARCHAR(20) NULL,
    propietarioEmail VARCHAR(100) NULL,
    CONSTRAINT CHK_Propietario_TelefonoEmail CHECK (propietarioTelefono IS NOT NULL OR propietarioEmail IS NOT NULL) );
GO
CREATE TABLE Gato (
    gatoID INT IDENTITY(1,1) PRIMARY KEY,
    gatoNombre VARCHAR(50) NOT NULL,
    gatoRaza VARCHAR(50),
    gatoEdad INT,
    gatoPeso DECIMAL(5,2),
    propietarioDocumento CHAR(30) NOT NULL,
    CONSTRAINT CHK_Gato_Edad CHECK (gatoEdad >= 0),
    CONSTRAINT CHK_Gato_Peso CHECK (gatoPeso > 0),
    CONSTRAINT FK_Gato_Propietario FOREIGN KEY (propietarioDocumento) REFERENCES Propietario(propietarioDocumento) );
GO
CREATE TABLE Habitacion (
    habitacionNombre CHAR(30) PRIMARY KEY,
    habitacionCapacidad INT,
	habitacionPrecio DECIMAL(6,2),
    habitacionEstado VARCHAR(20),
    CONSTRAINT CHK_Habitacion_Capacidad CHECK (habitacionCapacidad > 0),
    CONSTRAINT CHK_Habitacion_Precio CHECK (habitacionPrecio > 0),
    CONSTRAINT CHK_Habitacion_Estado CHECK (habitacionEstado IN ('DISPONIBLE', 'LLENA', 'LIMPIANDO')) );
GO
CREATE TABLE Reserva (
    reservaID INT IDENTITY(1,1) PRIMARY KEY,
    gatoID INT NOT NULL,
    habitacionNombre CHAR(30) NOT NULL,
    reservaFechaInicio DATE NOT NULL,
    reservaFechaFin DATE NOT NULL,
    reservaMonto DECIMAL(7,2) NOT NULL,
    CONSTRAINT FK_Reserva_Gato FOREIGN KEY (gatoID) REFERENCES Gato(gatoID),
    CONSTRAINT FK_Reserva_Habitacion FOREIGN KEY (habitacionNombre) REFERENCES Habitacion(habitacionNombre),
    CONSTRAINT CHK_Reserva_Fecha CHECK (reservaFechaFin > reservaFechaInicio) );
GO
CREATE TABLE Servicio (
    servicioNombre CHAR(30) NOT NULL PRIMARY KEY,
    servicioPrecio DECIMAL(7,2),
    CONSTRAINT CHK_Servicio_Precio CHECK (servicioPrecio >= 0) );
GO
CREATE TABLE Reserva_Servicio (
    reservaID INT NOT NULL,
    servicioNombre CHAR(30) NOT NULL,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (reservaID, servicioNombre),
    CONSTRAINT CHK_ReservaServicio_Cantidad CHECK (cantidad > 0),
    CONSTRAINT FK_ReservaServicio_Reserva FOREIGN KEY (reservaID) REFERENCES Reserva(reservaID),
    CONSTRAINT FK_ReservaServicio_Servicio FOREIGN KEY (servicioNombre) REFERENCES Servicio(servicioNombre) );
GO

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

GO
CREATE INDEX idx_PropietarioGato ON Gato (propietarioDocumento)
GO
CREATE INDEX idx_GatoReserva ON Reserva (gatoID)
GO
CREATE INDEX idx_HabitacionReserva ON Reserva (habitacionNombre)
GO

INSERT INTO Propietario (propietarioDocumento, propietarioNombre, propietarioTelefono, propietarioEmail)
VALUES 
('12345672', 'Alejandro Torres', '+598 91 234 567', 'alejandro.torres@gmail.com'),
('51953448', 'Beatriz Mendoza', '+598 92 345 678', 'beatriz.mendoza@hotmail.com'),
('14406662', 'Camila Rodríguez', '+598 93 456 789', 'camila.rodriguez@outlook.com'),
('35569956', 'Daniel Herrera', '+598 94 567 890', 'daniel.herrera@gmail.com'),
('30240527', 'Elena Jiménez', NULL, 'elena.jimenez@hotmail.com'),
('53468374', 'Francisco Morales', '+598 96 789 012', 'francisco.morales@outlook.com'),
('56779790', 'Gabriela Castro', '+598 97 890 123', 'gabriela.castro@gmail.com'),
('68047090', 'Héctor Vargas', '+598 98 901 234', NULL),
('55525512', 'Inés Romero', '+598 99 012 345', 'ines.romero@outlook.com'),
('75984413', 'Jorge Salazar', '+598 2612 3456', 'jorge.salazar@gmail.com'),
('60150754', 'Karina Paredes', '+598 2623 4567', NULL),
('15450103', 'Luis Ortega', '+598 2201 2345', 'luis.ortega@outlook.com');
GO

INSERT INTO Gato (gatoNombre, gatoRaza, gatoEdad, gatoPeso, propietarioDocumento)
VALUES 
('Darius', 'Persa', 11, 8.2, '55525512'),
('Miau', 'Persa', 12, 5.2, '30240527'),
('Garfield', 'Exótico', 5, 8, '30240527'),
('Mish', 'Siames', 2, 4.5, '14406662'),
('Ginger', 'Mestizo', 3, 4.6, '53468374'),
('Missy', 'Exótico', 3, 6.1, '35569956'),
('Kitty', 'Manx', 3, 4.9, '56779790'),
('Nala', 'Siames', 2, 4.2, '30240527'),
('Leo', 'Abyssinian', 4, 5.3, '68047090'),
('Nina', 'British Shorthair', 2, 5.8, '53468374'),
('Loki', 'Esfinge', 2, 4, '55525512'),
('Oliver', 'Persa', 4, 5.8, '56779790'),
('Luna', 'Ragdoll', 3, 5.7, '60150754'),
('Oscar', 'Scottish Fold', 5, 7, '68047090'),
('Yuna', 'Maine Coon', 1, 6.8, '75984413'),
('Pelusa', 'Persa', 3, 5.2, '55525512'),
('Max', 'Exótico', 2, 5.9, '15450103'),
('Pepper', 'Cornish Rex', 2, 4.1, '75984413'),
('Maya', 'Somalí', 2, 4.7, '12345672'),
('Rocky', 'Siames', 5, 7.5, '60150754'),
('Milo', 'Maine Coon', 1, 7.2, '51953448'),
('Salem', 'Bombay', 4, 5.5, '15450103'),
('Shadow', 'Bombay', 3, 6.2, '12345672'),
('Simba', 'Bengalí', 2, 6, '14406662'),
('Alberto', 'Bengalí', 4, 7.1, '51953448'),
('Toby', 'Angora', 4, 4.8, '35569956'),
('Tom', 'Oriental', 4, 5.4, '30240527'),
('Zoe', 'Ragdoll', 1, 4.5, '53468374'),
('Bella', 'Birmano', 1, 4.4, '12345672'),
('Chloe', 'Siberiano', 5, 6.9, '51953448'),
('Cleo', 'Siames', 3, 4.3, '14406662'),
('Felix', 'Bengalí', 3, 6.5, '35569956');
GO

INSERT INTO Habitacion (habitacionNombre, habitacionCapacidad, habitacionPrecio, habitacionEstado) VALUES
('El Rascador', 3, 80, 'DISPONIBLE'),
('La Almohada', 2, 100, 'LLENA'),
('El Mirador', 4, 70, 'LIMPIANDO'),
('La Cueva', 2, 100, 'DISPONIBLE'),
('El Jardín', 6, 40, 'DISPONIBLE'),
('El Solarium', 1, 120, 'DISPONIBLE'),
('El Árbol', 5, 50, 'DISPONIBLE'),
('La Estantería', 7, 30, 'LLENA'),
('La Caja', 4, 70, 'DISPONIBLE');
GO


INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) VALUES
(31, 'La Caja', '2024-03-23', '2024-04-04', 910),
(32, 'El Rascador', '2024-07-23', '2024-08-01', 800),
(25, 'La Caja', '2023-03-23', '2023-04-04', 910),
(17, 'El Rascador', '2023-02-02', '2023-02-06', 400),
(30, 'La Caja', '2024-08-25', '2024-08-28', 280),
(6, 'El Mirador', '2023-04-07', '2023-04-17', 770),
(16, 'El Rascador', '2024-07-23', '2024-08-01', 800),
(21, 'El Rascador', '2022-05-25', '2022-06-01', 640),
(23, 'La Estantería', '2022-11-21', '2022-12-02', 360),
(5, 'El Árbol', '2023-06-24', '2023-06-25', 100),
(17, 'El Solarium', '2024-02-19', '2024-02-27', 1080),
(23, 'El Solarium', '2023-11-08', '2023-11-12', 600),
(4, 'La Caja', '2023-01-15', '2023-01-22', 560),
(2, 'La Cueva', '2023-10-12', '2023-10-22', 1100),
(8, 'La Caja', '2022-08-24', '2022-09-01', 630),
(4, 'La Caja', '2024-02-28', '2024-03-07', 630),
(8, 'El Jardín', '2024-02-11', '2024-02-14', 160),
(19, 'La Almohada', '2023-04-20', '2023-04-25', 600),
(15, 'La Caja', '2023-09-21', '2023-09-23', 210),
(28, 'El Mirador', '2024-01-04', '2024-01-15', 840),
(29, 'El Solarium', '2023-12-07', '2023-12-17', 1320),
(25, 'La Estantería', '2024-09-26', '2024-10-08', 390),
(7, 'La Cueva', '2023-06-25', '2023-07-03', 900),
(4, 'La Almohada', '2022-07-23', '2022-07-26', 400),
(10, 'La Cueva', '2023-06-17', '2023-06-20', 400),
(4, 'La Estantería', '2024-02-05', '2024-02-08', 120),
(7, 'El Rascador', '2024-08-24', '2024-08-26', 240),
(17, 'La Almohada', '2024-08-15', '2024-08-25', 1100),
(7, 'El Rascador', '2023-07-18', '2023-07-29', 960),
(2, 'La Cueva', '2023-05-25', '2023-05-26', 100),
(25, 'El Solarium', '2023-06-14', '2023-06-23', 1200),
(22, 'El Solarium', '2024-05-07', '2024-05-08', 240),
(7, 'La Caja', '2022-09-26', '2022-09-29', 280),
(18, 'La Caja', '2024-02-19', '2024-02-29', 770),
(16, 'El Solarium', '2023-08-22', '2023-08-28', 840),
(6, 'El Solarium', '2022-06-22', '2022-07-01', 1200),
(30, 'La Cueva', '2024-05-03', '2024-05-10', 800),
(9, 'El Rascador', '2022-09-04', '2022-09-08', 400),
(24, 'La Caja', '2023-07-07', '2023-07-18', 840),
(2, 'El Solarium', '2023-09-03', '2023-09-09', 840),
(10, 'El Rascador', '2022-12-09', '2022-12-11', 240),
(15, 'La Almohada', '2023-05-04', '2023-05-13', 1000),
(11, 'El Mirador', '2024-06-18', '2024-06-29', 840),
(24, 'La Cueva', '2023-08-31', '2023-09-10', 1100),
(7, 'La Estantería', '2024-08-19', '2024-08-27', 270),
(6, 'La Caja', '2024-09-07', '2024-09-11', 350),
(13, 'El Mirador', '2023-11-29', '2023-12-04', 420),
(25, 'El Jardín', '2023-06-27', '2023-07-02', 240),
(20, 'El Jardín', '2024-06-25', '2024-07-02', 320),
(16, 'El Solarium', '2024-08-16', '2024-08-26', 1320),
(27, 'La Estantería', '2022-10-25', '2022-11-03', 300),
(29, 'El Solarium', '2022-11-28', '2022-11-30', 360),
(7, 'La Caja', '2023-03-26', '2023-04-06', 840),
(12, 'El Solarium', '2023-01-25', '2023-02-01', 960),
(23, 'El Solarium', '2023-08-27', '2023-09-03', 960),
(7, 'La Almohada', '2023-11-21', '2023-11-22', 100),
(27, 'El Mirador', '2024-01-05', '2024-01-08', 280),
(13, 'La Estantería', '2023-01-09', '2023-01-10', 60);
GO

INSERT INTO Servicio (servicioNombre, servicioPrecio) VALUES
('CONTROL_PARASITOS', 35),
('REVISION_VETERINARIA', 50),
('PELUQUERIA', 30),
('BAÑO', 20),
('CORTE_DE_UNAS', 15),
('ALIMENTACION_ESPECIAL', 25),
('JUEGO_GUIADO', 10);
GO

INSERT INTO Reserva_Servicio(reservaID, servicioNombre, cantidad) VALUES
(17,'CONTROL_PARASITOS',1),
(17,'REVISION_VETERINARIA',3),
(17,'CORTE_DE_UNAS',2),
(17,'JUEGO_GUIADO',5),
(19,'PELUQUERIA',1),
(32,'PELUQUERIA',2),
(36,'PELUQUERIA',4),
(35,'JUEGO_GUIADO',3),
(43,'BAÑO',7),
(29,'ALIMENTACION_ESPECIAL',4),
(3,'PELUQUERIA',5),
(54,'PELUQUERIA',3),
(34,'ALIMENTACION_ESPECIAL',4),
(17,'ALIMENTACION_ESPECIAL',3),
(12,'JUEGO_GUIADO',7),
(53,'ALIMENTACION_ESPECIAL',3),
(29,'PELUQUERIA',2),
(11,'PELUQUERIA',1),
(45,'BAÑO',5),
(15,'PELUQUERIA',4),
(6,'JUEGO_GUIADO',8),
(10,'CORTE_DE_UNAS',4),
(41,'CONTROL_PARASITOS',6),
(6,'CONTROL_PARASITOS',6),
(54,'JUEGO_GUIADO',3),
(9,'PELUQUERIA',8),
(54,'ALIMENTACION_ESPECIAL',1),
(5,'ALIMENTACION_ESPECIAL',2),
(32,'BAÑO',4),
(47,'CORTE_DE_UNAS',2),
(49,'PELUQUERIA',8),
(55,'PELUQUERIA',3),
(43,'CONTROL_PARASITOS',3),
(20,'ALIMENTACION_ESPECIAL',3),
(25,'CONTROL_PARASITOS',2),
(18,'JUEGO_GUIADO',6),
(40,'CONTROL_PARASITOS',2),
(35,'ALIMENTACION_ESPECIAL',2),
(32,'ALIMENTACION_ESPECIAL',2),
(17,'BAÑO',3),
(11,'REVISION_VETERINARIA',8),
(17,'PELUQUERIA',2),
(7,'CORTE_DE_UNAS',7),
(27,'JUEGO_GUIADO',5),
(11,'ALIMENTACION_ESPECIAL',2),
(41,'CORTE_DE_UNAS',6),
(48,'CONTROL_PARASITOS',1),
(22,'JUEGO_GUIADO',6),
(42,'JUEGO_GUIADO',6),
(43,'ALIMENTACION_ESPECIAL',8),
(9,'BAÑO',3),
(44,'CORTE_DE_UNAS',6);

GO

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

GO


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

GO


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

GO


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
