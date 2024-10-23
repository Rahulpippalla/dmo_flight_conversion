@EndUserText.label: 'BookSupplement Interface Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_BookingSupplement_D
  as projection on ZR_BookingSupplement_D
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      BookSupplPrice,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZI_Booking_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZI_Travel_D
}
