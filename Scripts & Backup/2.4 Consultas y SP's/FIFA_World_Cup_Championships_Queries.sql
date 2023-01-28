 use [FIFA_World_Cup_Championships]
 GO

/*1. Total de asistentes (en millones) por cada Mundial de F�tbol*/
SELECT
	INFO.[A�o de edici�n],
	CAST(CAST(SUM([N�mero de espectadores]) AS DECIMAL (10, 2)) / 1000000 AS DECIMAL (10, 2)) AS 'N� total de espectadores'
FROM informe_general_partidos INFO
GROUP BY INFO.[A�o de edici�n]
ORDER BY [N� total de espectadores] DESC
GO

/*2. Cantidad de veces que un pa�s clasific� a los mundiales*/
SELECT
	P.nombre 'Pa�s',
	COUNT(*) AS 'N� de participaciones'
FROM PaisesClasificados PC
LEFT JOIN Pais P ON PC.id_pais = P.id_pais
GROUP BY P.id_pais, P.nombre
ORDER BY [N� de participaciones] DESC
GO

/*3. N� total de asistentes por estadio*/
SELECT
ES.nombre AS 'Estadio', 
SUM(EN.num_espectadores) AS  'N�mero de total asistentes'
FROM Encuentro EN
INNER JOIN Estadio ES ON EN.id_estadio = ES.id_estadio
GROUP BY ES.nombre
ORDER BY [N�mero de total asistentes] DESC
GO

/*4. Las 20 mayores goleadas en la Copa del Mundo*/
SELECT TOP 20
	info.[A�o de edici�n],
	info.[Pa�ses que se enfrentaron] AS 'Enfrentamiento',
	info.[Goles anotados por el equipo LOCAL],
	info.[Goles anotados por el equipo VISITANTE],
ABS(CAST(info.[Goles anotados por el equipo LOCAL] AS INT) -  
	cast(info.[Goles anotados por el equipo VISITANTE] AS INT)) AS 'Diferencia de goles'
FROM informe_general_partidos AS info
ORDER BY [Diferencia de goles] DESC
GO

/*5. Cantidad de veces que un pa�s gan� la Copa del Mundo*/
SELECT
PA.nombre AS 'Pa�s', 
COUNT(*) AS 'N� de veces que gan� la Copa del Mundo'
FROM Encuentro EN
LEFT JOIN Fase F ON EN.id_fase = F.id_fase
LEFT JOIN PaisesClasificados PC ON EN.id_pais_ganador = PC.id_clasificado
LEFT JOIN Pais PA ON PA.id_pais = PC.id_pais
WHERE 
	F.descripcion IN ('Final')
GROUP BY PA.nombre
ORDER BY PA.nombre ASC
GO

/*6. Cantidad de veces que gan� un pa�s por penalties*/
SELECT
	PA.nombre AS 'Pa�s', 
	COUNT(*) AS 'Veces que gan� por penalties'
FROM Encuentro EN
LEFT JOIN Fase F ON EN.id_fase = F.id_fase
LEFT JOIN PaisesClasificados PC ON EN.id_pais_ganador = PC.id_clasificado
LEFT JOIN Pais PA ON PA.id_pais = PC.id_pais
WHERE 
	F.descripcion IN ('Round of 16','Quarterfinals','Semifinals','Third place','Final')
	AND EN.num_goles_local = EN.num_goles_visitante
	AND EN.id_pais_ganador IS NOT NULL
GROUP BY PA.nombre
ORDER BY [Veces que gan� por penalties] DESC
GO

/*7. Pa�ses que perdieron m�s encuentros en primera fase o fase de grupos*/
SELECT
	(CASE
		WHEN EN.id_pais_ganador = EN.id_pais_local THEN P.nombre
		ELSE PA.nombre
		END 
	) AS 'Pa�s',
	COUNT(*) AS 'Cantidad de partidos perdidos'
FROM Encuentro EN
LEFT JOIN Fase F ON EN.id_fase = F.id_fase
LEFT JOIN PaisesClasificados PCL ON PCL.id_clasificado = EN.id_pais_local
LEFT JOIN PaisesClasificados PCV ON PCV.id_clasificado = EN.id_pais_visitante
LEFT JOIN Pais P ON P.id_pais = PCV.id_pais
LEFT JOIN Pais PA ON PA.id_pais = PCL.id_pais
WHERE
	F.descripcion in ('Group A','Group B','Group C','Group D','Group E','Group F','Group G','Group H',
						'Group 1','Group 2','Group 3','Group 4','Group 5','Group 6')
	AND EN.id_pais_ganador IS NOT NULL
GROUP BY
		(CASE
			WHEN EN.id_pais_ganador = EN.id_pais_local THEN P.nombre
			ELSE PA.nombre
		 END)
ORDER BY [Cantidad de partidos perdidos] DESC
GO

/*8. Partidos que gan� un pa�s dentro de cada edici�n del Mundial*/
DROP PROCEDURE IF EXISTS SP_partidos_ganados_x_pais
GO

CREATE PROCEDURE SP_partidos_ganados_x_pais @nombre_pais VARCHAR(64)
AS
BEGIN
	SELECT
		ED.anio AS 'A�o de edici�n',
		P.nombre AS 'Pa�s que gan� el encuentro',
		info.[Pa�ses que se enfrentaron] AS 'Enfrentamiento',
		CONCAT(EN.num_goles_local, ' - ', EN.num_goles_visitante) AS 'Resultado',
		F.descripcion AS 'Fase'
	FROM Encuentro EN
	LEFT JOIN Fase F ON EN.id_fase = F.id_fase
	LEFT JOIN PaisesClasificados PCG ON EN.id_pais_ganador = PCG.id_clasificado
	LEFT JOIN Edicion ED ON PCG.id_edicion = ED.id_edicion
	LEFT JOIN Pais P ON PCG.id_pais = P.id_pais
	LEFT JOIN informe_general_partidos info ON EN.id_encuentro = info.[ID partido] 
	WHERE
		P.nombre = @nombre_pais
		AND EN.id_pais_ganador IS NOT NULL
END
GO

EXEC SP_partidos_ganados_x_pais 'Peru'
GO

/*9. Cantidad de veces que un pa�s lleg� a ser finalista en un Mundial*/
WITH TableIDClasificados
AS 
(
	SELECT 
	E.id_pais_local AS IDClasificados
	FROM
	Encuentro E
	LEFT JOIN Fase F
	ON E.id_fase = F.id_fase
	WHERE F.descripcion = 'Final'

	UNION

	SELECT 
	EN.id_pais_visitante AS IDClasificados
	FROM
	Encuentro EN
	left join Fase FA
	ON EN.id_fase = FA.id_fase
	WHERE FA.descripcion = 'Final'
)
SELECT
	P.nombre AS 'Pa�s', 
	COUNT (*) AS 'N� de participaciones en una final'
FROM PaisesClasificados PC
INNER JOIN TableIDClasificados IDC ON PC.id_clasificado = IDC.IDClasificados
LEFT JOIN Pais P ON PC.id_pais = P.id_pais
GROUP BY P.nombre
ORDER BY [N� de participaciones en una final] DESC