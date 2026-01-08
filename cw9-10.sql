CREATE TABLE public.exports_union AS
SELECT ST_Union(rast) AS rast
FROM public.exports