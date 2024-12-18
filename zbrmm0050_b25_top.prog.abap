*&---------------------------------------------------------------------*
*& Include          ZBRMM0050_TOP
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*& 사용할 테이블, TYPE, ITAB, WA 선언.
*&--------------------------------------------------------------------*
TABLES: ZTBMM0040, " 자재문서 header
        ZTBMM0041, " 자재문서 item
        ZTBMM1010, " 자재마스터
        ZTBMM1011, " 자재 text table
        ZTBMM1020, " 플랜트 마스터
        ZTBMM0020, " 구매오더 header
        ZTBMM0021, " 구매오더 item
        ZTBPP0030, " 생산오더 header
        ZTBPP0031, " 생산오더 item
        ZTBSD0030, " 판매오더 header
        ZTBSD0031, " 판매오더 item
        ZSBMM0040, " 자재문서 ALV100 structure
        ZSBMM1010, " 자재 마스터 & 자재 텍스트 테이블
        ZSBMM0070, " 인포레코드 & BP명 테이블
        ZSBPP0060, " BOM HEADER & 라우팅 HEADER & 라우팅 ITEM
        ZSBSD0080. " 완제품 마스터 & 국가 마스터
*&---------------------------------------------------------------------*
*& NODE DISPLAY TYPE & WA & ITAB
*&---------------------------------------------------------------------*
DATA: OK_CODE TYPE SY-UCOMM.

TYPES: BEGIN OF TS_TREE,
         DOCYEAR TYPE ZTBMM0040-DOCYEAR, " 자재문서 생성연도
         PLTCODE TYPE ZTBMM1020-PLTCODE, " 플랜트 코드
         PLTNAME TYPE ZTBMM1020-PLTNAME, " 플랜트 이름
         MATTYPE TYPE ZTBMM1010-MATTYPE, " 자재 타입
         MATCODE TYPE ZTBMM1010-MATCODE, " 자재 번호
         MATNAME TYPE ZTBMM1011-MATNAME, " 자재 이름
       END OF TS_TREE.

DATA: GS_TREE TYPE TS_TREE, " 트리 노드 WA
      GT_TREE LIKE TABLE OF GS_TREE. " 트리 노드 ITAB

*&---------------------------------------------------------------------*
*& ALV100 DISPLAY TYPE & WA & ITAB
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TS_DISPLAY,
         DOCYEAR  TYPE ZTBMM0040-DOCYEAR, " 자재문서 생성연도
         DOCNUM   TYPE ZTBMM0040-DOCNUM,  " 자재문서 번호
         DOCDATE  TYPE ZTBMM0040-DOCDATE, " 자재문서 생성일자
         PLTCODE  TYPE ZTBMM1020-PLTCODE, " 플랜트 코드
         PLTNAME  TYPE ZTBMM1020-PLTNAME, " 플랜트 명
         MVCODE   TYPE ZTBMM0040-MVCODE,  " 이동유형
         PONUM    TYPE ZTBMM0020-PONUM,   " 구매오더 번호
         PORDNUM  TYPE ZTBPP0030-PORDNUM, " 생산오더 번호
         SONUM    TYPE ZTBSD0030-SONUM,   " 판매오더 번호
         MATTYPE  TYPE ZTBMM1010-MATTYPE, " 자재 타입
         MATCODE  TYPE ZTBMM1010-MATCODE, " 자재 번호
         MATNAME  TYPE ZTBMM1011-MATNAME, " 자재 이름
         MVQUANT  TYPE ZEB_MVQUANT,       " 자재 수량
         UNITCODE TYPE ZEB_UNITCODE,      " 단위
         MVPRICE  TYPE ZEB_MVPRICE,       " 자재 금액
         CURRENCY TYPE ZEB_CURRCODE,      " 화폐단위
         GT_COL   TYPE LVC_T_SCOL,
       END OF TS_DISPLAY.

DATA: GS_DISPLAY TYPE TS_DISPLAY,          " ALV100 WA
      GT_DISPLAY LIKE TABLE OF GS_DISPLAY. " ALV100 ITAB

*&---------------------------------------------------------------------*
*& ALV100 OBJECT 선언부
*&---------------------------------------------------------------------*
DATA: GO_DOCK    TYPE REF TO CL_GUI_DOCKING_CONTAINER,  " Docking Container 선언
      GO_SPLIT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER, " Split Container 선언
      GO_CONT1   TYPE REF TO CL_GUI_CONTAINER,          " Container 1 선언
      GO_CONT2   TYPE REF TO CL_GUI_CONTAINER,          " Container 2 선언
      GO_TREE100 TYPE REF TO CL_GUI_SIMPLE_TREE,        " Tree object 변수 선언
      GO_ALV100  TYPE REF TO CL_GUI_ALV_GRID,           " ALV object 변수 선언
      GT_NODE    TYPE TABLE OF MTREESNODE,              " Tree Node ITAB
      GS_NODE    LIKE LINE OF GT_NODE,                  " Tree Node WA
      GS_LAYO    TYPE LVC_S_LAYO,
      GT_SORT    TYPE LVC_T_SORT,
      GT_FCAT    TYPE LVC_T_FCAT,
      GS_FCAT    TYPE LVC_S_FCAT,
      GS_VARIANT TYPE DISVARIANT,
      GV_SAVE    TYPE C.

*&---------------------------------------------------------------------*
*& Node key 값에 대한 data를 저장할 Range 변수 선언부
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TS_NODE_INFO,
         NODE_KEY LIKE MTREESNODE-NODE_KEY, " Tree Node key
         DOCYEAR  TYPE ZTBMM0040-DOCYEAR,   " 자재문서 생성연도
         PLTCODE  TYPE ZTBMM1020-PLTCODE,   " 플랜트 코드
         MATTYPE  TYPE ZTBMM1010-MATTYPE,   " 자재 타입
         MATCODE  TYPE ZTBMM1010-MATCODE,   " 자재 번호
       END OF TS_NODE_INFO.

DATA: GS_NODE_INFO TYPE TS_NODE_INFO,
      GT_NODE_INFO LIKE TABLE OF GS_NODE_INFO.

*&---------------------------------------------------------------------*
*& 자재문서 번호 Hotspot 클릭 시 팝업 ALV 변수 선언부
*&---------------------------------------------------------------------*
* ALV200 DISPLAY WA & ITAB
DATA: GS_DISPLAY200 TYPE TS_DISPLAY,
      GT_DISPLAY200 LIKE TABLE OF GS_DISPLAY200.

* ALV200 ALV WA & ITAB
DATA: GO_CUST200 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV200  TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYO200 TYPE LVC_S_LAYO,
      GT_SORT200 TYPE LVC_T_SORT,
      GS_SORT200 TYPE LVC_S_SORT,
      GT_FCAT200 TYPE LVC_T_FCAT,
      GS_FCAT200 TYPE LVC_S_FCAT.

*&---------------------------------------------------------------------*
*& 자재문서 번호 Hotspot 팝업화면 설정을 위한 변수
*&---------------------------------------------------------------------*
DATA: GV_PAGE TYPE I,
      GV_MODE TYPE I.

*&---------------------------------------------------------------------*
*& 구매오더 번호 Hotspot 클릭 시 팝업 ALV 변수 선언부
*&---------------------------------------------------------------------*
* ALV120 DISPLAY WA & ITAB
DATA: GS_DISPLAY120 TYPE ZSBMM0020,
      GT_DISPLAY120 LIKE TABLE OF GS_DISPLAY120.

* ALV120 ALV WA & ITAB
DATA: GO_CUST120 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV120  TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYO120 TYPE LVC_S_LAYO,
      GT_FCAT120 TYPE LVC_T_FCAT,
      GS_FCAT120 TYPE LVC_S_FCAT.

*&---------------------------------------------------------------------*
*& 생산오더 번호 Hotspot 클릭 시 팝업 ALV 변수 선언부
*&---------------------------------------------------------------------*
* ALV130 DISPLAY WA & ITAB
DATA: GS_DISPLAY130 TYPE ZSBPP0030,
      GT_DISPLAY130 LIKE TABLE OF GS_DISPLAY130.

* ALV130 ALV WA & ITAB
DATA: GO_CUST130 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV130  TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYO130 TYPE LVC_S_LAYO,
      GT_FCAT130 TYPE LVC_T_FCAT,
      GS_FCAT130 TYPE LVC_S_FCAT.

*&---------------------------------------------------------------------*
*& 판매오더 번호 Hotspot 클릭 시 팝업 ALV 변수 선언부
*&---------------------------------------------------------------------*
* ALV140 DISPLAY WA & ITAB
DATA: GS_DISPLAY140 TYPE ZSBSD0030_STR,
      GT_DISPLAY140 LIKE TABLE OF GS_DISPLAY140.

* ALV140 ALV WA & ITAB
DATA: GO_CUST140 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV140  TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYO140 TYPE LVC_S_LAYO,
      GT_FCAT140 TYPE LVC_T_FCAT,
      GS_FCAT140 TYPE LVC_S_FCAT.

*&---------------------------------------------------------------------*
*& 자재번호 Hotspot 클릭 시 팝업 TAB STRIP & ALV 변수 선언부
*&---------------------------------------------------------------------*
* TAB STRIP 변수.
DATA: GV_DYNNR TYPE SY-DYNNR.
CONTROLS: TAB_STRIP TYPE TABSTRIP.

* ALV170 DISPLAY WA & ITAB
DATA: GS_DISPLAY170 TYPE ZTBMM0030,
      GT_DISPLAY170 LIKE TABLE OF GS_DISPLAY170.

* ALV170 ALV WA & ITAB
DATA: GO_CUST170 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV170  TYPE REF TO CL_GUI_ALV_GRID,
      GS_LAYO170 TYPE LVC_S_LAYO,
      GT_FCAT170 TYPE LVC_T_FCAT,
      GS_FCAT170 TYPE LVC_S_FCAT.
