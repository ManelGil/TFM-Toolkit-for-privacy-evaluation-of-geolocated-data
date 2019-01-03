--------------------------------------------------------
--  DDL for Procedure COORD_TRANSLATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."COORD_TRANSLATION" 
(
  DX_LAT IN NUMBER 
, DY_LONG IN NUMBER
, M_R1_C1 IN NUMBER DEFAULT 1
, T_R1_C1 OUT NUMBER
, M_R1_C2 IN NUMBER DEFAULT 0
, T_R1_C2 OUT NUMBER
, M_R1_C3 IN NUMBER DEFAULT 0
, T_R1_C3 OUT NUMBER
, M_R2_C1 IN NUMBER DEFAULT 0
, T_R2_C1 OUT NUMBER
, M_R2_C2 IN NUMBER DEFAULT 1
, T_R2_C2 OUT NUMBER
, M_R2_C3 IN NUMBER DEFAULT 0
, T_R2_C3 OUT NUMBER
, M_R3_C1 IN NUMBER DEFAULT 0
, T_R3_C1 OUT NUMBER
, M_R3_C2 IN NUMBER DEFAULT 0
, T_R3_C2 OUT NUMBER
, M_R3_C3 IN NUMBER DEFAULT 1
, T_R3_C3 OUT NUMBER
) AS 
BEGIN
  -- Primera fila
  T_R1_C1 := M_R1_C1;
  T_R1_C2 := M_R1_C2;
  T_R1_C3 := M_R1_C1*DX_LAT + M_R1_C2*DY_LONG + M_R1_C3;
  
  -- Segunda fila
  T_R2_C1 := M_R2_C1;
  T_R2_C2 := M_R2_C2;
  T_R2_C3 := M_R2_C1*DX_LAT + M_R2_C2*DY_LONG + M_R2_C3;
  
  -- Tercera fila
  T_R3_C1 := M_R3_C1;
  T_R3_C2 := M_R3_C2;
  T_R3_C3 := M_R3_C1*DX_LAT + M_R3_C2*DY_LONG + M_R3_C3;
  
END COORD_TRANSLATION;

/
