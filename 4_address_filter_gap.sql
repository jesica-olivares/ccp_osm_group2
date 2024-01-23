

DROP TABLE IF EXISTS  filt_address;
CREATE TABLE filt_address AS SELECT osm_id, building, way_area, way FROM planet_osm_polygon
where building is not null;


CREATE OR REPLACE FUNCTION add_gap_to_address(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address ADD COLUMN '|| column_count ||'_count_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address AS points SET '|| column_count ||'_count_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM table_gap_germany amenities
      WHERE ST_DWithin(amenities.point_id, points.way, 500)
	  )';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT add_gap_to_address('gap', 'building');


select count(*) from filt_address
where building_count_gap>0;

--drop table filt_address_model
CREATE TABLE filt_address_model AS SELECT osm_id, building, way_area, building_count_gap, way FROM filt_address where building_count_gap>0;

select count(*) from filt_address_model;

--run multiples types for point 200m
CREATE OR REPLACE FUNCTION add_point_count_columns_from_list_200(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address_model ADD COLUMN '|| column_count ||'_count_200_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address_model AS points SET '|| column_count ||'_count_200_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_point amenities
      WHERE ST_DWithin(points.way, amenities.way, 200)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run multiples types for polygon 200m
CREATE OR REPLACE FUNCTION add_polygon_count_columns_from_list_200(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address_model ADD COLUMN '|| column_count ||'_count_200_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address_model AS points SET '|| column_count ||'_count_200_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_polygon amenities
      WHERE ST_DWithin(points.way, amenities.way, 200)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run multiples types for point 500m
CREATE OR REPLACE FUNCTION add_point_count_columns_from_list_500(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address_model ADD COLUMN '|| column_count ||'_count_500_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address_model AS points SET '|| column_count ||'_count_500_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_point amenities
      WHERE ST_DWithin(points.way, amenities.way, 500)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run multiples types for polygon 500m
CREATE OR REPLACE FUNCTION add_polygon_count_columns_from_list_500(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address_model ADD COLUMN '|| column_count ||'_count_500_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address_model AS points SET '|| column_count ||'_count_500_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_polygon amenities
      WHERE ST_DWithin(points.way, amenities.way, 500)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


--run multiples types for point 10000m
CREATE OR REPLACE FUNCTION add_point_count_columns_from_list_1000(amenities VARCHAR, column_count varchar)
RETURNS VOID AS $$
DECLARE
  amenity_name text;
  sql_query text;
BEGIN
  -- Split the input 'amenities' string into an array
  FOREACH amenity_name IN ARRAY STRING_TO_ARRAY(amenities, ',') 
  LOOP
    -- Create a SQL query to add a column for the amenity count
    sql_query := 'ALTER TABLE filt_address_model ADD COLUMN '|| column_count ||'_count_1000_' || amenity_name || ' INT';

    -- Execute the SQL query to add the column
    EXECUTE sql_query;
    -- Create a SQL query to update the amenity count
    sql_query := 'UPDATE filt_address_model AS points SET '|| column_count ||'_count_1000_' || amenity_name || ' = (
      SELECT COUNT(*)
      FROM planet_osm_point amenities
      WHERE ST_DWithin(points.way, amenities.way, 1000)
      AND amenities.'|| column_count ||'= ' || quote_literal(amenity_name) || ')';
    -- Execute the SQL query to update the count
    EXECUTE sql_query;
  END LOOP;
END;
$$ LANGUAGE plpgsql;



--add amenities in a 500m radius
SELECT add_point_count_columns_from_list_500('restaurant,cafe,fast_food,pub,bar,ice_cream,atm,bicycle_parking,pharmacy', 'amenity');
--
SELECT add_point_count_columns_from_list_500('parking_entrance,charging_station,taxi,bank,post_office,theatre,nightclub,school,events_venue,cinema,marketplace','amenity');
--6h50m
SELECT add_point_count_columns_from_list_500('subway_entrance,stop,tram_stop,station,crossing', 'railway');
--2h59m
SELECT add_point_count_columns_from_list_500('picnic_table,playground,pitch,sports_centre,fitness_centre,fitness_station,swimming_pool', 'leisure');
--3h..
SELECT add_polygon_count_columns_from_list_500('apartments,residential,retail,kiosk,commercial,office,house,detached,roof,train_station,garage', 'building');


SELECT add_point_count_columns_from_list_500('park', 'leisure');

SELECT add_point_count_columns_from_list_500('firepit,slipway,outdoor_seating,garden', 'leisure');

SELECT add_point_count_columns_from_list_500('marina,adult_gaming_centre,dance,,horse_riding,sauna,tanning_salon,water_park,park', 'leisure');

SELECT add_point_count_columns_from_list_200('restaurant,cafe,fast_food,pub,bar,ice_cream', 'amenity');

SELECT add_point_count_columns_from_list_200('atm,bicycle_parking,pharmacy','amenity');

SELECT add_point_count_columns_from_list_200('parking_entrance,charging_station,taxi,bank,post_office,theatre,nightclub,school,events_venue,cinema,marketplace','amenity');

SELECT add_point_count_columns_from_list_200('subway_entrance,stop,tram_stop,station,crossing', 'railway');

SELECT add_point_count_columns_from_list_200('picnic_table,playground,pitch,sports_centre,fitness_centre,fitness_station,swimming_pool', 'leisure');

SELECT add_point_count_columns_from_list_200('firepit,slipway,outdoor_seating,garden,park', 'leisure');

SELECT add_polygon_count_columns_from_list_200('apartments,residential,retail,kiosk,commercial,office', 'building');

SELECT add_polygon_count_columns_from_list_200('house,detached', 'building');

SELECT add_polygon_count_columns_from_list_200('roof,train_station', 'building');

SELECT add_point_count_columns_from_list_1000('pharmacy,bank,bicycle_parking', 'amenity');

SELECT add_polygon_count_columns_from_list_200('garage', 'building') ;


ALTER TABLE filt_address_model ADD COLUMN centroid GEOMETRY;
UPDATE filt_address_model SET centroid = ST_PointOnSurface(way);

ALTER TABLE planet_osm_polygon ADD COLUMN centroid GEOMETRY;
UPDATE planet_osm_polygon SET centroid = ST_PointOnSurface(way);

