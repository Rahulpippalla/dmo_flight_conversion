extension using interface zi_agencytp
implementation in class zzz_bp_x_cntry_r_agencytp unique;

extend behavior for ZAgency
{

  validation ZZvalidateDiallingCode on save { field PhoneNumber; }

  determination ZZdetermineCountryCode on modify { field PhoneNumber; }

  determination ZZdetermineDiallingCode on modify { field CountryCode; }

  extend draft determine action Prepare
  {
    validation ZZvalidateDiallingCode;
  }

  factory action ZZcreateFromTemplate [1];

}