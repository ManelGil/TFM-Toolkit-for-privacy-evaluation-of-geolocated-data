/*
  *** Swap Mob Inferred Homes ***
  - Se seleccionan las 5 localizaciones más repetidas para cada uno de los individuos, sin importar si el taxi está o no ocupado.
*/
insert into inferred_homes
select
  id,
  rownumber,
  repetitions,
  latitude001,
  longitude001
from
(
  select
    row_number() over (partition by id order by repetitions desc) rownumber,
    repetitions,
    id, latitude001, longitude001
  from
  (
    select
      count(*) repetitions, id, latitude001, longitude001
    from
      traces
    group by
      id, latitude001, longitude001
  )
)
where
  rownumber <= 5
order by
  id, rownumber
;
commit;