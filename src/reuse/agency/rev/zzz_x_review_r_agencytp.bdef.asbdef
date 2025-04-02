extension using interface zi_agencytp
implementation in class zzz_bp_x_review_r_agencytp unique;

extend behavior for ZAgency
{
  event ZZAgencyReviewCreated parameter ZZZ_D_AgencyReviewCreated;

  extend draft determine action Prepare{
    validation ZZZ_Review~ZratingInRange;
  }
  association ZZZ_ReviewZAG { create; with draft; }
}

define behavior for ZZZ_R_AGENCY_REVIEWTP alias ZZZ_Review using ZZZ_I_AGENCY_REVIEWTP
with additional save
persistent table ZZZ_AGN_REVA
draft table ZZZ_AGN_REVD
etag master LocalLastChangedAt
lock dependent
authorization dependent
late numbering
{
  update ( features : instance );
  delete ( features : instance );

  field ( readonly ) ReviewID, AgencyID, HelpfulCount, HelpfulTotal, Reviewer;

  action ZreviewWasHelpful result [1] $self;
  action ZreviewWasNotHelpful result [1] $self;

  validation ZratingInRange on save { create; field Rating; }

  association _Agency { with draft; }

  mapping for zzz_agn_reva
  {
    AgencyId = agency_id;
    ReviewId = review_id;
    Rating = rating;
    FreeTextComment = free_text_comment;
    HelpfulCount = helpful_count;
    HelpfulTotal = helpful_total;
    Reviewer = reviewer;
    LocalCreatedAt = local_created_at;
    LocalLastChangedAt = local_last_changed_at;
  }
}