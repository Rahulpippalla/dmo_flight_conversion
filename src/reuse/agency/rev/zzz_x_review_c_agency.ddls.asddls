extend view entity ZC_AgencyTP with
{
  @UI.facet: [
      {
        id:            'Review',
        purpose:       #STANDARD,
        type:          #LINEITEM_REFERENCE,
        label:         'Review',
        position:      20,
        targetElement: 'ZZZ_ReviewZAG'
      }
    ]
  Agency.ZZZ_ReviewZAG : redirected to composition child ZZZ_C_Agency_ReviewTP
}
