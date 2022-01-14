*&---------------------------------------------------------------------*
*& Report z_airline
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_salt_airline.

*entering airline code
PARAMETERS p_carrid TYPE s_carr_id.

**********************************************************************
AT SELECTION-SCREEN.
  "checks if the entry is valid
  SELECT SINGLE
    FROM spfli
    FIELDS carrid
    WHERE carrid = @p_carrid
    INTO @DATA(g_exists).

  "error message in case of wrong entry
  IF g_exists IS INITIAL.
    MESSAGE 'Invalid Airline Code. Please try again.' TYPE 'E'.
  ENDIF.

**********************************************************************
START-OF-SELECTION.
  "creates structure as a template for the table
  TYPES: BEGIN OF ty_carr,
           connid    TYPE s_conn_id,
           fldate    TYPE s_date,
           arrtime   TYPE s_arr_time,
           deptime   TYPE s_dep_time,
           countryfr TYPE land1,
           cityfrom  TYPE s_from_cit,
           airpfrom  TYPE s_fromairp,
           countryto TYPE land1,
           cityto    TYPE s_to_city,
           airpto    TYPE s_toairp,
           planetype TYPE s_planetye,
         END OF ty_carr.

  "creates table to later fill the needed data into
  TYPES ty_carrs TYPE STANDARD TABLE OF ty_carr WITH KEY connid.
  DATA g_carr TYPE ty_carrs.

  "fills the needed data into the table
  SELECT
         FROM ( ( spfli AS p
           INNER JOIN sflight AS f ON p~connid = f~connid
                                   AND p~carrid = f~carrid
                                   AND p~carrid = @p_carrid
           )  )
         FIELDS p~connid, f~fldate, p~arrtime, p~deptime, p~countryfr, p~cityfrom, p~airpfrom, p~countryto, p~cityto, p~airpto, f~planetype
         INTO CORRESPONDING FIELDS OF TABLE @g_carr.

  "displays the table
  cl_salv_table=>factory( IMPORTING
                           r_salv_table = DATA(o_alv)
                         CHANGING
                           t_table = g_carr ).
  o_alv->display( ).
