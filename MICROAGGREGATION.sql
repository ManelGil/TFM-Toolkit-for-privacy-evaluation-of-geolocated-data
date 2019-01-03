--------------------------------------------------------
--  DDL for Procedure MICROAGGREGATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."MICROAGGREGATION" AS 
BEGIN
  declare
    /* Declaración variables */
    latitude_avg number;
    longitude_avg number;
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    cursor t001
    is
      select
        latitude, longitude
      from
        traces001
      group by
        latitude, longitude
    ;
  begin
    DBMS_OUTPUT.PUT_LINE('********** MicroAggregation **********');
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    for t in t001
    loop
      BEGIN
        select
          --id,
          round(avg(latitude),5),
          round(avg(longitude),5)
          --datetime
        into
          latitude_avg,
          longitude_avg
        from
          traces
        where
          trunc(latitude, 3) = t.latitude
          and
          trunc(longitude, 3) = t.longitude
        ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          goto siguiente_grupo;
      END;
      
      BEGIN
        insert into traces_aggregated
        select
          id,
          latitude_avg,
          longitude_avg,
          datetime
        from
          traces
        where
          trunc(latitude, 3) = t.latitude
          and
          trunc(longitude, 3) = t.longitude
        ;
      END;
      
      --DBMS_OUTPUT.put_line('lat:'||latitude_avg||' long:'||longitude_avg);
      
      <<siguiente_grupo>>
        null;
    end loop;
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
    commit;
  end;
END MICROAGGREGATION;

/
