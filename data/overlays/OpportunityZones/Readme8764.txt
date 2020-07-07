This Zip file contains a Geographic Information System (GIS) shapefile of all population census tracts designated as Qualified Opportunity Zones (QOZs).  

Section 1400Z–1(b)(1)(A) of the Code allowed the Chief Executive Officer (CEO) of each State to nominate a limited number of population census tracts to be designated as Zones for purposes of §§ 1400Z–1 and 1400Z–2.  Revenue Procedure 2018–16, 2018–9 I.R.B. 383, provided guidance to State CEOs on the eligibility criteria and procedure for making these nominations.  Section 1400Z–1(b)(1)(B) of the Code provides that after the Secretary receives notice of the nominations, the Secretary may certify the nominations and designate the nominated tracts as Zones.

Section 1400Z–2 of the Code allows the temporary deferral of inclusion in gross income for certain realized gains to the extent that corresponding amounts are timely invested in a qualified opportunity fund.  Investments in a qualified opportunity fund may also be eligible for additional tax benefits.

See IRS Notice 2018-48, 2018–28 Internal Revenue Bulletin 9, July 9, 2018, for the official list of all population census tracts designated as QOZs for purposes of §§ 1400Z-1 and 1400Z-2 of the Code.

The following is a list of variables in the shapefile:
 
CENSUSTRAC=2010 Census tract 11 character number available from US Census Bureau Tiger Line Shapefiles 
https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
 
STATE=Name of state

COUNTY=Name of county

TRACT_TYPE=New Markets Tax Credit Low-Income Community (LIC) or Non-Contiguous LIC

                         
------------------------------------------------------------------------------------------------
              storage   display    value
variable name   type    format     label      variable label
------------------------------------------------------------------------------------------------
CENSUSTRAC      str11   %11s                  CENSUSTRAC
STATE           str24   %24s                  STATE
COUNTY          str28   %28s                  COUNTY

codebook

------------------------------------------------------------------------------------------------
CENSUSTRAC                                                                            CENSUSTRAC
------------------------------------------------------------------------------------------------

                  type:  string (str11)

         unique values:  8,764                    missing "":  0/8,764

              examples:  "12077950200"
                         "25025080601"
                         "37117970200"
                         "48309003602"

------------------------------------------------------------------------------------------------
STATE                                                                                      STATE
------------------------------------------------------------------------------------------------

                  type:  string (str24)

         unique values:  56                       missing "":  0/8,764

              examples:  "Florida"
                         "Massachusetts"
                         "North Carolina"
                         "Puerto Rico"

------------------------------------------------------------------------------------------------
COUNTY                                                                                    COUNTY
------------------------------------------------------------------------------------------------

                  type:  string (str28)

         unique values:  1,424                    missing "":  0/8,764

              examples:  "Cook"
                         "Hubbard"
                         "Miami-Dade"
                         "Sacramento"

