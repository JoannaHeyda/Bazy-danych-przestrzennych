--3
CREATE TABLE uk_250k_mosaic AS
SELECT ST_Union(rast) AS rast
FROM uk_250k;

ALTER TABLE uk_250k_mosaic
ADD COLUMN rid SERIAL PRIMARY KEY;

CREATE INDEX idx_uk_250k_mosaic_rast_gist
ON uk_250k_mosaic
USING GIST (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name, 'uk_250k_mosaic'::name,'rast'::name);

CREATE TABLE tmp_uk_250k_out AS
SELECT lo_from_bytea (
	0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM uk_250k_mosaic;

SELECT lo_export(loid, "C:\Users\Joasia\Desktop\Studia\Bazy danych przestrzennych\cw7\uk_250k.sql"
	)
FROM tmp_uk_250k_out;

SELECT lo_unlink(loid)
FROM tmp_uk_250k_out

--6
SELECT geom
FROM national_park
WHERE name ILIKE '%Lake District%';

CREATE TABLE uk_lake_district AS
SELECT r.rid, ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)) AS rast)
FROM uk_250k r
JOIN national_parks p ON p.name ILIKE '%Lake District%'
WHERE ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));

--7
CREATE TABLE tmp_lake_out AS
SELECT lo_from_bytea(0, STST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM uk_lake_district;
SELECT lo_export(loid, 'C:\Users\Joasia\Desktop\Studia\Bazy danych przestrzennych\cw7')
FROM tmp_lake_out;

SELECT lo_unlink(loid)
FROM tmp_lake_out;

--9
SELECT AddRastersConstraints('public'::name, 's2_lake'::name, 'rast'::name);

--10
CREATE TABLE public.tmp_ndwi_out AS
WITH lake AS (
SELECT geom
FROM national_parks
WHERE name ILIKE '%Lake District%'
),
r AS(
	SELECT a.rid,ST_Clip(a.rast, ST_Transform(l.geom, ST_SRID(a.rast)), true) AS rast
FROM s2_lake a, lake l
WHERE ST_Intersects(a.rast, ST_Transform(l.geom, ST_SRID(a.rast)))
)
SELECT
	r.rid, ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
	) AS rast
FROM r;

--11
CREATE TABLE tmp_ndwi_out AS
SELECT lo_from_bytea(0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM lake_ndwi;

SELECT lo_export(loid, 'C:\Users\Joasia\Desktop\Studia\Bazy danych przestrzennych\cw7') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp__ndwi_out;

SELECT lo_unlink(loid)
FROM tmp_ndwi_out;



