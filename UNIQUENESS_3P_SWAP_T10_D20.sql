--------------------------------------------------------
--  DDL for Procedure UNIQUENESS_3P_SWAP_T10_D20
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."UNIQUENESS_3P_SWAP_T10_D20" 
(
  TIME_INTERVAL_2 IN NUMBER DEFAULT 15 -- Minutos/2
) AS
BEGIN
  declare
  
    found_n_times number;
    
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    
    TYPE unique_trace IS RECORD (lat001 SWAPPED_TRACES_T10_D20.latitude001%TYPE, long001 SWAPPED_TRACES_T10_D20.longitude001%TYPE, dt SWAPPED_TRACES_T10_D20.datetime%TYPE); -- Record con latitud y longitud con precisi�n .001 y timestamp
    TYPE unique_trace_tbl IS TABLE OF unique_trace; -- Nested table de trazas
    unique_traces unique_trace_tbl;
    
  begin
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('********** Uniqueness of SWAPPED_TRACES_T10_D20 - 2 Points**********');
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    
    declare
      -- Se obtienen todos los sujetos
      cursor individuals
      is
        select
          distinct id
        from
          SWAPPED_TRACES_T10_D20
      ;
    begin
      -- Se itera por cada uno de los sujetos del dataset
      for i in individuals
      loop
        
        -- Selecci�n de n trazas del sujeto sobre el que se itera
        select
          latitude001, longitude001, datetime
        BULK COLLECT INTO unique_traces
        from
        (
          select
            latitude001, longitude001, datetime
          from
            SWAPPED_TRACES_T10_D20
          where
            id = i.id
          order by
            dbms_random.value
        )
        where
          rownum <= 2;
        
        -- Se salta al siguiente sujeto si no se han encontrado 2 trazas
        --dbms_output.put_line('unique_traces.count:'||unique_traces.count);
        continue when unique_traces.count < 2;
        
        found_n_times := 0;
        
        -- Buscar cantidad de individuos con las mismas trazas que las seleccionadas previamente (2 trazas)
        -- 2o nivel
        select
          count(distinct id)
        into
          found_n_times
        from
          SWAPPED_TRACES_T10_D20
        where
          latitude001=to_number(unique_traces(1).lat001)
          and
          longitude001=to_number(unique_traces(1).long001)
          and
          datetime >= to_timestamp(unique_traces(1).dt)-numtodsinterval(TIME_INTERVAL_2,'minute') and datetime <= to_timestamp(unique_traces(1).dt)+numtodsinterval(TIME_INTERVAL_2,'minute')
          and
          id in
          (
            -- 1er nivel
            select
              distinct id
            from
              SWAPPED_TRACES_T10_D20
            where
              latitude001=to_number(unique_traces(2).lat001)
              and
              longitude001=to_number(unique_traces(2).long001)
              and
              datetime >= to_timestamp(unique_traces(2).dt)-numtodsinterval(TIME_INTERVAL_2,'minute') and datetime <= to_timestamp(unique_traces(2).dt)+numtodsinterval(TIME_INTERVAL_2,'minute')
          )
        ;
        
        insert into T_UNIQUENESS_3P_SWAP_T10_D20
        (
          id,
          p1_latitude, p1_longitude, p1_datetime,
          p2_latitude, p2_longitude, p2_datetime,
          times_found
        )
        values
        (
          i.id,
          -- 1a traza
          unique_traces(1).lat001, unique_traces(1).long001, unique_traces(1).dt,
          -- 2a traza
          unique_traces(2).lat001, unique_traces(2).long001, unique_traces(2).dt,
          -- Veces encontrado
          found_n_times
        )
        ;
        
        --DBMS_OUTPUT.PUT_LINE('id:'||i.id);
      end loop;
      
    commit;
    end;
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
  end;
END UNIQUENESS_3P_SWAP_T10_D20;

/
