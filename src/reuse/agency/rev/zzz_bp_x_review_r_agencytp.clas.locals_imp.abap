CLASS ltcl_review DEFINITION DEFERRED FOR TESTING.
CLASS lhc_zzz_review DEFINITION INHERITING FROM cl_abap_behavior_handler
  FRIENDS ltcl_review.
  PRIVATE SECTION.
    CONSTANTS: rating_in_range TYPE string VALUE 'RATING_IN_RANGE' ##NO_TEXT.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zzz_review RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zzz_review RESULT result.

    METHODS reviewwashelpful FOR MODIFY
      IMPORTING keys FOR ACTION zzz_review~zreviewwashelpful RESULT result.

    METHODS reviewwasnothelpful FOR MODIFY
      IMPORTING keys FOR ACTION zzz_review~zreviewwasnothelpful RESULT result.

    METHODS ratinginrange FOR VALIDATE ON SAVE
      IMPORTING keys FOR zzz_review~zratinginrange.

ENDCLASS.

CLASS lhc_zzz_review IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        FIELDS ( reviewer )
        WITH CORRESPONDING #( keys )
        RESULT DATA(reviews)
      FAILED failed.

    result = VALUE #(
        FOR review IN reviews
        LET enabled = COND #( WHEN review-reviewer = cl_abap_context_info=>get_user_technical_name( )
                                THEN if_abap_behv=>fc-o-enabled
                                ELSE if_abap_behv=>fc-o-disabled ) IN
        (
          %tky = review-%tky
          %update = enabled
          %delete = enabled
        )
      ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD reviewwashelpful.
    READ ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(reviews)
        FAILED failed.

    LOOP AT reviews ASSIGNING FIELD-SYMBOL(<review>).
      <review>-helpfulcount += 1.
      <review>-helpfultotal += 1.

      APPEND VALUE #(
          %tky   = <review>-%tky
          %param = CORRESPONDING #( <review> )
        ) TO result.
    ENDLOOP.

    MODIFY ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        UPDATE FIELDS ( helpfulcount helpfultotal )
          WITH CORRESPONDING #( reviews ).
  ENDMETHOD.

  METHOD reviewwasnothelpful.
    READ ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(reviews)
        FAILED failed.

    LOOP AT reviews ASSIGNING FIELD-SYMBOL(<review>).
      <review>-helpfultotal += 1.

      APPEND VALUE #(
          %tky   = <review>-%tky
          %param = CORRESPONDING #( <review> )
        ) TO result.
    ENDLOOP.

    MODIFY ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        UPDATE FIELDS ( helpfultotal )
          WITH CORRESPONDING #( reviews ).
  ENDMETHOD.

  METHOD ratinginrange.
    READ ENTITIES OF zi_agencytp IN LOCAL MODE
      ENTITY zzz_review
        FIELDS ( rating )
        WITH CORRESPONDING #( keys )
        RESULT DATA(reviews)
      ENTITY zzz_review BY \_agency
        FROM CORRESPONDING #( keys )
        LINK DATA(agency_links).

    LOOP AT reviews INTO DATA(review).
      APPEND VALUE #(
          %tky        = review-%tky
          %state_area = rating_in_range
        ) TO reported-zzz_review.

      IF review-rating > 5 OR review-rating < 1.
        APPEND VALUE #(
            %tky              = review-%tky
            %state_area       = rating_in_range
            %msg              = NEW zzz_cx_agency_review( zzz_cx_agency_review=>rating_invalid )
            %element-rating   = if_abap_behv=>mk-on
            %path-zagency-%tky = VALUE #( agency_links[ KEY draft  source-%tky = review-%tky ]-target-%tky OPTIONAL )
          ) TO reported-zzz_review.
        APPEND VALUE #( %tky = review-%tky ) TO failed-zzz_review.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_sc_r_agency DEFINITION DEFERRED FOR TESTING.
CLASS lsc_r_agency DEFINITION INHERITING FROM cl_abap_behavior_saver FRIENDS ltcl_sc_r_agency.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_r_agency IMPLEMENTATION.

  METHOD adjust_numbers.
    TYPES: t_mapped_review TYPE STRUCTURE FOR MAPPED LATE zzz_i_agency_reviewtp.
    DATA: agencies TYPE STANDARD TABLE OF zagency_id WITH KEY table_line.
    FIELD-SYMBOLS: <mapped_review> TYPE t_mapped_review.

    CHECK mapped-zzz_review IS NOT INITIAL.

    LOOP AT mapped-zzz_review ASSIGNING <mapped_review> GROUP BY <mapped_review>-%tmp-agencyid.
      APPEND <mapped_review>-%tmp-agencyid TO agencies.
    ENDLOOP.

    ASSERT agencies IS NOT INITIAL.

    SELECT
      FROM zzz_agn_reva  AS db
      JOIN @agencies         AS itab
        ON db~agency_id = itab~table_line
      FIELDS DISTINCT
        db~agency_id,
        MAX( db~review_id ) AS max_review_id
      GROUP BY db~agency_id
      INTO TABLE @DATA(max_reviews).

    LOOP AT mapped-zzz_review INTO DATA(mapped_review_group) GROUP BY mapped_review_group-%tmp-agencyid.
      DATA(max_review_id) = VALUE #( max_reviews[ agency_id = mapped_review_group-%tmp-agencyid ]-max_review_id OPTIONAL ).
      LOOP AT mapped-zzz_review ASSIGNING <mapped_review> WHERE %tmp-agencyid = mapped_review_group-%tmp-agencyid.
        <mapped_review>-agencyid = <mapped_review>-%tmp-agencyid.
        max_review_id += 1.
        <mapped_review>-reviewid = max_review_id.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD save_modified.
    IF create-zzz_review IS NOT INITIAL.
      READ ENTITIES OF zi_agencytp IN LOCAL MODE
        ENTITY zagency
          FIELDS ( emailaddress ) WITH CORRESPONDING #( create-zzz_review )
        RESULT DATA(agencies).

      RAISE ENTITY EVENT zi_agencytp~zagencyreviewcreated
        FROM VALUE #(
          FOR review IN create-zzz_review (
              agencyid        = review-agencyid
              reviewid        = review-reviewid
              rating          = review-rating
              freetextcomment = review-freetextcomment
              emailaddress    = agencies[ KEY entity  agencyid = review-agencyid ]-emailaddress
            )
          ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
