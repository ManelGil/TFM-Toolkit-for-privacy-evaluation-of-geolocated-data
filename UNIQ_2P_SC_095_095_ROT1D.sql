--------------------------------------------------------
--  DDL for Procedure UNIQ_2P_SC_095_095_ROT1D
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."UNIQ_2P_SC_095_095_ROT1D" 
(
  TIME_INTERVAL_2 IN NUMBER DEFAULT 15 -- Minutos/2
) AS
BEGIN
  declare
  
    found_n_times number;
    
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    
    TYPE unique_trace IS RECORD (lat001 T_TRANS_SCL_105_09.latitude001%TYPE, long001 T_TRANS_SCL_105_09.longitude001%TYPE, dt T_TRANS_SCL_105_09.datetime%TYPE); -- Record con latitud y longitud con precisi�n .001 y timestamp
    TYPE unique_trace_tbl IS TABLE OF unique_trace; -- Nested table de trazas
    unique_traces unique_trace_tbl;
    
  begin
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('********** Uniqueness of T_TRANS_SCL_105_09 - 2 Points**********');
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    
    declare
      -- Se obtienen todos los sujetos
      cursor individuals
      is
        select
          distinct id
        from
          T_TRANS_SCL_105_09
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
            T_TRANS_SCL_105_09
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
          T_TRANS_SCL_105_09
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
              T_TRANS_SCL_105_09
            where
              latitude001=to_number(unique_traces(2).lat001)
              and
              longitude001=to_number(unique_traces(2).long001)
              and
              datetime >= to_timestamp(unique_traces(2).dt)-numtodsinterval(TIME_INTERVAL_2,'minute') and datetime <= to_timestamp(unique_traces(2).dt)+numtodsinterval(TIME_INTERVAL_2,'minute')
          )
        ;
        
        insert into T_UNIQ_2P_SC_095_095_ROT1D
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
END UNIQ_2P_SC_095_095_ROT1D;

/
