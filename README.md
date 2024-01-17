# Cooperation Company Project
## OSM retail location analysis

Note:
To replicate the process, a Postgres DB must be created with the data for the country. The setup can be done following the steps given by: https://learnosm.org/en/osm-data/osm2pgsql/

With the created, the enumerated steps must be followed:<br>
  PostgreSQL: 1_create_grid.sql<br>
  PostgreSQL:2_create_amenities.sql<br>
  Python:3_model1.ipynb<br>
  PostgreSQL:4_address_filter_gap.sql<br>
  Python:5_model2_address_colab.ipynb<br>
