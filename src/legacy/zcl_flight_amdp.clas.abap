CLASS zcl_flight_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS convert_currency IMPORTING VALUE(iv_amount)               TYPE ztotal_price
                                                  VALUE(iv_currency_code_source) TYPE zcurrency_code
                                                  VALUE(iv_currency_code_target) TYPE zcurrency_code
                                                  VALUE(iv_exchange_rate_date)   TYPE d
                                        EXPORTING VALUE(ev_amount)               TYPE ztotal_price.
ENDCLASS.



CLASS zcl_flight_amdp IMPLEMENTATION.

  METHOD convert_currency BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY .
    tab = SELECT CONVERT_CURRENCY( amount         => :iv_amount,
                                   source_unit    => :iv_currency_code_source,
                                   target_unit    => :iv_currency_code_target,
                                   reference_date => :iv_exchange_rate_date,
                                   schema         => CURRENT_SCHEMA,
                                   error_handling => 'set to null',
                                   steps          => 'shift,convert,shift_back',
                                   client         => SESSION_CONTEXT( 'CLIENT' )
                                ) AS target_value
              FROM dummy ;
    ev_amount = :tab.target_value[1];
  ENDMETHOD.

ENDCLASS.
