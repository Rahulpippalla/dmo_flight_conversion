CLASS zcl_data_generator_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_data_generation_badi .
    INTERFACES if_badi_interface .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_data_generator_draft IMPLEMENTATION.


  METHOD zif_data_generation_badi~data_generation.
    " Travels
    out->write( ' --> ZA_TRAVEL_D' ).

    DELETE FROM zd_travel_d.                        "#EC CI_NOWHERE
    DELETE FROM za_travel_d.                        "#EC CI_NOWHERE

    INSERT za_travel_d FROM (
      SELECT FROM ztravel FIELDS
        " client
        uuid( ) AS travel_uuid,
        travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        CASE status WHEN 'B' THEN 'A'
                    WHEN 'P' THEN 'O'
                    WHEN 'N' THEN 'O'
                    ELSE 'X' END AS overall_status,
        createdby AS local_created_by,
        createdat AS local_created_at,
        lastchangedby AS local_last_changed_by,
        lastchangedat AS local_last_changed_at,
        lastchangedat AS last_changed_at
    ).


    " bookings
    out->write( ' --> ZA_BOOKING_D' ).

    DELETE FROM zd_booking_d.                       "#EC CI_NOWHERE
    DELETE FROM za_booking_d.                       "#EC CI_NOWHERE

    INSERT za_booking_d FROM (
        SELECT
          FROM zbooking
            JOIN za_travel_d ON zbooking~travel_id = za_travel_d~travel_id
            JOIN ztravel ON ztravel~travel_id = zbooking~travel_id
          FIELDS  "client,
                  uuid( ) AS booking_uuid,
                  za_travel_d~travel_uuid AS parent_uuid,
                  zbooking~booking_id,
                  zbooking~booking_date,
                  zbooking~customer_id,
                  zbooking~carrier_id,
                  zbooking~connection_id,
                  zbooking~flight_date,
                  zbooking~flight_price,
                  zbooking~currency_code,
                  CASE ztravel~status WHEN 'P' THEN 'N'
                                                   ELSE ztravel~status END AS booking_status,
                  za_travel_d~last_changed_at AS local_last_changed_at
    ).



    " Booking supplements
    out->write( ' --> ZA_BKSUPPL_D' ).

    DELETE FROM zd_bksuppl_d.                       "#EC CI_NOWHERE
    DELETE FROM za_bksuppl_d.                       "#EC CI_NOWHERE

    INSERT za_bksuppl_d FROM (
      SELECT FROM zbook_suppl    AS supp
               JOIN za_travel_d  AS trvl ON trvl~travel_id = supp~travel_id
               JOIN za_booking_d AS book ON book~parent_uuid = trvl~travel_uuid
                                            AND book~booking_id = supp~booking_id

        FIELDS
          " client
          uuid( )                 AS booksuppl_uuid,
          trvl~travel_uuid        AS root_uuid,
          book~booking_uuid       AS parent_uuid,
          supp~booking_supplement_id,
          supp~supplement_id,
          supp~price,
          supp~currency_code,
          trvl~last_changed_at    AS local_last_changed_at
    ).

  ENDMETHOD.


ENDCLASS.
