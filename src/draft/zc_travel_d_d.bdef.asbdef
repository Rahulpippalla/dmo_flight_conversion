projection;
strict(2);
use draft;

define behavior for ZC_Travel_D_D alias Travel
use etag
{
  use create;
  use update;
  use delete;

  use action acceptTravel;
  use action rejectTravel;
  use action deductDiscount;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Prepare;
  use action Resume;

  use association _Booking { create; with draft; }
}

define behavior for ZCBooking_D_D alias Booking
use etag
{
  use update;
  use delete;

  use association _BookingSupplement { create; with draft; }
  use association _Travel { with draft; }
}

define behavior for ZC_BookingSupplement_D_D alias BookingSupplement
use etag
{
  use update;
  use delete;

  use association _Travel { with draft; }
  use association _Booking { with draft; }
}