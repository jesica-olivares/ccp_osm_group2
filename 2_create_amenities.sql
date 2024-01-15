DROP TABLE IF EXISTS  amenity_counts;

/*create table with amenities*/
CREATE TABLE amenity_counts (
  point_id geometry,
  amenity_count_restaurant INTEGER
);

select * from amenity_counts;

/*add points with count of restaurants in 200m*/
INSERT INTO amenity_counts (
  point_id,
  amenity_count_restaurant
)
SELECT points.geom as points,
  COALESCE(COUNT(*), 0) AS amenity_count
FROM
  "Regular_points_200m" as points
LEFT JOIN planet_osm_point as amenities ON ST_DWithin(points.geom, amenities.way, 200)
WHERE
  amenities.amenity = 'restaurant'
group by points

select * from amenity_counts
limit 10;

select * from amenity_counts
where amenity_count_restaurant>0
order by amenity_count_restaurant desc;

select count(point_id) from amenity_counts;


select count(id) from "Regular_points_200m";

/*add points with no restaurants added*/
INSERT INTO amenity_counts (
  point_id,
  amenity_count_restaurant
)
SELECT geom as point_id, 0 as amenity_count_restaurant from "Regular_points_200m" points 
LEFT JOIN amenity_counts amenities ON points.geom = amenities.point_id
WHERE amenities.point_id IS NULL;

/*add column for cafes*/
ALTER TABLE amenity_counts
ADD COLUMN amenity_count_cafe INT;

/*add count of cafes*/
UPDATE amenity_counts points
SET amenity_count_cafe = (
  SELECT COUNT(*)
  FROM planet_osm_point amenities
  WHERE ST_DWithin(points.point_id, amenities.way, 200)
  AND amenities.amenity = 'cafe'
);

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
    sql_query := 'ALTER TABLE amenity_counts ADD COLUMN '|| column_count ||'_count_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE amenity_counts AS points SET '|| column_count ||'_count_' || amenity_name || ' = (
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
    sql_query := 'ALTER TABLE amenity_counts ADD COLUMN '|| column_count ||'_count_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE amenity_counts AS points SET '|| column_count ||'_count_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_polygon amenities
      WHERE ST_DWithin(points.point_id, amenities.way, 500)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

select * from amenity_counts
limit 10;

--run the function to add fast_food,pub,bar
SELECT add_point_count_columns_from_list('fast_food,pub,bar', 'amenity');

--run the function to add multiple columns
SELECT add_point_count_columns_from_list('bicycle_parking,parking_entrance,atm,charging_station,pharmacy,parking,taxi,bank,ice_cream,post_office,place_of_worship,fuel,theatre,nightclub,school,library,events_venue,arts_centre,car_rental,marketplace,cinema,ticket_validator,childcare,public_bookcase,studio','amenity');

--run the function to add railway items
SELECT add_point_count_columns_from_list('tram_stop,stop,subway_entrance,buffer_stop,crossing,station,train_station_entrance', 'railway');

--run the function to add buildings items
SELECT add_polygon_count_columns_from_list('apartments,house', 'building');

--run the function to add buildings items
SELECT add_polygon_count_columns_from_list('detached,residential,shed,garage,terrace,allotment_house,semidetached_house,commercial,bungalow,roof,garages,industrial,retail,school,hut,office,service,carport,kindergarten,construction,hospital,church,university,warehouse,civic,hotel,greenhouse,dormitory,train_station,government,sports_centre,sports_hall,public,kiosk,parking,ruins,storage_tank,chapel,toilets,supermarket,container,bridge,electricity,farm_auxiliary,cabin,silo,fire_station', 'building');




















