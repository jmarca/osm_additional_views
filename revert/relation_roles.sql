-- Revert osm_via_osmosis:relation_roles from pg

BEGIN;

DROP VIEW osm.relation_roles;

COMMIT;
