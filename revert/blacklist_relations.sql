-- Revert osm_via_osmosis:blacklist_relations from pg

BEGIN;

DROP TABLE osm.blacklist_relations;

COMMIT;
