managed implementation in class zbp_r_agencytp unique;
strict(2);
with draft;
extensible {
  with determinations on modify;
  with determinations on save;
  with validations on save;
  with additional save; }

define behavior for ZR_AgencyTP alias ZAgency
persistent table zagency
draft table zagency_d query ZR_AgencyDraft
lock master
total etag LastChangedAt
authorization master ( global )
etag master LocalLastChangedAt
late numbering
extensible
{
  create;
  update;
  delete;

  field ( readonly ) AgencyID;
  field ( mandatory ) CountryCode, EMailAddress, Name;

  draft action Resume;
  draft action Edit;
  draft action Activate;
  draft action Discard;

  // Validations for mandatory fields
  validation ZvalidateEMailAddress on save { create; field EMailAddress; }
  validation ZvalidateCountryCode  on save { create; field CountryCode; }
  validation ZvalidateName         on save { create; field Name; }

  draft determine action Prepare extensible
  {
    validation ZvalidateEMailAddress;
    validation ZvalidateCountryCode;
    validation ZvalidateName;
  }

  mapping for zagency {
    AgencyId           = agency_id;
    Name               = name;
    Street             = street;
    PostalCode         = postal_code;
    City               = city;
    CountryCode        = country_code;
    PhoneNumber        = phone_number;
    EmailAddress       = email_address;
    WebAddress         = web_address;
    Attachment         = attachment;
    MimeType           = mime_type;
    Filename           = filename;
    LocalCreatedBy     = local_created_by;
    LocalCreatedAt     = local_created_at;
    LocalLastChangedBy = local_last_changed_by;
    LocalLastChangedAt = local_last_changed_at;
    LastChangedAt      = last_changed_at;
  }
}