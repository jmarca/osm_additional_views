-- Verify osm_via_osmosis:blacklist_relations on pg

BEGIN;

SELECT relation_id,reason
  FROM osm.blacklist_relations
 WHERE FALSE;

ROLLBACK;
