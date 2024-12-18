*&---------------------------------------------------------------------*
*& Include          ZBRMM0050_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA .
  CLEAR GT_TREE.

  SELECT FROM ZTBMM0040 AS A " 자재문서 HEADER
    LEFT JOIN ZTBMM0041 AS B " 자재문서 ITEM
           ON A~DOCYEAR = B~DOCYEAR " 자재문서 생성연도
          AND A~DOCNUM  = B~DOCNUM  "자재문서번호
         JOIN ZTBMM1010 AS C " 자재 마스터
           ON B~MATCODE = C~MATCODE " 자재 번호
         JOIN ZTBMM1020 AS D " 플랜트 마스터
           ON A~PLTCODE = D~PLTCODE " 플랜트 코드
         JOIN ZTBMM1011 AS E " 자재명 TEXT TABLE
           ON C~MATCODE = E~MATCODE " 자재번호
          AND E~SPRAS = @SY-LANGU " Language key
       FIELDS A~DOCYEAR, A~PLTCODE, D~PLTNAME, C~MATTYPE, B~MATCODE, E~MATNAME
   INTO TABLE @GT_TREE.

  SORT GT_TREE BY DOCYEAR PLTCODE MATTYPE MATCODE.

  DELETE ADJACENT DUPLICATES FROM GT_TREE COMPARING DOCYEAR PLTCODE MATTYPE MATCODE. " 트리에 중복된 값을 제거.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_NODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_NODE .
* NODE KEY LEVEL 관련 변수 선언.
  DATA: LV_NODE_KEY       TYPE N LENGTH 6, " 해당 노드 키 값.
        LV_NODE_KEY_SUPER TYPE N LENGTH 6, " 부모 노드 키 값.
        LT_NODE_KEY_LEVEL LIKE TABLE OF LV_NODE_KEY, " 부모 노드 키 값을 저장하는 ITAB.
        LV_MATTYPE_NAME   TYPE STRING,
        LV_PNAME          TYPE STRING.

* GT_TREE에 담은 데이터를 sorting.
  SORT GT_TREE BY DOCYEAR DESCENDING PLTCODE MATTYPE MATCODE.

*&---------------------------------------------------------------------*
*& NODE 구현.
*&---------------------------------------------------------------------*

* ROOT NODE 1레벨.
  LV_NODE_KEY += 1.

* Node key 값 및 display 설정.
  CLEAR GS_NODE.
  GS_NODE-RELATKEY = SPACE. " 최상위 Node 레벨은 부모 Node key 값 설정하지 않음.
  GS_NODE-NODE_KEY = LV_NODE_KEY_SUPER = LV_NODE_KEY. " 부모 Node key 값 & Node key 값 설정.
  GS_NODE-ISFOLDER = ABAP_ON. " Node를 Folder로 만들기.
  GS_NODE-TEXT     = '자재문서 생성연도'. " Node 이름 설정.
  GS_NODE-N_IMAGE = ICON_ALV_VARIANTS. " Node Image 설정.
  GS_NODE-EXP_IMAGE = ICON_ALV_VARIANTS.  " Node Image 설정.
  APPEND GS_NODE TO GT_NODE. " Node ITAB에 값 할당.
  CLEAR GS_NODE. " CLEAR Node WA.

* 부모 Node key 값을 관리하는 ITAB에 값 할당.
  INSERT LV_NODE_KEY_SUPER INTO LT_NODE_KEY_LEVEL INDEX 1.

* Range 변수 ITAB 에 값 할당.
  CLEAR GS_NODE_INFO.
  GS_NODE_INFO-NODE_KEY = LV_NODE_KEY.
  APPEND GS_NODE_INFO TO GT_NODE_INFO.
  CLEAR GS_NODE_INFO.

*--------------------------------------------------------------------*
* AT NEW / ENDAT : LOOP문 안에서 사용되는 제어문.
* AT NEW internal_table_field .
* LOGIC Block.
* ENDAT.
* ITAB의 field 값이, 이전 행의 값과 다른 값이면 AT NEW ~ ENDAT 사이의 LOGIC Block을 수행.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* AT END OF / ENDAT : LOOP문 안에서 사용되는 제어문.
* AT END OF internal_table_field .
* LOGIC Block.
* ENDAT.
* ITAB의 field 값이, 다음 행의 값과 다른 값이면 AT END OF ~ ENDAT 사이의 LOGIC Block을 수행.
*--------------------------------------------------------------------*

* 자재유형에 따라서 text 할당.
  LOOP AT GT_TREE INTO GS_TREE.
    CASE GS_TREE-MATTYPE.
      WHEN 'M'.
        LV_MATTYPE_NAME = '구매자재'.
      WHEN 'S'.
        LV_MATTYPE_NAME = '반제품'.
      WHEN 'C'.
        LV_MATTYPE_NAME = '완제품'.
    ENDCASE.

* 플랜트코드에 따라서 text 할당.
    LV_PNAME = GS_TREE-PLTNAME.

* 자재문서 생성연도 값 변경 시.
    AT NEW DOCYEAR.

      LV_NODE_KEY += 1. " Node key 값 증가.
      GS_NODE-RELATKEY = LV_NODE_KEY_SUPER. " 부모 Node key 값 설정.
      GS_NODE-NODE_KEY = LV_NODE_KEY_SUPER = LV_NODE_KEY. " 부모 Node key 값 & Node key 값 설정.
      GS_NODE-ISFOLDER = ABAP_ON. " Node를 Folder로 만들기.
      GS_NODE-TEXT     = |{ GS_TREE-DOCYEAR }|. " Node 이름 설정 -> 연도 값을 동적으로 할당.
      GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD. " 현재 Node를 부모 Node의 최하위 순서에 생성.
      GS_NODE-N_IMAGE = ICON_DATE. " Node Image 설정.
      GS_NODE-EXP_IMAGE = ICON_DATE.  " Node Image 설정.
      APPEND GS_NODE TO GT_NODE. " Node ITAB 에 값 할당.
      CLEAR GS_NODE. " CLEAR Node WA.

*     부모 Node key 값을 관리하는 ITAB에 값 할당.
      INSERT LV_NODE_KEY_SUPER INTO LT_NODE_KEY_LEVEL INDEX 1.

*     Range 변수 ITAB 에 값 할당.
      GS_NODE_INFO-DOCYEAR = GS_TREE-DOCYEAR. " 현재 생성연도 값.
      GS_NODE_INFO-PLTCODE = SPACE.
      GS_NODE_INFO-MATTYPE = SPACE.
      GS_NODE_INFO-MATCODE = SPACE.
      GS_NODE_INFO-NODE_KEY = LV_NODE_KEY.
      APPEND GS_NODE_INFO TO GT_NODE_INFO.
      CLEAR GS_NODE_INFO.
    ENDAT.

* 플랜트코드 값 변경 시.
    AT NEW PLTCODE.
      IF GS_TREE-PLTCODE IS NOT INITIAL.

        LV_NODE_KEY += 1.
        GS_NODE-RELATKEY = LV_NODE_KEY_SUPER.
        GS_NODE-NODE_KEY = LV_NODE_KEY_SUPER = LV_NODE_KEY.
        GS_NODE-ISFOLDER = ABAP_ON.
        GS_NODE-TEXT     = |{ GS_TREE-PLTCODE } - { LV_PNAME }|. " Node 이름 설정 -> 플랜트명 값을 동적으로 할당.
        GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
        GS_NODE-N_IMAGE = ICON_PLANT.
        GS_NODE-EXP_IMAGE = ICON_PLANT.
        APPEND GS_NODE TO GT_NODE.
        CLEAR GS_NODE.

        INSERT LV_NODE_KEY_SUPER INTO LT_NODE_KEY_LEVEL INDEX 1.

        GS_NODE_INFO-DOCYEAR = GS_TREE-DOCYEAR.
        GS_NODE_INFO-PLTCODE = GS_TREE-PLTCODE.
        GS_NODE_INFO-MATTYPE = SPACE.
        GS_NODE_INFO-MATCODE = SPACE.
        GS_NODE_INFO-NODE_KEY = LV_NODE_KEY.
        APPEND GS_NODE_INFO TO GT_NODE_INFO.
        CLEAR GS_NODE_INFO.
      ENDIF.
    ENDAT.

* 자재유형 값 변경 시.
    AT NEW MATTYPE.
      IF GS_TREE-MATTYPE IS NOT INITIAL.
        LV_NODE_KEY += 1.
        GS_NODE-RELATKEY = LV_NODE_KEY_SUPER.
        GS_NODE-NODE_KEY = LV_NODE_KEY_SUPER = LV_NODE_KEY.
        GS_NODE-ISFOLDER = ABAP_ON.
        GS_NODE-TEXT     = |{ GS_TREE-MATTYPE } - { LV_MATTYPE_NAME }|. " Node 이름 설정 -> 자재유형명 값을 동적으로 할당.
        GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
        GS_NODE-N_IMAGE = ICON_BIW_VIRTUAL_INFO_PROV_INA.
        GS_NODE-EXP_IMAGE = ICON_BIW_VIRTUAL_INFO_PROVIDER.
        APPEND GS_NODE TO GT_NODE.
        CLEAR GS_NODE.

        INSERT LV_NODE_KEY_SUPER INTO LT_NODE_KEY_LEVEL INDEX 1.

        GS_NODE_INFO-DOCYEAR = GS_TREE-DOCYEAR.
        GS_NODE_INFO-PLTCODE = GS_TREE-PLTCODE.
        GS_NODE_INFO-MATTYPE = GS_TREE-MATTYPE.
        GS_NODE_INFO-MATCODE = SPACE.
        GS_NODE_INFO-NODE_KEY = LV_NODE_KEY.
        APPEND GS_NODE_INFO TO GT_NODE_INFO.
        CLEAR GS_NODE_INFO.
      ENDIF.
    ENDAT.

*   자재번호 값이 존재할 때.
    IF GS_TREE-MATCODE IS NOT INITIAL.
      LV_NODE_KEY += 1.
      GS_NODE-RELATKEY = LV_NODE_KEY_SUPER.
      GS_NODE-NODE_KEY = LV_NODE_KEY.
      GS_NODE-ISFOLDER = ABAP_OFF. " NODE를 LEAF로 만들기.
      GS_NODE-TEXT     = |{ GS_TREE-MATCODE } - { GS_TREE-MATNAME }|. " Node 이름 설정 -> 자재번호 값을 동적으로 할당.
      GS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
      APPEND GS_NODE TO GT_NODE.
      CLEAR GS_NODE.

      GS_NODE_INFO-DOCYEAR = GS_TREE-DOCYEAR.
      GS_NODE_INFO-PLTCODE = GS_TREE-PLTCODE.
      GS_NODE_INFO-MATTYPE = GS_TREE-MATTYPE.
      GS_NODE_INFO-MATCODE = GS_TREE-MATCODE.
      GS_NODE_INFO-NODE_KEY = LV_NODE_KEY.
      APPEND GS_NODE_INFO TO GT_NODE_INFO.
      CLEAR GS_NODE_INFO.
    ENDIF.

*   MATTYPE 값이 다음 행의 값과 다를 때, 현재 부모 Node key 값보다 한 level 더 큰 값으로 부모 Node key 값을 설정한다.
    AT END OF MATTYPE.
      DELETE LT_NODE_KEY_LEVEL INDEX 1.
      READ TABLE LT_NODE_KEY_LEVEL INTO LV_NODE_KEY_SUPER INDEX 1.
    ENDAT.

*   PLTCODE 값이 다음 행의 값과 다를 때, 현재 부모 Node key 값보다 한 level 더 큰 값으로 부모 Node key 값을 설정한다.
    AT END OF PLTCODE.
      DELETE LT_NODE_KEY_LEVEL INDEX 1.
      READ TABLE LT_NODE_KEY_LEVEL INTO LV_NODE_KEY_SUPER INDEX 1.
    ENDAT.

*   DOCYEAR 값이 다음 행의 값과 다를 때, 현재 부모 Node key 값보다 한 level 더 큰 값으로 부모 Node key 값을 설정한다.
    AT END OF DOCYEAR.
      DELETE LT_NODE_KEY_LEVEL INDEX 1.
      READ TABLE LT_NODE_KEY_LEVEL INTO LV_NODE_KEY_SUPER INDEX 1.
    ENDAT.
  ENDLOOP.

* GT_NODE 에 담긴 Node 정보들로 Tree Node 생성.
  CALL METHOD GO_TREE100->ADD_NODES
    EXPORTING
      TABLE_STRUCTURE_NAME           = 'MTREESNODE'
      NODE_TABLE                     = GT_NODE
    EXCEPTIONS
      ERROR_IN_NODE_TABLE            = 1                " Node Table Contains Errors
      FAILED                         = 2                " General error
      DP_ERROR                       = 3                " Error in Data Provider
      TABLE_STRUCTURE_NAME_NOT_FOUND = 4                " Unable to Find Structure in Dictionary
      OTHERS                         = 5.
  IF SY-SUBRC <> 0.
    MESSAGE S203 DISPLAY LIKE 'E'.
  ENDIF.

  CALL METHOD GO_TREE100->EXPAND_ROOT_NODES
    EXPORTING
      EXPAND_SUBTREE = ABAP_ON
    EXCEPTIONS
      OTHERS         = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S204 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TREE100_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TREE100_EVENT .
* EVENT 변수 선언.
  DATA: LT_EVENT TYPE CNTL_SIMPLE_EVENTS,
        LS_EVENT LIKE LINE OF LT_EVENT.

* 더블클릭 이벤트를 TREE ALV 에서 활성화 해주는 기능.
  CLEAR LS_EVENT.
  LS_EVENT-APPL_EVENT = ABAP_ON.
  LS_EVENT-EVENTID   = CL_GUI_SIMPLE_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  APPEND LS_EVENT TO LT_EVENT.

  CALL METHOD GO_TREE100->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS = LT_EVENT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_ALV100 .
  CLEAR GS_LAYO.

  GS_LAYO-ZEBRA = 'X'. " 가독성을 위한 행 줄무늬 색 지정.
  GS_LAYO-CWIDTH_OPT = 'A'. " 열 넓이 최적화 설정.
  GS_LAYO-CTAB_FNAME = 'GT_COL'. " 특정 열 색 지정.
  GS_LAYO-NO_TOTLINE = 'X'. " Total 행 display 하지 않음.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT_ALV100 .
* Tree Node 더블 클릭 시 Range ITAB에서 해당 Node key 값에 해당하는 data 호출
  SET HANDLER LCL_EVENT_HANDLER=>ON_NODE_DOUBLE_CLICK FOR GO_TREE100.

* ALV Hotspot Click Event
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV100.

* ALV Toolbar 이벤트 핸들링을 위한 메소드 등록
  SET HANDLER LCL_EVENT_HANDLER=>ON_TOOLBAR FOR GO_ALV100.

* ALV User-command 이벤트 핸들링을 위한 메소드 등록
  SET HANDLER LCL_EVENT_HANDLER=>ON_USER_COMMAND FOR GO_ALV100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ON_NODE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& Node 더블 클릭 시 해당 Node key 값에 대한 ALV data display 구현.
*&---------------------------------------------------------------------*
*&      --> NODE_KEY
*&      --> SENDER
*&---------------------------------------------------------------------*
FORM ON_NODE_DOUBLE_CLICK  USING PV_NODE_KEY TYPE MTREESNODE-NODE_KEY.
  DATA: LS_SCOL TYPE LVC_S_SCOL. " Cell 색 지정을 위한 변수

  DATA : LV_CURR       LIKE ZTBMM0041-CURRENCY, " Currency 값 변수
         LV_BEFORE_AMT LIKE BAPICURR-BAPICURR,  " DB 금액 값 변수
         LV_AFTER_AMT  LIKE BAPICURR-BAPICURR.  " ALV display 금액 값 변수

* SELECT-OPTION RANGE 변수 선언.
  RANGES: RT_DOCYEAR FOR GS_NODE_INFO-DOCYEAR, " 자재문서 생성연도
          RT_PLTCODE FOR GS_NODE_INFO-PLTCODE, " 플랜트 코드
          RT_MATTYPE FOR GS_NODE_INFO-MATTYPE, " 자재 유형
          RT_MATCODE FOR GS_NODE_INFO-MATCODE. " 자재 번호

* Node 더블 클릭 시, 현재 Range 변수 값 clear
  CLEAR: RT_DOCYEAR, RT_PLTCODE, RT_MATTYPE, RT_MATCODE.

  READ TABLE GT_NODE_INFO INTO GS_NODE_INFO
  WITH KEY NODE_KEY = PV_NODE_KEY.

* READ TABLE 결과가 정상일때.
  CHECK SY-SUBRC = 0.

* 각 Node Key 값에 해당하는 data들을 Range 변수로 설정.
* 자재문서 생성연도
  IF GS_NODE_INFO-DOCYEAR IS NOT INITIAL.
    RT_DOCYEAR-SIGN = 'I'.
    RT_DOCYEAR-OPTION = 'EQ'.
    RT_DOCYEAR-LOW = GS_NODE_INFO-DOCYEAR.
    APPEND RT_DOCYEAR.
  ENDIF.

* 플랜트코드
  IF GS_NODE_INFO-PLTCODE IS NOT INITIAL.
    RT_PLTCODE-SIGN = 'I'.
    RT_PLTCODE-OPTION = 'EQ'.
    RT_PLTCODE-LOW = GS_NODE_INFO-PLTCODE.
    APPEND RT_PLTCODE.
  ENDIF.

* 자재유형
  IF GS_NODE_INFO-MATTYPE IS NOT INITIAL.
    RT_MATTYPE-SIGN = 'I'.
    RT_MATTYPE-OPTION = 'EQ'.
    RT_MATTYPE-LOW = GS_NODE_INFO-MATTYPE.
    APPEND RT_MATTYPE.
  ENDIF.

* 자재번호
  IF GS_NODE_INFO-MATCODE IS NOT INITIAL.
    RT_MATCODE-SIGN = 'I'.
    RT_MATCODE-OPTION = 'EQ'.
    RT_MATCODE-LOW = GS_NODE_INFO-MATCODE.
    APPEND RT_MATCODE.
  ENDIF.

* ALV ITAB에 Data 할당.
  SELECT FROM ZTBMM0040 AS A          " 자재문서 HEADER
    LEFT JOIN ZTBMM0041 AS B          " 자재문서 ITEM
           ON A~DOCNUM EQ B~DOCNUM    " 자재문서번호.
         JOIN ZTBMM1020  AS C         " PLANT 마스터.
           ON A~PLTCODE EQ C~PLTCODE  " 플랜트 코드.
         JOIN ZTBMM1010 AS D          " 자재 마스터.
           ON B~MATCODE EQ D~MATCODE  " 자재 번호.
         JOIN ZTBMM1011 AS E          " 자재 TEXT TABLE.
           ON D~MATCODE EQ E~MATCODE  " 자재 번호.
          AND E~SPRAS EQ @SY-LANGU    " 언어 키.
    FIELDS *
    WHERE A~DOCYEAR IN @RT_DOCYEAR    " 생성연도
      AND C~PLTCODE IN @RT_PLTCODE    " 플랜트코드
      AND B~MATTYPE IN @RT_MATTYPE    " 자재유형
      AND B~MATCODE IN @RT_MATCODE    " 자재번호
    ORDER BY A~DOCYEAR DESCENDING, A~DOCNUM DESCENDING, B~MATCODE ASCENDING " Data Sorting
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY.

* 입고건 & 출고건에 대해서 Cell 색깔 지정.
  LOOP AT GT_DISPLAY INTO GS_DISPLAY.
    CLEAR LS_SCOL.
    CASE GS_DISPLAY-MVCODE.
      WHEN 'MV01' OR 'MV03' OR 'MV04' .
        LS_SCOL-FNAME = 'MVPRICE'.
        LS_SCOL-COLOR-COL = '5'.
        LS_SCOL-COLOR-INT = '0'.
        LS_SCOL-COLOR-INV = '0'.
        APPEND LS_SCOL TO GS_DISPLAY-GT_COL.
      WHEN 'MV02' OR 'MV05'.
        LS_SCOL-FNAME = 'MVPRICE'.
        LS_SCOL-COLOR-COL = '6'.
        LS_SCOL-COLOR-INT = '0'.
        LS_SCOL-COLOR-INV = '0'.
        APPEND LS_SCOL TO GS_DISPLAY-GT_COL.
    ENDCASE.

* 화폐단위가 'KRW'일 때, 단위 오류 해결을 위한 BAPI FM 호출.
    LV_BEFORE_AMT = GS_DISPLAY-MVPRICE.
    LV_CURR = GS_DISPLAY-CURRENCY.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        AMOUNT_EXTERNAL      = LV_BEFORE_AMT
        CURRENCY             = LV_CURR
        MAX_NUMBER_OF_DIGITS = 21  "출력할 금액필드의 자릿수"
      IMPORTING
        AMOUNT_INTERNAL      = LV_AFTER_AMT.

    GS_DISPLAY-MVPRICE = LV_AFTER_AMT.

    MODIFY GT_DISPLAY FROM GS_DISPLAY.
    CLEAR: LV_BEFORE_AMT, LV_CURR, LV_AFTER_AMT.
  ENDLOOP.

* ALV Refresh
  PERFORM REFRESH_ALV_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV100 .
* ALV DISPLAY.
  GS_VARIANT-REPORT = SY-CPROG.
*  GS_VARIANT-VARIANT = '/ALV100'.

  GO_ALV100->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      I_STRUCTURE_NAME              = 'ZSBMM0040'
      IS_VARIANT                    = GS_VARIANT  " Layout
      I_SAVE                        = 'A'     " Save Layout
*      I_DEFAULT                     = 'X'     " Default Display Variant
      IS_LAYOUT                     = GS_LAYO " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY  " Output ITAB
      IT_FIELDCATALOG               = GT_FCAT " Field Catalog
      IT_SORT                       = GT_SORT " SORT
    EXCEPTIONS
      OTHERS                        = 1
).
  IF SY-SUBRC NE 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV_DISPLAY .
  GO_ALV100->REFRESH_TABLE_DISPLAY(
    EXCEPTIONS
      FINISHED       = 1                " Display was Ended (by Export)
      OTHERS         = 2 ).
  IF SY-SUBRC NE 0.
    MESSAGE S205.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_FIELDCAT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DISPLAY
*&      --> GT_FCAT
*&---------------------------------------------------------------------*
FORM GET_FIELDCAT_ALV100  USING    PT_DISPLAY
                                   PT_FCAT.
  TRY.
      CALL METHOD CL_SALV_TABLE=>FACTORY
        IMPORTING
          R_SALV_TABLE = DATA(LO_SALV_TABLE)
        CHANGING
          T_TABLE      = PT_DISPLAY.

      DATA(LO_COLUMNS)      = LO_SALV_TABLE->GET_COLUMNS( ).
      DATA(LO_AGGREGATIONS) = LO_SALV_TABLE->GET_AGGREGATIONS( ).

      PT_FCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
                  R_COLUMNS = LO_COLUMNS
                  R_AGGREGATIONS = LO_AGGREGATIONS ).

    CATCH CX_SALV_MSG.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV100 .
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'DOCYEAR'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-KEY = ABAP_ON.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'DOCNUM'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  GS_FCAT-KEY = ABAP_ON.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'DOCDATE'.
  GS_FCAT-JUST = 'C'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'PLTCODE'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MVCODE'.
  GS_FCAT-JUST = 'C'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MATTYPE'.
  GS_FCAT-JUST = 'C'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MATCODE'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  GS_FCAT-KEY = ABAP_ON.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MATNAME'.
  GS_FCAT-JUST = 'C'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MVQUANT'.
  GS_FCAT-JUST = 'R'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'UNITCODE'.
  GS_FCAT-JUST = 'L'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'MVPRICE'.
  GS_FCAT-JUST = 'R'.
  GS_FCAT-DO_SUM = 'X'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'CURRENCY'.
  GS_FCAT-JUST = 'L'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'PONUM'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'PORDNUM'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  GS_FCAT-COLTEXT = '생산오더번호'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

  GS_FCAT-FIELDNAME = 'SONUM'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-HOTSPOT = 'X'.
  GS_FCAT-COLTEXT = '판매오더번호'.
  APPEND GS_FCAT TO GT_FCAT.
  CLEAR GS_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORT_ALV100 .
  DATA: LS_SORT TYPE LVC_S_SORT.

  LS_SORT-FIELDNAME = 'DOCYEAR'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'DOCNUM'.
  LS_SORT-UP = 'X'.
  LS_SORT-SUBTOT = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'DOCDATE'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'PLTCODE'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'MVCODE'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'PONUM'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'PORDNUM'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'SONUM'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.

  LS_SORT-FIELDNAME = 'MATCODE'.
  LS_SORT-UP = 'X'.
  APPEND LS_SORT TO GT_SORT.
  CLEAR LS_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING PV_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.
  DATA LS_BUTTON LIKE LINE OF PV_OBJECT->MT_TOOLBAR.

* 구분자 추가.
  CLEAR LS_BUTTON.
  LS_BUTTON-BUTN_TYPE = 3.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.

* 각 버튼의 개수를 담을 변수.
  DATA LV_COUNT TYPE I. " 전체.
  DATA LV_COUNT_MV01 TYPE I. " 구매오더 자재 입고.
  DATA LV_COUNT_MV02 TYPE I. " 생산오더 자재 출고.
  DATA LV_COUNT_MV03 TYPE I. " 생산오더 자재 입고.
  DATA LV_COUNT_MV04 TYPE I. " 생산오더 완제품 입고.
  DATA LV_COUNT_MV05 TYPE I. " 생산오더 완제품 출고.

* 자재문서 HEADER 기준으로 개수 COUNT.
  LOOP AT GT_DISPLAY INTO GS_DISPLAY.
    AT NEW DOCNUM.
      ADD 1 TO LV_COUNT.
    ENDAT.

    CASE GS_DISPLAY-MVCODE.
      WHEN 'MV01'.
        AT NEW DOCNUM.
          ADD 1 TO LV_COUNT_MV01.
        ENDAT.
      WHEN 'MV02'.
        AT NEW DOCNUM.
          ADD 1 TO LV_COUNT_MV02.
        ENDAT.
      WHEN 'MV03'.
        AT NEW DOCNUM.
          ADD 1 TO LV_COUNT_MV03.
        ENDAT.
      WHEN 'MV04'.
        AT NEW DOCNUM.
          ADD 1 TO LV_COUNT_MV04.
        ENDAT.
      WHEN 'MV05'.
        AT NEW DOCNUM.
          ADD 1 TO LV_COUNT_MV05.
        ENDAT.
    ENDCASE.
  ENDLOOP.

* 버튼 '전체 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 전체: ' && LV_COUNT.
  LS_BUTTON-FUNCTION  = 'FILTER_TOTAL'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

* 버튼 '구매오더 자재 입고 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 구매 자재입고 : ' && LV_COUNT_MV01.
  LS_BUTTON-FUNCTION  = 'FILTER_MV01'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

* 버튼 '생산오더 자재 출고 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 생산 자재출고 : ' && LV_COUNT_MV02.
  LS_BUTTON-FUNCTION  = 'FILTER_MV02'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

* 버튼 '생산오더 자재 입고 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 생산 자재입고 : ' && LV_COUNT_MV03.
  LS_BUTTON-FUNCTION  = 'FILTER_MV03'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

* 버튼 '생산오더 완제품 입고 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 생산 완제품입고 : ' && LV_COUNT_MV04.
  LS_BUTTON-FUNCTION  = 'FILTER_MV04'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

* 버튼 '생산오더 완제품 출고 : ##' 추가.
  LS_BUTTON-BUTN_TYPE = 0. " 일반 버튼(NORMAL BUTTON)
  LS_BUTTON-TEXT      = ' 판매 완제품출고 : ' && LV_COUNT_MV05.
  LS_BUTTON-FUNCTION  = 'FILTER_MV05'.
  APPEND LS_BUTTON TO PV_OBJECT->MT_TOOLBAR.
  CLEAR LS_BUTTON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING    PV_UCOMM LIKE SY-UCOMM.
  CASE PV_UCOMM.
      " 각 버튼 마다 FILTERING.
    WHEN 'FILTER_TOTAL'.
      PERFORM APPLY_FILTER USING SPACE.

    WHEN 'FILTER_MV01'.
      PERFORM APPLY_FILTER USING 'MV01'.

    WHEN 'FILTER_MV02'.
      PERFORM APPLY_FILTER USING 'MV02'.

    WHEN 'FILTER_MV03'.
      PERFORM APPLY_FILTER USING 'MV03'.

    WHEN 'FILTER_MV04'.
      PERFORM APPLY_FILTER USING 'MV04'.

    WHEN 'FILTER_MV05'.
      PERFORM APPLY_FILTER USING 'MV05'.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPLY_FILTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SPACE
*&---------------------------------------------------------------------*
FORM APPLY_FILTER  USING    PV_VALUE.
  DATA: LT_FILTER TYPE LVC_T_FILT,
        LS_FILTER LIKE LINE OF LT_FILTER.

  IF PV_VALUE IS NOT INITIAL.
    CLEAR LS_FILTER.
    LS_FILTER-FIELDNAME = 'MVCODE'.
    LS_FILTER-SIGN      = 'I'.
    LS_FILTER-OPTION    = 'EQ'.
    LS_FILTER-LOW       = PV_VALUE.
    APPEND LS_FILTER TO LT_FILTER.
  ENDIF.

* 필터 기준 설정.
  CALL METHOD GO_ALV100->SET_FILTER_CRITERIA
    EXPORTING
      IT_FILTER = LT_FILTER.         " FILTER CONDITIONS

  CALL METHOD GO_ALV100->REFRESH_TABLE_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_DOC .
  CLEAR: GT_DISPLAY200, GS_DISPLAY200.

* DIALOG ALV 스크린 호출.
  IF GS_DISPLAY-DOCNUM IS INITIAL.
    MESSAGE S224 DISPLAY LIKE 'E'.
  ELSE.
    PERFORM SET_BUTTON. " '이전', '다음' 버튼 활성화/비활성화.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_200 .

  CREATE OBJECT GO_CUST200
    EXPORTING
      CONTAINER_NAME              = 'AREA200'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
  ENDIF.

  CREATE OBJECT GO_ALV200
    EXPORTING
      I_PARENT          = GO_CUST200
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_ALV200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_ALV200 .
  DATA : LV_CURR       LIKE ZTBMM0041-CURRENCY, " Currency 값 변수
         LV_BEFORE_AMT LIKE BAPICURR-BAPICURR,  " DB 금액 값 변수
         LV_AFTER_AMT  LIKE BAPICURR-BAPICURR.  " ALV display 금액 값 변수

  CLEAR: ZTBMM0040.

* 팝업창의 '자재문서번호', '생성연도' 필드 값에 현재 선택한 자재문서의 값 할당.
  MOVE-CORRESPONDING GS_DISPLAY TO GS_DISPLAY200.
  MOVE-CORRESPONDING GS_DISPLAY200 TO ZTBMM0040.

* ALV200 ITAB에 DATA 할당.
  SELECT FROM ZTBMM0040 AS A        " 자재문서 HEADER
    LEFT JOIN ZTBMM0041 AS B        " 자재문서 ITEM
           ON A~DOCNUM EQ B~DOCNUM  " 자재문서번호.
         JOIN ZTBMM1020  AS C       " PLANT 마스터.
           ON A~PLTCODE EQ C~PLTCODE" 플랜트 코드.
         JOIN ZTBMM1010 AS D        " 자재 마스터.
           ON B~MATCODE EQ D~MATCODE" 자재 번호.
         JOIN ZTBMM1011 AS E        " 자재 TEXT TABLE.
           ON D~MATCODE EQ E~MATCODE" 자재 번호.
          AND E~SPRAS EQ @SY-LANGU  " 언어 키.
    FIELDS *
    WHERE A~DOCNUM = @GS_DISPLAY200-DOCNUM
     INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY200.

  SORT GT_DISPLAY200 BY DOCYEAR DOCNUM MATCODE.

* 'KRW' 화폐단위의 표기 오류 수정을 위한 BAPI FM 호출.
  LOOP AT GT_DISPLAY200 INTO GS_DISPLAY200.
    LV_BEFORE_AMT = GS_DISPLAY200-MVPRICE.
    LV_CURR = GS_DISPLAY200-CURRENCY.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        AMOUNT_EXTERNAL      = LV_BEFORE_AMT
        CURRENCY             = LV_CURR
        MAX_NUMBER_OF_DIGITS = 21  "출력할 금액필드의 자릿수"
      IMPORTING
        AMOUNT_INTERNAL      = LV_AFTER_AMT.

    GS_DISPLAY200-MVPRICE = LV_AFTER_AMT.

    MODIFY GT_DISPLAY200 FROM GS_DISPLAY200.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV200 .
* DIALOG ALV TOOLBAR HIDDEN 처리.
  DATA: LS_EXCLUD TYPE UI_FUNC,
        LT_EXCLUD TYPE UI_FUNCTIONS.

  LS_EXCLUD = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND LS_EXCLUD TO LT_EXCLUD.

  GS_VARIANT-REPORT = SY-CPROG.
  GS_VARIANT-VARIANT = '/ALV200'.

* DIALOG ALV DISPLAY.
  CALL METHOD GO_ALV200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = 'ZSBMM0040'
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*     I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYO200
*     IT_TOOLBAR_EXCLUDING          = LT_EXCLUD
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY200
      IT_FIELDCATALOG               = GT_FCAT200
*     IT_SORT                       = GT_SORT200
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT200 .
  CLEAR GS_LAYO200.

  GS_LAYO200-ZEBRA = 'X'.
  GS_LAYO200-CWIDTH_OPT = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV200 .
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'DOCYEAR'.
  GS_FCAT200-JUST = 'C'.
  GS_FCAT200-NO_OUT = 'X'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'DOCNUM'.
  GS_FCAT200-JUST = 'C'.
  GS_FCAT200-NO_OUT = 'X'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'DOCDATE'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'PLTCODE'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MVCODE'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MATTYPE'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MATCODE'.
  GS_FCAT200-JUST = 'C'.
  GS_FCAT200-COL_POS = 1.
  GS_FCAT200-KEY = 'X'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MATNAME'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MVQUANT'.
  GS_FCAT200-JUST = 'R'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'UNITCODE'.
  GS_FCAT200-JUST = 'L'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'MVPRICE'.
  GS_FCAT200-JUST = 'R'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'CURRENCY'.
  GS_FCAT200-JUST = 'L'.
  GS_FCAT200-OUTPUTLEN = 50.
  GS_FCAT200-DO_SUM = 'X'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'PONUM'.
  GS_FCAT200-JUST = 'C'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'PORDNUM'.
  GS_FCAT200-JUST = 'C'.
  GS_FCAT200-COLTEXT = '생산오더번호'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.

  GS_FCAT200-FIELDNAME = 'SONUM'.
  GS_FCAT200-JUST = 'C'.
  GS_FCAT200-COLTEXT = '판매오더번호'.
  APPEND GS_FCAT200 TO GT_FCAT200.
  CLEAR GS_FCAT200.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV200 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV200->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO200.

  GS_LAYO200-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV200->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO200.

  CALL METHOD GO_ALV200->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_PLT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_PLT .
  IF GS_DISPLAY-PLTCODE IS INITIAL.
    MESSAGE S225 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 110
    STARTING AT 20 8.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PLT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PLT_DATA .
  SELECT SINGLE *
    FROM ZTBMM1020
   WHERE PLTCODE = GS_DISPLAY-PLTCODE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PO_DATA .
  " ZSBMM0020  구매오더 STRUCTURE
  " ZTBMM0020  구매오더 header
  " ZTBMM0021  구매오더 item
  " ZTBSD1050  BP 마스터.
  " ZTBMM1020  플랜트 마스터.

  SELECT *
         FROM ZTBMM0020 AS A
    LEFT JOIN ZTBMM0021 AS B
           ON A~PONUM = B~PONUM
        WHERE A~PONUM = @GS_DISPLAY-PONUM
         INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY120.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_PO .
  CLEAR: GT_DISPLAY120, GS_DISPLAY120.

  IF GS_DISPLAY-PONUM IS INITIAL.
    MESSAGE S226 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 120
    STARTING AT 20 8.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_120 .
  CREATE OBJECT GO_CUST120
    EXPORTING
      CONTAINER_NAME              = 'AREA120'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
  ENDIF.

  CREATE OBJECT GO_ALV120
    EXPORTING
      I_PARENT          = GO_CUST120
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT120 .
  CLEAR GS_LAYO120.

  GS_LAYO120-ZEBRA = 'X'.
  GS_LAYO120-CWIDTH_OPT = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV120 .
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'PONUM'.
  GS_FCAT120-JUST = 'C'.
  GS_FCAT120-KEY  = 'X'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'PRNUM'.
  GS_FCAT120-JUST = 'C'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'BPCODE'.
  GS_FCAT120-JUST = 'C'.
  GS_FCAT120-COLTEXT = '거래처 코드'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'PLTCODE'.
  GS_FCAT120-JUST = 'C'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'PODATE'.
  GS_FCAT120-JUST = 'C'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'INBODATE'.
  GS_FCAT120-JUST = 'C'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'EMPID'.
  GS_FCAT120-JUST = 'C'.
  GS_FCAT120-COLTEXT = '구매오더 담당자'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'STATUS'.
  GS_FCAT120-JUST = 'C'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'MATCODE'.
  GS_FCAT120-JUST = 'C'.
  GS_FCAT120-KEY = 'X'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'POQUANT'.
  GS_FCAT120-JUST = 'R'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'UNITCODE'.
  GS_FCAT120-JUST = 'L'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'POPRICE'.
  GS_FCAT120-JUST = 'R'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

  GS_FCAT120-FIELDNAME = 'CURRENCY'.
  GS_FCAT120-JUST = 'L'.
  APPEND GS_FCAT120 TO GT_FCAT120.
  CLEAR GS_FCAT120.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV120 .
* DIALOG ALV TOOLBAR HIDDEN 처리.
  DATA: LS_EXCLUD TYPE UI_FUNC,
        LT_EXCLUD TYPE UI_FUNCTIONS.

  LS_EXCLUD = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND LS_EXCLUD TO LT_EXCLUD.

  GS_VARIANT-REPORT = SY-CPROG.
  GS_VARIANT-VARIANT = '/ALV120'.

* DIALOG ALV DISPLAY.
  CALL METHOD GO_ALV120->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = 'ZSBMM0020'
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*     I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYO120
*     IT_TOOLBAR_EXCLUDING          = LT_EXCLUD
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY120
      IT_FIELDCATALOG               = GT_FCAT120
*     IT_SORT                       = GT_SORT120
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV120 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV120->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO120.

  GS_LAYO120-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV120->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO120.

  CALL METHOD GO_ALV120->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_ALV130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_ALV130 .
  " ZSBPP0030  생산오더 STRUCTURE
  " ZTBPP0030  생산오더 header
  " ZTBPP0031  생산오더 item

  DATA: LV_PRODOR TYPE C LENGTH 10,
        LV_WHCODE TYPE C LENGTH 10,
        LV_MRP    TYPE C LENGTH 10.

  SELECT *
       FROM ZTBPP0030 AS A
  LEFT JOIN ZTBPP0031 AS B
         ON A~PORDNUM = B~PORDNUM
      WHERE A~PORDNUM = @GS_DISPLAY-PORDNUM
       INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY130.

  READ TABLE GT_DISPLAY130 INTO GS_DISPLAY130 INDEX 1.

  SELECT SINGLE MRPNUM
    FROM ZTBPP0020
   WHERE PREQNUM EQ @GS_DISPLAY130-PREQNUM
    INTO @LV_MRP.

  SELECT SINGLE WHCODE
    FROM ZTBPP0080
   WHERE MRPNUM EQ @LV_MRP
    INTO @LV_WHCODE.

  LOOP AT GT_DISPLAY130 INTO GS_DISPLAY130.
    CASE LV_WHCODE.
      WHEN 'STP0000001'.

      WHEN 'STP0000002'.

      WHEN 'STP0000003'.

      WHEN 'STP0000004'.

      WHEN 'STP0000005'.

    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_130 .
  CREATE OBJECT GO_CUST130
    EXPORTING
      CONTAINER_NAME              = 'AREA130'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
  ENDIF.

  CREATE OBJECT GO_ALV130
    EXPORTING
      I_PARENT          = GO_CUST130
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT130 .
  CLEAR GS_LAYO130.

  GS_LAYO130-ZEBRA = 'X'.
  GS_LAYO130-CWIDTH_OPT = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV130 .
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'PORDNUM'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '생산오더번호'.
  GS_FCAT130-KEY = 'X'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'PREQNUM'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '생산요청번호'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'WHCODE'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '플랜트 코드'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'MATCODE'.
  GS_FCAT130-JUST = 'C'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'PRDQUAN'.
  GS_FCAT130-JUST = 'R'.
  GS_FCAT130-COLTEXT = '생산단위수량'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'UNITCODE'.
  GS_FCAT130-JUST = 'L'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'PRDSTDAT'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '생산시작일'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'PRDENDAT'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '생산완료일'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.

  GS_FCAT130-FIELDNAME = 'STATUS'.
  GS_FCAT130-JUST = 'C'.
  GS_FCAT130-COLTEXT = '상태'.
  APPEND GS_FCAT130 TO GT_FCAT130.
  CLEAR GS_FCAT130.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV130 .
* DIALOG ALV TOOLBAR HIDDEN 처리.
  DATA: LS_EXCLUD TYPE UI_FUNC,
        LT_EXCLUD TYPE UI_FUNCTIONS.

  LS_EXCLUD = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND LS_EXCLUD TO LT_EXCLUD.

  GS_VARIANT-REPORT = SY-CPROG.
  GS_VARIANT-VARIANT = '/ALV130'.

* DIALOG ALV DISPLAY.
  CALL METHOD GO_ALV130->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = 'ZSBPP0030'
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*     I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYO130
*     IT_TOOLBAR_EXCLUDING          = LT_EXCLUD
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY130
      IT_FIELDCATALOG               = GT_FCAT130
*     IT_SORT                       = GT_SORT120
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV130 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV130->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO130.

  GS_LAYO130-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV130->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO130.

  CALL METHOD GO_ALV130->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_PORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_PORD .
  CLEAR: GT_DISPLAY130, GS_DISPLAY130.

  IF GS_DISPLAY-PORDNUM IS INITIAL.
    MESSAGE S227 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 130
    STARTING AT 20 8.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SO_DATA .
  " ZSBSD0030  판매오더 STRUCTURE
  " ZTBSD0030  판매오더 header
  " ZTBSD0031  판매오더 item

  SELECT *
    FROM ZTBSD0030 AS A
LEFT JOIN ZTBSD0031 AS B
      ON A~SONUM = B~SONUM
   WHERE A~SONUM = @GS_DISPLAY-SONUM
INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY140.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_140 .
  CREATE OBJECT GO_CUST140
    EXPORTING
      CONTAINER_NAME              = 'AREA140'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
  ENDIF.

  CREATE OBJECT GO_ALV140
    EXPORTING
      I_PARENT          = GO_CUST140
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT140 .
  CLEAR GS_LAYO140.

  GS_LAYO140-ZEBRA = 'X'.
  GS_LAYO140-CWIDTH_OPT = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV140 .
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'SONUM'.
  GS_FCAT140-JUST = 'C'.
  GS_FCAT140-COLTEXT = '판매오더번호'.
  GS_FCAT140-KEY = 'X'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'BPCODE'.
  GS_FCAT140-JUST = 'C'.
  GS_FCAT140-COLTEXT = '고객사 코드'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'SUPCODE'.
  GS_FCAT140-JUST = 'C'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'EMPID'.
  GS_FCAT140-JUST = 'C'.
  GS_FCAT140-COLTEXT = '판매오더 담당자'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'DELIVDATE'.
  GS_FCAT140-JUST = 'C'.
  GS_FCAT140-COLTEXT = '납기일'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'MATCODE'.
  GS_FCAT140-JUST = 'C'.
  GS_FCAT140-KEY = 'X'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'AMOUNTPRD'.
  GS_FCAT140-JUST = 'R'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'UNITCODE'.
  GS_FCAT140-JUST = 'L'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'TOTALPRD'.
  GS_FCAT140-JUST = 'R'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.

  GS_FCAT140-FIELDNAME = 'CURRENCY'.
  GS_FCAT140-JUST = 'L'.
  APPEND GS_FCAT140 TO GT_FCAT140.
  CLEAR GS_FCAT140.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV140 .
* DIALOG ALV TOOLBAR HIDDEN 처리.
  DATA: LS_EXCLUD TYPE UI_FUNC,
        LT_EXCLUD TYPE UI_FUNCTIONS.

  LS_EXCLUD = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND LS_EXCLUD TO LT_EXCLUD.

  GS_VARIANT-REPORT = SY-CPROG.
  GS_VARIANT-VARIANT = '/ALV140'.

* DIALOG ALV DISPLAY.
  CALL METHOD GO_ALV140->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = 'ZSBSD0030_STR'
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*     I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYO140
*     IT_TOOLBAR_EXCLUDING          = LT_EXCLUD
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY140
      IT_FIELDCATALOG               = GT_FCAT140
*     IT_SORT                       = GT_SORT120
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV140 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV140->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO140.

  GS_LAYO120-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV140->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO140.

  CALL METHOD GO_ALV140->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_SO .
  CLEAR: GT_DISPLAY140, GS_DISPLAY140.

  IF GS_DISPLAY-SONUM IS INITIAL.
    MESSAGE S228 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 140
    STARTING AT 20 8.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIALOG_MATCODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DIALOG_MATCODE .
  CLEAR: GS_DISPLAY170, GT_DISPLAY170, ZSBMM1010, ZSBMM0070, ZSBPP0060, ZSBSD0080.

* TAB1 DATA
  PERFORM GET_TAB1.
  PERFORM GET_DATA_ALV170.

  IF GS_DISPLAY-MATCODE IS INITIAL.
    MESSAGE S229 DISPLAY LIKE 'E'.
  ELSE.
    TAB_STRIP-ACTIVETAB = '160'.
    CALL SCREEN 150
    STARTING AT 30 3.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TAB1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TAB1 .
  SELECT SINGLE *
    FROM ZTBMM1010 AS A
    JOIN ZTBMM1011 AS B
      ON A~MATCODE = B~MATCODE
   WHERE A~MATCODE = @GS_DISPLAY-MATCODE
     AND B~SPRAS = @SY-LANGU
    INTO CORRESPONDING FIELDS OF @ZSBMM1010.

  SELECT SINGLE *
  FROM ZTBMM0070 AS A
  JOIN ZTBSD1051 AS B
    ON A~BPCODE = B~BPCODE
 WHERE A~MATCODE = @GS_DISPLAY-MATCODE
   AND B~SPARS = @SY-LANGU
  INTO CORRESPONDING FIELDS OF @ZSBMM0070.

  SELECT SINGLE BOMID
  FROM ZTBPP0070
 WHERE MATCODE = @GS_DISPLAY-MATCODE
  INTO CORRESPONDING FIELDS OF @ZSBPP0060.

  SELECT SINGLE *
    FROM ZTBPP0061 AS A
    JOIN ZTBPP0060 AS B
      ON A~ROUTID = B~ROUTID
   WHERE A~MATCODE = @GS_DISPLAY-MATCODE
    INTO CORRESPONDING FIELDS OF @ZSBPP0060.

  SELECT SINGLE A~CTRYCODE, A~PRICE, A~CURRENCY, B~CTRYNAME
    FROM ZTBSD0080 AS A
    JOIN ZTBSD1040 AS B
      ON A~CTRYCODE = B~CTRYCODE
   WHERE A~MATCODE = @GS_DISPLAY-MATCODE
     AND A~CTRYCODE = 'KR'
    INTO (@ZSBSD0080-CTRYCODE1, @ZSBSD0080-PRICE1, @ZSBSD0080-CURRENCY1, @ZSBSD0080-CTRYNAME1).

  SELECT SINGLE A~CTRYCODE, A~PRICE, A~CURRENCY, B~CTRYNAME
  FROM ZTBSD0080 AS A
  JOIN ZTBSD1040 AS B
    ON A~CTRYCODE = B~CTRYCODE
 WHERE A~MATCODE = @GS_DISPLAY-MATCODE
   AND A~CTRYCODE = 'CH'
  INTO (@ZSBSD0080-CTRYCODE3, @ZSBSD0080-PRICE3, @ZSBSD0080-CURRENCY3, @ZSBSD0080-CTRYNAME3).

  SELECT SINGLE A~CTRYCODE, A~PRICE, A~CURRENCY, B~CTRYNAME
FROM ZTBSD0080 AS A
JOIN ZTBSD1040 AS B
  ON A~CTRYCODE = B~CTRYCODE
WHERE A~MATCODE = @GS_DISPLAY-MATCODE
 AND A~CTRYCODE = 'DE'
INTO (@ZSBSD0080-CTRYCODE4, @ZSBSD0080-PRICE4, @ZSBSD0080-CURRENCY4, @ZSBSD0080-CTRYNAME4).

  SELECT SINGLE A~CTRYCODE, A~PRICE, A~CURRENCY, B~CTRYNAME
FROM ZTBSD0080 AS A
JOIN ZTBSD1040 AS B
ON A~CTRYCODE = B~CTRYCODE
WHERE A~MATCODE = @GS_DISPLAY-MATCODE
AND A~CTRYCODE = 'US'
INTO (@ZSBSD0080-CTRYCODE2, @ZSBSD0080-PRICE2, @ZSBSD0080-CURRENCY2, @ZSBSD0080-CTRYNAME2).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_ALV170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_ALV170 .
  " ZTBMM0030 재고현황.

  SELECT *
    FROM ZTBMM0030
   WHERE MATCODE = @GS_DISPLAY-MATCODE
    INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY170.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_170 .
  CREATE OBJECT GO_CUST170
    EXPORTING
      CONTAINER_NAME              = 'AREA170'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
  ENDIF.

  CREATE OBJECT GO_ALV170
    EXPORTING
      I_PARENT          = GO_CUST170
    EXCEPTIONS
      ERROR_CNTL_CREATE = 1
      ERROR_CNTL_INIT   = 2
      ERROR_CNTL_LINK   = 3
      ERROR_DP_CREATE   = 4
      OTHERS            = 5.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT170 .
  CLEAR GS_LAYO170.

  GS_LAYO170-ZEBRA = 'X'.
  GS_LAYO170-CWIDTH_OPT = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_ALV170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_ALV170 .
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'MANDT'.
  GS_FCAT170-JUST = 'C'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'WHCODE'.
  GS_FCAT170-JUST = 'C'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'MATCODE'.
  GS_FCAT170-JUST = 'C'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'MATTYPE'.
  GS_FCAT170-JUST = 'C'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'CURRSTOCK'.
  GS_FCAT170-JUST = 'R'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'UNITCODE1'.
  GS_FCAT170-JUST = 'L'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'SAFESTOCK'.
  GS_FCAT170-JUST = 'R'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.

  GS_FCAT170-FIELDNAME = 'UNITCODE2'.
  GS_FCAT170-JUST = 'L'.
  APPEND GS_FCAT170 TO GT_FCAT170.
  CLEAR GS_FCAT170.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_ALV170 .
* DIALOG ALV TOOLBAR HIDDEN 처리.
  DATA: LS_EXCLUD TYPE UI_FUNC,
        LT_EXCLUD TYPE UI_FUNCTIONS.

  LS_EXCLUD = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
  APPEND LS_EXCLUD TO LT_EXCLUD.

  GS_VARIANT-REPORT = SY-CPROG.
  GS_VARIANT-VARIANT = '/ALV170'.

* DIALOG ALV DISPLAY.
  CALL METHOD GO_ALV170->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_STRUCTURE_NAME              = 'ZTBMM0030'
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*     I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYO170
*     IT_TOOLBAR_EXCLUDING          = LT_EXCLUD
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY170
      IT_FIELDCATALOG               = GT_FCAT170
*     IT_SORT                       = GT_SORT120
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.
  IF SY-SUBRC <> 0.
    MESSAGE S205 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV170
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV170 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV170->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO170.

  GS_LAYO170-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV170->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO170.

  CALL METHOD GO_ALV170->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV100 .
  DATA: LS_STABLE TYPE LVC_S_STBL.

  CALL METHOD GO_ALV100->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = GS_LAYO.

  GS_LAYO-CWIDTH_OPT = ABAP_ON.

  CALL METHOD GO_ALV100->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYO.

  CALL METHOD GO_ALV100->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREV_PAGE
*&---------------------------------------------------------------------*
*& '이전' 버튼을 눌렀을 때, '이전'버튼 활성화/비활성화 설정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PREV_PAGE .
  DATA: LV_VALID   LIKE GV_PAGE,
        LV_INVALID LIKE GV_PAGE,
        LV_DOCNUM  TYPE N LENGTH 10.

  DATA : LV_CURR       LIKE ZTBMM0041-CURRENCY, " Currency 값 변수
         LV_BEFORE_AMT LIKE BAPICURR-BAPICURR,  " DB 금액 값 변수
         LV_AFTER_AMT  LIKE BAPICURR-BAPICURR.  " ALV display 금액 값 변수

  CLEAR: GV_PAGE, GT_DISPLAY200, GS_DISPLAY200.

  LV_VALID = 0.
  LV_INVALID = 1.

* 현재 자재문서 번호보다 2개 이전 데이터를 LT_ZTBMM0040 에 할당.
  SELECT DOCYEAR, DOCNUM
    FROM ZTBMM0040
   WHERE DOCYEAR LE @ZTBMM0040-DOCYEAR " 현재 자재문서의 생성연도 이하 포함.
     AND DOCNUM LT @ZTBMM0040-DOCNUM " 현재 자재문서의 번호보다 작은값.
ORDER BY DOCNUM DESCENDING
    INTO TABLE @DATA(LT_ZTBMM0040)
   UP TO 2 ROWS.

  IF SY-SUBRC = 0. " 선택한 자재 문서의 이전 자재 문서가 2개 있을 때.

    READ TABLE LT_ZTBMM0040 INTO DATA(LS_ZTBMM0040) INDEX 1.
    MOVE-CORRESPONDING LS_ZTBMM0040 TO GS_DISPLAY200.
    MOVE-CORRESPONDING LS_ZTBMM0040 TO ZTBMM0040.

*   ALV200에 띄울 데이터 SELECT문.
    SELECT FROM ZTBMM0040 AS A        " 자재문서 HEADER
      LEFT JOIN ZTBMM0041 AS B        " 자재문서 ITEM
             ON A~DOCNUM EQ B~DOCNUM  " 자재문서번호.
           JOIN ZTBMM1020  AS C       " PLANT 마스터.
             ON A~PLTCODE EQ C~PLTCODE" 플랜트 코드.
           JOIN ZTBMM1010 AS D        " 자재 마스터.
             ON B~MATCODE EQ D~MATCODE" 자재 번호.
           JOIN ZTBMM1011 AS E        " 자재 TEXT TABLE.
             ON D~MATCODE EQ E~MATCODE" 자재 번호.
            AND E~SPRAS EQ @SY-LANGU  " 언어 키.
      FIELDS *
      WHERE A~DOCNUM = @GS_DISPLAY200-DOCNUM
       INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY200.

    SORT GT_DISPLAY200 BY MATCODE.

* 'KRW' 화폐단위의 표기 오류 수정을 위한 BAPI FM 호출.
    LOOP AT GT_DISPLAY200 INTO GS_DISPLAY200.
      LV_BEFORE_AMT = GS_DISPLAY200-MVPRICE.
      LV_CURR = GS_DISPLAY200-CURRENCY.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          AMOUNT_EXTERNAL      = LV_BEFORE_AMT
          CURRENCY             = LV_CURR
          MAX_NUMBER_OF_DIGITS = 21  "출력할 금액필드의 자릿수"
        IMPORTING
          AMOUNT_INTERNAL      = LV_AFTER_AMT.

      GS_DISPLAY200-MVPRICE = LV_AFTER_AMT.

      MODIFY GT_DISPLAY200 FROM GS_DISPLAY200.
    ENDLOOP.

*   현재 자재문서의 전전 데이터가 있는지 확인.
    READ TABLE LT_ZTBMM0040 TRANSPORTING NO FIELDS INDEX 2.

*   전전 데이터의 존재유무에 따라 GV_PAGE 값 변경.
    IF SY-SUBRC = 0.
      GV_PAGE = LV_VALID. " 전전 데이터 있으면, GV_PAGE = 0.
    ELSE.
      GV_PAGE = LV_INVALID. " 전전 데이터 없으면, GV_PAGE = 1.
    ENDIF.

*   GV_PAGE 바뀐 값으로 STATUS 변경.
    CL_GUI_CFW=>SET_NEW_OK_CODE(
      EXPORTING
        NEW_CODE = 'ENTER').              " New OK_CODE

    PERFORM REFRESH_ALV200.

  ELSE. " 선택한 자재 문서의 이전 자재 문서가 없을 때.
    GV_PAGE = LV_INVALID. " 'PREV' 버튼 비활성화.

*   GV_PAGE 바뀐 값으로 STATUS 변경.
    CL_GUI_CFW=>SET_NEW_OK_CODE(
          EXPORTING
            NEW_CODE = 'ENTER').              " New OK_CODE

    PERFORM REFRESH_ALV200.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form NEXT_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM NEXT_PAGE .
  DATA: LV_VALID   LIKE GV_PAGE,
        LV_INVALID LIKE GV_PAGE,
        LV_DOCNUM  TYPE N LENGTH 10.

  DATA : LV_CURR       LIKE ZTBMM0041-CURRENCY, " Currency 값 변수
         LV_BEFORE_AMT LIKE BAPICURR-BAPICURR,  " DB 금액 값 변수
         LV_AFTER_AMT  LIKE BAPICURR-BAPICURR.  " ALV display 금액 값 변수

  CLEAR: GV_PAGE, GT_DISPLAY200, GS_DISPLAY200.

  LV_VALID = 0.
  LV_INVALID = -1.

* 현재 자재문서 번호보다 2개 다음 데이터를 LT_ZTBMM0040 에 할당.
  SELECT DOCYEAR, DOCNUM
    FROM ZTBMM0040
   WHERE DOCYEAR GE @ZTBMM0040-DOCYEAR " 현재 자재문서의 생성연도 이상 포함.
     AND DOCNUM GT @ZTBMM0040-DOCNUM " 현재 자재문서의 번호보다 큰값.
ORDER BY DOCNUM ASCENDING
    INTO TABLE @DATA(LT_ZTBMM0040)
   UP TO 2 ROWS.

  IF SY-SUBRC = 0. " 선택한 자재 문서의 다음 자재 문서가 2개 있을 때.

    READ TABLE LT_ZTBMM0040 INTO DATA(LS_ZTBMM0040) INDEX 1.
    MOVE-CORRESPONDING LS_ZTBMM0040 TO GS_DISPLAY200.
    MOVE-CORRESPONDING LS_ZTBMM0040 TO ZTBMM0040.

*   ALV200에 띄울 데이터 SELECT문.
    SELECT FROM ZTBMM0040 AS A        " 자재문서 HEADER
      LEFT JOIN ZTBMM0041 AS B        " 자재문서 ITEM
             ON A~DOCNUM EQ B~DOCNUM  " 자재문서번호.
           JOIN ZTBMM1020  AS C       " PLANT 마스터.
             ON A~PLTCODE EQ C~PLTCODE" 플랜트 코드.
           JOIN ZTBMM1010 AS D        " 자재 마스터.
             ON B~MATCODE EQ D~MATCODE" 자재 번호.
           JOIN ZTBMM1011 AS E        " 자재 TEXT TABLE.
             ON D~MATCODE EQ E~MATCODE" 자재 번호.
            AND E~SPRAS EQ @SY-LANGU  " 언어 키.
      FIELDS *
      WHERE A~DOCNUM = @GS_DISPLAY200-DOCNUM
       INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY200.

    SORT GT_DISPLAY200 BY MATCODE.

* 'KRW' 화폐단위의 표기 오류 수정을 위한 BAPI FM 호출.
    LOOP AT GT_DISPLAY200 INTO GS_DISPLAY200.
      LV_BEFORE_AMT = GS_DISPLAY200-MVPRICE.
      LV_CURR = GS_DISPLAY200-CURRENCY.

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          AMOUNT_EXTERNAL      = LV_BEFORE_AMT
          CURRENCY             = LV_CURR
          MAX_NUMBER_OF_DIGITS = 21  "출력할 금액필드의 자릿수"
        IMPORTING
          AMOUNT_INTERNAL      = LV_AFTER_AMT.

      GS_DISPLAY200-MVPRICE = LV_AFTER_AMT.

      MODIFY GT_DISPLAY200 FROM GS_DISPLAY200.
    ENDLOOP.

*   현재 자재문서의 다음다음 데이터가 있는지 확인.
    READ TABLE LT_ZTBMM0040 TRANSPORTING NO FIELDS INDEX 2.

*   다음다음 데이터의 존재유무에 따라 GV_PAGE 값 변경.
    IF SY-SUBRC = 0.
      GV_PAGE = LV_VALID. " 다음다음 데이터 있으면, GV_PAGE = 0.
    ELSE.
      GV_PAGE = LV_INVALID. " 다음다음 데이터 있으면, GV_PAGE = 1.
    ENDIF.

*   GV_PAGE 바뀐 값으로 STATUS 변경.
    CL_GUI_CFW=>SET_NEW_OK_CODE(
      EXPORTING
        NEW_CODE = 'ENTER').              " New OK_CODE

    PERFORM REFRESH_ALV200.

  ELSE. " 선택한 자재 문서의 다음 자재 문서가 없을 때.
    GV_PAGE = LV_INVALID. " 'NEXT' 버튼 비활성화.

*   GV_PAGE 바뀐 값으로 STATUS 변경.
    CL_GUI_CFW=>SET_NEW_OK_CODE(
          EXPORTING
            NEW_CODE = 'ENTER').              " New OK_CODE

    PERFORM REFRESH_ALV200.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& 클릭한 자재문서 번호에 대해 '이전', '다음' 번호가 있는지 여부 확인.
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .
  DATA: LV_VALID   LIKE GV_PAGE,
        LV_INVALID LIKE GV_PAGE.

  LV_VALID = 0.
  LV_INVALID = 1.

  SELECT DOCYEAR, DOCNUM
    FROM ZTBMM0040
   WHERE DOCYEAR LE @GS_DISPLAY-DOCYEAR " 현재 자재문서의 생성연도 이하 포함.
     AND DOCNUM LT @GS_DISPLAY-DOCNUM " 현재 자재문서의 번호보다 작은값.
ORDER BY DOCNUM DESCENDING
    INTO TABLE @DATA(LT_ZTBMM0040)
   UP TO 1 ROWS.

  IF SY-SUBRC = 0. " 선택한 자재 문서의 이전 자재 문서가 있을 때.
    GV_PAGE = LV_VALID. " 'PREV' 버튼 활성화.

  ELSE. " 선택한 자재 문서의 이전 자재 문서가 없을 때.
    GV_PAGE = LV_INVALID. " 'PREV' 버튼 비활성화.
  ENDIF.

  IF GV_PAGE EQ LV_INVALID. " 이전 자재 문서가 존재하지 않을 때.
    CALL SCREEN 200
      STARTING AT 15 7.

  ELSE. " 선택한 문서의 이전 자재 문서가 존재할 때, 다음 자재 문서가 존재하는지 확인.
    CLEAR: LV_INVALID, LT_ZTBMM0040.
    LV_INVALID = -1.

    SELECT DOCYEAR, DOCNUM
      FROM ZTBMM0040
     WHERE DOCYEAR GE @GS_DISPLAY-DOCYEAR " 현재 자재문서의 생성연도 이상 포함.
       AND DOCNUM GT @GS_DISPLAY-DOCNUM " 현재 자재문서의 번호보다 큰 값.
  ORDER BY DOCNUM ASCENDING
      INTO TABLE @LT_ZTBMM0040
     UP TO 1 ROWS.

    IF SY-SUBRC = 0. " 선택한 자재 문서의 다음 자재 문서가 있을 때.
      GV_PAGE = LV_VALID. " 'NEXT' 버튼 활성화.

    ELSE. " 선택한 자재 문서의 다음 자재 문서가 없을 때.
      GV_PAGE = LV_INVALID. " 'NEXT' 버튼 비활성화.
    ENDIF.
    CALL SCREEN 200
      STARTING AT 15 7.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GO_DOCK
    EXPORTING
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
      SIDE      = GO_DOCK->DOCK_AT_RIGHT
*     side      = cl_gui_docking_container=>dock_at_top
      EXTENSION = 2000.

  CREATE OBJECT GO_SPLIT
    EXPORTING
      PARENT  = GO_DOCK
      ROWS    = 1
      COLUMNS = 2.

  CALL METHOD GO_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 1                 " Column
    RECEIVING
      CONTAINER = GO_CONT1.                 " Container

  CALL METHOD GO_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 2                 " Column
    RECEIVING
      CONTAINER = GO_CONT2.                 " Container

  CALL METHOD GO_SPLIT->SET_COLUMN_WIDTH
    EXPORTING
      ID                = 1                " Column ID
      WIDTH             = 20                 " NPlWidth
    EXCEPTIONS
      CNTL_ERROR        = 1                " See CL_GUI_CONTROL
      CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
      OTHERS            = 3.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* DOCKING CONTAINER에 TREE 생성.
  CREATE OBJECT GO_TREE100
    EXPORTING
      PARENT              = GO_CONT1 " Parent Container
      NODE_SELECTION_MODE = CL_GUI_SIMPLE_TREE=>NODE_SEL_MODE_SINGLE
    EXCEPTIONS
      OTHERS              = 1.
  IF SY-SUBRC NE 0.
    MESSAGE S201 DISPLAY LIKE 'E'. " Tree 객체 생성 중 오류가 발생하였습니다.
  ENDIF.


* CUSTOM CONTAINER에 ALV 생성.
  CREATE OBJECT GO_ALV100
    EXPORTING
      I_PARENT = GO_CONT2 " Parent Container
    EXCEPTIONS
      OTHERS   = 1.
  IF SY-SUBRC NE 0.
    MESSAGE S202 DISPLAY LIKE 'E'. " ALV 객체 생성 중 오류가 발생하였습니다.
  ENDIF.
ENDFORM.
