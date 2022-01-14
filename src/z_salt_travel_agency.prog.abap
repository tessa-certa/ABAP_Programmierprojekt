*&---------------------------------------------------------------------*
*& Report z_salt_travel_agency
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_salt_travel_agency.

*variable to show only flights in near future (20 days)
DATA g_nextw TYPE d.
g_nextw = sy-datlo + 20.

*creates structure as a template for the table
TYPES: BEGIN OF ts_lastminutefl,
       connid TYPE s_conn_id,
       fldate TYPE s_date,
       price TYPE s_price,
       currency TYPE s_currcode,
       cityfrom TYPE s_from_cit,
       countryfr TYPE land1,
       airpfrom TYPE s_fromairp,
       cityto TYPE s_to_city,
       countryto TYPE Land1,
       airpto TYPE s_toairp,
       deptime TYPE s_dep_time,
       arrtime TYPE s_arr_time,
       fltime TYPE s_fltime,
       freeseats_e TYPE z_salt_freeseats,
       freeseats_b TYPE z_salt_freeseats_b,
       freeseats_f TYPE z_salt_freeseats_f,
       END OF ts_lastminutefl.

*creates table to fill in data of the results
data: gs_lastminutefl type standard table of ts_lastminutefl.

*select statement connecting sflight and spfli restricted by time and free seats
SELECT
       FROM ( ( spfli AS p
         INNER JOIN sflight AS f ON p~connid   = f~connid
             ) )
       FIELDS f~connid, f~fldate, f~price, f~currency,
         p~cityfrom, p~countryfr, p~airpfrom, p~cityto, p~countryto, p~airpto, p~deptime, p~arrtime, p~fltime,
         f~seatsmax - f~seatsocc  AS freeseats_e, f~seatsmax_b - f~seatsocc_b  AS freeseats_b,
         f~seatsmax_f - f~seatsocc_f  AS freeseats_f

       WHERE  f~fldate >= @sy-datlo AND f~fldate <= @g_nextw
              AND  f~seatsmax + f~seatsmax_b + f~seatsmax_f - f~seatsocc - f~seatsocc_b - f~seatsocc_f > 0
       ORDER BY f~price ASCENDING
       INTO CORRESPONDING FIELDS OF TABLE @gs_lastminutefl.

*display the table
cl_salv_table=>factory( IMPORTING
r_salv_table = data(o_alv)
changing t_table = gs_lastminutefl ).

o_alv->display( ).
