CLASS ltc_agency_handler DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Agency DEFINITION
  INHERITING FROM cl_abap_behavior_handler
  FRIENDS ltc_agency_handler
  .

  PUBLIC SECTION.

    CONSTANTS:
      state_area_validate_attachment TYPE string VALUE 'VALIDATE_ATTACHMENT' ##NO_TEXT,
      state_area_validate_name       TYPE string VALUE 'VALIDATE_NAME'       ##NO_TEXT,
      state_area_validate_email      TYPE string VALUE 'VALIDATE_EMAIL'      ##NO_TEXT,
      state_area_validate_country    TYPE string VALUE 'VALIDATE_COUNTRY'    ##NO_TEXT.


  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZAgency RESULT result.

    METHODS validateCountryCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZAgency~ZvalidateCountryCode.

    METHODS validateEMailAddress FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZAgency~ZvalidateEMailAddress.

    METHODS validateName FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZAgency~ZvalidateName.


ENDCLASS.

CLASS lhc_Agency IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateCountryCode.
    DATA: countries TYPE SORTED TABLE OF I_Country WITH UNIQUE KEY Country.

    READ ENTITIES OF ZR_AgencyTP IN LOCAL MODE
      ENTITY ZAgency
        FIELDS ( CountryCode )
        WITH CORRESPONDING #(  keys )
        RESULT DATA(agencies).


    countries = CORRESPONDING #( agencies DISCARDING DUPLICATES MAPPING Country = CountryCode EXCEPT * ).
    DELETE countries WHERE Country IS INITIAL.

    IF countries IS NOT INITIAL.
      SELECT FROM I_Country FIELDS Country
        FOR ALL ENTRIES IN @countries
        WHERE Country = @countries-Country
        INTO TABLE @DATA(countries_db).
    ENDIF.

    LOOP AT agencies INTO DATA(agency).
      APPEND VALUE #(
          %tky        = agency-%tky
          %state_area = state_area_validate_country
        ) TO reported-zagency.

      IF   agency-CountryCode IS INITIAL
        OR NOT line_exists( countries_db[ Country = agency-CountryCode ] ).

        APPEND VALUE #(  %tky = agency-%tky ) TO failed-zagency.
        APPEND VALUE #(
            %tky                 = agency-%tky
            %state_area          = state_area_validate_country
            %msg                 = NEW zcx_agency(
                                       textid      = zcx_agency=>country_code_invalid
                                       countrycode = agency-CountryCode
                                     )
            %element-CountryCode = if_abap_behv=>mk-on
          ) TO reported-zagency.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEMailAddress.
    READ ENTITIES OF ZR_AgencyTP IN LOCAL MODE
      ENTITY ZAgency
        FIELDS ( EMailAddress )
        WITH CORRESPONDING #( keys )
        RESULT DATA(agencies).

    LOOP AT agencies INTO DATA(agency).

      APPEND VALUE #(
          %tky        = Agency-%tky
          %state_area = state_area_validate_email
        ) TO reported-ZAgency.

      " Conversion to string to truncate trailing spaces, so + doesn't match space.
      IF CONV string( agency-emailaddress ) NP '+*@+*.+*'.

        APPEND VALUE #( %tky = agency-%tky ) TO failed-ZAgency.

        APPEND VALUE #(
            %tky                  = agency-%tky
            %state_area           = state_area_validate_email
            %msg                  = NEW zcx_agency( zcx_agency=>email_invalid_format )
            %element-EMailaddress = if_abap_behv=>mk-on
          ) TO reported-ZAgency.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateName.
    READ ENTITIES OF ZR_AgencyTP IN LOCAL MODE
      ENTITY ZAgency
        FIELDS ( Name )
        WITH CORRESPONDING #( keys )
        RESULT DATA(Agencies).

    LOOP AT Agencies INTO DATA(Agency).
      APPEND VALUE #(
          %tky        = Agency-%tky
          %state_area = state_area_validate_name
        ) TO reported-ZAgency.

      IF Agency-Name IS INITIAL.
        APPEND VALUE #( %tky = Agency-%tky ) TO failed-ZAgency.

        APPEND VALUE #(
            %tky          = Agency-%tky
            %state_area   = state_area_validate_name
            %msg          = NEW zcx_agency( zcx_agency=>name_required )
            %element-Name = if_abap_behv=>mk-on
          ) TO reported-ZAgency.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS ltc_agency_saver DEFINITION DEFERRED FOR TESTING.
CLASS lsc_Agency DEFINITION
  INHERITING FROM cl_abap_behavior_saver
  FRIENDS ltc_agency_saver.
  PROTECTED SECTION.
    METHODS adjust_numbers REDEFINITION.
ENDCLASS.

CLASS lsc_agency IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA:
      agency_id_max TYPE zagency_id,
      entity        TYPE STRUCTURE FOR MAPPED LATE ZR_AgencyTP.

    DATA(entities_wo_agencyid) = mapped-ZAgency.
    DELETE entities_wo_agencyid WHERE agencyid IS NOT INITIAL.

    IF entities_wo_agencyid IS INITIAL.
      EXIT.
    ENDIF.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZAGNCY'
            quantity          = CONV #( lines( entities_wo_agencyid  ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        RAISE SHORTDUMP lx_number_ranges.

    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        " 1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
        LOOP AT entities_wo_agencyid INTO entity.
          APPEND VALUE #(
              %pid = entity-%pid
              %key = entity-%key
              %msg = NEW zcx_agency(
                          textid   = zcx_agency=>number_range_depleted
                          severity = if_abap_behv_message=>severity-warning )
            ) TO reported-ZAgency.
        ENDLOOP.

      WHEN '2' OR '3'.
        " 2 - the last number of the interval was returned
        " 3 - if fewer numbers are available than requested,  the return code is 3
        RAISE SHORTDUMP NEW zcx_agency( textid   = zcx_agency=>not_sufficient_numbers
                                            severity = if_abap_behv_message=>severity-warning ).
    ENDCASE.

    " At this point ALL entities get a number!
    ASSERT number_range_returned_quantity = lines( entities_wo_agencyid ).

    agency_id_max = number_range_key - number_range_returned_quantity.

    " Set Agency ID
    LOOP AT mapped-ZAgency ASSIGNING FIELD-SYMBOL(<agency>) ."USING KEY entity" WHERE agencyid IS INITIAL.
      IF <agency>-agencyid IS INITIAL. "If condition necessary?
        agency_id_max += 1.
        <agency>-agencyid = agency_id_max .

        " Read table mapped assign
      ENDIF.
    ENDLOOP.

    ASSERT agency_id_max = number_range_key.

  ENDMETHOD.

ENDCLASS.
