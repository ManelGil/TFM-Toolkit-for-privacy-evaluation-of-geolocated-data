--------------------------------------------------------
--  DDL for Procedure SWAPPING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."SWAPPING" 
(
  TIME_DURATION IN NUMBER -- segundos
, DISTANCE IN NUMBER -- metros
) AS 
BEGIN
  -- Se dejan de calcular las distancias entre todos los puntos dentro del tiempo para buscar aquellos puntos que se encuentran
  -- dentro de la distancia máxima.
  declare
    /* Declaración variables */
    --start_dt timestamp;
    end_dt timestamp;
    current_dt timestamp;
    next_dt timestamp;
    
    dist_diameter number;
    
    current_loop number := 1;
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    swap_id_1 varchar2(50);
    swap_id_2 varchar2(50);
    swap_dt_1 timestamp;
    swap_dt_2 timestamp;
    
    updates number := 0;
    
  begin
    
    DBMS_OUTPUT.PUT_LINE('********** Swapping **********');
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    select
      min(datetime)
    into
      current_dt
    from
      traces
    ;
    select
      max(datetime)
      --to_timestamp('18/05/08 22:00:04,000000')
    into
      end_dt
    from
      traces
      --dual
    ;
    
    next_dt := current_dt + numtodsinterval(TIME_DURATION,'second');
    
    DBMS_OUTPUT.PUT_LINE('mindate:'||current_dt||', maxdate:'||end_dt||', next_dt:'||next_dt);
    
    while next_dt <= end_dt
    loop
    
      insert /*+ APPEND */ into T_SWAPS_TMP
      --insert into T_SWAPS_TMP
      with
      traces_interval as
      (
        select
          rownum row_num, id, latitude, longitude, datetime
        from
          traces
        where
          datetime >= current_dt
          and
          datetime < next_dt
      ),
      pairs_in_threshold as -- Pares de trazas sin repetición que se encuentran dentro del umbral
      (
        -- https://www.mullie.eu/geographic-searches/
        select
          pairs.id1, pairs.id2, pairs.datetime1, pairs.datetime2
        from
        (
          select
            /*6387700 * ACOS(round((sin(NVL(to_number(t_interval_1.latitude),0) / to_number(57.29577951)) * SIN(NVL(t_interval_2.latitude,0) / to_number(57.29577951))) +
              (COS(NVL(t_interval_1.latitude,0) / to_number(57.29577951)) * COS(NVL(t_interval_2.latitude,0) / to_number(57.29577951)) *
              COS(NVL(t_interval_2.longitude,0) / to_number(57.29577951) - NVL(t_interval_1.longitude,0)/ to_number(57.29577951))),37)) dist,*/
            t_interval_1.row_num row_num1,
            t_interval_1.id id1,
            t_interval_1.datetime datetime1,
            t_interval_2.row_num row_num2,
            t_interval_2.id id2,
            t_interval_2.datetime datetime2
          from
            traces_interval t_interval_1
            inner join traces_interval t_interval_2
              on t_interval_2.latitude between t_interval_1.latitude - ((DISTANCE/6387700)*to_number(57.29577951)) and t_interval_1.latitude + ((DISTANCE/6387700)*to_number(57.29577951)) and
                t_interval_2.longitude between t_interval_1.longitude - (((DISTANCE/6387700)/COS(NVL(t_interval_1.latitude,0) / to_number(57.29577951)))*to_number(57.29577951))
                                                and t_interval_1.longitude + (((DISTANCE/6387700)/COS(NVL(t_interval_1.latitude,0) / to_number(57.29577951)))*to_number(57.29577951))
          where
            t_interval_1.row_num < t_interval_2.row_num -- Evitar repeticiones
            and
            t_interval_1.id != t_interval_2.id -- Evitar intercambiar trazas del mismo individuo
        ) pairs
        --where
          --pairs.dist < DISTANCE -- Umbral de distancia
      ),
      possible_swaps as -- Todos los posibles swaps - Todas las trazas que intercambiar con rownum y total de registros para poder partir en 2 el record set
      (
        select
          rownum row_num, count(*) over (order by 1) total_poss_swaps, id1, datetime1
        from
        (
          select
            id1, datetime1
          from
            pairs_in_threshold
          union -- Hace el distinct
          select
            id2, datetime2
          from
            pairs_in_threshold
        )
      ),
      possible_swaps_first_half as
      (
        select
          rownum row_num, id1, datetime1
        from
        (
          select
            id1, datetime1
          from
            possible_swaps
          where
            row_num <= trunc(total_poss_swaps/2)
          order by
            DBMS_RANDOM.value
        )
      ),
      possible_swaps_second_half as
      (
        select
          rownum row_num, id1, datetime1
        from
        (
          select
            id1, datetime1
          from
            possible_swaps
          where
            row_num > trunc(total_poss_swaps/2)
          order by
            DBMS_RANDOM.value
        )
      ),
      -- Se sacan todos los swaps (en las dos direcciones) para poder hacer las DML con un BULK por rendimiento
      t_swaps as
      (
        select
          possible_swaps_first_half.id1 id1, possible_swaps_first_half.datetime1 datetime1,
          possible_swaps_second_half.id1 id2, possible_swaps_second_half.datetime1 datetime2
        from
          possible_swaps_first_half
          inner join possible_swaps_second_half on possible_swaps_first_half.row_num = possible_swaps_second_half.row_num
        union
          select
            possible_swaps_second_half.id1, possible_swaps_second_half.datetime1,
            possible_swaps_first_half.id1, possible_swaps_first_half.datetime1
          from 
            possible_swaps_second_half
            inner join possible_swaps_first_half on possible_swaps_second_half.row_num = possible_swaps_first_half.row_num
      )
      select
        id1, datetime1, id2, datetime2
      --BULK COLLECT INTO swaps
      from
        t_swaps
      ;
      commit;
      
      --select systimestamp into start_timestamp from dual;
      --DBMS_OUTPUT.PUT_LINE('Fin insert into >>>> '||start_timestamp||' <<<<');
      
      -- Actualizar timestamp
      current_dt := next_dt;
      next_dt := current_dt + numtodsinterval(TIME_DURATION,'second');
      
      current_loop := current_loop + 1;
    end loop;
    
    commit;
    
    -- Se realizan todos los swaps que se encuentran en la tabla T_SWAPS_TMP en orden
    declare
      cursor swaps is
      select
        id_orig, dt_orig, id_swap, dt_swap
      from
        T_SWAPS_TMP
      order by
        dt_orig;
    begin
      for swap in swaps
      loop
        -- Se hace el swap
        --update SWAPPED_TRACES set id=swap.id_swap where id = swap.id_orig and datetime <= swap.dt_orig;
        if swap.dt_orig > swap.dt_swap then
          update SWAPPED_TRACES set id=swap.id_swap where id = swap.id_orig and datetime <= swap.dt_orig and datetime >= to_timestamp(trunc(swap.dt_swap));
          updates := updates + SQL%ROWCOUNT;
          --dbms_output.put_line('Pasa');
        else
          update SWAPPED_TRACES set id=swap.id_swap where id = swap.id_orig and datetime <= swap.dt_orig and datetime >= to_timestamp(trunc(swap.dt_orig));
          updates := updates + SQL%ROWCOUNT;
        end if;
        --dbms_output.put_line('update:'||SQL%ROWCOUNT);
        --updates := updates + SQL%ROWCOUNT;
        
        if updates > 2500000 then
          dbms_output.put_line('Updates:'||updates);
          updates := updates - 2500000;
          commit;
        end if;
      end loop;
    end;
    dbms_output.put_line('Updates:'||updates);
    commit;
    
    DBMS_OUTPUT.PUT_LINE('Final loop: '||current_loop);
    DBMS_OUTPUT.PUT_LINE('mindate:'||current_dt||', maxdate:'||end_dt||', next_dt:'||next_dt);
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
  end;

END SWAPPING;

/
