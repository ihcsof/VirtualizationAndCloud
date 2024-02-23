-- TASK 15.c
-- Create a user with a password
CREATE ROLE {{ db_user_keycloak }} WITH LOGIN PASSWORD '{{ db_user_keycloak_password }}';
-- Create a database
CREATE DATABASE keycloak WITH OWNER = '{{ db_user_keycloak }}';