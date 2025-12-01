--wyświetlenia struktury
SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

--zmiana nazwy shema_nazwa
ALTER SCHEMA schema_name RENAME TO heyda;

-- sprawdzenie schemat rasters
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'rasters'
ORDER BY table_name;

--sprawdzenie struktury i zawarości public.raster_columns
SELECT * FROM PPUBLI
LIMIT 10

-- Przecięcie rastra z wektorem.
CREATE TABLE heyda.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table heyda.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON heyda.intersects
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('heyda'::name, 'intersects'::name,'rast'::name);

--Obcinanie rastra na podstawie wektora.
CREATE TABLE heyda.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--Połączenie wielu kafelków w jeden raster.
CREATE TABLE heyda.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--ST_AsRaster
CREATE TABLE heyda.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

-- łączy rekordy z poprzedniego przykładu przy użyciu funkcji ST_UNION w pojedynczy raster
DROP TABLE heyda.porto_parishes; 
CREATE TABLE heyda.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--można generować kafelki za pomocą funkcji ST_Tile.
DROP TABLE heyda.porto_parishes; 
CREATE TABLE heyda.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--ST_Intersection
create table heyda.intersection as
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--ST_DumpAsPolygons konwertuje rastry w wektory (poligony).
CREATE TABLE heyda.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);


--Funkcja ST_Band służy do wyodrębniania pasm z rastra
CREATE TABLE heyda.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--ST_Clip może być użyty do wycięcia rastra z innego rastra
CREATE TABLE heyda.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Poniższy przykład użycia funkcji ST_Slope wygeneruje nachylenie przy użyciu poprzednio wygenerowanej tabeli
CREATE TABLE heyda.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM heyda.paranhos_dem AS a;

--Aby zreklasyfikować raster należy użyć funkcji ST_Reclass.
CREATE TABLE heyda.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM heyda.paranhos_slope AS a;

--Aby obliczyć statystyki rastra można użyć funkcji ST_SummaryStats.
SELECT st_summarystats(a.rast) AS stats
FROM heyda.paranhos_dem AS a;

--ST_SummaryStats oraz Union
SELECT st_summarystats(ST_Union(a.rast))
FROM heyda.paranhos_dem AS a;

--ST_SummaryStats z min max mean
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM heyda.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--ST_SummaryStats w połączeniu z GROUP BY
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

-- Funkcja ST_Value pozwala wyodrębnić wartość piksela z punktu lub zestawu punktów
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--Funkcja ST_Value pozwala na utworzenie mapy TPI z DEM wysokości
create table heyda.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON heyda.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('heyda'::name, 'tpi30'::name,'rast'::name);

-- tpi dla gminy porto
create table heyda.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'

CREATE INDEX idx_tpi30_porto_rast_gist ON heyda.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('heyda'::name, 'tpi30_porto'::name,'rast'::name);

--czas dla tp to 24s a dla tpi porto nie całe 2s

--NDIV
CREATE TABLE heyda.porto_ndvi AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
	r.rast, 1,
	r.rast, 4,
	'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON heyda.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('heyda'::name, 'porto_ndvi'::name,'rast'::name);

--Funkcja zwrotna
create or replace function heyda.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
	RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

--
CREATE TABLE heyda.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'heyda.ndvi(double precision[], integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON heyda.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('heyda'::name, 'porto_ndvi2'::name,'rast'::name);


-- eksprt danych ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM heyda.porto_ndvi;

-- ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM heyda.porto_ndvi;

-- biblioteka GDAL
SELECT ST_GDALDrivers();

--Zapisywanie danych na dysku za pomocą dużego obiektu
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM heyda.porto_ndvi;

SELECT lo_export(loid, 'G:\myraster.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;


















