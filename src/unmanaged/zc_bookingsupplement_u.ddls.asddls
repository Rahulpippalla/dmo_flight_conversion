@EndUserText.label: 'Booking Supplement Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@Search.searchable: true
define view entity ZC_BookingSupplement_U
  as projection on ZI_BookingSupplement_U

{     //ZI_BookingSupplement_U
      @Search.defaultSearchElement: true
  key TravelID,

      @Search.defaultSearchElement: true
  key BookingID,

  key BookingSupplementID,


      @Consumption.valueHelpDefinition: [ 
          {  entity: {name: 'ZI_Supplement_StdVH', element: 'SupplementID' },
             additionalBinding: [ { localElement: 'Price',        element: 'Price',        usage: #RESULT },
                                  { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }], 
             useForValidation: true }
        ]
      @ObjectModel.text.element: ['SupplementText']
      SupplementID,
      _SupplementText.Description as SupplementText : localized,

      Price,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,

//      LastChangedAt,

      /* Associations */
      //ZI_BookingSupplement_U
      _Booking : redirected to parent ZC_Booking_U,
      _Travel  : redirected to ZC_Travel_U ,
      _Product,
      _SupplementText

}
