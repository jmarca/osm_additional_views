-- Deploy osm_via_osmosis:blacklist_relations to pg

BEGIN;


CREATE TABLE osm.blacklist_relations (
       relation_id integer PRIMARY KEY, -- relation id
       reason TEXT
);

--- some relations are just ugly and not worth fixing
-- source blacklist.sql here
-- \i blacklist-relations.sql


COMMIT;
