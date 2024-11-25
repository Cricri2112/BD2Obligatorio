show databases

use CatHotel

db.createCollection("reservas",{})
db.createCollection("propietarios", {})
db.createCollection("gatos", {})
db.createCollection("habitaciones",{})


db.propietarios.insertMany([
  { propietarioDocumento: '12345678', propietarioNombre: 'Alejandro Torres', propietarioTelefono: '+598 91 234 567', propietarioEmail: 'alejandro.torres@gmail.com' },
  { propietarioDocumento: '51953448', propietarioNombre: 'Beatriz Mendoza', propietarioTelefono: '+598 92 345 678', propietarioEmail: 'beatriz.mendoza@hotmail.com' },
  { propietarioDocumento: '55525512', propietarioNombre: 'Inés Romero', propietarioTelefono: '+598 99 012 345', propietarioEmail: 'ines.romero@outlook.com' },
  { propietarioDocumento: '60150754', propietarioNombre: 'Karina Paredes', propietarioTelefono: '+598 2623 4567' } 
])


db.gatos.insertMany([
  { gatoNombre: 'Darius', gatoRaza: 'Persa', gatoEdad: 11, gatoPeso: 8.2, propietarioDocumento: '55525512' },
  { gatoNombre: 'Luna', gatoRaza: 'Ragdoll', gatoEdad: 3, gatoPeso: 5.7, propietarioDocumento: '12345678' },
  { gatoNombre: 'Chloe', gatoRaza: 'Siberiano', gatoEdad: 5, gatoPeso: 6.9, propietarioDocumento: '51953448' },
  { gatoNombre: 'Cleo', gatoRaza: 'Siames', gatoEdad: 3, gatoPeso: 4.3, propietarioDocumento: '12345678' },
  { gatoNombre: 'Felix', gatoRaza: 'Bengalí', gatoEdad: 3, gatoPeso: 6.5, propietarioDocumento: '60150754' }
])

db.habitaciones.insertMany([
  { habitacionNombre: 'El Rascador', habitacionCapacidad: 3, habitacionPrecio: 80, habitacionEstado: 'DISPONIBLE' },
  { habitacionNombre: 'Suite1', habitacionCapacidad: 1, habitacionPrecio: 120, habitacionEstado: 'DISPONIBLE' },
  { habitacionNombre: 'La Estantería', habitacionCapacidad: 7, habitacionPrecio: 30, habitacionEstado: 'LLENA' },
  { habitacionNombre: 'La Caja', habitacionCapacidad: 4, habitacionPrecio: 70, habitacionEstado: 'DISPONIBLE' }
])

db.reservas.insertMany([
    {
        gato : {
            nombre : 'Luna',
            propietarioDocumento : '12345678',
            propietarioNombre: 'Alejandro Torres'
        },
        habitacionNombre: 'La Caja',
        estadia : {
            fechaInicio:'2024-11-23',
            fechaFin:'2024-12-04'
        },
        monto: 840,
        serviciosContratados: [
            {
                nombre: 'PELUQUERIA',
                cantidad: 1,
                precio: 25
            },
            {
                nombre: 'BAÑO',
                cantidad: 1,
                precio:20
            }
        ],
        montoTotal: 885,
        resenia: 'Muy buen trabajao con el servicio de peluquería, mi gata quedó hermosa'
    },
    {
        gato : {
            nombre : 'Luna',
            propietarioDocumento : '12345678',
            propietarioNombre: 'Alejandro Torres'
        },
        habitacionNombre: 'La Caja',
        estadia : {
            fechaInicio:'2024-07-23',
            fechaFin:'2024-07-25'
        },
        monto: 210,
        serviciosContratados: [
            {
                nombre: 'BAÑO',
                cantidad: 1,
                precio:20
            }
        ],
        montoTotal: 230,
        resenia: 'Mi gata estuvo en buenas manos'
    },
     {
        gato : {
            nombre : 'Felix',
            propietarioDocumento : '60150754',
            propietarioNombre: 'Karina Paredes'
        },
        habitacionNombre: 'El Rascador',
        estadia : {
            fechaInicio:'2024-03-23',
            fechaFin: '2024-04-04'
        },
        monto: 1040,
        serviciosContratados: [
            {
                nombre: 'PELUQUERIA',
                cantidad: 5,
                precio: 125
            },
            {
                nombre: 'CONTROL_PARASITOS',
                cantidad: 1,
                precio:50
            }
        ],
        montoTotal: 1215
    },
     {
        gato : {
            nombre : 'Cleo',
            propietarioDocumento : '12345678',
            propietarioNombre: 'Alejandro Torres'
        },
        habitacionNombre: 'La Estanteria',
        estadia : {
            fechaInicio:'2024-07-01',
            fechaFin:'2024-07-10'
        },
        serviciosContratados: [
            {
                nombre: 'ALIMENTACION_ESPECIAL',
                cantidad: 7,
                precio: 175
            }
            
        ],
        montoTotal: 475,
    },
    {
        gato : {
            nombre : 'Darius',
            propietarioDocumento : '55525512',
            propietarioNombre: 'Ines Romero'
        },
        habitacionNombre: 'Suite1',
        estadia : {
            fechaInicio:'2024-11-15',
            fechaFin:'2024-11-30'
        },
        serviciosContratados: [
            {
                nombre: 'ALIMENTACION_ESPECIAL',
                cantidad: 7,
                precio: 175
            }
            
        ],
        montoTotal: 2095,
        propietarioSatisfecho : true
    }
    
])

/*
B. Listar reservas del propietario con documento "12345678" 
*/

db.reservas.find({
   "gato.propietarioDocumento": "12345678"
    }
)

/*
C. Listar las reservas que incluyen el servicio "PELUQUERIA " 
*/

db.reservas.find({
    "serviciosContratados.nombre" : "PELUQUERIA"
    }
)

/*
D. Actualizar el estado de la habitación "Suite1" asegurándose que está en estado "DISPONIBLE" 
y pasándolo a estado "LLENA" 
*/

db.habitaciones.update(
    {habitacionNombre: "Suite1" , habitacionEstado : "DISPONIBLE"},
    {$set: {"habitacionEstado":"LLENA"}}
)

/*
E. Listar nombre de propietario y cantidad de reservas con fecha de inicio en julio 2024, para los 
propietarios que tengan más de una reserva en ese mes 
*/

db.reservas.aggregate(
    {
        $match: {"estadia.fechaInicio" :{
            $gte: "2024-07-01", 
            $lt: "2024-08-01"
        }}
    },
    {$group: { _id: "$gato.propietarioNombre", count:{$sum:1} }},
    {
        $match: {
            count:{$gt:1}
        }
    }
)







