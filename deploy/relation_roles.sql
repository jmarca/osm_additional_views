-- Deploy osm_via_osmosis:relation_roles to pg

BEGIN;


create or replace view osm.relation_roles as
select a.relation_id, a.roles from (
    select relation_id, array_agg(distinct member_role) as roles
    from osm.relation_members
    where member_role is not null
      and member_role != ''  group by relation_id
    ) a
join osm.relations b on (b.id = a.relation_id)
where  (b.tags->'network') ~* '^I$|^US:'
  and (b.tags->'direction') is null;


COMMIT;
