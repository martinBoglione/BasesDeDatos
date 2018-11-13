--Martin Boglione
--Tp Sql

--3.2
--1
CREATE TABLE carrera
			  (id SERIAL PRIMARY KEY,
			   nombre VARCHAR(200));
										
CREATE TABLE usuario 
			  (id SERIAL PRIMARY KEY,
			   nombre VARCHAR(100),
			   apellido VARCHAR(100),
			   username VARCHAR(30),
			   contrasenia VARCHAR(100),
			   fecha_nacimiento DATE,
			   email VARCHAR(50),
			   id_carrera  INT, 
			   CONSTRAINT carrera_fk FOREIGN KEY (id_carrera) REFERENCES carrera(id));
			   
CREATE TABLE grupo 
			 (id SERIAL PRIMARY KEY,
			  nombre_grupo VARCHAR(100),
			  requiere_invitacion BOOL);	
																				 
CREATE TABLE grupo_usuario
		     (id_grupo INT,
			  id_user INT,
			  CONSTRAINT grupos_usuario_pk PRIMARY KEY(id_grupo,id_user),
			  CONSTRAINT grupo_fk FOREIGN KEY (id_grupo) REFERENCES grupo(id),
			  CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id));
			  
CREATE TABLE publicacion
			  (id SERIAL PRIMARY KEY,
			   id_user INT,
			   id_grupo INT,
			   titulo VARCHAR(200),
			   contenido VARCHAR(200),
			   fecha_publicacion TIMESTAMP,
			   CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id),
			   CONSTRAINT grupo_fk FOREIGN KEY (id_grupo) REFERENCES grupo(id));

CREATE TABLE comentario 
			   (id SERIAL PRIMARY KEY,
			    id_public INT,
			    id_user INT,
			    contenido VARCHAR(200),
			    fecha_comentario TIMESTAMP,
				CONSTRAINT publicacion_fk FOREIGN KEY (id_public) REFERENCES publicacion(id),
			    CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id));
																		   
CREATE TABLE like_publicacion
			(id_public INT,
			 id_user INT,
			 positivo BOOL,
			 fecha TIMESTAMP,
			 CONSTRAINT like_publicacion_pk PRIMARY KEY(id_public,id_user),
			 CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id));
			 CONSTRAINT publicacion_fk FOREIGN KEY (id_public) REFERENCES publicacion(id)
																			
CREATE TABLE like_comentario
			  (id_coment INT,
			   id_user INT,
			   positivo BOOL,
			   fecha TIMESTAMP,
			   CONSTRAINT like_comentario_pk PRIMARY KEY(id_coment,id_user),
			   CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id));
			   CONSTRAINT comentario_fk FOREIGN KEY (id_coment) REFERENCES comentario(id)														 
											
--2
ALTER TABLE usuario
DROP COLUMN id_carrera
																			  
CREATE TABLE carrera_usuario
		      (id_carrera INT,
			   id_user INT,
			  CONSTRAINT carrera_usuario_pk PRIMARY KEY(id_user,id_carrera),
			  CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id),
			  CONSTRAINT carrera_fk FOREIGN KEY (id_carrera) REFERENCES carrera(id));
																				
--3
INSERT INTO usuario
			(nombre,apellido,username,contrasenia,fecha_nacimiento)
	VALUES
			('Matias','Silvestre','canapedemondongo','Dal41lama','2000-11-9');
																				
--La carrera no se encuentra en la base de datos, entonces la inserté.
--No es necesario insertarla antes de crear el usuario.											
INSERT INTO carrera
    VALUES (1, 'Tecnicatura en Programación');

--El usuario 1(Matias Silvestre) está cursando la carrera 1(Tecnicatura en programacición)																				
INSERT INTO carrera_usuario
	VALUES (1,1);
								
																				
--4
--Inserté el set de datos provisto en el archivo datos_unqfaces.sql en otro query(Boglione_Martin_datos.sql)
																				
--5																				 																			 																				  
SELECT nombre, COUNT(id_user) AS cant_alu
FROM carrera_usuario JOIN carrera ON carrera_usuario.id_carrera = carrera.id
GROUP BY nombre 																				  
ORDER BY length(nombre) DESC	
																				
--6 prueba
SELECT username,nombre,apellido
FROM (publicacion JOIN usuario ON publicacion.id_user = usuario.id)																	
													
																				
SELECT id_public,COUNT(positivo)
FROM like_publicacion
WHERE positivo = TRUE																		
GROUP BY id_public
HAVING COUNT(positivo) > 10		
																				

SELECT id_coment																				
FROM like_comentario
WHERE positivo = TRUE
GROUP BY id_coment

--7
																				
																				
--8			
--si la fecha_nacimiento es menor a 01/01/2002 significa que los usuarios del grupo tienen mas de 16 anios(teniendo en cuenta que la fecha actual es 2018)	
																				
SELECT nombre_grupo,COUNT(positivo) as cantLikes																	
FROM (grupo JOIN grupo_usuario ON grupo.id = grupo_usuario.id_grupo) 
	 						 JOIN 
	 (publicacion JOIN like_publicacion ON publicacion.id = like_publicacion.id_public) ON grupo.id = publicacion.id_grupo																		
WHERE grupo_usuario.id_user IN (SELECT id
				  				FROM usuario
				 				WHERE fecha_nacimiento < '01/01/2002')
																																																											
GROUP BY nombre_grupo
ORDER BY cantLikes	DESC				  
FETCH FIRST 6 ROWS ONLY	
				  
--9			  
SELECT username, COUNT(id_grupo) AS cantGrupos			  
FROM grupo_usuario JOIN usuario ON grupo_usuario.id_user = usuario.id
GROUP BY username
ORDER BY cantGrupos DESC , username ASC
				  
--10 FALTA AGREGAR EN EL SELECT LA CANTIDAD DE LIKES DEL COMENTARIO
SELECT comentario.contenido,publicacion.contenido,COUNT(positivo) as cantDislikes
FROM (like_comentario JOIN comentario ON like_comentario.id_coment = comentario.id) JOIN publicacion ON comentario.id_public = publicacion.id
WHERE positivo = false
GROUP BY id_coment,comentario.contenido,publicacion.contenido,fecha_comentario
HAVING COUNT(positivo) > 3
ORDER BY cantDislikes DESC, fecha_comentario DESC																			

--11
SELECT nombre,apellido,titulo,fecha_publicacion
FROM (like_publicacion JOIN publicacion ON like_publicacion.id_public = publicacion.id) JOIN usuario ON publicacion.id_user = usuario.id
WHERE positivo = false
																				
--12
SELECT id_grupo,max(fecha_nacimiento) AS menor,min(fecha_nacimiento) AS major,avg(age(fecha_nacimiento)) AS promedio
FROM grupo_usuario JOIN usuario ON grupo_usuario.id_user = usuario.id
GROUP BY id_grupo																				
																				
--13																			

																					  
																					  
																					  
																					  
																					  
																					  
																					  