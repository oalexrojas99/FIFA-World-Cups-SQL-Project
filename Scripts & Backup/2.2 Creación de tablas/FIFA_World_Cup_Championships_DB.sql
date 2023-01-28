USE MASTER
GO

-- Creación de la base de datos
DROP DATABASE IF EXISTS FIFA_World_Cup_Championships
GO

CREATE DATABASE FIFA_World_Cup_Championships
GO

-- Tablas
USE FIFA_World_Cup_Championships
GO

CREATE TABLE Pais
(
	id_pais INT IDENTITY(1, 1),
	nombre VARCHAR(32) NOT NULL,
	abreviatura VARCHAR(4) NOT NULL,
)
GO

ALTER TABLE Pais
	ADD CONSTRAINT pk_pais PRIMARY KEY (id_pais)
GO

CREATE TABLE Ciudad
(
	id_ciudad INT IDENTITY(1, 1),
	nombre VARCHAR(64) NOT NULL,
	id_pais INT NOT NULL
)
GO

ALTER TABLE Ciudad
	ADD CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
		CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais) REFERENCES Pais (id_pais)
GO

CREATE TABLE Estadio
(
	id_estadio INT IDENTITY(1, 1),
	nombre VARCHAR(64) NOT NULL,
	id_ciudad INT
)
GO

ALTER TABLE Estadio
	ADD CONSTRAINT pk_estadio PRIMARY KEY (id_estadio),
		CONSTRAINT fk_estadio_ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad (id_ciudad)
GO

CREATE TABLE Arbitro
(
	id_arbitro INT IDENTITY(1, 1),
	nombre VARCHAR(64) NOT NULL,
	id_pais_origen INT
)
GO

ALTER TABLE Arbitro
	ADD CONSTRAINT pk_arbitro PRIMARY KEY (id_arbitro),
		CONSTRAINT fk_arbitro_pais FOREIGN KEY (id_pais_origen) REFERENCES Pais (id_pais)
GO

CREATE TABLE Edicion
(
	id_edicion INT IDENTITY(1, 1),
	descripcion VARCHAR(64),
	anio SMALLINT NOT NULL
)
GO

ALTER TABLE Edicion
	ADD CONSTRAINT pk_edicion PRIMARY KEY (id_edicion)
GO

CREATE TABLE Anfitriones
(
	id_edicion INT NOT NULL,
	id_pais INT NOT NULL
)
GO

ALTER TABLE Anfitriones
	ADD CONSTRAINT fk_anfitrion_edicion FOREIGN KEY (id_edicion) REFERENCES Edicion (id_edicion),
		CONSTRAINT fk_anfitrion_pais FOREIGN KEY (id_pais) REFERENCES Pais (id_pais)
GO

CREATE TABLE PaisesClasificados
(
	id_clasificado INT IDENTITY(1, 1),
	id_edicion INT NOT NULL,
	id_pais INT NOT NULL
)
GO

ALTER TABLE PaisesClasificados
	ADD CONSTRAINT pk_PaisesClasificados_edicion PRIMARY KEY (id_clasificado),
		CONSTRAINT fk_paisesClasificados_edicion FOREIGN KEY (id_edicion) REFERENCES Edicion (id_edicion),
		CONSTRAINT fk_paisesClasificados_pais FOREIGN KEY (id_pais) REFERENCES Pais (id_pais)
GO

CREATE TABLE Fase
(
	id_fase INT IDENTITY(1, 1),
	descripcion VARCHAR(32) NOT NULL
)
GO

ALTER TABLE Fase
	ADD CONSTRAINT pk_fase PRIMARY KEY (id_fase)
GO

CREATE TABLE Encuentro
(
	id_encuentro INT IDENTITY(1, 1),
	fecha_hora DATETIME NOT NULL,
	id_pais_local INT,
	id_pais_visitante INT,
	num_goles_local TINYINT NOT NULL,
	num_goles_visitante TINYINT NOT NULL,
	id_pais_ganador INT, -- NULL: Hubo empate
	id_estadio INT NOT NULL,
	id_fase INT NOT NULL,
	id_arbitro_principal INT NOT NULL,
	id_arbitro_asistente_1 INT NOT NULL,
	id_arbitro_asistente_2 INT NOT NULL,
	num_espectadores INT NOT NULL
)
GO

ALTER TABLE Encuentro
	ADD CONSTRAINT pk_encuentro PRIMARY KEY (id_encuentro),
		CONSTRAINT fk_encuentro_pais_local FOREIGN KEY (id_pais_local) REFERENCES PaisesClasificados (id_clasificado),
		CONSTRAINT fk_encuentro_pais_visitante FOREIGN KEY (id_pais_visitante) REFERENCES PaisesClasificados (id_clasificado),
		CONSTRAINT fk_encuentro_pais_ganador FOREIGN KEY (id_pais_ganador) REFERENCES PaisesClasificados (id_clasificado),
		CONSTRAINT fk_encuentro_estadio FOREIGN KEY (id_estadio) REFERENCES Estadio (id_estadio),
		CONSTRAINT fk_encuentro_fase FOREIGN KEY (id_fase) REFERENCES Fase (id_fase),
		CONSTRAINT fk_encuentro_arbitro_principal FOREIGN KEY (id_arbitro_principal) REFERENCES Arbitro (id_arbitro),
		CONSTRAINT fk_encuentro_arbitro_asistente_1 FOREIGN KEY (id_arbitro_asistente_1) REFERENCES Arbitro (id_arbitro),
		CONSTRAINT fk_encuentro_arbitro_asistente_2 FOREIGN KEY (id_arbitro_asistente_2) REFERENCES Arbitro (id_arbitro)
GO