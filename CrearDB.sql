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
('La Almohada', 2, 100, 'DISPONIBLE'),
('El Mirador', 4, 70, 'DISPONIBLE'),
('La Cueva', 2, 100, 'DISPONIBLE'),
('El Jardín', 6, 40, 'DISPONIBLE'),
('El Solarium', 1, 120, 'DISPONIBLE'),
('El Árbol', 5, 50, 'DISPONIBLE'),
('La Estantería', 7, 30, 'DISPONIBLE'),
('La Caja', 4, 70, 'DISPONIBLE');
GO


INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) VALUES
(24,'La Caja','2023-07-07','2023-07-18',840),
(7,'El Rascador','2023-07-18','2023-07-29',960),
(16,'El Solarium','2023-08-22','2023-08-28',840),
(23,'El Solarium','2023-08-27','2023-09-03',960),
(24,'La Cueva','2023-08-31','2023-09-10',1100),
(2,'El Solarium','2023-09-03','2023-09-09',840),
(15,'La Caja','2023-09-21','2023-09-23',210),
(2,'La Cueva','2023-10-12','2023-10-22',1100),
(23,'El Solarium','2023-11-08','2023-11-12',600),
(7,'La Almohada','2023-11-21','2023-11-22',200),
(13,'El Mirador','2023-11-29','2023-12-04',420),
(29,'El Solarium','2023-12-07','2023-12-17',1320),
(28,'El Mirador','2024-01-04','2024-01-15',840),
(27,'El Mirador','2024-01-05','2024-01-08',280),
(4,'La Estantería','2024-02-05','2024-02-08',120),
(8,'El Jardín','2024-02-11','2024-02-14',160),
(17,'El Solarium','2024-02-19','2024-02-27',1080),
(18,'La Caja','2024-02-19','2024-02-29',770),
(4,'La Caja','2024-02-28','2024-03-07',630),
(31,'La Caja','2024-03-23','2024-04-04',910),
(30,'La Cueva','2024-05-03','2024-05-10',800),
(22,'El Solarium','2024-05-07','2024-05-08',240),
(11,'El Mirador','2024-06-18','2024-06-29',840),
(20,'El Jardín','2024-06-25','2024-07-02',320),
(32,'El Rascador','2024-07-23','2024-08-01',800),
(16,'El Rascador','2024-07-23','2024-08-01',800),
(17,'La Almohada','2024-08-15','2024-08-25',1100),
(16,'El Solarium','2024-08-16','2024-08-26',1320),
(7,'La Estantería','2024-08-19','2024-08-27',270),
(7,'El Rascador','2024-08-24','2024-08-26',240),
(30,'La Caja','2024-08-25','2024-08-28',280),
(6,'La Caja','2024-09-07','2024-09-11',350),
(25,'La Estantería','2024-09-26','2024-10-08',390),
(1,'La Estantería','2024-10-01','2024-10-04',120),
(2,'La Almohada','2024-10-10','2024-10-25',1600),
(1,'El Rascador','2023-01-10','2023-01-17',640),
(1,'El Solarium','2023-01-15','2023-01-20',720),
(9,'El Árbol','2023-01-15','2023-01-22',400),
(2,'La Almohada','2023-02-05','2023-02-10',600),
(2,'El Mirador','2023-02-05','2023-02-12',560),
(10,'El Jardín','2023-02-10','2023-02-17',320),
(3,'La Caja','2023-03-01','2023-03-08',560),
(11,'La Estantería','2023-03-05','2023-03-12',240),
(3,'La Cueva','2023-03-12','2023-03-18',700),
(4,'El Rascador','2023-04-01','2023-04-07',560),
(12,'El Solarium','2023-04-15','2023-04-22',960),
(4,'El Árbol','2023-04-15','2023-04-22',400),
(13,'La Almohada','2023-05-05','2023-05-12',800),
(5,'El Jardín','2023-05-05','2023-05-12',320),
(5,'El Mirador','2023-05-10','2023-05-15',420),
(14,'La Cueva','2023-06-01','2023-06-08',800),
(6,'La Estantería','2023-06-01','2023-06-08',240),
(6,'La Caja','2023-06-20','2023-06-25',420),
(7,'El Árbol','2023-07-05','2023-07-12',400),
(15,'El Rascador','2023-07-10','2023-07-17',640),
(7,'El Solarium','2023-07-10','2023-07-17',960),
(8,'El Jardín','2023-08-01','2023-08-08',320),
(8,'La Almohada','2023-08-15','2023-08-22',800),
(16,'El Mirador','2023-08-20','2023-08-27',560),
(1,'La Caja','2023-09-05','2023-09-12',560),
(9,'La Estantería','2023-09-15','2023-09-22',240),
(10,'El Solarium','2023-10-10','2023-10-17',960),
(2,'El Árbol','2023-10-15','2023-10-22',400),
(3,'El Jardín','2023-11-01','2023-11-08',320),
(11,'La Almohada','2023-11-05','2023-11-12',800),
(12,'La Cueva','2023-12-01','2023-12-08',800),
(4,'La Estantería','2023-12-05','2023-12-12',240),
(13,'El Rascador','2024-01-05','2024-01-10',480),
(5,'El Solarium','2024-01-15','2024-01-22',960),
(14,'El Mirador','2024-02-01','2024-02-06',420),
(6,'La Almohada','2024-02-05','2024-02-12',800),
(15,'La Caja','2024-03-01','2024-03-08',560),
(7,'La Cueva','2024-03-01','2024-03-08',800),
(16,'El Árbol','2024-04-10','2024-04-15',300),
(8,'El Rascador','2024-04-15','2024-04-22',640),
(9,'El Mirador','2024-05-05','2024-05-12',560),
(1,'El Jardín','2024-05-20','2024-05-25',240),
(10,'La Caja','2024-06-01','2024-06-08',560),
(2,'La Estantería','2024-06-10','2024-06-18',270),
(3,'El Solarium','2024-07-01','2024-07-08',960),
(11,'El Árbol','2024-07-10','2024-07-17',400),
(4,'La Almohada','2024-08-15','2024-08-22',800),
(12,'El Jardín','2024-08-15','2024-08-22',320),
(13,'La Estantería','2024-09-01','2024-09-08',240),
(5,'La Cueva','2024-09-10','2024-09-17',800),
(6,'El Rascador','2024-10-05','2024-10-12',640),
(14,'El Solarium','2024-10-05','2024-10-12',960),
(7,'El Mirador','2024-11-01','2024-11-07',490),
(15,'La Almohada','2024-11-01','2024-11-07',700),
(8,'La Caja','2024-12-01','2024-12-07',490),
(16,'La Cueva','2024-12-01','2024-12-08',800);
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
(3,'PELUQUERIA',5),
(5,'ALIMENTACION_ESPECIAL',2),
(6,'CONTROL_PARASITOS',6),
(6,'JUEGO_GUIADO',8),
(7,'CORTE_DE_UNAS',7),
(9,'BAÑO',3),
(9,'PELUQUERIA',8),
(10,'CORTE_DE_UNAS',4),
(11,'ALIMENTACION_ESPECIAL',2),
(11,'PELUQUERIA',1),
(11,'REVISION_VETERINARIA',8),
(12,'JUEGO_GUIADO',7),
(15,'PELUQUERIA',4),
(17,'ALIMENTACION_ESPECIAL',3),
(17,'BAÑO',3),
(17,'CONTROL_PARASITOS',1),
(17,'CORTE_DE_UNAS',2),
(17,'JUEGO_GUIADO',5),
(17,'PELUQUERIA',2),
(17,'REVISION_VETERINARIA',3),
(18,'JUEGO_GUIADO',6),
(19,'PELUQUERIA',1),
(20,'ALIMENTACION_ESPECIAL',3),
(22,'JUEGO_GUIADO',6),
(25,'CONTROL_PARASITOS',2),
(27,'JUEGO_GUIADO',5),
(29,'ALIMENTACION_ESPECIAL',4),
(29,'PELUQUERIA',2),
(32,'ALIMENTACION_ESPECIAL',2),
(32,'BAÑO',4),
(32,'PELUQUERIA',2),
(34,'ALIMENTACION_ESPECIAL',4),
(35,'ALIMENTACION_ESPECIAL',2),
(35,'JUEGO_GUIADO',3),
(36,'PELUQUERIA',4),
(40,'CONTROL_PARASITOS',2),
(41,'CONTROL_PARASITOS',6),
(41,'CORTE_DE_UNAS',6),
(42,'JUEGO_GUIADO',6),
(43,'ALIMENTACION_ESPECIAL',8),
(43,'BAÑO',7),
(43,'CONTROL_PARASITOS',3),
(44,'CORTE_DE_UNAS',6),
(45,'BAÑO',5),
(47,'CORTE_DE_UNAS',2),
(48,'CONTROL_PARASITOS',1),
(49,'PELUQUERIA',8),
(53,'ALIMENTACION_ESPECIAL',3),
(54,'ALIMENTACION_ESPECIAL',1),
(54,'JUEGO_GUIADO',3),
(54,'PELUQUERIA',3),
(55,'PELUQUERIA',3),
(60,'ALIMENTACION_ESPECIAL',2),
(60,'BAÑO',1),
(61,'CONTROL_PARASITOS',1),
(61,'JUEGO_GUIADO',3),
(62,'PELUQUERIA',1),
(62,'CORTE_DE_UNAS',2),
(63,'REVISION_VETERINARIA',1),
(64,'ALIMENTACION_ESPECIAL',3),
(65,'JUEGO_GUIADO',2),
(65,'PELUQUERIA',1),
(66,'CONTROL_PARASITOS',1),
(67,'CORTE_DE_UNAS',2),
(68,'REVISION_VETERINARIA',1),
(69,'ALIMENTACION_ESPECIAL',2),
(69,'BAÑO',1),
(70,'CONTROL_PARASITOS',3),
(71,'JUEGO_GUIADO',1),
(72,'PELUQUERIA',1),
(73,'ALIMENTACION_ESPECIAL',4),
(74,'REVISION_VETERINARIA',2),
(75,'JUEGO_GUIADO',3),
(76,'CORTE_DE_UNAS',2),
(77,'CONTROL_PARASITOS',1),
(77,'PELUQUERIA',2),
(78,'ALIMENTACION_ESPECIAL',3),
(79,'REVISION_VETERINARIA',1),
(80,'JUEGO_GUIADO',2),
(81,'BAÑO',1),
(81,'CONTROL_PARASITOS',1),
(82,'PELUQUERIA',2),
(83,'CORTE_DE_UNAS',1),
(84,'JUEGO_GUIADO',1),
(85,'REVISION_VETERINARIA',3),
(86,'ALIMENTACION_ESPECIAL',2),
(86,'BAÑO',1),
(87,'CONTROL_PARASITOS',4),
(88,'PELUQUERIA',1),
(89,'JUEGO_GUIADO',2),
(90,'REVISION_VETERINARIA',1),
(90,'CORTE_DE_UNAS',1),
(91,'ALIMENTACION_ESPECIAL',3);
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
