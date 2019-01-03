--------------------------------------------------------
--  DDL for Procedure TRANSF_ROT_5DEG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."TRANSF_ROT_5DEG" AS 
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
    DBMS_OUTPUT.PUT_LINE('********** Perturbación - Rotación de 5 grados respecto a 37.735085, -122.441601 **********');
    select systimestamp into start_timestamp from dual;
    DBMS_OUTPUT.PUT_LINE('Start >>>> '||start_timestamp||' <<<<');
    
    -- Trasladar al origen - rotar - trasladar al punto arbitrario
    -- Orden de las operaciones inverso: 1-Trasladar punto arbitrario 2-Rotar 3-Trasladar al origen
    --3-Trasladar al punto arbitrario
    COORD_TRANSLATION(DX_LAT => 37.735085, DY_LONG => -122.441601, T_R1_C1 => M_R1_C1, T_R1_C2 => M_R1_C2, T_R1_C3 => M_R1_C3, T_R2_C1 => M_R2_C1, T_R2_C2 => M_R2_C2, T_R2_C3 => M_R2_C3, T_R3_C1 => M_R3_C1, T_R3_C2 => M_R3_C2, T_R3_C3 => M_R3_C3);
    --2-Rotar ~5º
    COORD_ROTATION(THETA => 0.0872665, M_R1_C1 => M_R1_C1, M_R1_C2 => M_R1_C2, M_R1_C3 => M_R1_C3, M_R2_C1 => M_R2_C1, M_R2_C2 => M_R2_C2, M_R2_C3 => M_R2_C3, M_R3_C1 => M_R3_C1, M_R3_C2 => M_R3_C2, M_R3_C3 => M_R3_C3,
                    R_R1_C1 => M_R1_C1, R_R1_C2 => M_R1_C2, R_R1_C3 => M_R1_C3, R_R2_C1 => M_R2_C1, R_R2_C2 => M_R2_C2, R_R2_C3 => M_R2_C3, R_R3_C1 => M_R3_C1, R_R3_C2 => M_R3_C2, R_R3_C3 => M_R3_C3);
    --1-Trasladar al origen
    COORD_TRANSLATION(DX_LAT => -37.735085, DY_LONG => 122.441601, M_R1_C1 => M_R1_C1, M_R1_C2 => M_R1_C2, M_R1_C3 => M_R1_C3, M_R2_C1 => M_R2_C1, M_R2_C2 => M_R2_C2, M_R2_C3 => M_R2_C3, M_R3_C1 => M_R3_C1, M_R3_C2 => M_R3_C2, M_R3_C3 => M_R3_C3,
                      T_R1_C1 => M_R1_C1, T_R1_C2 => M_R1_C2, T_R1_C3 => M_R1_C3, T_R2_C1 => M_R2_C1, T_R2_C2 => M_R2_C2, T_R2_C3 => M_R2_C3, T_R3_C1 => M_R3_C1, T_R3_C2 => M_R3_C2, T_R3_C3 => M_R3_C3);
    
    insert into T_TRANS_ROT_5DEG
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
END TRANSF_ROT_5DEG;

/
