"! API for Saving the Transactional Buffer of the Travel API
"!
FUNCTION ZFLIGHT_TRAVEL_SAVE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  zcl_flight_legacy=>get_instance( )->save( ).
ENDFUNCTION.
