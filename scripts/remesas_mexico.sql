USE proyecto_remesas;

SET SQL_SAFE_UPDATES = 0;

UPDATE remesas2024
SET Fecha = STR_TO_DATE(Fecha, '%d/%m/%Y');

UPDATE remesas_ent
SET Fecha = STR_TO_DATE(Fecha, '%d/%m/%Y');

ALTER TABLE remesas2024 MODIFY Fecha DATE;

ALTER TABLE remesas2024
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE remesas_ent
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

UPDATE remesas_ent
SET Estado = 'Ciudad de Mexico'
WHERE Estado = 'Ciudad de MÃ©xico';

UPDATE remesas_ent
SET Estado = 'Estado de Mexico'
WHERE Estado = 'Estado de MÃ©xico';

UPDATE remesas_ent
SET Estado = 'Michoacan'
WHERE Estado = 'MichoacÃ¡n';

UPDATE remesas_ent
SET Estado = 'Nuevo Leon'
WHERE Estado = 'Nuevo LeÃ³n';

UPDATE remesas_ent
SET Estado = 'Queretaro'
WHERE Estado = 'QuerÃ©taro';

UPDATE remesas_ent
SET Estado = 'San Luis Potosi'
WHERE Estado = 'San Luis PotosÃ­';

UPDATE remesas_ent
SET Estado = 'Yucatan'
WHERE Estado = 'YucatÃ¡n';

-- 1
SELECT 
	FORMAT(SUM(Total),2) AS 'Remesas 2024' 
FROM remesas2024
WHERE YEAR(Fecha) = 2024;

-- 2
SELECT 
	Estado, 
    FORMAT(AVG(Remesas),2) AS 'Promedio (millones de dólares)'
FROM remesas_ent
WHERE YEAR(Fecha) = 2024 AND Estado <> 'TOTAL'
GROUP BY Estado
ORDER  BY AVG(Remesas) DESC
LIMIT 5;

-- 3 
SELECT 
	Estado, 
	FORMAT(SUM(Remesas),2) AS 'Remesas (millones de dólares)'
FROM remesas_ent
WHERE YEAR(Fecha) = 2024 AND Estado <> 'TOTAL'
GROUP BY Estado
ORDER  BY SUM(Remesas) ASC
LIMIT 1;

-- 4
SELECT 
	FORMAT(AVG(Total),2) AS 'Promedio (millones de dólares)'
FROM remesas2024
WHERE YEAR(Fecha) = 2024;

-- 5
WITH cte AS(SELECT 
				YEAR(Fecha) as Ano, 
                SUM(Total) AS Anual
			FROM remesas2024
			GROUP BY Ano
			ORDER BY Ano
)

SELECT 
	Ano,
    FORMAT(((Anual-LAG(Anual) OVER())/LAG(Anual) OVER())*100,2)
       AS 'Porcentaje(%)'
FROM cte;

-- 6
WITH cte AS (SELECT 
				YEAR(Fecha) AS Año, 
                Estado, 
                SUM(Remesas) AS total_2023
             FROM remesas_ent
             WHERE YEAR(Fecha) = 2023
             GROUP BY Año,Estado
),

cte_2 AS (SELECT 
			YEAR(Fecha) AS Año, 
            Estado, SUM(Remesas) AS total_2024
          FROM remesas_ent
          WHERE YEAR(Fecha) = 2024
          GROUP BY Año,Estado
) 

SELECT cte.Estado,
	   ROUND((cte_2.total_2024 - cte.total_2023)/(cte.total_2023)*100,2) AS crecimiento_porcentual
FROM cte
JOIN cte_2 ON
	 cte.Estado = cte_2.Estado
ORDER BY crecimiento_porcentual DESC;

-- 7
WITH cte AS (SELECT 
				SUM(Remesas) AS remesas
             FROM remesas_ent
             WHERE YEAR(Fecha) = 2024 AND Estado = 'Total'
             GROUP BY Estado
)
SELECT re.Estado, 
       ROUND(((SUM(re.Remesas) / cte.remesas)*100),2) AS porcentaje_total
FROM remesas_ent re
CROSS JOIN cte
WHERE YEAR(re.Fecha) = 2024 AND re.Estado <> 'TOTAL'
GROUP BY re.Estado, cte.remesas
ORDER BY porcentaje_total DESC;

-- 8
WITH remesas_mensuales AS(
	SELECT
		YEAR(Fecha) AS anio,
		MONTH(Fecha) AS mes_numero,
		MONTHNAME(Fecha) AS mes,
		Total AS Remesas,
		RANK() OVER(PARTITION BY YEAR(Fecha) ORDER BY Total DESC) AS pos
	FROM remesas2024
)
SELECT *
FROM remesas_mensuales
WHERE pos <= 1
ORDER BY mes;

-- 9
SELECT 
	Estado,
	CONCAT(QUARTER(Fecha),"-", YEAR(Fecha)) AS Trimestre_año, 
    FORMAT(((Remesas-LAG(Remesas) OVER(PARTITION BY Estado ORDER BY Fecha))/LAG(Remesas)OVER(PARTITION BY Estado ORDER BY Fecha))*100,2) AS 
		Crecimiento_trimestral_porcentaje
FROM remesas_ent
WHERE Estado <> 'Total';

-- 10
SELECT
	Estado,
    ROUND(STDDEV_SAMP(Remesas),2) AS Est_dev
FROM remesas_ent
WHERE YEAR(Fecha) >= 2015 AND YEAR(Fecha)<=2024 AND Estado <> 'Total'
GROUP BY Estado
ORDER BY Est_dev DESC
LIMIT 10;

-- 11
WITH cte AS (SELECT 
					YEAR(Fecha) as anio,
					SUM(Remesas) AS remesas
             FROM remesas_ent
             WHERE Estado = 'Total' AND YEAR(Fecha) <> 2025
             GROUP BY anio
),

cte_2 AS (SELECT 
			   anio,
			   re.Estado, 
			   SUM(re.Remesas) AS remesas_estado, 
			   cte.remesas,
			   ROUND(((SUM(re.Remesas)/ cte.remesas)*100),2) AS porcentaje_total
FROM remesas_ent re
JOIN cte ON
	YEAR(re.Fecha) = cte.anio  
WHERE YEAR(re.Fecha) <> 2025 AND re.Estado <> 'TOTAL'
GROUP BY anio, re.Estado, cte.remesas
)
SELECT *
FROM cte_2
ORDER BY anio, porcentaje_total DESC;
-- 12
SELECT
	YEAR(Fecha) as Año,
    CASE
		WHEN Estado IN ('Baja California', 'Sonora', 'Chihuahua', 'Coahuila', 'Nuevo Leon', 'Tamaulipas', 'Sinaloa', 'Durango', 'Baja California Sur') THEN 'Norte'
        WHEN Estado IN ('Ciudad de Mexico', 'Estado de Mexico', 'Hidalgo', 'Morelos', 'Queretaro', 'Tlaxcala', 'Puebla') THEN 'Centro'
        WHEN Estado IN ('Guerrero', 'Oaxaca', 'Chiapas', 'Tabasco', 'Campeche', 'Yucatan', 'Quintana Roo', 'Veracruz') THEN 'Sur'
        WHEN Estado IN ('Jalisco', 'Michoacan', 'Colima', 'Nayarit', 'Zacatecas', 'Aguascalientes', 'San Luis Potosi', 'Guanajuato') THEN 'Occidente'
		ELSE 'Otro'
    END AS Region,
    FORMAT(SUM(Remesas),2) AS total
FROM remesas_ent
WHERE Estado <> 'Total' AND YEAR(Fecha) = 2024
GROUP BY Año, Region
ORDER BY Año, total DESC;


