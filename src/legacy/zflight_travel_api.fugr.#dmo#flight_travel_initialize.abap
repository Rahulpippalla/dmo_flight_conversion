"! API for Initializing the Transactional Buffer of the Travel API
"!
FUNCTION ZFLIGHT_TRAVEL_INITIALIZE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
  zcl_flight_legacy=>get_instance( )->initialize( ).
ENDFUNCTION.
