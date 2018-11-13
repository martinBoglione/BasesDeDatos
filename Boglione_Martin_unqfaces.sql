--3.2 Preguntas
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
																		   
CREATE TABLE like_comentario
			  (id_coment INT,
			   id_user INT,
			   positivo BOOL,
			   fecha TIMESTAMP,
			   CONSTRAINT like_comentario_pk PRIMARY KEY(id_coment,id_user),
			   CONSTRAINT usuario_fk FOREIGN KEY (id_user) REFERENCES usuario(id));
																		 
											
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
--Inserté el set de datos provisto en el archivo datos_unqfaces.sql en otro query para que sea más ordenado este query.
																				
--5																				 																			 																				  
SELECT nombre, COUNT(id_user) AS cant_alu
FROM carrera_usuario 
JOIN carrera ON carrera_usuario.id_carrera = carrera.id
GROUP BY nombre 																				  
ORDER BY length(nombre) DESC;	
																				
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
SELECT nombre_grupo,COUNT(positivo) as cant_Likes																	
FROM (grupo 
JOIN grupo_usuario ON grupo.id = grupo_usuario.id_grupo) 
JOIN (publicacion JOIN like_publicacion ON publicacion.id = like_publicacion.id_public) ON grupo.id = publicacion.id_grupo																		
WHERE grupo_usuario.id_user IN (SELECT id
				  				FROM usuario
				 				WHERE (current_date - fecha_nacimiento) > 16)																																																							
GROUP BY nombre_grupo,like_publicacion.positivo
HAVING positivo = true
ORDER BY cant_Likes	DESC				  
FETCH FIRST 6 ROWS ONLY;
												
--9			  
SELECT username, COUNT(id_grupo) AS cantGrupos			  
FROM grupo_usuario 
JOIN usuario ON grupo_usuario.id_user = usuario.id
GROUP BY username
ORDER BY cantGrupos DESC , username ASC;
				  
--10 
SELECT comentario.contenido,publicacion.contenido,COUNT(positivo=false) as cant_Dislikes,COUNT(positivo=true) as cant_Likes
FROM (like_comentario 
JOIN comentario ON like_comentario.id_coment = comentario.id) 
JOIN publicacion ON comentario.id_public = publicacion.id
GROUP BY id_coment,comentario.contenido,publicacion.contenido,fecha_comentario
HAVING COUNT(positivo = false) > 3
ORDER BY cant_Dislikes DESC, fecha_comentario DESC;																		

--11
SELECT nombre,apellido,titulo,fecha_publicacion
FROM (like_publicacion 
JOIN publicacion ON like_publicacion.id_public = publicacion.id) 
JOIN usuario ON publicacion.id_user = usuario.id
GROUP BY nombre,apellido,titulo,fecha_publicacion
HAVING COUNT(positivo = false) > 0;
																				
--12
SELECT id_grupo,
max(age(fecha_nacimiento)) AS mayor,
min(age(fecha_nacimiento)) AS menor,
avg(age(fecha_nacimiento)) AS promedio
FROM grupo_usuario 
JOIN usuario ON grupo_usuario.id_user = usuario.id
GROUP BY id_grupo;
		
--13
SELECT DISTINCT(id)
FROM usuario 
JOIN carrera_usuario ON usuario.id = carrera_usuario.id_user 
JOIN like_publicacion ON usuario.id = like_publicacion.id_user
WHERE usuario.id IN (SELECT id_user
					 FROM like_publicacion
					 WHERE positivo = true)
 
INTERSECT -- UNION???					 

SELECT DISTINCT(id)
FROM usuario 
JOIN carrera_usuario ON usuario.id = carrera_usuario.id_user 
JOIN like_comentario ON usuario.id = like_comentario.id_user
WHERE usuario.id IN (SELECT id_user
					 FROM like_comentario
					 WHERE positivo = true)						
					  
--14
SELECT usuario.id AS id_usuario,max(fecha_comentario) AS ultimo_comentario
FROM usuario
JOIN grupo_usuario ON usuario.id = grupo_usuario.id_user
JOIN publicacion ON usuario.id = publicacion.id_user
JOIN comentario ON publicacion.id = comentario.id_public
GROUP BY usuario.id
ORDER BY usuario.id	
		
		
																				 