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
--Falta verificar habitacion con la capacidad m�s alta

--b. Mostrar los 3 servicios m�s solicitados, con su nombre, precio y cantidad total solicitada en el a�o anterior. Solo listar el servicio si cumple que tiene una cantidad total solicitada mayor o igual que 5

SELECT TOP 3 s.servicioNombre, s.servicioPrecio, SUM(rs.cantidad) 
FROM Servicio s, Reserva_Servicio rs, Reserva r
WHERE rs.reservaID = r.reservaID and
	  rs.servicioNombre = s.servicioNombre and
	  YEAR(r.reservaFechaInicio) = YEAR(GETDATE())-1
GROUP BY s.servicioNombre, s.servicioPrecio
HAVING SUM(rs.cantidad) >= 5


--c. Listar nombre de gato y nombre de habitaci�n para las reservas que tienen asociados todos los servicios adicionales disponibles

SELECT g.gatoNombre, h.habitacionNombre
FROM Gato g, Habitacion h, Reserva r, Reserva_Servicio rs, Servicio s
WHERE g.gatoID = r.gatoID and
	  r.habitacionNombre = h.habitacionNombre and
	  rs.reservaID = r.reservaID and
	  rs.servicioNombre = s.servicioNombre 
GROUP BY g.gatoNombre, h.habitacionNombre
HAVING COUNT(DISTINCT(rs.servicioNombre)) = 
	   (SELECT COUNT(servicioNombre) FROM Servicio)


--d. Listar monto total de reserva por a�o y por gato (nombre) para los gatos que tienen m�s de 10 a�os de edad, son de raza "Persa" y que en el a�o tuvieron montos total de reserva superior a 500 d�lares.

--e. Mostrar el ranking de reservas m�s caras, tomando como monto total de una reserva el monto propio de la reserva m�s los servicios adicionales contratados en la reserva

--f. Calcular el promedio de duraci�n en d�as de las reservas realizadas durante el a�o en curso. Deben ser consideradas solo aquellas reservas en las que se contrat� el servicio "CONTROL_PARASITOS" pero no se contrat� el servicio "REVISION_VETERINARIA"

--g. Para cada habitaci�n, listar su nombre, la cantidad de d�as que ha estado ocupada y la cantidad de d�as transcurridos desde la fecha de inicio de la primera reserva en el hotel. Adem�s, incluir una columna adicional que indique la categor�a de rentabilidad, asignando el valor "REDITUABLE" si la habitaci�n estuvo ocupada m�s del 60% de los d�as, "MAGRO" si estuvo ocupada entre el 40% y el 60%, y "NOESNEGOCIO" si estuvo ocupada menos del 40%.









/* 2. Para cada equipo en cuyo nombre aparece la palabra �FC�, mostrar su c�digo, nombre, cantidad de partidos
jugados de local, cantidad de goles marcados en dichos partidos y la fecha del �ltimo partido de local, ordene los
resultados por goles de mayor a menor, debe respetar el siguiente resultado: */

--SELECT e.codEquipo, 
--	   e.nomEquipo,
--	   COUNT(p.codEquipo_local) AS CantPartidosLocal,
--	   SUM(p.GL) AS GolesLocal,
--	   MAX(p.fecha) AS FechaUltimoPartido
--FROM Equipo e, Partido p
--WHERE e.codEquipo = p.codEquipo_local and 
--	  e.nomEquipo like '%FC%'
--GROUP BY e.codEquipo, e.nomEquipo
--ORDER BY GolesLocal DESC;



/* 7. Mostrar los nombres de los equipos de regi�n sur o de regi�n norte que jugaron mas de 2 partidos en canchas de
m�s de 2000 espectadores (tener en cuenta cuando fue local y cuando fue visitante). */

--SELECT e.nomEquipo	   
--FROM Equipo e, Partido p, Cancha c
--WHERE (p.codEquipo_local = e.codEquipo or p.codEquipo_visita = e.codEquipo) and 
--	  p.nomCancha = c.nomCancha	and 
--	  (e.regionEquipo = 'Sur' or e.regionEquipo = 'Norte') and 
--	  c.capCancha > 2000
--GROUP BY e.nomEquipo
--HAVING count(p.fecha) > 2