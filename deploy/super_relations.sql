-- Deploy osm_via_osmosis:super_relations to pg

BEGIN;

create or replace view osm.super_relations as
select a.relation_id, a.types from (
    select relation_id,array_agg(distinct member_type) as types
    from osm.relation_members
    group by relation_id
    ) a
join osm.relations b on (b.id = a.relation_id)
where 'R' = ANY ( a.types)
  and (b.tags->'network') is not null;


COMMIT;
