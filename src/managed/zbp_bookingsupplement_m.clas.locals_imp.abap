CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY IMPORTING keys FOR booksuppl~calculateTotalPrice.

ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.

  METHOD calculateTotalPrice.
    DATA: travel_ids TYPE STANDARD TABLE OF zi_travel_m WITH UNIQUE HASHED KEY key COMPONENTS travel_id.

    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING travel_id = travel_id ).

    MODIFY ENTITIES OF ZI_Travel_M IN LOCAL MODE
      ENTITY Travel
        EXECUTE ReCalcTotalPrice
        FROM CORRESPONDING #( travel_ids ).
  ENDMETHOD.

ENDCLASS.
