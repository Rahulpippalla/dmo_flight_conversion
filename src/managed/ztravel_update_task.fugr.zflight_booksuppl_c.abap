FUNCTION zflight_booksuppl_c.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  INSERT zbooksuppl_m FROM TABLE @values.

ENDFUNCTION. "#EC CI_VALPAR
