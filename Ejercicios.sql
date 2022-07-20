-- Views:

-- 2. a) Crear una vista que devuelva un resumen con el apellido y nombre (en una
-- sola columna denominada “artista”) de los artistas y la cantidad de
-- filmaciones que tienen. Traer solo aquellos que tengan más de 25
-- filmaciones y ordenarlos por apellido.
create view vw_artistas_cantidad_peliculas as
select concat(actor.first_name, ' ',actor.last_name) as Artista, 
count(film_actor.film_id) as CantidadPeliculas from actor
join film_actor on actor.actor_id = film_actor.actor_id
join film on film_actor.film_id = film.film_id
group by actor.actor_id
having count(film_actor.film_id) > 25
order by actor.last_name;

-- b) Invocar la vista creada.
select * from vw_artistas_cantidad_peliculas;

-- c) En la misma invocación de la vista, traer aquellos artistas que tienen
-- menos de 33 filmaciones.
select * from vw_artistas_cantidad_peliculas
where CantidadPeliculas > 33;

-- Reportes - JOINS

-- 7. Obtener aquellas películas que tengan asignado uno o más artistas, incluso
-- aquellas que aún no le han asignado un artista en nuestra base de datos.
select film.title, actor.first_name, actor.last_name from film
left join film_actor on film.film_id = film_actor.film_id
left join actor on film_actor.actor_id = actor.actor_id
-- where actor.actor_id is null
group by film.title, actor.actor_id;

-- 17. Listar la cantidad de reservas que se realizaron para los vuelos que el origen ha
-- sido de Argentina o Colombia, en el horario de las 18hs. Mostrar la cantidad de
-- vuelos y país de origen.
select vuelos.origen, count(vuelos.idvuelo) from vuelosxreserva
inner join vuelos on vuelosxreserva.idVuelo = vuelos.idvuelo
inner join reservas on vuelosxreserva.idreserva = reservas.idreserva
where hour(vuelos.fechapartida) = 18 and 
(vuelos.origen like '%Argentina%' or vuelos.origen like '%Colombia%')
group by vuelos.origen;

-- 18. Listar el usuario brasilero con más reacciones durante el 2021.
select usuario.nombre, count(*) from usuario
inner join pais on usuario.Pais_idPais = pais.idPais
inner join reaccion on usuario.idUsuario = reaccion.Usuario_idUsuario
where pais.nombre like '%brasil%' and year(reaccion.fecha) = 2021
group by usuario.nombre
order by count(*) desc;

-- stored procedure
DELIMITER $$
CREATE PROCEDURE sp_cantidad_productos(IN filtro_categoria VARCHAR(15), OUT cantidad INT)
BEGIN
SELECT count(*) INTO cantidad FROM productos p
JOIN categorias C ON p.CategoriaID = c.CategoriaID
WHERE CategoriaNombre = filtro_categoria;
END $$

CALL sp_cantidad_productos('Seafood', @cant_seafood);
SELECT @cant_seafood;

-- ---------

-- Solo los 10 primeros caracteres del nombre de la canción en mayúscula.
-- Los años de antigüedad que tiene cada canción desde su publicación. Ej: 25 años. 
-- El peso en KBytes en número entero (sin decimales, 1024 Bytes = 1 KB)
-- El precio formateado con 3 decimales, Ej: $100.123
-- El primer compositor de la canción (notar que si hay más de uno, estos se separan por coma)
select  upper(left(nombre, 10)) as Canciones, 
		concat(truncate((datediff(now(), publicada) / 365),0), ' anios') as Anios,
		-- timestampdiff(year, publicada, now())
		round((bytes / 1024),0) as KB,
        concat('$ ',(format(precio_unitario, 3))) as Precio,
        (case when compositor is null or compositor = '' then '<Sin Datos>'
			  when compositor not like '%,%' then compositor
              else left(compositor, (locate(',', compositor)) - 1)
              end) as Compositor
from canciones;