*&---------------------------------------------------------------------*
*& Report ZBRMM0050
*&---------------------------------------------------------------------*
*&   [MM]
*&   개발자        : CL2 kdt-b-25 하정훈
*&   프로그램 개요   : 자재 문서 조회 프로그램
*&   개발 시작일    :'2024.11.01'
*&   개발 완료일    :'2024.11.04'
*&   개발상태      : 개발 완료.
*&---------------------------------------------------------------------*
REPORT ZBRMM0050_B25 MESSAGE-ID ZCOMMON_MSG. " 공통 message class 호출

INCLUDE ZBRMM0050_B25_TOP." 데이터 선언부
INCLUDE ZBRMM0050_B25_C01." 클래스 선언부
INCLUDE ZBRMM0050_B25_O01." PBO 선언부
INCLUDE ZBRMM0050_B25_I01." PAI 선언부
INCLUDE ZBRMM0050_B25_F01." Subroutine 선언부

START-OF-SELECTION.
  PERFORM SELECT_DATA. " 트리 노드 ITAB 세팅 서브루틴 실행
  CALL SCREEN 100. " 100번 스크린 호출
