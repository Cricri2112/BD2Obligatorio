USE CatHotel



--3. Utilizando SQL implementar las siguientes consultas:
--a. Mostrar el nombre del gato, el nombre del propietario, la habitaci�n y el monto de la reserva m�s reciente en la(s) habitaci�n con la capacidad m�s alta

SELECT TOP 1 g.gatoNombre, p.propietarioNombre, h.habitacionNombre, r.reservaMonto
FROM Gato g, Propietario p, Reserva r, Habitacion h
WHERE g.propietarioDocumento = p.propietarioDocumento and 
      g.gatoID = r.gatoID and 
	  r.habitacionNombre = h.habitacionNombre and
	  h.habitacionCapacidad = (
	      SELECT MAX(h2.habitacionCapacidad)
		  FROM Habitacion h2
	  )
ORDER BY r.reservaFechaInicio DESC

--b. Mostrar los 3 servicios m�s solicitados, con su nombre, precio y cantidad total solicitada en el a�o anterior. Solo listar el servicio si cumple que tiene una cantidad total solicitada mayor o igual que 5

SELECT TOP 3 s.servicioNombre, s.servicioPrecio, SUM(rs.cantidad) AS CantidadSolicitada
FROM Servicio s, Reserva_Servicio rs, Reserva r
WHERE rs.reservaID = r.reservaID and
	  rs.servicioNombre = s.servicioNombre and
	  YEAR(r.reservaFechaInicio) = YEAR(GETDATE())-1
GROUP BY s.servicioNombre, s.servicioPrecio
HAVING SUM(rs.cantidad) >= 5
ORDER BY CantidadSolicitada DESC


--c. Listar nombre de gato y nombre de habitaci�n para las reservas que tienen asociados todos los servicios adicionales disponibles

SELECT g.gatoNombre, r.habitacionNombre
FROM Gato g, Reserva r, Reserva_Servicio rs
WHERE g.gatoID = r.gatoID and
	  rs.reservaID = r.reservaID	  
GROUP BY g.gatoNombre, r.habitacionNombre
HAVING COUNT(DISTINCT(rs.servicioNombre)) = (SELECT COUNT(servicioNombre) FROM Servicio)

--d. Listar monto total de reserva por a�o y por gato (nombre) para los gatos que tienen m�s de 10 a�os de edad, son de raza "Persa" y que en el a�o tuvieron montos total de reserva superior a 500 d�lares.

SELECT g.gatoNombre, SUM(r.reservaMonto) AS [Monto total]
FROM Gato g
JOIN Reserva r ON r.gatoID = g.gatoID
WHERE g.gatoEdad > 10 AND
	  g.gatoRaza = 'Persa' AND
	  YEAR(r.reservaFechaInicio) = YEAR(GETDATE())
GROUP BY g.gatoNombre
HAVING SUM(r.reservaMonto) > 500

--e. Mostrar el ranking de reservas m�s caras, tomando como monto total de una reserva el monto propio de la reserva m�s los servicios adicionales contratados en la reserva

SELECT TOP 10 r.gatoID, r.habitacionNombre, r.reservaFechaInicio, r.reservaFechaFin, r.reservaID, (
			SELECT (SUM(rs2.cantidad*s2.servicioPrecio))
			FROM Reserva_Servicio rs2
			JOIN Servicio s2 ON s2.servicioNombre = rs2.servicioNombre
			WHERE rs2.reservaID = r.reservaID)+ r.reservaMonto AS TotalPorReservaYServicio
FROM Reserva r
JOIN Reserva_Servicio rs ON rs.reservaID = r.reservaID
JOIN Servicio s ON rs.servicioNombre = s.servicioNombre
GROUP BY r.gatoID, r.habitacionNombre, r.reservaFechaInicio, r.reservaFechaFin, r.reservaID, r.reservaMonto
ORDER BY TotalPorReservaYServicio  DESC


--f. Calcular el promedio de duraci�n en d�as de las reservas realizadas durante el a�o en curso. Deben ser consideradas solo aquellas reservas en las que se contrat� el servicio "CONTROL_PARASITOS" pero no se contrat� el servicio "REVISION_VETERINARIA"

SELECT AVG(DATEDIFF(DAY,r.reservaFechaInicio, r.reservaFechaFin)) AS PromedioDiasReserva
FROM Reserva r
JOIN Reserva_Servicio rs ON rs.reservaID = r.reservaID
WHERE YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) AND
	  rs.servicioNombre = 'CONTROL_PARASITOS' AND 
	  r.reservaID NOT IN (					
						SELECT reservaID
						FROM Reserva_Servicio 
						WHERE servicioNombre = 'REVISION_VETERINARIA' AND
							  YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) 	
						)

--g. Para cada habitaci�n, listar su nombre, la cantidad de d�as que ha estado ocupada y la cantidad de d�as transcurridos desde la fecha de inicio de la primera reserva en el hotel. Adem�s, incluir una columna adicional que indique la categor�a de rentabilidad, asignando el valor "REDITUABLE" si la habitaci�n estuvo ocupada m�s del 60% de los d�as, "MAGRO" si estuvo ocupada entre el 40% y el 60%, y "NOESNEGOCIO" si estuvo ocupada menos del 40%.

SELECT h.habitacionNombre, SUM(DATEDIFF(DAY,r.reservaFechaInicio, r.reservaFechaFin)) AS DiasOcupada, (
	   DATEDIFF(DAY,MIN(r.reservaFechaInicio),GETDATE())) AS DiasDesdeInicio ,
	   CASE
		WHEN (SUM(DATEDIFF(DAY,r.reservaFechaInicio, r.reservaFechaFin)) / DATEDIFF(DAY,MIN(r.reservaFechaInicio),GETDATE()) ) >= 0.6 THEN 'REDITUABLE'
		WHEN (SUM(DATEDIFF(DAY,r.reservaFechaInicio, r.reservaFechaFin)) / DATEDIFF(DAY,MIN(r.reservaFechaInicio),GETDATE()) ) >= 0.4 THEN 'MAGRO'
		ELSE 'NOESNEGOCIO'
	    END

FROM Habitacion h
JOIN Reserva r ON r.habitacionNombre = h.habitacionNombre
GROUP BY h.habitacionNombre


