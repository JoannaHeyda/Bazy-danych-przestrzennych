CREATE EXTENSION postgis;

--1.tworzenie tabel W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. Układ odniesienia ustal jako niezdefiniowany.
CREATE TABLE obiekty (
	id SERIAL PRIMARY KEY,
	nazwa text,
	geom geometry
);

INSERT INTO obiekty (nazwa, geom) VALUES
('obiekt1', ST_GeomFromText('COMPOUNDCURVE(
	LINESTRING(0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), LINESTRING(5 1, 6 1))')),
('obiekt2', ST_GeomFromText('MULTICURVE(COMPOUNDCURVE(
	LINESTRING(10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2), LINESTRING(10 2, 10 6)), CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2))')),
('obiekt3', ST_GeomFromText('LINESTRING(10 17, 12 13, 7 15, 10 17)')),
('obiekt4', ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)')),
('obiekt5', ST_GeomFromText('MULTIPOINT Z((30 30 59), (38 32 234))')),
('obiekt6', ST_GeomFromText('GEOMETRYCOLLECTION( POINT(4 2), LINESTRING(1 1, 3 2))'));

--2 Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4
SELECT ST_Area(ST_Buffer(ST_ShortestLine(a.geom, b.geom),5)) AS pole_buffora
FROM obiekty a
JOIN obiekty b ON b.nazwa = 'obiekt4'
WHERE a.nazwa = 'obiekt3';

--3 Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te warunki.
--obiekt musi być zamkniętą linią
UPDATE obiekty
SET geom = ST_AddPoint(geom, ST_StartPoint(geom))
WHERE nazwa = 'obiekt4';

UPDATE obiekty
SET geom = ST_MakePolygon(geom)
WHERE nazwa = 'obiekt4;'

--4 W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.
INSERT INTO obiekty (nazwa, geom)
SELECT 'obiekt7', ST_Union(
	(SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'),
	(SELECT geom FROM obiekty WHERE nazwa = 'obiekt4'));

--5 Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie zawierających łuków.
SELECT nazwa, ST_Area(ST_Buffer(geom, 5)) AS pole_bufora
FROM obiekty
WHERE NOT ST_HasArc(geom);