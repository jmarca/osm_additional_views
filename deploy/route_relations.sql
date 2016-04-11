-- Deploy osm_via_osmosis:route_relations to pg
-- requires: blacklist_relations
-- requires: relation_roles
-- requires: super_relations

BEGIN;

create or replace view osm.route_relations as
SELECT r.*,
       r.tags->'network' AS network,
       r.tags->'ref' AS refstring,
       CASE
         WHEN (r.tags->'network') ~* '^I$|^US:' THEN CAST( SUBSTRING((r.tags->'ref') from E'\\d+') AS NUMERIC) ELSE NULL
       END AS refnum,
        CASE
         WHEN r.tags->'direction' ~* '^n' THEN 'north'
         WHEN r.tags->'direction' ~* '^s' THEN 'south'
         WHEN r.tags->'direction' ~* '^e'  THEN 'east'
         WHEN r.tags->'direction' ~* '^w'  THEN 'west'
         WHEN r.tags->'ref' ~* '(^n|north)' THEN 'north'
         WHEN r.tags->'ref' ~* '(^s|south)' THEN 'south'
         WHEN r.tags->'ref' ~* '(^e|east)'  THEN 'east'
         WHEN r.tags->'ref' ~* '(^w|west)'  THEN 'west'
         WHEN ARRAY['north','south','east','west'] && rr.roles THEN 'roles'
         ELSE r.tags->'direction'
        END
AS direction
FROM osm.relations r
   LEFT OUTER JOIN osm.super_relations sr on (r.id = sr.relation_id)
   LEFT OUTER JOIN osm.relation_roles rr on (r.id = rr.relation_id)
   LEFT OUTER JOIN osm.blacklist_relations br on (r.id = br.relation_id)
WHERE
   br.relation_id IS NULL
   AND sr.relation_id IS NULL
   AND (r.tags->'network') ~* '^I$|^US:'
   AND coalesce(r.tags->'addr:state', 'CA') = 'CA'
   AND coalesce( r.tags->'ref', r.tags->'direction' ) is not null;

COMMIT;
