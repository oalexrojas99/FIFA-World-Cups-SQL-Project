USE FIFA_World_Cup_Championships
GO

/*Vista 1*/
DROP VIEW IF EXISTS informe_general_partidos
GO

CREATE VIEW informe_general_partidos AS
	WITH CTE_clasificados AS
		(
			SELECT pc.id_clasificado, pc.id_edicion, pc.id_pais FROM Encuentro e
			LEFT JOIN PaisesClasificados pc ON e.id_pais_local = pc.id_clasificado
		
			UNION

			SELECT pc.id_clasificado, pc.id_edicion, pc.id_pais FROM Encuentro e
			LEFT JOIN PaisesClasificados pc ON e.id_pais_visitante = pc.id_clasificado
		),
		CTE_informacion_edicion AS
		(
			SELECT aux_en.id_encuentro, aux_e1.id_edicion, aux_e1.anio, cte_1.id_pais FROM Encuentro aux_en 
			LEFT JOIN CTE_clasificados cte_1 ON aux_en.id_pais_local = cte_1.id_clasificado
			LEFT JOIN CTE_clasificados cte_2 ON aux_en.id_pais_visitante = cte_2.id_clasificado
			LEFT JOIN Edicion aux_e1 ON cte_1.id_edicion = aux_e1.id_edicion
			LEFT JOIN Edicion aux_e2 ON cte_2.id_edicion = aux_e2.id_edicion
		),
		CTE_informacion_anfitrion AS
		(
			SELECT cte_1.id_encuentro, cte_1.id_edicion,  aux_p.id_pais, aux_p.nombre AS pais FROM CTE_informacion_edicion cte_1 
			LEFT JOIN Anfitriones aux_a ON cte_1.id_edicion = aux_a.id_edicion
			LEFT JOIN Pais aux_p ON aux_a.id_pais = aux_p.id_pais 
		)
	SELECT e.id_encuentro AS 'ID partido',
		(SELECT cte_ed.anio FROM CTE_informacion_edicion cte_ed
			WHERE cte_ed.id_encuentro = e.id_encuentro) AS 'Año de edición',
		(SELECT TOP 1 cte_an.pais FROM CTE_informacion_anfitrion cte_an
			WHERE cte_an.id_encuentro = e.id_encuentro) AS 'País anfitrión',
		f.descripcion AS 'Fase de encuentro',
		CONCAT(p.nombre, ' vs ', p_1.nombre) AS 'Países que se enfrentaron',
		es.nombre AS 'Estadio',
		c.nombre AS 'Ciudad en donde jugaron',
		e.num_goles_local AS 'Goles anotados por el equipo LOCAL',
		e.num_goles_visitante AS 'Goles anotados por el equipo VISITANTE',
		(
			CASE
				WHEN e.id_pais_ganador IS NULL THEN 'EMPATE'
				ELSE p_2.nombre
			END
		) AS 'País ganador del encuentro',
		a_principal.nombre AS 'Árbitro principal',
		a_1.nombre AS 'Primer árbitro asistente',
		a_2.nombre AS 'Segundo árbitro asistente',
		e.num_espectadores AS 'Número de espectadores'
	FROM Encuentro e
	LEFT JOIN PaisesClasificados pc_local ON e.id_pais_local = pc_local.id_clasificado
	LEFT JOIN PaisesClasificados pc_visitante ON e.id_pais_visitante = pc_visitante.id_clasificado
	LEFT JOIN PaisesClasificados pc_ganador ON e.id_pais_ganador = pc_ganador.id_clasificado

	INNER JOIN Estadio es ON e.id_estadio = es.id_estadio

	LEFT JOIN Ciudad c ON es.id_ciudad = c.id_ciudad

	INNER JOIN Fase f ON e.id_fase = f.id_fase

	INNER JOIN Arbitro a_principal ON e.id_arbitro_principal = a_principal.id_arbitro
	INNER JOIN Arbitro a_1 ON e.id_arbitro_asistente_1 = a_1.id_arbitro
	INNER JOIN Arbitro a_2 ON e.id_arbitro_asistente_2 = a_2.id_arbitro

	LEFT JOIN Pais p ON pc_local.id_pais = p.id_pais
	LEFT JOIN Pais p_1 ON pc_visitante.id_pais = p_1.id_pais
	LEFT JOIN Pais p_2 ON pc_ganador.id_pais = p_2.id_pais
GO

SELECT info.* FROM informe_general_partidos info
ORDER BY info.[ID partido]
GO

/*Vista 2*/
DROP VIEW IF EXISTS vCampeones_del_mundo
GO

CREATE VIEW vCampeones_del_mundo AS
	SELECT DISTINCT
		E.id_edicion AS 'Nº de edición', 
		E.anio AS 'Año de edición',
		PS.nombre AS 'País anfitrión',
		(CASE
			WHEN EN.id_pais_ganador = EN.id_pais_local THEN Pa.nombre
			ELSE P.nombre
			END 
		) AS 'Campeón del Mundo'

	FROM Edicion E
	LEFT JOIN Anfitriones A on E.id_edicion = A.id_edicion
	LEFT JOIN Pais PS on PS.id_pais = A.id_pais
	LEFT JOIN PaisesClasificados PC on PC.id_edicion = E.id_edicion
	LEFT JOIN Encuentro EN on EN.id_pais_ganador = PC.id_clasificado
	LEFT JOIN Fase F on EN.id_fase = F.id_fase
	LEFT JOIN PaisesClasificados PCL on PCL.id_clasificado = EN.id_pais_local
	LEFT JOIN PaisesClasificados PCV on PCV.id_clasificado = EN.id_pais_visitante
	LEFT JOIN Pais P on P.id_pais = PCV.id_pais
	LEFT JOIN Pais Pa on Pa.id_pais = PCL.id_pais
	WHERE 
		F.descripcion IN ('Final')
		AND EN.id_pais_ganador IS NOT NULL
	-- ORDER BY [Año de edición]
GO

SELECT info.* FROM vCampeones_del_mundo info
ORDER BY info.[Año de edición]
GO
