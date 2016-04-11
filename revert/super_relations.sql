-- Revert osm_via_osmosis:super_relations from pg

BEGIN;

DROP VIEW osm.super_relations;

COMMIT;
