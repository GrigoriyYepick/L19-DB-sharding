CREATE TABLE books (
id bigint not null,
category_id  int not null,
author character varying not null,
title character varying not null,
year int not null );

CREATE INDEX books_category_id_idx ON books USING btree(category_id)


-- setup shards
CREATE EXTENSION postgres_fdw;
GRANT USAGE ON FOREIGN DATA WRAPPER postgres_fdw to postgres;
CREATE SERVER books_1_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS( host '10.5.0.5', port '5432', dbname 'postgres' );

CREATE USER MAPPING FOR postgres
SERVER books_1_server
OPTIONS (user 'postgres', password 'postgres');

CREATE SERVER books_2_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS( host '10.5.0.6', port '5432', dbname 'postgres' );

CREATE USER MAPPING FOR postgres
SERVER books_2_server
OPTIONS (user 'postgres', password 'postgres');


-- create foreign tables

CREATE FOREIGN TABLE books_1 (
id bigint not null,
category_id  int not null,
author character varying not null,
title character varying not null,
year int not null )
SERVER books_1_server
OPTIONS (schema_name 'public', table_name 'books');

CREATE FOREIGN TABLE books_2 (
id bigint not null,
category_id  int not null,
author character varying not null,
title character varying not null,
year int not null )
SERVER books_2_server
OPTIONS (schema_name 'public', table_name 'books');


-- create view

CREATE VIEW books_v AS
    SELECT * FROM books_1
        UNION ALL
    SELECT * FROM books_2


-- create rules

CREATE RULE books_insert AS ON INSERT TO books
DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books
DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books
DO INSTEAD NOTHING;

CREATE RULE books_insert_to_1 AS ON INSERT TO books
WHERE ( category_id = 1 )
DO INSTEAD INSERT INTO books_1 VALUES (NEW.*);

CREATE RULE books_insert_to_2 AS ON INSERT TO books
WHERE ( category_id = 2 )
DO INSTEAD INSERT INTO books_2 VALUES (NEW.*);

/*
INSERT INTO books (id, category_id, author, title, year)
VALUES 
(4,1,'Lina Kostenko','Nepovtornist',1980),
(5,1,'Lina Kostenko','Incrustacii',1994);
*/