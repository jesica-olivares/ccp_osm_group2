DROP TABLE IF EXISTS  grid_points_500;

create table grid_points_500  (
  geom geometry
	);

WITH bounds AS (
    SELECT ST_Envelope(ST_Union(way)) AS geom
    FROM planet_osm_point
),
grid_params AS (
    SELECT
        bounds.geom,
        500 AS spacing,
        floor(ST_XMin(bounds.geom)::int / 500) * 500 AS min_x,
        floor(ST_YMin(bounds.geom)::int / 500) * 500 AS min_y,
        ceiling(ST_XMax(bounds.geom)::int / 500) * 500 AS max_x,
        ceiling(ST_YMax(bounds.geom)::int / 500) * 500 AS max_y
    FROM bounds
)
INSERT INTO grid_points_500 (geom)
SELECT ST_SetSRID(ST_MakePoint(x, y), ST_SRID(grid_params.geom))
FROM grid_params,
     generate_series(grid_params.min_x::int, grid_params.max_x::int, grid_params.spacing) AS x,
     generate_series(grid_params.min_y::int, grid_params.max_y::int, grid_params.spacing) AS y
WHERE ST_Intersects(grid_params.geom, ST_SetSRID(ST_MakePoint(x, y), ST_SRID(grid_params.geom)));

select * from grid_points_500
limit 10;

select count(*) from grid_points_500;











