@EndUserText.label: 'Booking Interface Projection View '
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_Booking_D
  as projection on ZR_Booking_D
{
  key BookingUUID,
      TravelUUID,
      BookingID,
      BookingDate,
      CustomerID,
      AirlineID,
      ConnectionID,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LocalLastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZI_BookingSupplement_D,
      _Carrier,
      _Connection,
      _Customer,
      _Travel            : redirected to parent ZI_Travel_D
}
