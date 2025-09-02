# <p align="center">Proyecto SQL: Remesas en México</p>
<p align="right">Peña Villalba Víctor</p>

---
### **Exploración de datos**
<br>

1.- [¿Cuál es el total de remesas recibidas en México en 2024?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L48-L51)
```sql
SELECT 
	FORMAT(SUM(Total),2) AS 'Remesas 2024' 
FROM remesas2024
WHERE YEAR(Fecha) = 2024;
```
El total de remesas que arribaron a México en 2024 alcanza al cifra de 64,746.38 millones de dolares.
<br>

2.- [¿Cuáles son los 5 estados que más remesas recibieron en 2024 en promedio?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L54-L61)
```sql
SELECT 
       Estado, 
       FORMAT(AVG(Remesas),2) AS 'Promedio (millones de dólares)'
FROM remesas_ent
WHERE YEAR(Fecha) = 2024 AND Estado <> 'TOTAL'
GROUP BY Estado
ORDER  BY AVG(Remesas) DESC
LIMIT 5;
```
Los estados que más volumen de remesas recibieron en 2024 en promedio fueron Guanajuato, Jalisco y Michoacán.

<br>

3.- [¿Cuál es el estado con menor recepción de remesas en 2024?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L64-L71)

```sql
SELECT 
	Estado, 
	FORMAT(SUM(Remesas),2) AS 'Remesas (millones de dólares)'
FROM remesas_ent
WHERE YEAR(Fecha) = 2024 AND Estado <> 'TOTAL'
GROUP BY Estado
ORDER  BY SUM(Remesas) ASC
LIMIT 1;
```
El estado que menor cantidad de remesas recibió en 2024 fue Baja California Sur.
<br>
4.- [¿Cuál fue el promedio mensual de remesas de todo el país en 2024?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L74-L77)

```sql
SELECT 
	FORMAT(AVG(Total),2) AS 'Promedio (millones de dólares)'
FROM remesas2024
WHERE YEAR(Fecha) = 2024;
```
El promedio mensual de remesas que llegaron a México en 2024 alcanzó la cifra de 5,595.53 millones de dólares.
<br>
5.- [¿Cuál es la tendencia anual de las remesas en México?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L80-L92)

```sql
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
```
Es fácil observar que, en general, la tendencia anual de las remesas en México desde 1995 y hasta 2024 es creciente.
### **Comparaciones y tendencias**

<br>

6.- [¿Qué estados tuvieron el mayor crecimiento anual  de remesas entre 2023 y 2024 en términos porcentuales?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L95-L117)

```sql
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
```
De acuerdo con los resultados arrojados por la consulta, fueron la Ciudad de México (21.12%), Puebla (7.05%) y Oaxaca (6.83%) los estados que mayor crecimiento anual de remesas presentaron en terminos porcentuales.

<br>

7.- [¿Cuál es la participación porcentual de cada estado en el total nacional de remesas en 2024?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L120-L132)

```sql
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
```
La consulta muestra que los estados que mayor participación tuvieron en el volumen total de remesas que percibió México en 2024 fueron Guanajuato, Michoacan y Jalisco; los estados con menor participación fueron Tabasco, Campeche y Baja California Sur.

<br>

8.- [¿Cuál es el mes que historicamente se caracteriza por ser el de mayor recepción de remesas?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L135-L147)

```sql
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
```
El mes que históricamente se caracteriza por ser el de mayor recepción de remesas es mayo, seguido de agosto.
<br>

### **Análisis con ventanas y cruces**

9.- [¿Cuál es la tasa de crecimiento trimestral de remesas en cada estado?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L150-L156)

```sql
SELECT 
       Estado,
	CONCAT(QUARTER(Fecha),"-", YEAR(Fecha)) AS Trimestre_año, 
       FORMAT(((Remesas-LAG(Remesas) OVER(PARTITION BY Estado ORDER BY Fecha))/LAG(Remesas)OVER(PARTITION BY Estado ORDER BY Fecha))*100,2) AS Crecimiento_trimestral_porcentaje
FROM remesas_ent
WHERE Estado <> 'Total';
```
La consulta refleja los crecimientos o los decrecimientos en los flujos de remesas que recibió cada estado de la republica durante el periodo 2003-2024.

<br>

10.- [¿Qué estados presentaron mayor volatilidad en los últimos 10 años?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L159-L166)
```sql
SELECT
       Estado,
       ROUND(STDDEV_SAMP(Remesas),2) AS Est_dev
FROM remesas_ent
WHERE YEAR(Fecha) >= 2015 AND YEAR(Fecha)<=2024 AND Estado <> 'Total'
GROUP BY Estado
ORDER BY Est_dev DESC
LIMIT 10;
```
Los 10 estados que mpas volatilidad presentaron en el volumen de remesas que percibió fueron Chiapas, Jalisco, Guanajuato, Ciudad de México, Michoacán,Estado de México, Guerrero, Oaxaca, Puebla y Veracruz.
<br>

11.- [¿Cómo ha cambiado la concentración de remesas a lo largo de los años?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L169-L191)
```sql
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
```
En general los tres estados que más volumen de remesas concentraron fueron Guanajuato, Jalisco y Michoacán.
<br>
12.- [Si agrupamos por regiones (Norte, Centro, Sur, Occidente), ¿qué región recibió más remesas en 2024?](https://github.com/victorvillalba/remesas_sql/blob/9298384a937b77d1385af1a4cb795c015dedd788/scripts/remesas_mexico.sql#L193-L206)

```sql
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
```
La región que más percibió remesas en 2024 fue la región de Occidente (Jalisco, Michoacan, Colima, Nayarit, Zacatecas, Aguascalientes, San Luis Potosi, Guanajuato).

