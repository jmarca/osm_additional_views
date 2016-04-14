-- Verify osm_via_osmosis:super_relations on pg

BEGIN;

SELECT relation_id,types
  FROM osm.super_relations
 WHERE FALSE;


ROLLBACK;
