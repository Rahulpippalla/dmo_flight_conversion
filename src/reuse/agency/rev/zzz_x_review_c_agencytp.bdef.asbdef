extension for projection;

extend behavior for ZAgency
{
  use association ZZZ_ReviewZAG { create; with draft; }
}

define behavior for ZZZ_C_Agency_ReviewTP alias ZZZ_Review
{
  use update;
  use delete;

  use action ZreviewWasHelpful;
  use action ZreviewWasNotHelpful;

  use association _Agency { with draft; }
}