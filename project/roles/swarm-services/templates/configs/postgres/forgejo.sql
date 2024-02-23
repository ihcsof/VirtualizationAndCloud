-- TASK 15.a
-- Create a user with a password
CREATE ROLE {{ db_user_forgejo }} WITH LOGIN PASSWORD '{{ db_user_forgejo_password }}';
-- Create a database
CREATE DATABASE forgejo WITH OWNER = '{{ db_user_forgejo }}';