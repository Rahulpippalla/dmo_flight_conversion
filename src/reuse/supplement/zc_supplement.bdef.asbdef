projection implementation in class zbp_c_supplement unique;
strict(2);
use draft;

define behavior for ZC_Supplement alias Supplement
{
  use create ( augment );
  use update ( augment );
  use delete;

  use action Resume;
  use action Edit;
  use action Activate;
  use action Discard;
  use action Prepare;

  field ( modify ) SupplementDescription;
}