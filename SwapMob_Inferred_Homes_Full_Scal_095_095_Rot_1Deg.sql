/*
  *** Swap Mob Inferred Homes ***
  - Se seleccionan las 5 localizaciones más repetidas para cada uno de los individuos, sin importar si el taxi está o no ocupado.
*/

--No muestra headers para los resultados
set heading off
--Oculta los comandos SQL ejecutados
set echo off
--Quita los posibles espacios en blanco al final de la línea
set trimspool on
--Se muestra el número de registros recuperados
set feedback on
--Se muestran los resultados por el output
set termout on

--Número de caracteres por línea
set linesize 100
--Número de páginas. 0 indica que no hay breaks.
set pagesize 0

-- https://docs.oracle.com/cd/B19306_01/server.102/b14357/ch12043.htm
spool Results/Execution_Result_Inferred_Homes_Full.log

drop table INF_HOMES_SCL_095_095_ROT_1DEG;

CREATE TABLE "SYS"."INF_HOMES_SCL_095_095_ROT_1DEG" 
(	"ID" VARCHAR2(50 BYTE), 
	"POSITION" NUMBER(*,0), 
	"REPETITIONS" NUMBER(*,0), 
	"LATITUDE" NUMBER, 
	"LONGITUDE" NUMBER
) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
NOCOMPRESS LOGGING
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;


insert into INF_HOMES_SCL_095_095_ROT_1DEG
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
      T_TRANS_SCL_095_095_ROT_1DEG
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

spool off