FUNCTION zflight_booksuppl_d.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  DELETE zbooksuppl_m FROM TABLE @values.

ENDFUNCTION.  "#EC CI_VALPAR
