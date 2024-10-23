@AbapCatalog.sqlViewName: 'ZCURRHLP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Help View for Currency Conversion'
define view ZCURRENCY_HELPER
  with parameters
    amount             : ztotal_price,
    source_currency    : zcurrency_code,
    target_currency    : zcurrency_code,
    exchange_rate_date : zbooking_date

  as select from zagency

{
  key currency_conversion( amount             => $parameters.amount,
                           source_currency    => $parameters.source_currency,
                           target_currency    => $parameters.target_currency,
                           exchange_rate_date => $parameters.exchange_rate_date,
                           error_handling     => 'SET_TO_NULL' ) as ConvertedAmount
}
