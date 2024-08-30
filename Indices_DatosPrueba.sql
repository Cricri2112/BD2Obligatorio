USE CatHotel

CREATE INDEX idx_PropietarioGato ON Gato (propietarioDocumento)

CREATE INDEX idx_GatoReserva ON Reserva (gatoID)

CREATE INDEX idx_HabitacionReserva ON Reserva (habitacionNombre)
