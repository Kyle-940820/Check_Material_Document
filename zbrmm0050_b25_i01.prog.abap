*&---------------------------------------------------------------------*
*& Include          ZBRMM0050_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CASE OK_CODE.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0150 INPUT.
  CASE OK_CODE.
    "TAB STRIP 버튼 클릭 시 활성화.
    WHEN 'TAB1' OR 'TAB2'.
      TAB_STRIP-ACTIVETAB = OK_CODE.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE OK_CODE.
    WHEN 'PREV'.
      GV_MODE = 1. " GV_MODE = 1 : 팝업창에서 '이전' or '다음' 버튼을 눌렀을 때.
      PERFORM PREV_PAGE.
    WHEN 'NEXT'.
      GV_MODE = 1. " GV_MODE = 1 : 팝업창에서 '이전' or '다음' 버튼을 눌렀을 때.
      PERFORM NEXT_PAGE.
  ENDCASE.
ENDMODULE.
