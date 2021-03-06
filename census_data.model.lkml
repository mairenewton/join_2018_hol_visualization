connection: "lookerdata_publicdata"

# include all the views
include: "*.view"

persist_for: "1000 hours"

explore: cps_clean {
  label: "CPS Household Explorer, 1994-2014"

  always_filter: {
    filters: {
      field: year_of_interview
      value: "2012"
    }
  }

  join: cps_2014_geo {
    sql_on: cps_clean.hrhhid = cps_2014_geo.hrhhid
      AND cps_clean.hrhhid2 = cps_2014_geo.hrhhid2
       ;;
    relationship: many_to_one
  }

  join: total_hh_members {
    sql_on: cps_clean.gestcen_clean = total_hh_members.gestcen
      AND cps_clean.hrhhid_clean = total_hh_members.hrhhid
      AND cps_clean.hrhhid2_clean = total_hh_members.hrhhid2
       ;;
    relationship: many_to_one
  }

  fields: [
    ALL_FIELDS*,
    -cps_clean.perace,
    -cps_clean.ptdtrace,
    -cps_clean.ptdtrace_census_2010,
    -cps_clean.ptdtrace_census_2008,
    -cps_clean.ptdtrace_census_2006,
    -cps_clean.ptdtrace_census_2004,
    -cps_clean.perace_census_1994,
    -cps_clean.pehspnon,
    -cps_clean.gtmetsta,
    -cps_clean.pes5_census_2000,
    -cps_clean.pes5_census_1998,
    -cps_clean.pes7_census_1996,
    -cps_clean.pes7_census_2006,
    -cps_clean.pes7_census_2000,
    -cps_clean.pes7_census_1998,
    -cps_clean.pes6,
    -cps_clean.pes4_census_1998,
    -cps_clean.pes4_census_1996,
    -cps_clean.pes3_census_1994,
    -cps_clean.prvel,
    -cps_clean.pes3_census_1998,
    -cps_clean.pes3_census_2000,
    -cps_clean.pes3_census_1996,
    -cps_clean.pes4,
    -cps_clean.pes6_census_1998,
    -cps_clean.pes6_census_1996,
    -cps_clean.pes6_census_2000,
    -cps_clean.pes6_census_2002,
    -cps_clean.pes4_census_1994,
    -cps_clean.pes2,
    -cps_clean.prs8,
    -cps_clean.pes8,
    -cps_clean.pes6_census_1994,
    -cps_clean.hryear,
    -cps_clean.hryear4,
    -cps_clean.hufinal,
    -cps_clean.huprscnt_census_2002,
    -cps_clean.pefntvty_census_2006,
    -cps_clean.pefntvty_census_2004,
    -cps_clean.pefntvty_census_2002,
    -cps_clean.pefntvty_census_2000,
    -cps_clean.pefntvty_census_1998,
    -cps_clean.pefntvty_census_1996,
    -cps_clean.pefntvty_census_1994,
    -cps_clean.pemntvty_census_2006,
    -cps_clean.pemntvty_census_2004,
    -cps_clean.pemntvty_census_2002,
    -cps_clean.pemntvty_census_2000,
    -cps_clean.pemntvty_census_1998,
    -cps_clean.pemntvty_census_1996,
    -cps_clean.pemntvty_census_1994,
    -cps_clean.penatvty_census_2006,
    -cps_clean.penatvty_census_2004,
    -cps_clean.penatvty_census_2002,
    -cps_clean.penatvty_census_2000,
    -cps_clean.penatvty_census_1998,
    -cps_clean.penatvty_census_1996,
    -cps_clean.penatvty_census_1994,
    -cps_clean.prdthsp_census_2012,
    -cps_clean.prdthsp_census_2010,
    -cps_clean.prdthsp_census_2008,
    -cps_clean.prdthsp_census_2006,
    -cps_clean.prdthsp_census_2004,
    -cps_clean.peafever,
    -cps_clean.puafever,
    -cps_clean.prfamnum,
    -cps_clean.prfamrel,
    -cps_clean.prfamtyp,
    -cps_clean.purelflg,
    -cps_clean.pupelig,
    -cps_clean.pulineno,
    -cps_clean.pecohab,
    -cps_clean.pelndad,
    -cps_clean.prmarsta,
    -cps_clean.peparent,
    -cps_clean.peafwhen,
    -cps_clean.puchinhh,
    -cps_clean.proldrrp,
    -cps_clean.perrp,
    -cps_clean.pespouse,
    -cps_clean.prtfage,
    -cps_clean.gtcbsasz,
    -cps_clean.gtmsasz,
    -cps_clean.gecmsasz,
    -cps_clean.gtmsast,
    -cps_clean.gtcbsast,
    -cps_clean.geindvcc,
    -cps_clean.gtindvpc,
    -cps_clean.prdtind1_census_2002,
    -cps_clean.prdtind1_census_2000,
    -cps_clean.prdtind1_census_1998,
    -cps_clean.prdtind1_census_1996,
    -cps_clean.prdtind1_census_1994,
    -cps_clean.prdtocc1_census_2002,
    -cps_clean.prdtocc1_census_2000,
    -cps_clean.prdtocc1_census_1998,
    -cps_clean.prdtocc1_census_1996,
    -cps_clean.prdtocc1_census_1994,
    -cps_clean.peio1icd_census_2002,
    -cps_clean.peio1icd_census_2000,
    -cps_clean.peio1icd_census_1998,
    -cps_clean.peio1icd_census_1996,
    -cps_clean.peio1icd_census_1994,
    -cps_clean.prdtind2_census_2002,
    -cps_clean.prdtind2_census_2000,
    -cps_clean.prdtind2_census_1998,
    -cps_clean.prdtind2_census_1996,
    -cps_clean.prdtind2_census_1994,
    -cps_clean.prdtocc2_census_2002,
    -cps_clean.prdtocc2_census_2000,
    -cps_clean.prdtocc2_census_1998,
    -cps_clean.prdtocc2_census_1996,
    -cps_clean.prdtocc2_census_1994,
    -cps_clean.peio1icd_census_2002,
    -cps_clean.peio1icd_census_2000,
    -cps_clean.peio1icd_census_1998,
    -cps_clean.peio1icd_census_1996,
    -cps_clean.peio1icd_census_1994,
    -cps_clean.ptnmemp1,
    -cps_clean.ptnmemp2,
    -cps_clean.puiock1,
    -cps_clean.puiock2,
    -cps_clean.puiock3,
    -cps_clean.prmjind1_census_2002,
    -cps_clean.prmjind1_census_2000,
    -cps_clean.prmjind1_census_1998,
    -cps_clean.prmjind1_census_1996,
    -cps_clean.prmjind1_census_1994,
    -cps_clean.ptio1ocd_census_2002,
    -cps_clean.ptio1ocd_census_2000,
    -cps_clean.ptio1ocd_census_1998,
    -cps_clean.ptio1ocd_census_1996,
    -cps_clean.ptio1ocd_census_1994,
    -cps_clean.prmjocgr_census_2002,
    -cps_clean.prmjocgr_census_2000,
    -cps_clean.prmjocgr_census_1998,
    -cps_clean.prmjocgr_census_1996,
    -cps_clean.prmjocgr_census_1994,
    -cps_clean.prmjocc1_census_2002,
    -cps_clean.prmjocc1_census_2000,
    -cps_clean.prmjocc1_census_1998,
    -cps_clean.prmjocc1_census_1996,
    -cps_clean.prmjocc1_census_1994,
    -cps_clean.prmjind2_census_2002,
    -cps_clean.prmjind2_census_2000,
    -cps_clean.prmjind2_census_1998,
    -cps_clean.prmjind2_census_1996,
    -cps_clean.prmjind2_census_1994,
    -cps_clean.ptio1ocd_census_2002,
    -cps_clean.ptio1ocd_census_2000,
    -cps_clean.ptio1ocd_census_1998,
    -cps_clean.ptio1ocd_census_1996,
    -cps_clean.ptio1ocd_census_1994,
    -cps_clean.prmjocgr_census_2002,
    -cps_clean.prmjocgr_census_2000,
    -cps_clean.prmjocgr_census_1998,
    -cps_clean.prmjocgr_census_1996,
    -cps_clean.prmjocgr_census_1994,
    -cps_clean.prmjocc2_census_2002,
    -cps_clean.prmjocc2_census_2000,
    -cps_clean.prmjocc2_census_1998,
    -cps_clean.prmjocc2_census_1996,
    -cps_clean.prmjocc2_census_1994,
    -cps_clean.peio2icd_census_2002,
    -cps_clean.peio2icd_census_2000,
    -cps_clean.peio2icd_census_1998,
    -cps_clean.peio2icd_census_1996,
    -cps_clean.peio2icd_census_1994,
    -cps_clean.ptio2ocd_census_2002,
    -cps_clean.ptio2ocd_census_2000,
    -cps_clean.ptio2ocd_census_1998,
    -cps_clean.ptio2ocd_census_1996,
    -cps_clean.ptio2ocd_census_1994,
    -cps_clean.peio2icd_census_2012,
    -cps_clean.puiodp1,
    -cps_clean.puiodp3,
    -cps_clean.pulkps1,
    -cps_clean.pulkps2,
    -cps_clean.pulkps3,
    -cps_clean.pulkps4,
    -cps_clean.pulkps5,
    -cps_clean.pulkps6,
    -cps_clean.hubusl1,
    -cps_clean.hubusl2,
    -cps_clean.hubusl3,
    -cps_clean.hubusl4,
    -cps_clean.pubusck2,
    -cps_clean.pulkm2,
    -cps_clean.pulkm3,
    -cps_clean.pulkm4,
    -cps_clean.pulkm5,
    -cps_clean.pulkm6,
    -cps_clean.pulkdk2,
    -cps_clean.pulkdk3,
    -cps_clean.pulkdk4,
    -cps_clean.pulkdk5,
    -cps_clean.pulkdk6,
    -cps_clean.pujhck4,
    -cps_clean.pujhck5,
    -cps_clean.pulkdk1,
    -cps_clean.punlfck1,
    -cps_clean.pulayck3,
    -cps_clean.pudwck1,
    -cps_clean.pudwck2,
    -cps_clean.pudwck3,
    -cps_clean.pudwck4,
    -cps_clean.pudwck5,
    -cps_clean.puhrck1,
    -cps_clean.puhrck12,
    -cps_clean.puhrck2,
    -cps_clean.puhrck3,
    -cps_clean.puhrck4,
    -cps_clean.puhrck5,
    -cps_clean.puhrck6,
    -cps_clean.puhrck7,
    -cps_clean.pubus2ot,
  ]
}

# explore: cps_with_groups {
#   hidden: yes
#   join: cps_2014_geo {
#     sql_on: cps_with_groups.hrhhid = cps_2014_geo.hrhhid
#       AND cps_with_groups.hrhhid2 = cps_2014_geo.hrhhid2
#       ;;
#     relationship: many_to_one
#   }

#   label: "CPS Group Explorer, 1994-2014"

#   always_filter: {
#     filters: {
#       field: year_of_interview
#       value: "2012"
#     }
#   }

#   fields: [
#     ALL_FIELDS*,
#     -cps_with_groups.perace,
#     -cps_with_groups.ptdtrace,
#     -cps_with_groups.ptdtrace_census_2010,
#     -cps_with_groups.ptdtrace_census_2008,
#     -cps_with_groups.ptdtrace_census_2006,
#     -cps_with_groups.ptdtrace_census_2004,
#     -cps_with_groups.perace_census_1994,
#     -cps_with_groups.select_ptdtrace,
#     -cps_with_groups.select_ptdtrace_census_2010,
#     -cps_with_groups.select_ptdtrace_census_2008,
#     -cps_with_groups.select_ptdtrace_census_2006,
#     -cps_with_groups.select_ptdtrace_census_2004,
#     -cps_with_groups.select_perace,
#     -cps_with_groups.select_perace_census_1994,
#     -cps_with_groups.pehspnon,
#     -cps_with_groups.select_pehspnon,
#     -cps_with_groups.gtmetsta,
#     -cps_with_groups.select_gtmetsta,
#     -cps_with_groups.gemetsta,
#     -cps_with_groups.select_gemetsta,
#     -cps_with_groups.pes5_census_2000,
#     -cps_with_groups.pes5_census_2002,
#     -cps_with_groups.pes5_census_1998,
#     -cps_with_groups.pes5_census_1996,
#     -cps_with_groups.select_pes5_census_2000,
#     -cps_with_groups.select_pes5_census_2002,
#     -cps_with_groups.select_pes5_census_1998,
#     -cps_with_groups.select_pes5_census_1996,
#     -cps_with_groups.pes7_census_2004,
#     -cps_with_groups.pes7,
#     -cps_with_groups.pes7_census_2002,
#     -cps_with_groups.pes7_census_2008,
#     -cps_with_groups.pes7_census_1996,
#     -cps_with_groups.pes7_census_2006,
#     -cps_with_groups.pes7_census_2000,
#     -cps_with_groups.pes7_census_1998,
#     -cps_with_groups.select_pes7_census_2004,
#     -cps_with_groups.select_pes7,
#     -cps_with_groups.select_pes7_census_2002,
#     -cps_with_groups.select_pes7_census_2008,
#     -cps_with_groups.select_pes7_census_1996,
#     -cps_with_groups.select_pes7_census_2006,
#     -cps_with_groups.select_pes7_census_2000,
#     -cps_with_groups.select_pes7_census_1998,
#     -cps_with_groups.pes1,
#     -cps_with_groups.select_pes1,
#     -cps_with_groups.pes5,
#     -cps_with_groups.select_pes5,
#     -cps_with_groups.pes4_census_2002,
#     -cps_with_groups.select_pes4_census_2002,
#     -cps_with_groups.select_pes4_census_2000,
#     -cps_with_groups.pes4_census_2000,
#     -cps_with_groups.pes6,
#     -cps_with_groups.select_pes6,
#     -cps_with_groups.pes4_census_1998,
#     -cps_with_groups.select_pes4_census_1998,
#     -cps_with_groups.pes4_census_1996,
#     -cps_with_groups.select_pes4_census_1996,
#     -cps_with_groups.pes3_census_1994,
#     -cps_with_groups.select_pes3_census_1994,
#     -cps_with_groups.prvel,
#     -cps_with_groups.select_prvel,
#     -cps_with_groups.pes3_census_2002,
#     -cps_with_groups.pes3_census_1998,
#     -cps_with_groups.pes3_census_2000,
#     -cps_with_groups.pes3_census_1996,
#     -cps_with_groups.select_pes3_census_2002,
#     -cps_with_groups.select_pes3_census_1998,
#     -cps_with_groups.select_pes3_census_2000,
#     -cps_with_groups.select_pes3_census_1996,
#     -cps_with_groups.pes4,
#     -cps_with_groups.select_pes4,
#     -cps_with_groups.pes7_census_1994,
#     -cps_with_groups.select_pes7_census_1994,
#     -cps_with_groups.pes6_census_1998,
#     -cps_with_groups.pes6_census_1996,
#     -cps_with_groups.pes6_census_2000,
#     -cps_with_groups.pes6_census_2002,
#     -cps_with_groups.pes4_census_1994,
#     -cps_with_groups.select_pes6_census_1998,
#     -cps_with_groups.select_pes6_census_1996,
#     -cps_with_groups.select_pes6_census_2000,
#     -cps_with_groups.select_pes6_census_2002,
#     -cps_with_groups.select_pes4_census_1994,
#     -cps_with_groups.pes2,
#     -cps_with_groups.prs8,
#     -cps_with_groups.pes8,
#     -cps_with_groups.pes6_census_1994,
#     -cps_with_groups.select_pes2,
#     -cps_with_groups.select_prs8,
#     -cps_with_groups.select_pes8,
#     -cps_with_groups.select_pes6_census_1994,
#     -cps_with_groups.preduca5,
#     -cps_with_groups.select_preduca5,
#     -cps_with_groups.preduca4,
#     -cps_with_groups.select_preduca4,
#     -cps_with_groups.hryear,
#     -cps_with_groups.select_hryear,
#     -cps_with_groups.hryear4,
#     -cps_with_groups.select_hryear4,
#     -cps_with_groups.hufinal,
#     -cps_with_groups.select_hufinal,
#     -cps_with_groups.hufinal_census_2002,
#     -cps_with_groups.select_hufinal_census_2002,
#     -cps_with_groups.hufinal_census_2000,
#     -cps_with_groups.select_hufinal_census_2000,
#     -cps_with_groups.hufinal_census_1998,
#     -cps_with_groups.select_hufinal_census_1998,
#     -cps_with_groups.hufinal_census_1996,
#     -cps_with_groups.select_hufinal_census_1996,
#     -cps_with_groups.hufinal_census_1994,
#     -cps_with_groups.select_hufinal_census_1994,
#     -cps_with_groups.hrintsta,
#     -cps_with_groups.select_hrintsta,
#     -cps_with_groups.hurespli,
#     -cps_with_groups.select_hurespli,
#     -cps_with_groups.hutypb,
#     -cps_with_groups.select_hutypb,
#     -cps_with_groups.hrlonglk,
#     -cps_with_groups.select_hrlonglk,
#     -cps_with_groups.hetelavl,
#     -cps_with_groups.select_hetelavl,
#     -cps_with_groups.hephoneo,
#     -cps_with_groups.select_hephoneo,
#     -cps_with_groups.huhhnum,
#     -cps_with_groups.select_huhhnum,
#     -cps_with_groups.huprscnt_census_2002,
#     -cps_with_groups.select_huprscnt_census_2002,
#     -cps_with_groups.hutypc,
#     -cps_with_groups.select_hutypc,
#     -cps_with_groups.hutypc_census_2002,
#     -cps_with_groups.select_hutypc_census_2002,
#     -cps_with_groups.hutypc_census_2000,
#     -cps_with_groups.select_hutypc_census_2000,
#     -cps_with_groups.hutypc_census_1998,
#     -cps_with_groups.select_hutypc_census_1998,
#     -cps_with_groups.hutypc_census_1996,
#     -cps_with_groups.select_hutypc_census_1996,
#     -cps_with_groups.hutypc_census_1994,
#     -cps_with_groups.select_hutypc_census_1994,
#     -cps_with_groups.hutypea,
#     -cps_with_groups.select_hutypea,
#     -cps_with_groups.hutypea_census_2008,
#     -cps_with_groups.select_hutypea_census_2008,
#     -cps_with_groups.hutypea_census_2006,
#     -cps_with_groups.select_hutypea_census_2006,
#     -cps_with_groups.hutypea_census_2004,
#     -cps_with_groups.select_hutypea_census_2004,
#     -cps_with_groups.hutypea_census_2002,
#     -cps_with_groups.select_hutypea_census_2002,
#     -cps_with_groups.hutypea_census_2000,
#     -cps_with_groups.select_hutypea_census_2000,
#     -cps_with_groups.hutypea_census_1998,
#     -cps_with_groups.select_hutypea_census_1998,
#     -cps_with_groups.hutypea_census_1996,
#     -cps_with_groups.select_hutypea_census_1996,
#     -cps_with_groups.hutypea_census_1994,
#     -cps_with_groups.select_hutypea_census_1994,
#     -cps_with_groups.hulensec,
#     -cps_with_groups.select_hulensec,
#     -cps_with_groups.huinttyp,
#     -cps_with_groups.select_huinttyp,
#     -cps_with_groups.hufaminc,
#     -cps_with_groups.select_hufaminc,
#     -cps_with_groups.peschenr,
#     -cps_with_groups.select_peschenr,
#     -cps_with_groups.prcitflg,
#     -cps_with_groups.select_prcitflg,
#     -cps_with_groups.pefntvty_census_2006,
#     -cps_with_groups.select_pefntvty_census_2006,
#     -cps_with_groups.pefntvty_census_2004,
#     -cps_with_groups.select_pefntvty_census_2004,
#     -cps_with_groups.pefntvty_census_2002,
#     -cps_with_groups.select_pefntvty_census_2002,
#     -cps_with_groups.pefntvty_census_2000,
#     -cps_with_groups.select_pefntvty_census_2000,
#     -cps_with_groups.pefntvty_census_1998,
#     -cps_with_groups.select_pefntvty_census_1998,
#     -cps_with_groups.pefntvty_census_1996,
#     -cps_with_groups.select_pefntvty_census_1996,
#     -cps_with_groups.pefntvty_census_1994,
#     -cps_with_groups.select_pefntvty_census_1994,
#     -cps_with_groups.pemntvty_census_2006,
#     -cps_with_groups.select_pemntvty_census_2006,
#     -cps_with_groups.pemntvty_census_2004,
#     -cps_with_groups.select_pemntvty_census_2004,
#     -cps_with_groups.pemntvty_census_2002,
#     -cps_with_groups.select_pemntvty_census_2002,
#     -cps_with_groups.pemntvty_census_2000,
#     -cps_with_groups.select_pemntvty_census_2000,
#     -cps_with_groups.pemntvty_census_1998,
#     -cps_with_groups.select_pemntvty_census_1998,
#     -cps_with_groups.pemntvty_census_1996,
#     -cps_with_groups.select_pemntvty_census_1996,
#     -cps_with_groups.pemntvty_census_1994,
#     -cps_with_groups.select_pemntvty_census_1994,
#     -cps_with_groups.penatvty_census_2006,
#     -cps_with_groups.select_penatvty_census_2006,
#     -cps_with_groups.penatvty_census_2004,
#     -cps_with_groups.select_penatvty_census_2004,
#     -cps_with_groups.penatvty_census_2002,
#     -cps_with_groups.select_penatvty_census_2002,
#     -cps_with_groups.penatvty_census_2000,
#     -cps_with_groups.select_penatvty_census_2000,
#     -cps_with_groups.penatvty_census_1998,
#     -cps_with_groups.select_penatvty_census_1998,
#     -cps_with_groups.penatvty_census_1996,
#     -cps_with_groups.select_penatvty_census_1996,
#     -cps_with_groups.penatvty_census_1994,
#     -cps_with_groups.select_penatvty_census_1994,
#     -cps_with_groups.prdthsp_census_2012,
#     -cps_with_groups.select_prdthsp_census_2012,
#     -cps_with_groups.prdthsp_census_2010,
#     -cps_with_groups.select_prdthsp_census_2010,
#     -cps_with_groups.prdthsp_census_2008,
#     -cps_with_groups.select_prdthsp_census_2008,
#     -cps_with_groups.prdthsp_census_2006,
#     -cps_with_groups.select_prdthsp_census_2006,
#     -cps_with_groups.prdthsp_census_2004,
#     -cps_with_groups.select_prdthsp_census_2004,
#     -cps_with_groups.peafever,
#     -cps_with_groups.select_peafever,
#     -cps_with_groups.puafever,
#     -cps_with_groups.select_puafever,
#     -cps_with_groups.prfamnum,
#     -cps_with_groups.select_prfamnum,
#     -cps_with_groups.prfamrel,
#     -cps_with_groups.select_prfamrel,
#     -cps_with_groups.prfamtyp,
#     -cps_with_groups.select_prfamtyp,
#     -cps_with_groups.purelflg,
#     -cps_with_groups.select_purelflg,
#     -cps_with_groups.pupelig,
#     -cps_with_groups.select_pupelig,
#     -cps_with_groups.pulineno,
#     -cps_with_groups.select_pulineno,
#     -cps_with_groups.pecohab,
#     -cps_with_groups.select_pecohab,
#     -cps_with_groups.pelndad,
#     -cps_with_groups.select_pelndad,
#     -cps_with_groups.prmarsta,
#     -cps_with_groups.select_prmarsta,
#     -cps_with_groups.pelnmom,
#     -cps_with_groups.select_pelnmom,
#     -cps_with_groups.peparent,
#     -cps_with_groups.select_peparent,
#     -cps_with_groups.peafwhen,
#     -cps_with_groups.puchinhh,
#     -cps_with_groups.select_puchinhh,
#     -cps_with_groups.proldrrp,
#     -cps_with_groups.select_proldrrp,
#     -cps_with_groups.perrp,
#     -cps_with_groups.select_perrp,
#     -cps_with_groups.pespouse,
#     -cps_with_groups.select_pespouse,
#     -cps_with_groups.prtfage,
#     -cps_with_groups.select_prtfage,
#     -cps_with_groups.gtcbsasz,
#     -cps_with_groups.select_gtcbsasz,
#     -cps_with_groups.gtmsasz,
#     -cps_with_groups.select_gtmsasz,
#     -cps_with_groups.gecmsasz,
#     -cps_with_groups.select_gecmsasz,
#     -cps_with_groups.gtmsast,
#     -cps_with_groups.select_gtmsast,
#     -cps_with_groups.gtcbsast,
#     -cps_with_groups.select_gtcbsast,
#     -cps_with_groups.geindvcc,
#     -cps_with_groups.select_geindvcc,
#     -cps_with_groups.gtindvpc,
#     -cps_with_groups.select_gtindvpc,
#     -cps_with_groups.prdtind1_census_2002,
#     -cps_with_groups.select_prdtind1_census_2002,
#     -cps_with_groups.prdtind1_census_2000,
#     -cps_with_groups.select_prdtind1_census_2000,
#     -cps_with_groups.prdtind1_census_1998,
#     -cps_with_groups.select_prdtind1_census_1998,
#     -cps_with_groups.prdtind1_census_1996,
#     -cps_with_groups.select_prdtind1_census_1996,
#     -cps_with_groups.prdtind1_census_1994,
#     -cps_with_groups.select_prdtind1_census_1994,
#     -cps_with_groups.prdtocc1_census_2002,
#     -cps_with_groups.select_prdtocc1_census_2002,
#     -cps_with_groups.prdtocc1_census_2000,
#     -cps_with_groups.select_prdtocc1_census_2000,
#     -cps_with_groups.prdtocc1_census_1998,
#     -cps_with_groups.select_prdtocc1_census_1998,
#     -cps_with_groups.prdtocc1_census_1996,
#     -cps_with_groups.select_prdtocc1_census_1996,
#     -cps_with_groups.prdtocc1_census_1994,
#     -cps_with_groups.select_prdtocc1_census_1994,
#     -cps_with_groups.peio1icd_census_2002,
#     -cps_with_groups.select_peio1icd_census_2002,
#     -cps_with_groups.peio1icd_census_2000,
#     -cps_with_groups.select_peio1icd_census_2000,
#     -cps_with_groups.peio1icd_census_1998,
#     -cps_with_groups.select_peio1icd_census_1998,
#     -cps_with_groups.peio1icd_census_1996,
#     -cps_with_groups.select_peio1icd_census_1996,
#     -cps_with_groups.peio1icd_census_1994,
#     -cps_with_groups.select_peio1icd_census_1994,
#     -cps_with_groups.prdtind2_census_2002,
#     -cps_with_groups.select_prdtind2_census_2002,
#     -cps_with_groups.prdtind2_census_2000,
#     -cps_with_groups.select_prdtind2_census_2000,
#     -cps_with_groups.prdtind2_census_1998,
#     -cps_with_groups.select_prdtind2_census_1998,
#     -cps_with_groups.prdtind2_census_1996,
#     -cps_with_groups.select_prdtind2_census_1996,
#     -cps_with_groups.prdtind2_census_1994,
#     -cps_with_groups.select_prdtind2_census_1994,
#     -cps_with_groups.prdtocc2_census_2002,
#     -cps_with_groups.select_prdtocc2_census_2002,
#     -cps_with_groups.prdtocc2_census_2000,
#     -cps_with_groups.select_prdtocc2_census_2000,
#     -cps_with_groups.prdtocc2_census_1998,
#     -cps_with_groups.select_prdtocc2_census_1998,
#     -cps_with_groups.prdtocc2_census_1996,
#     -cps_with_groups.select_prdtocc2_census_1996,
#     -cps_with_groups.prdtocc2_census_1994,
#     -cps_with_groups.select_prdtocc2_census_1994,
#     -cps_with_groups.peio1icd_census_2002,
#     -cps_with_groups.select_peio1icd_census_2002,
#     -cps_with_groups.peio1icd_census_2000,
#     -cps_with_groups.select_peio1icd_census_2000,
#     -cps_with_groups.peio1icd_census_1998,
#     -cps_with_groups.select_peio1icd_census_1998,
#     -cps_with_groups.peio1icd_census_1996,
#     -cps_with_groups.select_peio1icd_census_1996,
#     -cps_with_groups.peio1icd_census_1994,
#     -cps_with_groups.select_peio1icd_census_1994,
#     -cps_with_groups.ptnmemp1,
#     -cps_with_groups.select_ptnmemp1,
#     -cps_with_groups.ptnmemp2,
#     -cps_with_groups.select_ptnmemp2,
#     -cps_with_groups.puiock1,
#     -cps_with_groups.select_puiock1,
#     -cps_with_groups.puiock2,
#     -cps_with_groups.select_puiock2,
#     -cps_with_groups.puiock3,
#     -cps_with_groups.select_puiock3,
#     -cps_with_groups.prmjind1_census_2002,
#     -cps_with_groups.select_prmjind1_census_2002,
#     -cps_with_groups.prmjind1_census_2000,
#     -cps_with_groups.select_prmjind1_census_2000,
#     -cps_with_groups.prmjind1_census_1998,
#     -cps_with_groups.select_prmjind1_census_1998,
#     -cps_with_groups.prmjind1_census_1996,
#     -cps_with_groups.select_prmjind1_census_1996,
#     -cps_with_groups.prmjind1_census_1994,
#     -cps_with_groups.select_prmjind1_census_1994,
#     -cps_with_groups.ptio1ocd_census_2002,
#     -cps_with_groups.select_ptio1ocd_census_2002,
#     -cps_with_groups.ptio1ocd_census_2000,
#     -cps_with_groups.select_ptio1ocd_census_2000,
#     -cps_with_groups.ptio1ocd_census_1998,
#     -cps_with_groups.select_ptio1ocd_census_1998,
#     -cps_with_groups.ptio1ocd_census_1996,
#     -cps_with_groups.select_ptio1ocd_census_1996,
#     -cps_with_groups.ptio1ocd_census_1994,
#     -cps_with_groups.select_ptio1ocd_census_1994,
#     -cps_with_groups.prmjocgr_census_2002,
#     -cps_with_groups.select_prmjocgr_census_2002,
#     -cps_with_groups.prmjocgr_census_2000,
#     -cps_with_groups.select_prmjocgr_census_2000,
#     -cps_with_groups.prmjocgr_census_1998,
#     -cps_with_groups.select_prmjocgr_census_1998,
#     -cps_with_groups.prmjocgr_census_1996,
#     -cps_with_groups.select_prmjocgr_census_1996,
#     -cps_with_groups.prmjocgr_census_1994,
#     -cps_with_groups.select_prmjocgr_census_1994,
#     -cps_with_groups.prmjocc1_census_2002,
#     -cps_with_groups.select_prmjocc1_census_2002,
#     -cps_with_groups.prmjocc1_census_2000,
#     -cps_with_groups.select_prmjocc1_census_2000,
#     -cps_with_groups.prmjocc1_census_1998,
#     -cps_with_groups.select_prmjocc1_census_1998,
#     -cps_with_groups.prmjocc1_census_1996,
#     -cps_with_groups.select_prmjocc1_census_1996,
#     -cps_with_groups.prmjocc1_census_1994,
#     -cps_with_groups.select_prmjocc1_census_1994,
#     -cps_with_groups.prmjind2_census_2002,
#     -cps_with_groups.select_prmjind2_census_2002,
#     -cps_with_groups.prmjind2_census_2000,
#     -cps_with_groups.select_prmjind2_census_2000,
#     -cps_with_groups.prmjind2_census_1998,
#     -cps_with_groups.select_prmjind2_census_1998,
#     -cps_with_groups.prmjind2_census_1996,
#     -cps_with_groups.select_prmjind2_census_1996,
#     -cps_with_groups.prmjind2_census_1994,
#     -cps_with_groups.select_prmjind2_census_1994,
#     -cps_with_groups.ptio1ocd_census_2002,
#     -cps_with_groups.select_ptio1ocd_census_2002,
#     -cps_with_groups.ptio1ocd_census_2000,
#     -cps_with_groups.select_ptio1ocd_census_2000,
#     -cps_with_groups.ptio1ocd_census_1998,
#     -cps_with_groups.select_ptio1ocd_census_1998,
#     -cps_with_groups.ptio1ocd_census_1996,
#     -cps_with_groups.select_ptio1ocd_census_1996,
#     -cps_with_groups.ptio1ocd_census_1994,
#     -cps_with_groups.select_ptio1ocd_census_1994,
#     -cps_with_groups.prmjocgr_census_2002,
#     -cps_with_groups.select_prmjocgr_census_2002,
#     -cps_with_groups.prmjocgr_census_2000,
#     -cps_with_groups.select_prmjocgr_census_2000,
#     -cps_with_groups.prmjocgr_census_1998,
#     -cps_with_groups.select_prmjocgr_census_1998,
#     -cps_with_groups.prmjocgr_census_1996,
#     -cps_with_groups.select_prmjocgr_census_1996,
#     -cps_with_groups.prmjocgr_census_1994,
#     -cps_with_groups.select_prmjocgr_census_1994,
#     -cps_with_groups.prmjocc2_census_2002,
#     -cps_with_groups.select_prmjocc2_census_2002,
#     -cps_with_groups.prmjocc2_census_2000,
#     -cps_with_groups.select_prmjocc2_census_2000,
#     -cps_with_groups.prmjocc2_census_1998,
#     -cps_with_groups.select_prmjocc2_census_1998,
#     -cps_with_groups.prmjocc2_census_1996,
#     -cps_with_groups.select_prmjocc2_census_1996,
#     -cps_with_groups.prmjocc2_census_1994,
#     -cps_with_groups.select_prmjocc2_census_1994,
#     -cps_with_groups.peio2icd_census_2002,
#     -cps_with_groups.select_peio2icd_census_2002,
#     -cps_with_groups.peio2icd_census_2000,
#     -cps_with_groups.select_peio2icd_census_2000,
#     -cps_with_groups.peio2icd_census_1998,
#     -cps_with_groups.select_peio2icd_census_1998,
#     -cps_with_groups.peio2icd_census_1996,
#     -cps_with_groups.select_peio2icd_census_1996,
#     -cps_with_groups.peio2icd_census_1994,
#     -cps_with_groups.select_peio2icd_census_1994,
#     -cps_with_groups.ptio2ocd_census_2002,
#     -cps_with_groups.select_ptio2ocd_census_2002,
#     -cps_with_groups.ptio2ocd_census_2000,
#     -cps_with_groups.select_ptio2ocd_census_2000,
#     -cps_with_groups.ptio2ocd_census_1998,
#     -cps_with_groups.select_ptio2ocd_census_1998,
#     -cps_with_groups.ptio2ocd_census_1996,
#     -cps_with_groups.select_ptio2ocd_census_1996,
#     -cps_with_groups.ptio2ocd_census_1994,
#     -cps_with_groups.select_ptio2ocd_census_1994,
#     -cps_with_groups.peio2icd_census_2012,
#     -cps_with_groups.select_peio2icd_census_2012,
#     -cps_with_groups.puiodp1,
#     -cps_with_groups.select_puiodp1,
#     -cps_with_groups.puiodp3,
#     -cps_with_groups.select_puiodp3,
#     -cps_with_groups.pulkps1,
#     -cps_with_groups.select_pulkps1,
#     -cps_with_groups.pulkps2,
#     -cps_with_groups.select_pulkps2,
#     -cps_with_groups.pulkps3,
#     -cps_with_groups.select_pulkps3,
#     -cps_with_groups.pulkps4,
#     -cps_with_groups.select_pulkps4,
#     -cps_with_groups.pulkps5,
#     -cps_with_groups.select_pulkps5,
#     -cps_with_groups.pulkps6,
#     -cps_with_groups.select_pulkps6,
#     -cps_with_groups.hubusl1,
#     -cps_with_groups.select_hubusl1,
#     -cps_with_groups.hubusl2,
#     -cps_with_groups.select_hubusl2,
#     -cps_with_groups.hubusl3,
#     -cps_with_groups.select_hubusl3,
#     -cps_with_groups.hubusl4,
#     -cps_with_groups.select_hubusl4,
#     -cps_with_groups.pubusck2,
#     -cps_with_groups.select_pubusck2,
#     -cps_with_groups.pulkm2,
#     -cps_with_groups.select_pulkm2,
#     -cps_with_groups.pulkm3,
#     -cps_with_groups.select_pulkm3,
#     -cps_with_groups.pulkm4,
#     -cps_with_groups.select_pulkm4,
#     -cps_with_groups.pulkm5,
#     -cps_with_groups.select_pulkm5,
#     -cps_with_groups.pulkm6,
#     -cps_with_groups.select_pulkm6,
#     -cps_with_groups.pulkdk2,
#     -cps_with_groups.select_pulkdk2,
#     -cps_with_groups.pulkdk3,
#     -cps_with_groups.select_pulkdk3,
#     -cps_with_groups.pulkdk4,
#     -cps_with_groups.select_pulkdk4,
#     -cps_with_groups.pulkdk5,
#     -cps_with_groups.select_pulkdk5,
#     -cps_with_groups.pulkdk6,
#     -cps_with_groups.select_pulkdk6,
#     -cps_with_groups.pujhck4,
#     -cps_with_groups.select_pujhck4,
#     -cps_with_groups.pujhck5,
#     -cps_with_groups.select_pujhck5,
#     -cps_with_groups.pulkdk1,
#     -cps_with_groups.select_pulkdk1,
#     -cps_with_groups.punlfck1,
#     -cps_with_groups.select_punlfck1,
#     -cps_with_groups.pulayck3,
#     -cps_with_groups.select_pulayck3,
#     -cps_with_groups.pudwck1,
#     -cps_with_groups.select_pudwck1,
#     -cps_with_groups.pudwck2,
#     -cps_with_groups.select_pudwck2,
#     -cps_with_groups.pudwck3,
#     -cps_with_groups.select_pudwck3,
#     -cps_with_groups.pudwck4,
#     -cps_with_groups.select_pudwck4,
#     -cps_with_groups.pudwck5,
#     -cps_with_groups.select_pudwck5,
#     -cps_with_groups.puhrck1,
#     -cps_with_groups.select_puhrck1,
#     -cps_with_groups.puhrck12,
#     -cps_with_groups.select_puhrck12,
#     -cps_with_groups.puhrck2,
#     -cps_with_groups.select_puhrck2,
#     -cps_with_groups.puhrck3,
#     -cps_with_groups.select_puhrck3,
#     -cps_with_groups.puhrck4,
#     -cps_with_groups.select_puhrck4,
#     -cps_with_groups.puhrck5,
#     -cps_with_groups.select_puhrck5,
#     -cps_with_groups.puhrck6,
#     -cps_with_groups.select_puhrck6,
#     -cps_with_groups.puhrck7,
#     -cps_with_groups.select_puhrck7,
#     -cps_with_groups.pubus2ot,
#     -cps_with_groups.select_pubus2ot
#   ]
# }
