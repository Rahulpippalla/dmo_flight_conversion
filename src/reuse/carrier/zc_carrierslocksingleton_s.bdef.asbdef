projection;
strict(2);
use draft;

define behavior for ZC_CarriersLockSingleton_S alias CarriersLockSingleton
{
  use action Activate;
  use action Discard;
  use action Edit;
  use action Prepare;
  use action Resume;

  use association _Airline { create; with draft; }
}

define behavior for ZC_Carrier_S alias Carrier
use etag
{
  use update;
  use delete;

  use association _CarrierSingleton { with draft; }
}