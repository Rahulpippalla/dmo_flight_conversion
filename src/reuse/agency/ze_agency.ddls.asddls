@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency - Extension Include View'

@AbapCatalog.extensibility: {
  extensible: true,
  elementSuffix: 'ZAG',
  allowNewDatasources: false,
  dataSources: ['Agency'],
  quota: {
    maximumFields: 500,
    maximumBytes: 5000
  }
}



define view entity ZE_Agency
  as select from zagency as Agency
{
  key agency_id as AgencyId

}
