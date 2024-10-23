FUNCTION zflight_booksuppl_u.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUES) TYPE  ZTT_BOOKSUPPL_M
*"----------------------------------------------------------------------
  UPDATE zbooksuppl_m FROM TABLE @values.

ENDFUNCTION.  "#EC CI_VALPAR
