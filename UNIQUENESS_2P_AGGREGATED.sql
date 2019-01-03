--------------------------------------------------------
--  DDL for Procedure UNIQUENESS_2P_AGGREGATED
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."UNIQUENESS_2P_AGGREGATED" 
(
  TIME_INTERVAL_2 IN NUMBER DEFAULT 15 -- Minutos/2
) AS
BEGIN
  declare
  
    found_n_times number;
    
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    
    TYPE unique_trace IS RECORD (lat001 TRACES_AGGREGATED.latitude001%TYPE, long001 TRACES_AGGREGATED.longitude001%TYPE, dt TRACES_AGGREGATED.datetime%TYPE); -- Record con latitud y longitud con precisión .001 y timestamp
    TYPE unique_trace_tbl IS TABLE OF unique_trace; -- Nested table de trazas
    unique_traces unique_trace_tbl;
    
  begin
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('********** Uniqueness of TRACES_AGGREGATED - 2 Points**********');
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    
    declare
      -- Se obtienen todos los sujetos
      cursor individuals
      is
        select
          distinct id
        from
          TRACES_AGGREGATED
      ;
    begin
      -- Se itera por cada uno de los sujetos del dataset
      for i in individuals
      loop
        
        -- Selección de n trazas del sujeto sobre el que se itera
        select
          latitude001, longitude001, datetime
        BULK COLLECT INTO unique_traces
        from
        (
          select
            latitude001, longitude001, datetime
          from
            TRACES_AGGREGATED
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
          TRACES_AGGREGATED
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
              TRACES_AGGREGATED
            where
              latitude001=to_number(unique_traces(2).lat001)
              and
              longitude001=to_number(unique_traces(2).long001)
              and
              datetime >= to_timestamp(unique_traces(2).dt)-numtodsinterval(TIME_INTERVAL_2,'minute') and datetime <= to_timestamp(unique_traces(2).dt)+numtodsinterval(TIME_INTERVAL_2,'minute')
          )
        ;
        
        insert into T_UNIQUENESS_2P_AGGREGATED
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
END UNIQUENESS_2P_AGGREGATED;

/
