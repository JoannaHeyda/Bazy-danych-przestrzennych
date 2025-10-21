--3
CREATE EXTENSION postgis 

--4
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POLYGON),
    name TEXT
)

CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(LINESTRING),
    name TEXT
)

CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POINT),
    name TEXT
)

--5
INSERT INTO buildings (geometry, name) VALUES
(ST_GeomFromText('POLYGON((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))'), 'BuildingA'),
(ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))'), 'BuildingB'),
(ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))'), 'BuildingC'),
(ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))'), 'BuildingD'),
(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 'BuildingF')

INSERT INTO roads (geometry, name) VALUES
(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
(ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY')

INSERT INTO poi (geometry, name) VALUES
(ST_GeomFromText('POINT(1 3.5)'), 'G'),
(ST_GeomFromText('POINT(5.5 1.5)'), 'H'),
(ST_GeomFromText('POINT(9.5 6)'), 'I'),
(ST_GeomFromText('POINT(6.5 6)'), 'J'),
(ST_GeomFromText('POINT(6 9.5)'), 'K')

--6a
SELECT SUM(ST_Length(geometry))
FROM roads

--6b
SELECT ST_AsText(geometry), ST_Area(geometry), ST_Perimeter(geometry)
FROM buildings
WHERE name = 'BuildingA'

--6c
SELECT name, ST_Area(geometry)
FROM buildings
ORDER BY NAME

--6d
SELECT name, ST_Perimeter(geometry)
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2

--6e
SELECT ST_Distance(b.geometry, p.geometry)
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'K'

--6f
SELECT ST_Area(ST_Difference(c.geometry,ST_Buffer(b.geometry, 0.5)))
FROM buildings b, buildings c
WHERE b.name = 'BuildingB' AND c.name = 'BuildingC'

--6g
SELECT NAME
FROM buildings
WHERE ST_Y(ST_Centroid(geometry)) > 4.5

--6h
SELECT ST_Area(ST_SymDifference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))
FROM buildings
WHERE name = 'BuildingC'