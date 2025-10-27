CREATE EXTENSION postgis

select * from t2018_kar_buildings
select * from t2019_kar_buildings

--1
create view new_buildings as
select b2019. *
from t2019_kar_buildings b2019
left join t2018_kar_buildings b2018 on b2019.geom = b2018.geom
where b2018.geom is null

--2
select * from t2018_kar_poi_table
select * from t2019_kar_poi_table

create view new_poi as
select p2019.geom, p2019.type
from t2019_kar_poi_table p2019
left join t2018_kar_poi_table p2018 on p2019.geom = p2018.geom
where p2018.geom is null

select p.type, count(*) as poi_count
from new_poi p
join new_buildings b on ST_Dwithin(p.geom::geography, b.geom::geography, 500)
group by p.type
order by poi_count desc

SELECT COUNT(*) AS total_poi
FROM new_poi;

--3
create table streets_reprojected as
select * , ST_Transform(geom, 3068) as geom_3068
from t2019_kar_streets

--4
create table input_points (
	id serial primary key,
	geom GEOMETRY(POINT)
	
)

insert into input_points (geom) values
(ST_GeomFromText('POINT(8.36093 49.03174)')),
(ST_GeomFromText('POINT(8.39876 49.00644)'))


--5
update input_points
set geom = ST_SetSRID(geom,4326)

update input_points
set geom = ST_Transform(geom, 3068)

--select ST_SRID(geom) from input_points 

--6
select ST_SRID(geom)
from t2019_kar_street_node

with lines as (
select ST_MakeLine(geom) as geom_line
from input_points
)
select  sn2019. *
from t2019_kar_street_node sn2019, lines l
where ST_DWithin(ST_Transform(sn2019.geom, 3068), l.geom_line, 200)

--7
select * from  t2019_kar_land_use_a

select count (distinct p2019.poi_id)
from t2019_kar_poi_table p2019, t2019_kar_land_use_a l2019
where p2019.type = 'Sporting Goods Store' and l2019.type like 'Park (City/County)'
and ST_DWithin(p2019.geom::geography, l2019.geom::geography, 300)

--8
create table t2019_kar_bridges as
select ST_Intersection(r2019.geom, w2019.geom) as geom
from t2019_kar_railways r2019
join t2019_kar_water_lines w2019 on ST_Intersects(r2019.geom, w2019.geom)
where ST_Intersection(r2019.geom, w2019.geom)


select * from t2019_kar_bridges

