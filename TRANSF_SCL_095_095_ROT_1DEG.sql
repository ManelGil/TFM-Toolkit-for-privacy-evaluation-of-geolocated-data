--------------------------------------------------------
--  DDL for Procedure TRANSF_SCL_095_095_ROT_1DEG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."TRANSF_SCL_095_095_ROT_1DEG" AS 
BEGIN
  declare
    M_R1_C1 number;
    M_R1_C2 number;
    M_R1_C3 number;
    M_R2_C1 number;
    M_R2_C2 number;
    M_R2_C3 number;
    M_R3_C1 number;
    M_R3_C2 number;
    M_R3_C3 number;
    
    start_timestamp timestamp;
    end_timestamp timestamp;
    
  begin
    DBMS_OUTPUT.PUT_LINE('********** Perturbación - Escala 0.95-0.95 + Rotación de 1 grado respecto a 37.735085, -122.441601 **********');
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    -- 1-Trasladar al origen - 2-Escalar - 3-Rotar - 4-Trasladar al punto arbitrario
    -- Orden de las operaciones inverso.
    --4-Trasladar al punto arbitrario
    COORD_TRANSLATION(DX_LAT => 37.735085, DY_LONG => -122.441601, T_R1_C1 => M_R1_C1, T_R1_C2 => M_R1_C2, T_R1_C3 => M_R1_C3, T_R2_C1 => M_R2_C1, T_R2_C2 => M_R2_C2, T_R2_C3 => M_R2_C3, T_R3_C1 => M_R3_C1, T_R3_C2 => M_R3_C2, T_R3_C3 => M_R3_C3);
    --3-Rotar ~1º
    COORD_ROTATION(THETA => 0.0174533, M_R1_C1 => M_R1_C1, M_R1_C2 => M_R1_C2, M_R1_C3 => M_R1_C3, M_R2_C1 => M_R2_C1, M_R2_C2 => M_R2_C2, M_R2_C3 => M_R2_C3, M_R3_C1 => M_R3_C1, M_R3_C2 => M_R3_C2, M_R3_C3 => M_R3_C3,
                    R_R1_C1 => M_R1_C1, R_R1_C2 => M_R1_C2, R_R1_C3 => M_R1_C3, R_R2_C1 => M_R2_C1, R_R2_C2 => M_R2_C2, R_R2_C3 => M_R2_C3, R_R3_C1 => M_R3_C1, R_R3_C2 => M_R3_C2, R_R3_C3 => M_R3_C3);
    --2-Escalar con Sx=0.95 (se acerca al punto de origen) y Sy=0.95 (se acerca al punto de origen)
    COORD_SCALING(SX_LAT => 0.95, SY_LONG => 0.95, M_R1_C1 => M_R1_C1, M_R1_C2 => M_R1_C2, M_R1_C3 => M_R1_C3, M_R2_C1 => M_R2_C1, M_R2_C2 => M_R2_C2, M_R2_C3 => M_R2_C3, M_R3_C1 => M_R3_C1, M_R3_C2 => M_R3_C2, M_R3_C3 => M_R3_C3,
                    S_R1_C1 => M_R1_C1, S_R1_C2 => M_R1_C2, S_R1_C3 => M_R1_C3, S_R2_C1 => M_R2_C1, S_R2_C2 => M_R2_C2, S_R2_C3 => M_R2_C3, S_R3_C1 => M_R3_C1, S_R3_C2 => M_R3_C2, S_R3_C3 => M_R3_C3);
    --1-Trasladar al origen
    COORD_TRANSLATION(DX_LAT => -37.735085, DY_LONG => 122.441601, M_R1_C1 => M_R1_C1, M_R1_C2 => M_R1_C2, M_R1_C3 => M_R1_C3, M_R2_C1 => M_R2_C1, M_R2_C2 => M_R2_C2, M_R2_C3 => M_R2_C3, M_R3_C1 => M_R3_C1, M_R3_C2 => M_R3_C2, M_R3_C3 => M_R3_C3,
                      T_R1_C1 => M_R1_C1, T_R1_C2 => M_R1_C2, T_R1_C3 => M_R1_C3, T_R2_C1 => M_R2_C1, T_R2_C2 => M_R2_C2, T_R2_C3 => M_R2_C3, T_R3_C1 => M_R3_C1, T_R3_C2 => M_R3_C2, T_R3_C3 => M_R3_C3);
    
    insert into T_TRANS_SCL_095_095_ROT_1DEG
    select
      id,
      round(M_R1_C1*latitude+M_R1_C2*longitude+M_R1_C3, 5),
      round(M_R2_C1*latitude+M_R2_C2*longitude+M_R2_C3, 5),
      trunc(round(M_R1_C1*latitude+M_R1_C2*longitude+M_R1_C3, 5), 3),
      trunc(round(M_R2_C1*latitude+M_R2_C2*longitude+M_R2_C3, 5), 3),
      fare,
      datetime
    from
      traces
    ;
    commit;
    
    select systimestamp into end_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('End >>>> '||end_timestamp||' <<<<');
  end;
END TRANSF_SCL_095_095_ROT_1DEG;

/
