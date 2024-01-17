--Create extension pgcrypto;
--select extname from pg_extension;

DROP TABLE IF EXISTS  amenity_counts_500;

/*create table with amenities*/
CREATE TABLE amenity_counts_500 (
  point_id geometry,
  amenity_count_restaurant INTEGER
);

/*add points with count of restaurants in 500m*/
INSERT INTO amenity_counts_500 (
  point_id,
  amenity_count_restaurant
)
SELECT points.geom as points,
  COALESCE(COUNT(*), 0) AS amenity_count
FROM
  grid_points_500 as points
LEFT JOIN planet_osm_point as amenities ON ST_DWithin(points.geom, amenities.way, 500)
WHERE
  amenities.amenity = 'restaurant'
group by points

select * from amenity_counts_500
order by amenity_count_restaurant desc
limit 100;

select count(point_id) from amenity_counts_500;

/*add points with no restaurants added*/
INSERT INTO amenity_counts_500 (
  point_id,
  amenity_count_restaurant
)
SELECT geom as point_id, 0 as amenity_count_restaurant from grid_points_500 points 
LEFT JOIN amenity_counts_500 amenities ON points.geom = amenities.point_id
WHERE amenities.point_id IS NULL;


--run multiples types for point
CREATE OR REPLACE FUNCTION add_point_count_columns_from_list(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE amenity_counts_500 ADD COLUMN '|| column_count ||'_count_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE amenity_counts_500 AS points SET '|| column_count ||'_count_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_point amenities
      WHERE ST_DWithin(points.point_id, amenities.way, 500)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run multiples types for polygon
CREATE OR REPLACE FUNCTION add_polygon_count_columns_from_list(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE amenity_counts_500 ADD COLUMN '|| column_count ||'_count_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE amenity_counts_500 AS points SET '|| column_count ||'_count_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_polygon amenities
      WHERE ST_DWithin(points.point_id, amenities.way, 500)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run the function to add cafe,fast_food,pub,bar
SELECT add_point_count_columns_from_list('cafe,fast_food,pub,bar,ice_cream', 'amenity');

--run the function to add buildings items
SELECT add_polygon_count_columns_from_list('apartments,residential', 'building');
	
--run the function to add multiple columns
SELECT add_point_count_columns_from_list('atm,bicycle_parking,pharmacy','amenity');

--create a copy as backup with the full grid
CREATE TABLE amenity_counts_500_full AS SELECT * FROM amenity_counts_500;

--remove rows without amenities
DELETE FROM amenity_counts_500
WHERE (cast(amenity_count_restaurant as integer) + 	cast(amenity_count_cafe as integer) + 	cast(amenity_count_fast_food as integer) + 	cast(amenity_count_pub as integer) + 	cast(amenity_count_bar as integer) + 	cast(amenity_count_ice_cream as integer) + 	cast(building_count_apartments as integer) + 	cast(building_count_residential as integer) + 	cast(amenity_count_atm as integer) + 	cast(amenity_count_bicycle_parking as integer) + 	cast(amenity_count_pharmacy as integer) 
) < 1

--run the function to add the aditional amenities
SELECT add_point_count_columns_from_list('parking_entrance,charging_station,parking,taxi,bank,post_office,place_of_worship,fuel,theatre,nightclub,school,library,events_venue,arts_centre,car_rental,marketplace,cinema,ticket_validator,childcare,public_bookcase,studio','amenity');

--run the function to add railway items
SELECT add_point_count_columns_from_list('tram_stop,stop,subway_entrance,buffer_stop,crossing,station,train_station_entrance', 'railway');

--run the function to add leisure items
SELECT add_point_count_columns_from_list('picnic_table,playground,pitch,sports_centre,fitness_centre,fitness_station,swimming_pool', 'leisure');

SELECT add_point_count_columns_from_list('firepit,slipway,outdoor_seating,marina,adult_gaming_centre,dance,garden,horse_riding,sauna,tanning_salon,water_park,park', 'leisure');

alter table planet_osm_polygon
add column centroid_way geometry;

update planet_osm_polygon
set centroid_way = ST_Centroid(way)

--run the function to add buildings items
SELECT add_polygon_count_columns_from_list('detached,house,shed,garage,terrace,allotment_house,semidetached_house', 'building');

SELECT add_polygon_count_columns_from_list('commercial,bungalow,roof,garages,industrial,retail,school,hut,office,service,carport,kindergarten,construction,hospital', 'building');

SELECT add_polygon_count_columns_from_list('church,university,warehouse,civic,hotel,greenhouse,dormitory,train_station,government,sports_centre,sports_hall,public,kiosk,parking', 'building');

SELECT add_polygon_count_columns_from_list('supermarket,fire_station', 'building');




--,ruins,storage_tank,chapel,toilets,container,bridge,electricity,farm_auxiliary,cabin,silo,

select * from amenity_counts_500
limit 10;

select count(*) from amenity_counts_500
limit 10;	

select * from planet_osm_polygon
limit 10;
