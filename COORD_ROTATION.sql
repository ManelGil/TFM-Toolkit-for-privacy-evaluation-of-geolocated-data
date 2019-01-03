--------------------------------------------------------
--  DDL for Procedure COORD_ROTATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."COORD_ROTATION" 
(
  THETA IN VARCHAR2 
, M_R1_C1 IN NUMBER DEFAULT 1
, R_R1_C1 OUT NUMBER
, M_R1_C2 IN NUMBER DEFAULT 0
, R_R1_C2 OUT NUMBER
, M_R1_C3 IN NUMBER DEFAULT 0
, R_R1_C3 OUT NUMBER
, M_R2_C1 IN NUMBER DEFAULT 0
, R_R2_C1 OUT NUMBER
, M_R2_C2 IN NUMBER DEFAULT 1
, R_R2_C2 OUT NUMBER
, M_R2_C3 IN NUMBER DEFAULT 0
, R_R2_C3 OUT NUMBER
, M_R3_C1 IN NUMBER DEFAULT 0
, R_R3_C1 OUT NUMBER
, M_R3_C2 IN NUMBER DEFAULT 0
, R_R3_C2 OUT NUMBER
, M_R3_C3 IN NUMBER DEFAULT 1
, R_R3_C3 OUT NUMBER
) AS 
BEGIN
  -- Primera fila
  R_R1_C1 := M_R1_C1*cos(THETA) + M_R1_C2*sin(THETA);
  R_R1_C2 := M_R1_C1*(-sin(THETA)) + M_R1_C2*cos(THETA);
  R_R1_C3 := M_R1_C3;
  
  -- Segunda fila
  R_R2_C1 := M_R2_C1*cos(THETA) + M_R2_C2*sin(THETA);
  R_R2_C2 := M_R2_C1*(-sin(THETA)) + M_R2_C2*cos(THETA);
  R_R2_C3 := M_R2_C3;
  
  -- Tercera fila
  R_R3_C1 := M_R3_C1*cos(THETA) + M_R3_C2*sin(THETA);
  R_R3_C2 := M_R3_C1*(-sin(THETA)) + M_R3_C2*cos(THETA);
  R_R3_C3 := M_R3_C3;
END COORD_ROTATION;

/
