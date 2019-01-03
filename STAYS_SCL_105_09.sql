--------------------------------------------------------
--  DDL for Procedure STAYS_SCL_105_09
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."STAYS_SCL_105_09" 
(
  DISTANCE IN NUMBER DEFAULT 200 -- metros
, TIME_DURATION IN NUMBER DEFAULT 600 -- segundos
) AS 
BEGIN
  /* Declaración de variables */
  declare
    j_prima_dt timestamp;
    j_prima_lat number;
    j_prima_long number;
    diameter number;
    
    current_id varchar2(50);
    current_dt timestamp;
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
    cursor distinct_ids
    is
      select
        distinct id
      from T_TRANS_SCL_105_09
        --where id='abboip'
      ;
  begin
    
    for ids in distinct_ids
    loop 
    
      declare
      
        cursor raw_location
        is
          select
            --row_number() over (partition by id order by datetime) row_id,
            id,
            latitude,
            longitude,
            datetime
          from T_TRANS_SCL_105_09
            where id=ids.id
          order by
            --id,
            datetime
          ;
      
      BEGIN
        current_dt := null;
        current_id := ids.id;
        DBMS_OUTPUT.PUT_LINE('current_id:'||current_id);
        
        DBMS_OUTPUT.PUT_LINE('********** Density-Time Cluster (DT Cluster) **********');
        select systimestamp into start_timestamp from dual;
        DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
        
        for r in raw_location
        loop
          diameter := 0;
          
          
          /* Condición para cumplir i ? j * +1; */
          --if current_dt is null or r.datetime > current_dt then
          continue when current_dt is not null and r.datetime <= current_dt;
            
          /* j*?min j s.t. rj ? ri + ?tdur ; */
          BEGIN
            /*select
              --datetime, to_number(latitude), to_number(longitude)
              datetime, latitude, longitude
            into
              j_prima_dt, j_prima_lat, j_prima_long
            from
            (
              select
                datetime, latitude, longitude
              from T_TRANS_SCL_105_09
              where
                id = r.id
                and
                datetime >= to_timestamp(r.datetime) + numtodsinterval(TIME_DURATION,'second')
              order by
                datetime
            )
            where
              rownum = 1
            ;*/
            
            select /*+ FIRST_ROWS(1) */
              datetime, latitude, longitude
            into
              j_prima_dt, j_prima_lat, j_prima_long
            from T_TRANS_SCL_105_09
            where
              id = r.id
              and
              datetime >= to_timestamp(r.datetime) + numtodsinterval(TIME_DURATION,'second')
            order by
              datetime
            fetch first row only
            ;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              continue;
          END;
          --DBMS_OUTPUT.PUT_LINE(r.datetime + numtodsinterval(TIME_DURATION,'second'));
          --DBMS_OUTPUT.PUT_LINE('id:'||r.datetime||', lat:'||r.latitude||', long:'||r.longitude); 
          --DBMS_OUTPUT.PUT_LINE('id:'||j_prima_dt||', lat:'||j_prima_lat||', long:'||j_prima_long); 
          
          /* Cálculo de Diameter(R,i, j*) */
          -- Spherical Law of Cosines - https://www.movable-type.co.uk/scripts/latlong.html
          --https://www.geodatasource.com/developers/sql
          begin
            -- Se obtiene la distancia máxima entre todas las trazas
            with traces_interval as
            (
              select
                latitude, longitude, rownum row_num
              from
                T_TRANS_SCL_105_09
              where
                id = r.id
                and datetime >= r.datetime
                and datetime <= j_prima_dt
            )
            select
              max(NVL(to_number(6387000.7),0) * ACOS(round((sin(NVL(to_number(dt1.latitude),0) / to_number(57.29577951)) * SIN(NVL(dt2.latitude,0) / to_number(57.29577951))) +
                (COS(NVL(dt1.latitude,0) / to_number(57.29577951)) * COS(NVL(dt2.latitude,0) / to_number(57.29577951)) *
                COS(NVL(dt2.longitude,0) / to_number(57.29577951) - NVL(dt1.longitude,0)/ to_number(57.29577951))),37))) calc
            into
              diameter
            from
              traces_interval dt1, traces_interval dt2
            where
              dt1.row_num < dt2.row_num -- Evitar repeticiones
            ;
          exception
            when NO_DATA_FOUND then
              continue;
            when OTHERS then
              continue;
          end;
          
          --DBMS_OUTPUT.PUT_LINE('diameter:'||diameter);
          
          /* if ( Diameter(R,i, j*) > ?lroam ) */
          if diameter > DISTANCE then
            continue;
          else
            /* j*? max j s.t. Diameter(R,i, j) ? ?lroam ; */
            declare cursor greatest_location
            is
              select
                --row_number() over (partition by id order by datetime) row_id,
                id,
                latitude,
                longitude,
                datetime
              from T_TRANS_SCL_105_09
              where
                id=r.id
                and datetime > j_prima_dt
              order by
                datetime
              ;
            
            BEGIN
              for g in greatest_location
              loop
                exit when 6387700 * ACOS(round((sin(NVL(to_number(r.latitude),0) / to_number(57.29577951)) * SIN(NVL(g.latitude,0) / to_number(57.29577951))) +
                    (COS(NVL(r.latitude,0) / to_number(57.29577951)) * COS(NVL(g.latitude,0) / to_number(57.29577951)) *
                    COS(NVL(g.longitude,0) / to_number(57.29577951) - NVL(r.longitude,0)/ to_number(57.29577951))),37)) > DISTANCE;
                /*
                if 6387700 * ACOS(round((sin(NVL(to_number(r.latitude),0) / to_number(57.29577951)) * SIN(NVL(g.latitude,0) / to_number(57.29577951))) +
                    (COS(NVL(r.latitude,0) / to_number(57.29577951)) * COS(NVL(g.latitude,0) / to_number(57.29577951)) *
                    COS(NVL(g.longitude,0) / to_number(57.29577951) - NVL(r.longitude,0)/ to_number(57.29577951))),37)) > DISTANCE then
                  goto add_to_cluster;*/
                --else
                  j_prima_dt := g.datetime;
                  j_prima_lat := g.latitude;
                  j_prima_long := g.longitude;
                --end if;
              end loop;
              
              --close greatest_location;
            END;
            
            --DBMS_OUTPUT.PUT_LINE('row_id:'||r.row_id);
            
            /* Insertar stay en S (set of stays) -> t_stays_scl_105_09 */
            /* S? S?(Medoid(R,i, j*),ti ,t j* ) ; */
            insert into t_stays_scl_105_09
            (
              id, latitude, longitude, start_dt, end_dt
            )
            select
              r.id, round(avg(latitude),5), round(avg(longitude),5), r.datetime, j_prima_dt
            from
              T_TRANS_SCL_105_09
            where
              id = r.id
              and datetime >= r.datetime
              and datetime <= j_prima_dt
            ;
            
            /* i ? j * +1; */
            current_dt := j_prima_dt;
            
          end if;
        end loop;
      end;
    end loop;
    
    commit;
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
    DBMS_OUTPUT.PUT_LINE('current_dt:'||current_dt);
    
  END;
END STAYS_SCL_105_09;

/
