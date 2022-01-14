*&---------------------------------------------------------------------*
*& Report z_salt_customer
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_salt_customer.

*entering customer number
PARAMETERS p_custid TYPE scustom-id.

**********************************************************************
AT SELECTION-SCREEN.
  SELECT SINGLE
  FROM sbook
  FIELDS passname
  WHERE customid = @p_custid
  INTO @DATA(g_exists).

  IF g_exists IS INITIAL.
    MESSAGE 'Customer not found' TYPE 'E'.
  ENDIF.

**********************************************************************
START-OF-SELECTION.
*entering airline code



*creates structure as a template for the table
TYPES: BEGIN OF ts_complete,
         connid     TYPE s_conn_id,
         class      TYPE s_class,
         fldate     TYPE s_date,
         luggweight TYPE s_lugweigh,
         wunit      TYPE s_weiunit,
         cityfrom   TYPE s_from_cit,
         countryfr  TYPE land1,
         airpfrom   TYPE s_fromairp,
         cityto     TYPE s_to_city,
         countryto  TYPE Land1,
         airpto     TYPE s_toairp,
         deptime    TYPE s_dep_time,
         arrtime    TYPE s_arr_time,
         fltime     TYPE s_fltime,
         price      TYPE s_price,
         currency   TYPE s_currcode,
       END OF ts_complete.

*creates table to fill in data of the search results
DATA: gs_custinfo TYPE STANDARD TABLE OF ts_complete.

*select statement connecting sbook, sflight and spfli according to the searched parameters into a table
SELECT
       FROM sbook AS b
       INNER JOIN sflight AS f ON b~connid = f~connid AND
                                b~customid = @p_custid


       INNER JOIN spfli AS p ON p~connid =  f~connid


       FIELDS b~connid, b~fldate, f~price, f~currency, p~countryfr, p~cityfrom, p~airpfrom,
              p~countryto, p~cityto, p~airpto, p~deptime, p~arrtime,p~fltime, b~class, b~luggweight, b~wunit
       WHERE  b~fldate >= @sy-datlo
       ORDER BY b~fldate ASCENDING
       INTO CORRESPONDING FIELDS OF TABLE @gs_custinfo.

*deletes unnecessary duplicates from the table
DELETE ADJACENT DUPLICATES FROM gs_custinfo COMPARING connid.

*display the table if there results otherwise writes a hint that there are no entries for the search parameters
IF gs_custinfo IS NOT INITIAL.
  cl_salv_table=>factory( IMPORTING
                          r_salv_table = DATA(o_alv)
                        CHANGING
                          t_table = gs_custinfo ).
  o_alv->display( ).
ELSE.
  WRITE `No entries found.`.
ENDIF.
