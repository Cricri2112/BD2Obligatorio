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