-- Verify osm_via_osmosis:relation_roles on pg

BEGIN;

select relation_id,roles
from osm.relation_roles
where false;

ROLLBACK;
