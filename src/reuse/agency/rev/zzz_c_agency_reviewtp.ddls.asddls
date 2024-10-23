@EndUserText.label: 'Agency Review'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['Reviewer']

define view entity ZZZ_C_Agency_ReviewTP
  as projection on ZZZ_R_Agency_ReviewTP
{
  key AgencyId,
  key ReviewId,
      Rating,
      FreeTextComment,
      HelpfulCount,
      HelpfulTotal,
      Reviewer,
      LocalCreatedAt,
      LocalLastChangedAt,
      /* Associations */
      _Agency : redirected to parent ZC_AgencyTP
}
