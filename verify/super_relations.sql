-- Verify osm_via_osmosis:super_relations on pg

BEGIN;

SELECT relation_id,roles
  FROM osm.relation_roles
 WHERE FALSE;


ROLLBACK;
