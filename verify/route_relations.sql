-- Verify osm_via_osmosis:route_relations on pg

BEGIN;

SELECT id,version,user_id,tstamp,changeset_id,tags,
       network,refstring,refnum,direction
  FROM osm.route_relations
 WHERE FALSE;

ROLLBACK;
