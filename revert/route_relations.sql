-- Revert osm_via_osmosis:route_relations from pg

BEGIN;

Drop view osm.route_relations;

COMMIT;
