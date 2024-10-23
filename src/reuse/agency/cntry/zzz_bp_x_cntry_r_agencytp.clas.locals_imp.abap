CLASS ltcl_agency DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Agency DEFINITION INHERITING FROM cl_abap_behavior_handler
  FRIENDS ltcl_Agency.

  PUBLIC SECTION.

    CONSTANTS:
      validate_dialling_code    TYPE string VALUE 'VALIDATE_DIALLING_CODE' ##NO_TEXT.

    TYPES: BEGIN OF t_countries,
             number TYPE zphone_number,
             code   TYPE land1,
           END OF t_countries.

    CLASS-DATA: countries TYPE STANDARD TABLE OF t_countries WITH KEY number.
    CLASS-METHODS: class_constructor.

  PRIVATE SECTION.

    METHODS validateDiallingCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZAgency~ZvalidateDiallingCode.
    METHODS determineCountryCode FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZAgency~ZdetermineCountryCode.
    METHODS determineDiallingCode FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZAgency~ZdetermineDiallingCode.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZAgency RESULT result.
    METHODS createFromTemplate FOR MODIFY
      IMPORTING keys FOR ACTION ZAgency~ZcreateFromTemplate.

ENDCLASS.

CLASS lhc_Agency IMPLEMENTATION.



  METHOD validateDiallingCode.

    READ ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY ZAgency
       FIELDS ( PhoneNumber CountryCode ) WITH CORRESPONDING #( keys )
      RESULT DATA(agencies).

    LOOP AT agencies INTO DATA(agency).
      APPEND VALUE #( %tky        = agency-%tky
                      %state_area = validate_dialling_code ) TO reported-ZAgency.

      IF agency-PhoneNumber IS INITIAL.
        CONTINUE.
      ENDIF.

      IF agency-PhoneNumber(2) = '00'.
        REPLACE FIRST OCCURRENCE OF '00' IN agency-Phonenumber WITH '+'.
      ENDIF.

      IF agency-PhoneNumber(1) <> '+'.

        APPEND VALUE #( %tky        = agency-%tky
                        %state_area = validate_dialling_code
                        %msg        = NEW zzz_cx_agency_country( textid      = zzz_cx_agency_country=>number_invalid
                                                             phonenumber = agency-PhoneNumber )
                        %element-PhoneNumber = if_abap_behv=>mk-on )
                        TO reported-ZAgency.

      ELSEIF NOT line_exists( countries[ number = agency-phonenumber(2) code = agency-CountryCode ] )
      AND NOT line_exists( countries[ number = agency-phonenumber(3) code = agency-CountryCode ] )
      AND NOT line_exists( countries[ number = agency-phonenumber(4) code = agency-CountryCode ] ).
        APPEND VALUE #( %tky        = agency-%tky
                        %state_area = validate_dialling_code
                        %msg        = NEW zzz_cx_agency_country( textid      = zzz_cx_agency_country=>combination_invalid )
                        %element-PhoneNumber = if_abap_behv=>mk-on )
                        TO reported-ZAgency.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD determineCountryCode.

    READ ENTITIES OF zi_agencytp IN LOCAL MODE
        ENTITY ZAgency
          FIELDS ( PhoneNumber CountryCode ) WITH CORRESPONDING #( keys )
        RESULT DATA(agencies).

    DELETE agencies WHERE CountryCode IS NOT INITIAL.
    DATA: agencies_to_update TYPE TABLE FOR UPDATE zi_agencytp.

    LOOP AT countries INTO DATA(country).
      DATA(country_with_00) = country-number.
      REPLACE FIRST OCCURRENCE OF '+' IN country_with_00 WITH '00'.
      LOOP AT agencies INTO DATA(agency)
        WHERE PhoneNumber CP country-number  && '*'
          OR  PhoneNumber CP country_with_00 && '*'.
        APPEND VALUE #( %tky        = agency-%tky
                        countrycode = country-code ) TO agencies_to_update.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY ZAgency
        UPDATE FIELDS ( countrycode ) WITH agencies_to_update
      REPORTED DATA(reported_modify).

  ENDMETHOD.

  METHOD determineDiallingCode.

    READ ENTITIES OF zi_agencytp IN LOCAL MODE
        ENTITY ZAgency
          FIELDS ( PhoneNumber CountryCode ) WITH CORRESPONDING #( keys )
        RESULT DATA(agencies).

    DELETE agencies WHERE PhoneNumber IS NOT INITIAL.
    DATA: agencies_to_update TYPE TABLE FOR UPDATE zi_agencytp.

    LOOP AT agencies INTO DATA(agency).
      DATA(PhoneNumber) = VALUE #( countries[ code = agency-countrycode ]-number OPTIONAL ) .
      IF PhoneNumber IS NOT INITIAL.
        APPEND VALUE #( %tky = agency-%tky
                        phonenumber = PhoneNumber ) TO agencies_to_update.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY ZAgency
        UPDATE FIELDS ( PhoneNumber ) WITH agencies_to_update
      REPORTED DATA(reported_modify).

  ENDMETHOD.



  METHOD class_constructor.

    countries = VALUE #( ( number = '+1'   code = 'US' )
                         ( number = '+49'  code = 'DE' )
                         ( number = '+39'  code = 'IT' )
                         ( number = '+43'  code = 'AT' )
                         ( number = '+44'  code = 'GB' )
                         ( number = '+81'  code = 'JP' )
                         ( number = '+33'  code = 'FR' )
                         ( number = '+358' code = 'FI' )
                         ( number = '+385' code = 'HR' ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD createFromTemplate.

    READ ENTITIES OF ZI_AgencyTP IN LOCAL MODE
      ENTITY ZAgency
        FIELDS ( CountryCode PostalCode City Street ) WITH CORRESPONDING #( keys )
      RESULT DATA(agencies)
      FAILED failed.

    DATA: agencies_to_create TYPE TABLE FOR CREATE ZI_AgencyTP.
    LOOP AT agencies INTO DATA(agency).
      APPEND CORRESPONDING #( agency EXCEPT agencyid ) TO agencies_to_create ASSIGNING FIELD-SYMBOL(<agency_to_create>).
      <agency_to_create>-%cid = keys[ KEY id  %tky = agency-%tky ]-%cid.
      <agency_to_create>-%is_draft = if_abap_behv=>mk-on.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_AgencyTP IN LOCAL MODE
      ENTITY ZAgency
        CREATE FIELDS ( CountryCode PostalCode City Street ) WITH agencies_to_create
      MAPPED mapped.

  ENDMETHOD.

ENDCLASS.
