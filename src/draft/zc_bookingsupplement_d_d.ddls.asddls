@EndUserText.label: 'BookingSuppl Proj View for Draft RefScen'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['BookingSupplementID']

define view entity ZC_BookingSupplement_D_D
  as projection on ZR_BookingSupplement_D
{
  key BookSupplUUID,

      TravelUUID,

      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: ['SupplementDescription']
      @Consumption.valueHelpDefinition: [ 
          {  entity: {name: 'ZI_Supplement_StdVH', element: 'SupplementID' },
             additionalBinding: [ { localElement: 'BookSupplPrice',  element: 'Price',        usage: #RESULT },
                                  { localElement: 'CurrencyCode',    element: 'CurrencyCode', usage: #RESULT }], 
             useForValidation: true }
        ]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,

      BookSupplPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,

      LocalLastChangedAt,

      /* Associations */
      _Booking : redirected to parent ZC_Booking_D_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZC_Travel_D_D
}
