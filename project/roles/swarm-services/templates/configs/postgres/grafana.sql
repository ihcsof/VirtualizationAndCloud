-- TASK 15.b
-- Create a user with a password
CREATE ROLE {{ db_user_grafana }} WITH LOGIN PASSWORD '{{ db_user_grafana_password }}';
-- Create a database
CREATE DATABASE grafana WITH OWNER = '{{ db_user_grafana }}';