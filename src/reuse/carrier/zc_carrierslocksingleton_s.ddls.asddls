@EndUserText.label: 'Carrier Singleton Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['CarrierSingletonID']

define root view entity ZC_CarriersLockSingleton_S
  provider contract transactional_query
  as projection on ZI_CarriersLockSingleton_S
{
  key CarrierSingletonID,

      @Consumption.hidden: true
      LastChangedAtMax,
      /* Associations */
      _Airline : redirected to composition child ZC_Carrier_S
}
