
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
