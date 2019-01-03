--------------------------------------------------------
--  DDL for Procedure BEGIN_END_SCL_1_07
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."BEGIN_END_SCL_1_07" 
(
  TIME_DURATION IN NUMBER DEFAULT 21600
) AS 
BEGIN
  declare
  
    current_id varchar2(50) := '';
    first_dt timestamp;
    first_lat number;
    first_long number;
    
    last_dt timestamp;
    last_lat number;
    last_long number;
    
    current_dt number;
    
    start_dt timestamp;
    end_dt timestamp;
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    cursor traces_cursor is
    select
      id, latitude, longitude, datetime
    from
      T_TRANS_SCL_1_07
    order by
      id, datetime
    ;
    
  begin
    DBMS_OUTPUT.PUT_LINE('********** Begin-End Location Finder **********');
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    
    for trace_reg in traces_cursor
    loop
      if current_id is null or current_id != trace_reg.id then
        current_id := trace_reg.id;
        first_dt := trace_reg.datetime;
        first_lat := trace_reg.latitude;
        first_long := trace_reg.longitude;
        
        last_dt := trace_reg.datetime;
        last_lat := trace_reg.latitude;
        last_long := trace_reg.longitude;
        
        continue;
        --DBMS_OUTPUT.PUT_LINE('current_id:'||current_id);
      end if;
      
      --current_dt := extract (day from trace_reg.datetime - last_dt)*24*60*60 + extract (hour from trace_reg.datetime - last_dt)*60*60 + extract (minute from trace_reg.datetime - last_dt)*60 + extract (second from trace_reg.datetime - last_dt);
        --DBMS_OUTPUT.PUT_LINE('current_dt: '||current_dt);
        --DBMS_OUTPUT.PUT_LINE('first_dt: '||first_dt||', last_dt: '||last_dt||', actual:'||trace_reg.datetime);
        --DBMS_OUTPUT.PUT_LINE('diferencia: '||trace_reg.datetime - last_dt);
      
      if extract (day from trace_reg.datetime - last_dt)*24*60*60
        + extract (hour from trace_reg.datetime - last_dt)*60*60
        + extract (minute from trace_reg.datetime - last_dt)*60
        + extract (second from trace_reg.datetime - last_dt)
      > TIME_DURATION then
        --DBMS_OUTPUT.PUT_LINE('inserta');
        --DBMS_OUTPUT.PUT_LINE('current_dt: '||current_dt);
        --DBMS_OUTPUT.PUT_LINE('first_dt: '||first_dt||', last_dt: '||last_dt||', actual:'||trace_reg.datetime);
        
        -- Se añaden el inicio y el fin de la jornada como POIs del individuo
        insert into T_BEGIN_END_SCL_1_07 (id, latitude, longitude, datetime)
        values (current_id, first_lat, first_long, first_dt);
        insert into T_BEGIN_END_SCL_1_07 (id, latitude, longitude, datetime)
        values (current_id, last_lat, last_long, last_dt);
        
        -- Se establece el registro de la iteración actual como el primero del siguiente período
        first_dt := trace_reg.datetime;
        first_lat := trace_reg.latitude;
        first_long := trace_reg.longitude;
      end if;
      
      last_dt := trace_reg.datetime;
      last_lat := trace_reg.latitude;
      last_long := trace_reg.longitude;
      
    end loop;
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
  end;
END BEGIN_END_SCL_1_07;

/
