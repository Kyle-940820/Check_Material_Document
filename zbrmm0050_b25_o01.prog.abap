*&---------------------------------------------------------------------*
*& Include          ZBRMM0050_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OKCODE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CLEAR_OKCODE OUTPUT.
  CLEAR OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_OBJECT_100 OUTPUT.
  IF GO_DOCK IS INITIAL.
    " TREE & ALV OBJECT 생성.
    PERFORM CREATE_OBJECT.

    " TREE 관련 SUBROUTINES.
    PERFORM CREATE_NODE.      " TREE NODE 구현.
    PERFORM SET_TREE100_EVENT." TREE NODE DOUBLE CLICK EVENT 기능 구현.

    " ALV 관련 SUBROUTINES.
    PERFORM SET_LAYOUT_ALV100.    " ALV Layout 구현.
    PERFORM SET_EVENT_ALV100. " ALV Event 구현.
    PERFORM SET_FIELDCAT_ALV100. " ALV Field Catalog 구현.
    PERFORM SET_SORT_ALV100. " ALV Sorting 구현.
    PERFORM INIT_ALV100.      " ALV Display 구현.
  ELSE.
    PERFORM REFRESH_ALV100. " ALV Refresh 구현.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
* GV_PAGE 값에 따라서 'PREV' & 'NEXT' 활성화/비활성화.
  IF GV_PAGE EQ -1.
    SET PF-STATUS 'S200' EXCLUDING 'NEXT'. " '다음' 버튼 비활성화
  ELSEIF GV_PAGE EQ 1.
    SET PF-STATUS 'S200' EXCLUDING 'PREV'. " '이전' 버튼 비활성화
  ELSE.
    SET PF-STATUS 'S200'. " '이전', '다음' 버튼 모두 활성화
  ENDIF.

  SET TITLEBAR 'T200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DATA200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DATA200 OUTPUT.
  IF GV_MODE = 0. " GV_MODE = 0 : Hotspot 클릭했을 때.
    PERFORM GET_DATA_ALV200.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV200 OUTPUT.
  IF GO_CUST200 IS INITIAL.
    " DIALOG CON & ALV200 구현.
    PERFORM CREATE_OBJECT_200.

    " ALV200 LAYOUT & FIELD CATALOG & SORT 설정.
    PERFORM SET_LAYOUT200.
    PERFORM SET_FIELDCAT_ALV200.

    " ALV200 DISPLAY 구현.
    PERFORM INIT_ALV200.
  ELSE.

    " 프로그램 종료 하지 않고, HOTSPOT 두번 이상 클릭 시.
    PERFORM REFRESH_ALV200.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'S110'.
  SET TITLEBAR 'T110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'S120'.
  SET TITLEBAR 'T120'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DATA120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DATA120 OUTPUT.
  PERFORM GET_PO_DATA.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV120 OUTPUT.
  IF GO_CUST120 IS INITIAL.
    " DIALOG CON & ALV120 구현.
    PERFORM CREATE_OBJECT_120.

    " ALV120 LAYOUT & FIELD CATALOG & SORT 설정.
    PERFORM SET_LAYOUT120.
    PERFORM SET_FIELDCAT_ALV120.

    " ALV120 DISPLAY 구현.
    PERFORM INIT_ALV120.

  ELSE.
    " 프로그램 종료 하지 않고, HOTSPOT 두번 이상 클릭 시.
    PERFORM REFRESH_ALV120.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0130 OUTPUT.
  SET PF-STATUS 'S130'.
  SET TITLEBAR 'T130'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DATA130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DATA130 OUTPUT.
  PERFORM GET_DATA_ALV130.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV130 OUTPUT.
  IF GO_CUST130 IS INITIAL.
    " DIALOG CON & ALV130 구현.
    PERFORM CREATE_OBJECT_130.

    " ALV130 LAYOUT & FIELD CATALOG & SORT 설정.
    PERFORM SET_LAYOUT130.
    PERFORM SET_FIELDCAT_ALV130.

    " ALV130 DISPLAY 구현.
    PERFORM INIT_ALV130.

  ELSE.
    " 프로그램 종료 하지 않고, HOTSPOT 두번 이상 클릭 시.
    PERFORM REFRESH_ALV130.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0140 OUTPUT.
  SET PF-STATUS 'S140'.
  SET TITLEBAR 'T140'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DATA140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DATA140 OUTPUT.
  PERFORM GET_SO_DATA.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV140 OUTPUT.
  IF GO_CUST140 IS INITIAL.
    " DIALOG CON & ALV140 구현.
    PERFORM CREATE_OBJECT_140.

    " ALV140 LAYOUT & FIELD CATALOG & SORT 설정.
    PERFORM SET_LAYOUT140.
    PERFORM SET_FIELDCAT_ALV140.

    " ALV140 DISPLAY 구현.
    PERFORM INIT_ALV140.

  ELSE.
    " 프로그램 종료 하지 않고, HOTSPOT 두번 이상 클릭 시.
    PERFORM REFRESH_ALV140.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0150 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0150 OUTPUT.
  SET PF-STATUS 'S150'.
  SET TITLEBAR 'T150'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_DYNNR OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_DYNNR OUTPUT.
  PERFORM SET_ACTIVETAB.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_ACTIVETAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ACTIVETAB .
  "TAB STRIP 에서 선택한 TAB에 따라 불러온 SUB SCREEN 설정.
  CASE TAB_STRIP-ACTIVETAB.
    WHEN 'TAB1'.
      GV_DYNNR = '160'.
    WHEN 'TAB2'.
      GV_DYNNR = '170'.
    WHEN OTHERS.
      TAB_STRIP-ACTIVETAB = 'TAB1'.
      GV_DYNNR = '160'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module GET_DATA170 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DATA170 OUTPUT.
  CLEAR GT_DISPLAY170.
  PERFORM GET_DATA_ALV170.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV170 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV170 OUTPUT.
  IF GO_CUST170 IS INITIAL.
    PERFORM CREATE_OBJECT_170.
    PERFORM SET_LAYOUT170.
    PERFORM SET_FIELDCAT_ALV170.
    PERFORM INIT_ALV170.

  ELSE.
    PERFORM REFRESH_ALV170.
  ENDIF.
ENDMODULE.
