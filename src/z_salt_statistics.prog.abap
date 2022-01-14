*&---------------------------------------------------------------------*
*& Report z_statistics
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_salt_statistics.

*entering country, city or airport
PARAMETERS p_input  TYPE string.

*creating checkboxes and assigning values for sy-ucomm
PARAMETERS p_countr AS CHECKBOX USER-COMMAND check1.
PARAMETERS p_city   AS CHECKBOX USER-COMMAND check2.
PARAMETERS p_airprt AS CHECKBOX USER-COMMAND check3.

*variable for checking if the input exists in the chosen category
DATA g_exists.

*variable for working with sy-ucomm
DATA gd_ucomm TYPE sy-ucomm.

************************************************************************
AT SELECTION-SCREEN.
  gd_ucomm = sy-ucomm.
  "subdivision depending on type of chosen checkbox
  CASE gd_ucomm.

    WHEN 'CHECK1'.
      screen-input = 0.
      "clears other checkboxes
      CLEAR: p_city, p_airprt.
      CLEAR g_exists.

      "checks if the entry has the desired length
      IF strlen( p_input ) <= 3.

        "assigning value to g_exists in case the entry is valid
        SELECT SINGLE
          FROM spfli
          FIELDS carrid
          WHERE countryfr = @p_input
             OR countryto = @p_input
          INTO @g_exists.
      ENDIF.

    WHEN 'CHECK2'.

      "clears other checkboxes
      CLEAR: p_countr, p_airprt.
      CLEAR g_exists.

      "checks if the entry has the desired length
      IF strlen( p_input ) <= 20.

        "assigning value to g_exists in case the entry is valid
        SELECT SINGLE
        FROM spfli
        FIELDS carrid
        WHERE cityfrom = @p_input
           OR cityto = @p_input
        INTO @g_exists.
      ENDIF.

    WHEN 'CHECK3'.

      "clears other checkboxes
      CLEAR: p_countr, p_city.
      CLEAR g_exists.

      "checks if the entry has the desired length
      IF strlen( p_input ) <= 3.

        "assigning value to g_exists in case the entry is valid
        SELECT SINGLE
          FROM spfli
          FIELDS carrid
          WHERE airpfrom = @p_input
             OR airpto = @p_input
          INTO @g_exists.
      ENDIF.

  ENDCASE.

  "error message in case of wrong entry or choice of checkbox
  IF g_exists IS INITIAL.
    MESSAGE 'Invalid entry or wrong checkbox chosen. Please try again.' TYPE 'E'.
  ENDIF.

**********************************************************************
START-OF-SELECTION.

  "structure for the table
  TYPES: BEGIN OF ty_flight,
           connid TYPE s_conn_id,
         END OF ty_flight.

  "creation of tables for the desired information
  TYPES ty_flights TYPE STANDARD TABLE OF ty_flight WITH KEY connid.
  DATA g_depflights TYPE ty_flights.
  DATA g_arrflights TYPE ty_flights.

  "variables for output
  DATA g_depcount TYPE i.
  DATA g_arrcount TYPE i.

  "prints location
  WRITE p_input.

  "subdivision depending on type of chosen checkbox
  IF p_countr = 'X'.

    "initialize variable with accurate data type for countries
    DATA g_country TYPE land1.
    g_country = p_input.

    "fills table with departing flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~countryfr = @g_country
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_depflights.

    "fills table with arriving flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~countryto = @g_country
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_arrflights.
  ENDIF.
  IF p_city = 'X'.

    "initialize variable with accurate data type for cities
    DATA g_city TYPE s_to_city.
    g_city = p_input.

    "fills table with departing flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~cityfrom = @g_city
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_depflights.

    "fills table with arriving flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~cityto = @g_city
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_arrflights.
  ENDIF.
  IF p_airprt = 'X'.

    "initialize variable with accurate data type for airports
    DATA g_airport TYPE s_toairp.
    g_airport = p_input.

    "fills table with departing flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~airpfrom = @g_airport
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_depflights.

    "fills table with arriving flights
    SELECT
        FROM ( ( spfli AS p
            INNER JOIN sflight AS f ON p~connid = f~connid
                                    AND p~carrid = f~carrid
                                    AND p~airpto = @g_airport
            )  )
        FIELDS p~connid
        INTO CORRESPONDING FIELDS OF TABLE @g_arrflights.

  ENDIF.

  "counts and prints numbers of departing and arriving flights
  g_depcount = lines( g_depflights ).
  WRITE / `Number of departing flights:`.
  WRITE g_depcount .
  g_arrcount = lines( g_arrflights ).
  WRITE / `Number of arriving flights:`.
  WRITE g_arrcount.
