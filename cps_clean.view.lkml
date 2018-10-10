include: "cps_voter_supp_base_wo_cohort.view.lkml"
view: cps_clean {
  label: "Voter Data"
  extends: [CPS_Voting_and_Registration_wo_cohort]

  dimension: prtage {
    label: "Age - Tiered"
    view_label: "Demographic Variables"
    type: tier
    style: integer
    tiers: [
      0,
      18,
      25,
      35,
      45,
      55,
      65,
      75,
      85
    ]
  }

  dimension: county {
    view_label: "Geography Variables"
    description: "Only available for 2014 data"
    hidden: no
    sql: ${cps_2014_geo.county} ;;
  }

  dimension: raw_age {
    label: "Age"
    view_label: "Demographic Variables"
    type: number
    sql: ${TABLE}.PRTAGE ;;
    description: "Age is top-coded at 90, so all persons 90 or older are coded as 90."
  }

  dimension: raw_age_2016 {
    hidden: yes
    label: "Age in 2016"
    view_label: "Demographic Variables"
    type: number
    sql: ${TABLE}.PRTAGE + 2016 - ${year_of_interview} ;;
  }

  measure: weighted_age {
    hidden: yes
    type: sum
    sql: 1.0 * ${TABLE}.PRTAGE * ${TABLE}.PWSSWGT ;;
  }

  measure: average_age {
    view_label: "Demographic Variables"
    type: number
    sql: ${weighted_age} / ${cohort_population} ;;
    value_format_name: decimal_1
  }

  dimension: white_yesno {
    label: "White, Non-Hispanic (Yes/No)"
    type: string
    view_label: "Demographic Variables"
    sql: CASE WHEN
      ${race} = "White only or White"
      and ${prhspnon_yesno} = 'No'
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: eligible_registered_voter {
    label: "Eligible to vote, Registered to vote, Voted"
    type: string
    sql: CASE WHEN ${voted_recode} = "Yes" THEN 'Eligible|Registered|Voted' WHEN ${registered_recode_yesno} = "Yes" THEN 'Eligible|Registered' WHEN ${eligible_vote_yesno} = "Yes" THEN 'Eligible' END ;;
    suggestions: ["Eligible", "Registered", "Voted"]
    full_suggestions: no
  }

  dimension: prhspnon_yesno {
    label: "Hispanic origin (Yes/No)"
    view_label: "Demographic Variables"
    type: string
    sql: CASE WHEN
      (${TABLE}.prhspnon = 1
      AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
      or
      (${TABLE}.pehspnon = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: metro_status {
    label: "Metropolitan Status"
    view_label: "Geography Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.gtmetsta = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.gemetsta = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metropolitan"
      }

      when: {
        sql: (${TABLE}.gtmetsta = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.gemetsta = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonmetropolitan"
      }

      when: {
        sql: (${TABLE}.gtmetsta = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.gemetsta = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not Identified"
      }
    }
  }

  dimension: prez_cong {
    label: "Type of Election"

    case: {
      when: {
        sql: ${year_of_interview} % 4 = 0 ;;
        label: "Presidential"
      }

      when: {
        sql: ${year_of_interview} % 4 = 2 ;;
        label: "Congressional"
      }
    }
  }

  dimension: year_of_interview {
    view_label: "Household Variables"
    type: number
    sql: CASE WHEN ${TABLE}.HRYEAR in (94, 96)
      THEN integer(CONCAT('19', string(${TABLE}.HRYEAR)))
      ELSE ${TABLE}.HRYEAR4
      END
       ;;
    value_format: "0"
  }

  dimension: pes3 {
    label: "What was the main reason you did not register to vote?"
  }

  dimension: voted {
    hidden: yes
    label: "Did you vote in the November election?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.pes1 = -9
          OR (${TABLE}.pes3 = -9
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "No response (N/A)"
      }

      when: {
        sql: ${TABLE}.pes1 = -3 OR
          (${TABLE}.pes3 = -3
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Refused"
      }

      when: {
        sql: ${TABLE}.pes1 = -2 OR
          (          ${TABLE}.pes3 = -2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.pes1 = -1 OR
          (${TABLE}.pes3 = -1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.pes1 = 1 OR
          (${TABLE}.pes3 = 1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Yes"
      }

      when: {
        sql: ${TABLE}.pes1 = 2 OR
          (${TABLE}.pes3 = 2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "No"
      }
    }
  }

  dimension: in_person_mail {
    label: "Did you vote in person or did you vote by mail?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.pes5 = -9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = -9
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "No answer"
      }

      when: {
        sql: (${TABLE}.pes5 = -3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = -3
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "Refusal"
      }

      when: {
        sql: (${TABLE}.pes5 = -2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = -2
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "Don't Know"
      }

      when: {
        sql: (${TABLE}.pes5 = -1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = -1
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "Out of Universe"
      }

      when: {
        sql: (${TABLE}.pes5 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 in (1, 2)
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "In person"
      }

      when: {
        sql: (${TABLE}.pes5 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "By mail"
      }
    }
  }

  dimension: on_or_before {
    hidden: yes
    label: "Did you vote on Election Day or before?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.pes6 = -9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "No answer"
      }

      when: {
        sql: ${TABLE}.pes6 = -3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Refusal"
      }

      when: {
        sql: ${TABLE}.pes6 = -2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.pes6 = -1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Out of Universe"
      }

      when: {
        sql: (${TABLE}.pes6 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "On election day"
      }

      when: {
        sql: (${TABLE}.pes6 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes4 in (2, 3)
          AND ${TABLE}.src_table in ('census_2002', 'census_1998', 'census_1996'))
           ;;
        label: "Before election day"
      }
    }
  }

  dimension: when_obtained_license {
    hidden: yes
    label: "Did you register when you obtained or renewed license or another way?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.pes6 = -3
          AND ${TABLE}.src_table in ('census_1998', 'census_1996', 'census_2000', 'census_2002')
           ;;
        label: "Refused"
      }

      when: {
        sql: ${TABLE}.pes6 = -2
          AND ${TABLE}.src_table in ('census_1998', 'census_1996', 'census_2000', 'census_2002')
           ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.pes6 = -1
          AND ${TABLE}.src_table in ('census_1998', 'census_1996', 'census_2000', 'census_2002')
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.pes6 = 1
          AND ${TABLE}.src_table in ('census_1998', 'census_1996', 'census_2000', 'census_2002')
           ;;
        label: "When driver's license was obtained/renewed"
      }

      when: {
        sql: ${TABLE}.pes6 = 2
          AND ${TABLE}.src_table in ('census_1998', 'census_1996', 'census_2000', 'census_2002')
           ;;
        label: "Some other way"
      }
    }
  }

  dimension: registered {
    hidden: yes
    label: "Were you registered to vote in the November election?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${voted} = 'true'
          or
          (${TABLE}.pes2 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes4 = 1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Yes"
      }

      when: {
        sql: (${TABLE}.pes2 = -9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          OR
          (${TABLE}.pes4 = -9
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "No response"
      }

      when: {
        sql: (${TABLE}.pes2 = -3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          OR
          (${TABLE}.pes4 = -3
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Refused"
      }

      when: {
        sql: (${TABLE}.pes2 = -2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes4 = -2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Don't Know"
      }

      when: {
        sql: (${TABLE}.pes2 = -1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes4 = -1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: (${TABLE}.pes2 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes4 = 2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "No"
      }
    }
  }

  dimension: time_at_address {
    hidden: yes
    label: "How long have you been at your current address?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.prs8 = -9
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = -9
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = -9
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "No response"
      }

      when: {
        sql: (${TABLE}.prs8 = -3
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = -3
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = -3
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Refused"
      }

      when: {
        sql: (${TABLE}.prs8 = -2
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = -2
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = -2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Don't Know"
      }

      when: {
        sql: (${TABLE}.prs8 = -1
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = -1
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = -1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: (${TABLE}.pes8 = 1
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = 1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Less than 1 month"
      }

      when: {
        sql: (${TABLE}.pes8 = 2
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = 2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "1-6 months"
      }

      when: {
        sql: (${TABLE}.pes8 = 3
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = 3
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "7-11 months"
      }

      when: {
        sql: ${TABLE}.prs8 = 1
          AND ${TABLE}.src_table in ('census_2014')
           ;;
        label: "Less than 1 year"
      }

      when: {
        sql: (${TABLE}.prs8 = 2
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = 4
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = 4
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "1-2 years"
      }

      when: {
        sql: (${TABLE}.prs8 = 3
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = 5
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes6 = 5
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "3-4 years"
      }

      when: {
        sql: (${TABLE}.prs8 = 4
          AND ${TABLE}.src_table in ('census_2014'))
          or
          (${TABLE}.pes8 = 6
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          ${TABLE}.pes6 = 6
          AND ${TABLE}.src_table in ('census_1994')
           ;;
        label: "5 years or longer"
      }
    }
  }

  dimension: race {
    label: "Race"
    view_label: "Demographic Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.ptdtrace = 01
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.perace = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "White only or White"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 02
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.perace = 2
          AND ${TABLE}.src_table in ('census_1994', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Black only or Black"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.perace = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "American Indian, Alaskan Native Only or American Indian, Aleut, Eskimo"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.perace = 4
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Asian only or Asian or Pacific Islander"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "Hawaiian/Pacific Islander Only"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-Black"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-American Indian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "White-Asian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "White-Hawaiian/Pacific Islander"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Black-American Indian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Black-Asian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Black-Hawaiian/Pacific Islander"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "American Indian-Asian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012')
           ;;
        label: "American Indian-Hawaiian/Pacific Islander"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 14
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "Asian-Hawaiian/Pacific Islander"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 15
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-Black-American Indian"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 17
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 16
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-Black-Asian"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 19
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 17
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-American Indian-Asian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 20
          AND ${TABLE}.src_table in ('census_2014', 'census_2012')
           ;;
        label: "White-American Indian-Hawaiian/Pacific Islander"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 21
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 18
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-Asian-Hawaiian/Pacific Islander"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 22
          AND ${TABLE}.src_table in ('census_2014', 'census_2012')
           ;;
        label: "Black-American Indian-Asian"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 23
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 19
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "White-Black-American Indian-Asian"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 24
          AND ${TABLE}.src_table in ('census_2014', 'census_2012')
           ;;
        label: "White-American Indian-Asian-Hawaiian/Pacific Islander"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 25
          AND ${TABLE}.src_table in ('census_2014', 'census_2012')
           ;;
        label: "Other 3 Race Combinations"
      }

      when: {
        sql: (${TABLE}.ptdtrace = 26
          AND ${TABLE}.src_table in ('census_2014', 'census_2012'))
          or
          (${TABLE}.ptdtrace = 21
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "Other 4 and 5 Race Combinations"
      }

      when: {
        sql: ${TABLE}.ptdtrace = 20
          AND ${TABLE}.src_table in ('census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Unspecified 2 or 3 Races"
      }

      when: {
        sql: ${TABLE}.perace = 5
          AND ${TABLE}.src_table in ('census_1994')
           ;;
        label: "Other"
      }
    }
  }

  dimension: race_hisp {
    hidden: yes
    label: "Race With Hispanic"
    view_label: "Cohort Demographic Variables"
    type: string

    case: {
      when: {
        sql: ${white_yesno} = 'Yes'
          ;;
        label: "White, Non-Hispanic"
      }

      when: {
        sql: ${demo_group} = 'Hispanic'
          ;;
        label: "Hispanic"
      }

      when: {
        sql: ${demo_group} = 'Black Only or Mixed-Race Black'
          ;;
        label: "Black"
      }

      when: {
        sql: ${race} = 'American Indian, Alaskan Native Only or American Indian, Aleut, Eskimo'
          ;;
        label: "American Indian"
      }

      when: {
        sql: ${race} = 'Asian only or Asian or Pacific Islander'
          ;;
        label: "Asian, Pacific Islander"
      }

      else: "Other"
    }
  }

  dimension: register_after_1995 {
    hidden: yes
    label: "Did you register to vote after January 1, 1995?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.pes5 = -9
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "No response"
      }

      when: {
        sql: ${TABLE}.pes5 = -3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "Refused"
      }

      when: {
        sql: ${TABLE}.pes5 = -2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.pes5 = -1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.pes5 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "Yes"
      }

      when: {
        sql: ${TABLE}.pes5 = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996')
           ;;
        label: "No"
      }
    }
  }

  dimension: how_register {
    label: "How did you register to vote?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.pes7 = -9
          AND ${TABLE}.src_table not in ('census_1994')
           ;;
        label: "No response"
      }

      when: {
        sql: ${TABLE}.pes7 = -3
          AND ${TABLE}.src_table not in ('census_1994')
           ;;
        label: "Refused"
      }

      when: {
        sql: ${TABLE}.pes7 = -2
          AND ${TABLE}.src_table not in ('census_1994')
           ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.pes7 = -1
          AND ${TABLE}.src_table not in ('census_1994')
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.pes7 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2004', 'census_2008', 'census_2006')
           ;;
        label: "At a department of motor vehicles (for example, when obtaining a driver's license or other identification card)"
      }

      when: {
        sql: (${TABLE}.pes7 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_1996', 'census_2000', 'census_1998'))
           ;;
        label: "At a public assistance agency (for example, a Medicaid, AFDC, or Food Stamps office, an office serving di)"
      }

      when: {
        sql: (${TABLE}.pes7 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_1996', 'census_2000', 'census_1998'))
           ;;
        label: "Registered by mail"
      }

      when: {
        sql: ${TABLE}.pes7 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010')
           ;;
        label: "Registered using the internet or online"
      }

      when: {
        sql: (${TABLE}.pes7 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          or
          (${TABLE}.pes7 = 4
          AND ${TABLE}.src_table in ('census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_1996', 'census_2000', 'census_1998'))
           ;;
        label: "At a school, hospital, or on campus"
      }

      when: {
        sql: (${TABLE}.pes7 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          or
          (${TABLE}.pes7 = 5
          AND ${TABLE}.src_table in ('census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 4
          AND ${TABLE}.src_table in ('census_2002', 'census_1996', 'census_2000', 'census_1998'))
           ;;
        label: "Went to a town hall or county/government registration office"
      }

      when: {
        sql: (${TABLE}.pes7 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          or
          (${TABLE}.pes7 = 6
          AND ${TABLE}.src_table in ('census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 5
          AND ${TABLE}.src_table in ('census_2002', 'census_1996', 'census_2000', 'census_1998'))
           ;;
        label: "Filled out form at a registration drive (library, post office, or someone came to your door)"
      }

      when: {
        sql: (${TABLE}.pes7 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          or
          (${TABLE}.pes7 = 7
          AND ${TABLE}.src_table in ('census_2004', 'census_2008', 'census_1996', 'census_2006'))
          or
          (${TABLE}.pes7 = 6
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998'))
           ;;
        label: "Registered at polling place (on election or primary day)"
      }

      when: {
        sql: (${TABLE}.pes7 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          or
          (${TABLE}.pes7 = 8
          AND ${TABLE}.src_table in ('census_2004', 'census_2008', 'census_2006'))
          or
          (${TABLE}.pes7 = 7
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998'))
          or
          (${TABLE}.pes7 = 6
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Other"
      }
    }
  }

  dimension: why_not_vote {
    label: "What was the main reason you did not vote?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.pes4 = -9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = -9
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996'))
           ;;
        label: "No answer"
      }

      when: {
        sql: (${TABLE}.pes4 = -3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = -3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996'))
           ;;
        label: "Refusal"
      }

      when: {
        sql: (${TABLE}.pes4 = -2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = -2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996'))
           ;;
        label: "Don't Know"
      }

      when: {
        sql: (${TABLE}.pes4 = -1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = -1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996'))
           ;;
        label: "Out of Universe"
      }

      when: {
        sql: (${TABLE}.pes4 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 3
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 4
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Illness or disability (own or family's)"
      }

      when: {
        sql: (${TABLE}.pes4 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 5
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 3
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Out of town or away from home"
      }

      when: {
        sql: (${TABLE}.pes4 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 6
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 7
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Forgot to vote (or send in absentee ballot)"
      }

      when: {
        sql: (${TABLE}.pes4 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 4
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 2
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 6
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Not interested, felt my vote wouldn't make a difference"
      }

      when: {
        sql: (${TABLE}.pes4 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 5
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 1
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 2
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Too busy, conflicting work or school schedule"
      }

      when: {
        sql: (${TABLE}.pes4 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 6
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 7
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 1
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Transportation problems"
      }

      when: {
        sql: (${TABLE}.pes4 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 7
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 4
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 5
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Didn't like candidates or campaign issues"
      }

      when: {
        sql: (${TABLE}.pes4 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 8
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 9
          AND ${TABLE}.src_table in ('census_1998'))
           ;;
        label: "Registration problems (e.g. didn't receive absentee ballot, not registered in current location)"
      }

      when: {
        sql: (${TABLE}.pes4 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 9
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 10
          AND ${TABLE}.src_table in ('census_1998'))
           ;;
        label: "Bad weather conditions"
      }

      when: {
        sql: (${TABLE}.pes4 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 10
          AND ${TABLE}.src_table in ('census_2002', 'census_2000'))
          or
          (${TABLE}.pes3 = 8
          AND ${TABLE}.src_table in ('census_1998'))
          or
          (${TABLE}.pes3 = 9
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Inconvenient hours, polling place or hours or lines too long"
      }

      when: {
        sql: (${TABLE}.pes4 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          or
          (${TABLE}.pes3 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998'))
          or
          (${TABLE}.pes3 = 8
          AND ${TABLE}.src_table in ('census_1996'))
           ;;
        label: "Other"
      }
    }
  }

  dimension: pusck4 {
    hidden: yes
    label: "Are you reporting for yourself or for another person?"
    view_label: "Voting and Registration Supplement Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.pusck4 = -1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes7 = -9
          AND ${TABLE}.src_table in ('census_1994'))
          or
          (${TABLE}.pes7 is null
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Not in Universe"
      }

      when: {
        sql: (${TABLE}.pusck4 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes7 = 1
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Self"
      }

      when: {
        sql: (${TABLE}.pusck4 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
          or
          (${TABLE}.pes7 = 2
          AND ${TABLE}.src_table in ('census_1994'))
           ;;
        label: "Other"
      }
    }
  }

  dimension: eligible_vote_yesno {
    hidden: yes
    label: "Were you eligible to vote in the November election? (Yes/No)"
    view_label: "Voting and Registration Supplement Variables"
    type: string
    sql: CASE WHEN
      ${raw_age} >= 18
      AND
      ${TABLE}.prcitshp in (1, 2, 3, 4)
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: registered_recode_yesno {
    hidden: yes
    label: "Were you registered to vote in the November election? (Yes/No)"
    view_label: "Voting and Registration Supplement Variables"
    type: string
    sql: CASE WHEN
      ${voted} = 'true'
      or
      (${TABLE}.pes2 = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996'))
      or
      (${TABLE}.pes4 = 1
      AND ${TABLE}.src_table in ('census_1994'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: voted_recode {
    label: "Did you vote in the November election? (Yes/No)"
    view_label: "Voting and Registration Supplement Variables"
    type: string
    sql: CASE WHEN ${TABLE}.pes1 = 1 OR
      (${TABLE}.pes3 = 1
      AND ${TABLE}.src_table in ('census_1994'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: obama_coalition {
    hidden: yes
    label: "Member of the Obama Coalition (Yes/No)"
    view_label: "Voting and Registration Supplement Variables"
    type: string
    sql: CASE WHEN
      (${white_yesno} = 'No')
      OR ((${weekly_earnings} * 52) between 0 and 15000)
      OR (${raw_age} < 30)
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: weekly_earnings {
    hidden: yes
    sql: CASE WHEN ${TABLE}.pternwa between 0.0 AND 2884.61 AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.pternwa ELSE -1 END ;;
    type: number
    view_label: "Earnings Variables"
  }

  dimension: yearly_earnings {
    label: "Yearly Earnings Tier"
    type: tier
    tiers: [
      0,
      15000,
      30000,
      45000,
      60000,
      75000,
      90000,
      105000
    ]
    value_format_name: decimal_0
    view_label: "Earnings Variables"
    sql: CASE WHEN ${TABLE}.PTERNWA not in (0, 21474836.47) AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.PTERNWA * 52 ELSE -1 END
      ;;
  }

  measure: weighted_yearly_earnings {
    hidden: yes
    type: sum
    sql: CASE WHEN ${weekly_earnings} >= 0 THEN 52.0 * ${weekly_earnings} * ${TABLE}.PWSSWGT ELSE NULL END ;;
  }

  measure: weighted_yearly_earnings_2012 {
    hidden: yes
    type: sum
    sql: CASE WHEN ${weekly_earnings} >= 0 THEN 52.0 * ${weekly_earnings} * ${TABLE}.PWSSWGT ELSE NULL END ;;
    filters: {
      field: year_of_interview
      value: "2012"
    }
  }

  measure: weighted_yearly_earnings_2014 {
    hidden: yes
    type: sum
    sql: CASE WHEN ${weekly_earnings} >= 0 THEN 52.0 * ${weekly_earnings} * ${TABLE}.PWSSWGT ELSE NULL END ;;
    filters: {
      field: year_of_interview
      value: "2014"
    }
  }

  measure: average_yearly_earnings {
    view_label: "Earnings Variables"
    type: number
    sql: ${weighted_yearly_earnings} / ${cohort_population_for_earnings} ;;
    value_format_name: usd_0
  }

  measure: average_yearly_earnings_2012 {
    hidden: yes
    label: "2012 Average Earnings"
    view_label: "Earnings Variables"
    type: number
    sql: ${weighted_yearly_earnings_2012} / ${cohort_population_for_earnings_2012} ;;
    value_format_name: usd_0
  }

  measure: average_yearly_earnings_2014 {
    label: "Average Yearly Earnings in 2014"
    view_label: "Earnings Variables"
    type: number
    sql: ${weighted_yearly_earnings_2014} / ${cohort_population_for_earnings_2014} ;;
    html: {{ rendered_value }} average earnings in {{ prmjind1._rendered_value }} in 2014 ;;
    value_format_name: usd_0
  }

  measure: percent_change_average_earnings_2012_vs_2014 {
    type: number
    label: "% Change Earnings 2014 vs. 2012"
    view_label: "Earnings Variables"
    sql: (${average_yearly_earnings_2014}-${average_yearly_earnings_2012})/${average_yearly_earnings_2012} ;;
    value_format_name: percent_1
  }

  measure: average_yearly_family_earnings {
    view_label: "Earnings Variables"
    type: number
    sql: ${weighted_yearly_earnings} / ${cohort_households_for_earnings} ;;
    value_format_name: usd_0
  }

  dimension: education5 {
    label: "Education (5 Categories)"
    view_label: "Demographic Variables"

    case: {
      when: {
        sql: ${TABLE}.preduca5 = 1
          ;;
        label: "Less than a high school diploma"
      }

      when: {
        sql: ${TABLE}.preduca5 = 2
          ;;
        label: "High school diploma, no college"
      }

      when: {
        sql: ${TABLE}.preduca5 = 3
          ;;
        label: "Some college, no degree"
      }

      when: {
        sql: ${TABLE}.preduca5 = 4
          ;;
        label: "Associate degree"
      }

      when: {
        sql: ${TABLE}.preduca5 = 5
          ;;
        label: "Bachelor's degree or higher"
      }
    }
  }

  dimension: education4 {
    label: "Education (4 Categories)"
    view_label: "Demographic Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.preduca4 = 1
          ;;
        label: "Less than a high school diploma"
      }

      when: {
        sql: ${TABLE}.preduca4 = 2
          ;;
        label: "High school diploma, no college"
      }

      when: {
        sql: ${TABLE}.preduca4 = 3
          ;;
        label: "Some college or associate degree"
      }

      when: {
        sql: ${TABLE}.preduca4 = 4
          ;;
        label: "Bachelor's degree or higher"
      }
    }
  }

  dimension: generation {
    label: "Generation Name"
    view_label: "Demographic Variables"

    case: {
      when: {
        sql: ${year_of_interview} - ${raw_age} < 1900 ;;
        label: "Lost Generation"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 1900 and 1924 ;;
        label: "Greatest Generation"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 1925 and 1945 ;;
        label: "Silent Generation"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 1946 and 1964 ;;
        label: "Baby Boomers"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 1965 and 1980 ;;
        label: "Generation X"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 1981 and 2000 ;;
        label: "Millennials"
      }

      when: {
        sql: ${year_of_interview} - ${raw_age} between 2001 and 2020 ;;
        label: "Generation Z"
      }
    }
  }

  dimension: pedipged {
    label: "High school completion type: Graduation or GED"
  }

  dimension: pehgcomp {
    label: "Highest grade completed before GED obtained"
  }

  dimension: demo_group {
    label: "Demographic Groups Recode (5 groups)"
    view_label: "Demographic Variables"

    case: {
      when: {
        sql: ${white_yesno} = 'Yes' AND
          ${education5} in ('Less than a high school diploma', 'High school diploma, no college')
           ;;
        label: "White, No College"
      }

      when: {
        sql: ${white_yesno} = 'Yes' AND
          ${education5} not in ('Less than a high school diploma', 'High school diploma, no college')
           ;;
        label: "College-Educated White"
      }

      when: {
        sql: ${prhspnon_yesno} = 'Yes' ;;
        label: "Hispanic"
      }

      when: {
        sql: ${race} in ('Black only or Black', 'White-Black', 'Black-American Indian', 'Black-Asian',
          'Black-Hawaiian/Pacific Islander', 'White-Black-American Indian', 'White-Black-Asian',
          'Black-American Indian-Asian', 'White-Black-American Indian-Asian')
           ;;
        label: "Black Only or Mixed-Race Black"
      }

      else: "Other"
    }
  }

  dimension: prnlfsch {
    label: "In School/Not in School (not in labor force)"
    view_label: "School Enrollment Variables"
  }

  dimension: peschft {
    label: "Type of Student (FT/PT)"
    view_label: "School Enrollment Variables"
  }

  dimension: peschlvl {
    label: "In High School or College/University"
    view_label: "School Enrollment Variables"
  }

  dimension: peschenr_yesno {
    label: "In High School/College/University (Yes/No)"
    view_label: "School Enrollment Variables"
    sql: CASE WHEN
      ${peschenr} = 1
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: pegrprof {
    label: "Has taken graduate/professional courses (has BS/BA)"
  }

  dimension: pegr6cor {
    label: "Completed 6 or more graduate courses (Yes/No)"
  }

  dimension: peafnow {
    hidden: yes
  }

  dimension: peafnow1 {
    label: "Currently in armed forces (Yes/No)"
    type: string
    sql: CASE WHEN
        ${TABLE}.peafnow = -1
        THEN 'Out of Universe'
        WHEN ${TABLE}.peafnow = 1
        THEN 'Yes'
        WHEN ${TABLE}.peafnow = 2
        THEN 'No'
      END
       ;;
  }

  dimension: pefntvty {
    label: "Native country of father"
    map_layer_name: countries

    case: {
      when: {
        sql: ${TABLE}.pefntvty = 57
          ;;
        label: "United States of America"
      }

      when: {
        sql: ${TABLE}.pefntvty = 60
          ;;
        label: "American Samoa"
      }

      when: {
        sql: ${TABLE}.pefntvty = 66
          ;;
        label: "Guam"
      }

      when: {
        sql: ${TABLE}.pefntvty = 69
          ;;
        label: "Northern Marianas"
      }

      when: {
        sql: (${TABLE}.pefntvty = 73
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 72
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Puerto Rico"
      }

      when: {
        sql: ${TABLE}.pefntvty = 78
          ;;
        label: "U. S. Virgin Islands"
      }

      when: {
        sql: ${TABLE}.pefntvty = 96
          ;;
        label: "Other U. S. Island Areas"
      }

      when: {
        sql: ${TABLE}.pefntvty = 100
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006')
           ;;
        label: "Albania"
      }

      when: {
        sql: ${TABLE}.pefntvty = 102
          ;;
        label: "Austria"
      }

      when: {
        sql: ${TABLE}.pefntvty = 103
          ;;
        label: "Belgium"
      }

      when: {
        sql: ${TABLE}.pefntvty = 104
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006')
           ;;
        label: "Bulgaria"
      }

      when: {
        sql: ${TABLE}.pefntvty = 105
          ;;
        label: "Czechoslovakia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 106
          ;;
        label: "Denmark"
      }

      when: {
        sql: ${TABLE}.pefntvty = 108
          ;;
        label: "Finland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 109
          ;;
        label: "France"
      }

      when: {
        sql: ${TABLE}.pefntvty = 110
          ;;
        label: "Germany"
      }

      when: {
        sql: ${TABLE}.pefntvty = 116
          ;;
        label: "Greece"
      }

      when: {
        sql: ${TABLE}.pefntvty = 117
          ;;
        label: "Hungary"
      }

      when: {
        sql: ${TABLE}.pefntvty = 119
          ;;
        label: "Ireland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 120
          ;;
        label: "Italy"
      }

      when: {
        sql: ${TABLE}.pefntvty = 126
          ;;
        label: "Netherlands"
      }

      when: {
        sql: ${TABLE}.pefntvty = 127
          ;;
        label: "Norway"
      }

      when: {
        sql: ${TABLE}.pefntvty = 128
          ;;
        label: "Poland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 129
          ;;
        label: "Portugal"
      }

      when: {
        sql: ${TABLE}.pefntvty = 130
          ;;
        label: "Azores"
      }

      when: {
        sql: ${TABLE}.pefntvty = 132
          ;;
        label: "Romania"
      }

      when: {
        sql: ${TABLE}.pefntvty = 134
          ;;
        label: "Spain"
      }

      when: {
        sql: ${TABLE}.pefntvty = 136
          ;;
        label: "Sweden"
      }

      when: {
        sql: ${TABLE}.pefntvty = 137
          ;;
        label: "Switzerland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 138
          ;;
        label: "United Kingdom"
      }

      when: {
        sql: ${TABLE}.pefntvty = 139
          ;;
        label: "England"
      }

      when: {
        sql: ${TABLE}.pefntvty = 140
          ;;
        label: "Scotland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 141
          ;;
        label: "Wales"
      }

      when: {
        sql: ${TABLE}.pefntvty = 142
          ;;
        label: "Northern Ireland"
      }

      when: {
        sql: ${TABLE}.pefntvty = 147
          ;;
        label: "Yugoslavia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 148
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 155
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Czech Republic"
      }

      when: {
        sql: (${TABLE}.pefntvty = 149
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 156
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Slovakia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 150
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Bosnia & Herzegovina"
      }

      when: {
        sql: ${TABLE}.pefntvty = 151
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Croatia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 152
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Macedonia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 154
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Serbia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 156
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 183
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Latvia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 157
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 184
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lithuania"
      }

      when: {
        sql: (${TABLE}.pefntvty = 158
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 185
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armenia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 159
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Azerbaijan"
      }

      when: {
        sql: ${TABLE}.pefntvty = 160
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Belarus"
      }

      when: {
        sql: ${TABLE}.pefntvty = 161
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Georgia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 162
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Moldova"
      }

      when: {
        sql: (${TABLE}.pefntvty = 163
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 192
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Russia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 164
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 195
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ukraine"
      }

      when: {
        sql: (${TABLE}.pefntvty = 165
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 180
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "USSR"
      }

      when: {
        sql: (${TABLE}.pefntvty = 166
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 148
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Europe,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 167
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kosovo"
      }

      when: {
        sql: ${TABLE}.pefntvty = 200
          ;;
        label: "Afghanistan"
      }

      when: {
        sql: ${TABLE}.pefntvty = 202
          ;;
        label: "Bangladesh"
      }

      when: {
        sql: ${TABLE}.pefntvty = 205
          ;;
        label: "Myanmar (Burma)"
      }

      when: {
        sql: ${TABLE}.pefntvty = 206
          ;;
        label: "Cambodia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 207
          ;;
        label: "China"
      }

      when: {
        sql: ${TABLE}.pefntvty = 208
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cyprus"
      }

      when: {
        sql: ${TABLE}.pefntvty = 209
          ;;
        label: "Hong Kong"
      }

      when: {
        sql: ${TABLE}.pefntvty = 210
          ;;
        label: "India"
      }

      when: {
        sql: ${TABLE}.pefntvty = 211
          ;;
        label: "Indonesia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 212
          ;;
        label: "Iran"
      }

      when: {
        sql: ${TABLE}.pefntvty = 213
          ;;
        label: "Iraq"
      }

      when: {
        sql: ${TABLE}.pefntvty = 214
          ;;
        label: "Israel"
      }

      when: {
        sql: ${TABLE}.pefntvty = 215
          ;;
        label: "Japan"
      }

      when: {
        sql: ${TABLE}.pefntvty = 216
          ;;
        label: "Jordan"
      }

      when: {
        sql: ${TABLE}.pefntvty = 217
          ;;
        label: "Korea"
      }

      when: {
        sql: ${TABLE}.penatvty = 218
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Korea/ South Korea"
      }

      when: {
        sql: ${TABLE}.pefntvty = 220
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "South Korea"
      }

      when: {
        sql: ${TABLE}.pefntvty = 222
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kuwait"
      }

      when: {
        sql: (${TABLE}.pefntvty = 223
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 221
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Laos"
      }

      when: {
        sql: (${TABLE}.pefntvty = 224
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 222
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lebanon"
      }

      when: {
        sql: (${TABLE}.pefntvty = 226
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 224
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Malaysia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 229
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Nepal"
      }

      when: {
        sql: (${TABLE}.pefntvty = 231
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 229
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pakistan"
      }

      when: {
        sql: (${TABLE}.pefntvty = 233
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 231
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Philippines"
      }

      when: {
        sql: (${TABLE}.pefntvty = 235
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 233
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Saudi Arabia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 236
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 234
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Singapore"
      }

      when: {
        sql: ${TABLE}.pefntvty = 238
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sri Lanka"
      }

      when: {
        sql: (${TABLE}.pefntvty = 239
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 237
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Syria"
      }

      when: {
        sql: (${TABLE}.pefntvty = 240
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 238
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Taiwan"
      }

      when: {
        sql: (${TABLE}.pefntvty = 242
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 239
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Thailand"
      }

      when: {
        sql: (${TABLE}.pefntvty = 243
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 240
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Turkey"
      }

      when: {
        sql: ${TABLE}.pefntvty = 246
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uzbekistan"
      }

      when: {
        sql: (${TABLE}.pefntvty = 247
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 242
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vietnam"
      }

      when: {
        sql: ${TABLE}.pefntvty = 248
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Yemen"
      }

      when: {
        sql: (${TABLE}.pefntvty = 249
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 245
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Asia,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 252
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Middle East"
      }

      when: {
        sql: ${TABLE}.pefntvty = 253
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Palestine"
      }

      when: {
        sql: ${TABLE}.pefntvty = 300
          ;;
        label: "Bermuda"
      }

      when: {
        sql: ${TABLE}.pefntvty = 301
          ;;
        label: "Canada"
      }

      when: {
        sql: ${TABLE}.pefntvty = 304
          ;;
        label: "North America"
      }

      when: {
        sql: (${TABLE}.pefntvty = 303
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 315
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Mexico"
      }

      when: {
        sql: ${TABLE}.pefntvty = 310
          ;;
        label: "Belize"
      }

      when: {
        sql: ${TABLE}.pefntvty = 311
          ;;
        label: "Costa Rica"
      }

      when: {
        sql: ${TABLE}.pefntvty = 312
          ;;
        label: "El Salvador"
      }

      when: {
        sql: ${TABLE}.pefntvty = 313
          ;;
        label: "Guatemala"
      }

      when: {
        sql: ${TABLE}.pefntvty = 314
          ;;
        label: "Honduras"
      }

      when: {
        sql: (${TABLE}.pefntvty = 315
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 316
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nicaragua"
      }

      when: {
        sql: (${TABLE}.pefntvty = 316
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 317
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Panama"
      }

      when: {
        sql: ${TABLE}.pefntvty = 318
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Central America"
      }

      when: {
        sql: ${TABLE}.pefntvty = 321
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Antigua and Barbuda"
      }

      when: {
        sql: (${TABLE}.pefntvty = 323
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 333
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bahamas"
      }

      when: {
        sql: (${TABLE}.pefntvty = 324
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 334
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Barbados"
      }

      when: {
        sql: (${TABLE}.pefntvty = 327
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 337
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cuba"
      }

      when: {
        sql: (${TABLE}.pefntvty = 328
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 338
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominica"
      }

      when: {
        sql: (${TABLE}.pefntvty = 329
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 339
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominican Republic"
      }

      when: {
        sql: (${TABLE}.pefntvty = 330
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 340
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Grenada"
      }

      when: {
        sql: (${TABLE}.pefntvty = 332
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 342
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Haiti"
      }

      when: {
        sql: (${TABLE}.pefntvty = 333
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 343
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Jamaica"
      }

      when: {
        sql: ${TABLE}.pefntvty = 338
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Kitts-Nevis"
      }

      when: {
        sql: ${TABLE}.pefntvty = 339
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Lucia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 340
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Vincent and the Grenadines"
      }

      when: {
        sql: (${TABLE}.pefntvty = 341
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 351
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Trinidad and Tobago"
      }

      when: {
        sql: (${TABLE}.pefntvty = 343
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 353
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "West Indies,not specified"
      }

      when: {
        sql: (${TABLE}.pefntvty = 360
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 375
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Argentina"
      }

      when: {
        sql: (${TABLE}.pefntvty = 361
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 376
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bolivia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 362
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 377
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Brazil"
      }

      when: {
        sql: (${TABLE}.pefntvty = 363
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 378
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Chile"
      }

      when: {
        sql: (${TABLE}.pefntvty = 364
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 379
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Colombia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 365
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 380
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ecuador"
      }

      when: {
        sql: (${TABLE}.pefntvty = 368
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 383
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Guyana"
      }

      when: {
        sql: ${TABLE}.pefntvty = 369
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Paraguay"
      }

      when: {
        sql: (${TABLE}.pefntvty = 370
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 385
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Peru"
      }

      when: {
        sql: (${TABLE}.pefntvty = 372
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 387
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Uruguay"
      }

      when: {
        sql: (${TABLE}.pefntvty = 373
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 388
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Venezuela"
      }

      when: {
        sql: (${TABLE}.pefntvty = 374
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 389
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "South America,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 399
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Americas,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 400
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Algeria"
      }

      when: {
        sql: ${TABLE}.pefntvty = 407
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cameroon"
      }

      when: {
        sql: ${TABLE}.pefntvty = 408
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cape Verde"
      }

      when: {
        sql: (${TABLE}.pefntvty = 414
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 415
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Egypt"
      }

      when: {
        sql: (${TABLE}.pefntvty = 416
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 417
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ethiopia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 417
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Eritrea"
      }

      when: {
        sql: ${TABLE}.pefntvty = 421
          ;;
        label: "Ghana"
      }

      when: {
        sql: ${TABLE}.pefntvty = 427
          ;;
        label: "Kenya"
      }

      when: {
        sql: ${TABLE}.pefntvty = 429
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Liberia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 436
          ;;
        label: "Morocco"
      }

      when: {
        sql: ${TABLE}.pefntvty = 440
          ;;
        label: "Nigeria"
      }

      when: {
        sql: ${TABLE}.pefntvty = 444
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Senegal"
      }

      when: {
        sql: ${TABLE}.pefntvty = 447
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sierra Leone"
      }

      when: {
        sql: ${TABLE}.pefntvty = 448
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Somalia"
      }

      when: {
        sql: ${TABLE}.pefntvty = 449
          ;;
        label: "South Africa"
      }

      when: {
        sql: ${TABLE}.pefntvty = 451
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sudan"
      }

      when: {
        sql: ${TABLE}.pefntvty = 453
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tanzania"
      }

      when: {
        sql: ${TABLE}.pefntvty = 457
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uganda"
      }

      when: {
        sql: ${TABLE}.pefntvty = 461
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Zimbabwe"
      }

      when: {
        sql: ${TABLE}.pefntvty = 462
          ;;
        label: "Africa,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 468
          ;;
        label: "North Africa"
      }

      when: {
        sql: ${TABLE}.pefntvty = 501
          ;;
        label: "Australia"
      }

      when: {
        sql: (${TABLE}.pefntvty = 508
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 507
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fiji"
      }

      when: {
        sql: (${TABLE}.pefntvty = 515
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 514
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "New Zealand"
      }

      when: {
        sql: ${TABLE}.pefntvty = 523
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tonga"
      }

      when: {
        sql: ${TABLE}.pefntvty = 527
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Samoa"
      }

      when: {
        sql: (${TABLE}.pefntvty = 528
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pefntvty = 527
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Oceania,not specified"
      }

      when: {
        sql: ${TABLE}.pefntvty = 555
          ;;
        label: "Other"
      }
    }
  }

  dimension: pemntvty {
    label: "Native country of mother"
    map_layer_name: countries

    case: {
      when: {
        sql: ${TABLE}.pemntvty = 57
          ;;
        label: "United States of America"
      }

      when: {
        sql: ${TABLE}.pemntvty = 66
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Guam"
      }

      when: {
        sql: (${TABLE}.pemntvty = 73
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 72
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Puerto Rico"
      }

      when: {
        sql: ${TABLE}.pemntvty = 78
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "U. S. Virgin Islands"
      }

      when: {
        sql: ${TABLE}.pemntvty = 96
          ;;
        label: "Other U. S. Island Areas"
      }

      when: {
        sql: ${TABLE}.pemntvty = 100
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Albania"
      }

      when: {
        sql: ${TABLE}.pemntvty = 102
          ;;
        label: "Austria"
      }

      when: {
        sql: ${TABLE}.pemntvty = 103
          ;;
        label: "Belgium"
      }

      when: {
        sql: ${TABLE}.pemntvty = 104
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Bulgaria"
      }

      when: {
        sql: ${TABLE}.pemntvty = 105
          ;;
        label: "Czechoslovakia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 106
          ;;
        label: "Denmark"
      }

      when: {
        sql: ${TABLE}.pemntvty = 108
          ;;
        label: "Finland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 109
          ;;
        label: "France"
      }

      when: {
        sql: ${TABLE}.pemntvty = 110
          ;;
        label: "Germany"
      }

      when: {
        sql: ${TABLE}.pemntvty = 116
          ;;
        label: "Greece"
      }

      when: {
        sql: ${TABLE}.pemntvty = 117
          ;;
        label: "Hungary"
      }

      when: {
        sql: ${TABLE}.pemntvty = 119
          ;;
        label: "Ireland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 120
          ;;
        label: "Italy"
      }

      when: {
        sql: ${TABLE}.pemntvty = 126
          ;;
        label: "Netherlands"
      }

      when: {
        sql: ${TABLE}.pemntvty = 127
          ;;
        label: "Norway"
      }

      when: {
        sql: ${TABLE}.pemntvty = 128
          ;;
        label: "Poland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 129
          ;;
        label: "Portugal"
      }

      when: {
        sql: ${TABLE}.pemntvty = 130
          ;;
        label: "Azores"
      }

      when: {
        sql: ${TABLE}.pemntvty = 132
          ;;
        label: "Romania"
      }

      when: {
        sql: ${TABLE}.pemntvty = 134
          ;;
        label: "Spain"
      }

      when: {
        sql: ${TABLE}.pemntvty = 136
          ;;
        label: "Sweden"
      }

      when: {
        sql: ${TABLE}.pemntvty = 137
          ;;
        label: "Switzerland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 138
          ;;
        label: "United Kingdom"
      }

      when: {
        sql: ${TABLE}.pemntvty = 139
          ;;
        label: "England"
      }

      when: {
        sql: ${TABLE}.pemntvty = 140
          ;;
        label: "Scotland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 141
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Wales"
      }

      when: {
        sql: ${TABLE}.pemntvty = 142
          ;;
        label: "Northern Ireland"
      }

      when: {
        sql: ${TABLE}.pemntvty = 147
          ;;
        label: "Yugoslavia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 148
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 155
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Czech Republic"
      }

      when: {
        sql: (${TABLE}.pemntvty = 149
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 156
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Slovakia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 150
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Bosnia & Herzegovina"
      }

      when: {
        sql: ${TABLE}.pemntvty = 151
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Croatia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 152
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Macedonia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 154
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Serbia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 156
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 183
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Latvia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 157
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 184
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lithuania"
      }

      when: {
        sql: (${TABLE}.pemntvty = 158
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 185
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armenia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 159
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Azerbaijan"
      }

      when: {
        sql: ${TABLE}.pemntvty = 160
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Belarus"
      }

      when: {
        sql: ${TABLE}.pemntvty = 161
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Georgia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 162
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Moldova"
      }

      when: {
        sql: (${TABLE}.pemntvty = 163
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 192
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Russia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 164
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 195
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ukraine"
      }

      when: {
        sql: (${TABLE}.pemntvty = 165
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 180
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "USSR"
      }

      when: {
        sql: (${TABLE}.pemntvty = 166
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 148
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Europe,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 167
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kosovo"
      }

      when: {
        sql: ${TABLE}.pemntvty = 200
          ;;
        label: "Afghanistan"
      }

      when: {
        sql: ${TABLE}.pemntvty = 202
          ;;
        label: "Bangladesh"
      }

      when: {
        sql: ${TABLE}.pemntvty = 205
          ;;
        label: "Myanmar (Burma)"
      }

      when: {
        sql: ${TABLE}.pemntvty = 206
          ;;
        label: "Cambodia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 207
          ;;
        label: "China"
      }

      when: {
        sql: ${TABLE}.pemntvty = 208
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cyprus"
      }

      when: {
        sql: ${TABLE}.pemntvty = 209
          ;;
        label: "Hong Kong"
      }

      when: {
        sql: ${TABLE}.pemntvty = 210
          ;;
        label: "India"
      }

      when: {
        sql: ${TABLE}.pemntvty = 211
          ;;
        label: "Indonesia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 212
          ;;
        label: "Iran"
      }

      when: {
        sql: ${TABLE}.pemntvty = 213
          ;;
        label: "Iraq"
      }

      when: {
        sql: ${TABLE}.pemntvty = 214
          ;;
        label: "Israel"
      }

      when: {
        sql: ${TABLE}.pemntvty = 215
          ;;
        label: "Japan"
      }

      when: {
        sql: ${TABLE}.pemntvty = 216
          ;;
        label: "Jordan"
      }

      when: {
        sql: ${TABLE}.pemntvty = 217
          ;;
        label: "Korea"
      }

      when: {
        sql: (${TABLE}.pemntvty = 220
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 218
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "South Korea"
      }

      when: {
        sql: ${TABLE}.pemntvty = 222
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kuwait"
      }

      when: {
        sql: (${TABLE}.pemntvty = 223
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 221
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Laos"
      }

      when: {
        sql: (${TABLE}.pemntvty = 224
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 222
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lebanon"
      }

      when: {
        sql: (${TABLE}.pemntvty = 226
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 224
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Malaysia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 229
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Nepal"
      }

      when: {
        sql: (${TABLE}.pemntvty = 231
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 229
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pakistan"
      }

      when: {
        sql: (${TABLE}.pemntvty = 233
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 231
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Philippines"
      }

      when: {
        sql: (${TABLE}.pemntvty = 235
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 233
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Saudi Arabia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 236
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 234
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Singapore"
      }

      when: {
        sql: ${TABLE}.pemntvty = 238
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sri Lanka"
      }

      when: {
        sql: (${TABLE}.pemntvty = 239
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 237
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Syria"
      }

      when: {
        sql: (${TABLE}.pemntvty = 240
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 238
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Taiwan"
      }

      when: {
        sql: (${TABLE}.pemntvty = 242
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 239
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Thailand"
      }

      when: {
        sql: (${TABLE}.pemntvty = 243
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 240
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Turkey"
      }

      when: {
        sql: ${TABLE}.pemntvty = 246
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uzbekistan"
      }

      when: {
        sql: (${TABLE}.pemntvty = 247
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 242
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vietnam"
      }

      when: {
        sql: ${TABLE}.pemntvty = 248
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Yemen"
      }

      when: {
        sql: (${TABLE}.pemntvty = 249
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 245
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Asia,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 300
          ;;
        label: "Bermuda"
      }

      when: {
        sql: ${TABLE}.pemntvty = 301
          ;;
        label: "Canada"
      }

      when: {
        sql: ${TABLE}.pemntvty = 304
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "North America"
      }

      when: {
        sql: (${TABLE}.pemntvty = 303
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 315
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Mexico"
      }

      when: {
        sql: ${TABLE}.pemntvty = 310
          ;;
        label: "Belize"
      }

      when: {
        sql: ${TABLE}.pemntvty = 311
          ;;
        label: "Costa Rica"
      }

      when: {
        sql: ${TABLE}.pemntvty = 312
          ;;
        label: "El Salvador"
      }

      when: {
        sql: ${TABLE}.pemntvty = 313
          ;;
        label: "Guatemala"
      }

      when: {
        sql: ${TABLE}.pemntvty = 314
          ;;
        label: "Honduras"
      }

      when: {
        sql: (${TABLE}.pemntvty = 315
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 316
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nicaragua"
      }

      when: {
        sql: (${TABLE}.pemntvty = 316
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 317
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Panama"
      }

      when: {
        sql: ${TABLE}.pemntvty = 318
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Central America"
      }

      when: {
        sql: ${TABLE}.pemntvty = 321
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Antigua and Barbuda"
      }

      when: {
        sql: (${TABLE}.pemntvty = 323
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 333
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bahamas"
      }

      when: {
        sql: (${TABLE}.pemntvty = 324
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 334
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Barbados"
      }

      when: {
        sql: (${TABLE}.pemntvty = 327
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 337
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cuba"
      }

      when: {
        sql: (${TABLE}.pemntvty = 328
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 338
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominica"
      }

      when: {
        sql: (${TABLE}.pemntvty = 329
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 339
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominican Republic"
      }

      when: {
        sql: (${TABLE}.pemntvty = 330
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 340
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Grenada"
      }

      when: {
        sql: (${TABLE}.pemntvty = 332
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 342
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Haiti"
      }

      when: {
        sql: (${TABLE}.pemntvty = 333
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 343
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Jamaica"
      }

      when: {
        sql: ${TABLE}.pemntvty = 338
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Kitts-Nevis"
      }

      when: {
        sql: ${TABLE}.pemntvty = 339
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Lucia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 340
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Vincent and the Grenadines"
      }

      when: {
        sql: (${TABLE}.pemntvty = 341
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 351
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Trinidad and Tobago"
      }

      when: {
        sql: (${TABLE}.pemntvty = 343
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 353
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "West Indies,not specified"
      }

      when: {
        sql: (${TABLE}.pemntvty = 360
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 375
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Argentina"
      }

      when: {
        sql: (${TABLE}.pemntvty = 361
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 376
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bolivia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 362
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 377
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Brazil"
      }

      when: {
        sql: (${TABLE}.pemntvty = 363
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 378
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Chile"
      }

      when: {
        sql: (${TABLE}.pemntvty = 364
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 379
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Colombia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 365
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 380
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ecuador"
      }

      when: {
        sql: (${TABLE}.pemntvty = 368
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 383
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Guyana"
      }

      when: {
        sql: ${TABLE}.pemntvty = 369
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Paraguay"
      }

      when: {
        sql: (${TABLE}.pemntvty = 370
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 385
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Peru"
      }

      when: {
        sql: (${TABLE}.pemntvty = 372
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 387
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Uruguay"
      }

      when: {
        sql: (${TABLE}.pemntvty = 373
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 388
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Venezuela"
      }

      when: {
        sql: (${TABLE}.pemntvty = 374
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 389
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "South America,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 399
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Americas,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 400
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Algeria"
      }

      when: {
        sql: ${TABLE}.pemntvty = 407
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cameroon"
      }

      when: {
        sql: ${TABLE}.pemntvty = 408
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cape Verde"
      }

      when: {
        sql: (${TABLE}.pemntvty = 414
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 415
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Egypt"
      }

      when: {
        sql: (${TABLE}.pemntvty = 416
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 417
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ethiopia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 417
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Eritrea"
      }

      when: {
        sql: ${TABLE}.pemntvty = 421
          ;;
        label: "Ghana"
      }

      when: {
        sql: ${TABLE}.pemntvty = 427
          ;;
        label: "Kenya"
      }

      when: {
        sql: ${TABLE}.pemntvty = 429
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Liberia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 436
          ;;
        label: "Morocco"
      }

      when: {
        sql: ${TABLE}.pemntvty = 440
          ;;
        label: "Nigeria"
      }

      when: {
        sql: ${TABLE}.pemntvty = 444
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Senegal"
      }

      when: {
        sql: ${TABLE}.pemntvty = 447
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sierra Leone"
      }

      when: {
        sql: ${TABLE}.pemntvty = 448
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Somalia"
      }

      when: {
        sql: ${TABLE}.pemntvty = 449
          ;;
        label: "South Africa"
      }

      when: {
        sql: ${TABLE}.pemntvty = 451
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sudan"
      }

      when: {
        sql: ${TABLE}.pemntvty = 453
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tanzania"
      }

      when: {
        sql: ${TABLE}.pemntvty = 457
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uganda"
      }

      when: {
        sql: ${TABLE}.pemntvty = 461
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Zimbabwe"
      }

      when: {
        sql: ${TABLE}.pemntvty = 462
          ;;
        label: "Africa,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 468
          ;;
        label: "North Africa"
      }

      when: {
        sql: ${TABLE}.pemntvty = 501
          ;;
        label: "Australia"
      }

      when: {
        sql: (${TABLE}.pemntvty = 508
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 507
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fiji"
      }

      when: {
        sql: (${TABLE}.pemntvty = 515
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 514
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "New Zealand"
      }

      when: {
        sql: ${TABLE}.pemntvty = 523
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tonga"
      }

      when: {
        sql: ${TABLE}.pemntvty = 527
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Samoa"
      }

      when: {
        sql: (${TABLE}.pemntvty = 528
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.pemntvty = 527
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Oceania,not specified"
      }

      when: {
        sql: ${TABLE}.pemntvty = 555
          ;;
        label: "Other"
      }
    }
  }

  dimension: penatvty {
    label: "Native country of person"
    map_layer_name: countries

    case: {
      when: {
        sql: ${TABLE}.penatvty = 57
          ;;
        label: "United States of America"
      }

      when: {
        sql: ${TABLE}.penatvty = 66
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Guam"
      }

      when: {
        sql: (${TABLE}.penatvty = 73
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 72
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Puerto Rico"
      }

      when: {
        sql: ${TABLE}.penatvty = 78
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "U. S. Virgin Islands"
      }

      when: {
        sql: ${TABLE}.penatvty = 96
          ;;
        label: "Other U. S. Island Areas"
      }

      when: {
        sql: ${TABLE}.penatvty = 100
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Albania"
      }

      when: {
        sql: ${TABLE}.penatvty = 102
          ;;
        label: "Austria"
      }

      when: {
        sql: ${TABLE}.penatvty = 103
          ;;
        label: "Belgium"
      }

      when: {
        sql: ${TABLE}.penatvty = 104
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Bulgaria"
      }

      when: {
        sql: ${TABLE}.penatvty = 105
          ;;
        label: "Czechoslovakia"
      }

      when: {
        sql: ${TABLE}.penatvty = 106
          ;;
        label: "Denmark"
      }

      when: {
        sql: ${TABLE}.penatvty = 108
          ;;
        label: "Finland"
      }

      when: {
        sql: ${TABLE}.penatvty = 109
          ;;
        label: "France"
      }

      when: {
        sql: ${TABLE}.penatvty = 110
          ;;
        label: "Germany"
      }

      when: {
        sql: ${TABLE}.penatvty = 116
          ;;
        label: "Greece"
      }

      when: {
        sql: ${TABLE}.penatvty = 117
          ;;
        label: "Hungary"
      }

      when: {
        sql: ${TABLE}.penatvty = 119
          ;;
        label: "Ireland"
      }

      when: {
        sql: ${TABLE}.penatvty = 120
          ;;
        label: "Italy"
      }

      when: {
        sql: ${TABLE}.penatvty = 126
          ;;
        label: "Netherlands"
      }

      when: {
        sql: ${TABLE}.penatvty = 127
          ;;
        label: "Norway"
      }

      when: {
        sql: ${TABLE}.penatvty = 128
          ;;
        label: "Poland"
      }

      when: {
        sql: ${TABLE}.penatvty = 129
          ;;
        label: "Portugal"
      }

      when: {
        sql: ${TABLE}.penatvty = 130
          ;;
        label: "Azores"
      }

      when: {
        sql: ${TABLE}.penatvty = 132
          ;;
        label: "Romania"
      }

      when: {
        sql: ${TABLE}.penatvty = 134
          ;;
        label: "Spain"
      }

      when: {
        sql: ${TABLE}.penatvty = 136
          ;;
        label: "Sweden"
      }

      when: {
        sql: ${TABLE}.penatvty = 137
          ;;
        label: "Switzerland"
      }

      when: {
        sql: ${TABLE}.penatvty = 138
          ;;
        label: "United Kingdom"
      }

      when: {
        sql: ${TABLE}.penatvty = 139
          ;;
        label: "England"
      }

      when: {
        sql: ${TABLE}.penatvty = 140
          ;;
        label: "Scotland"
      }

      when: {
        sql: ${TABLE}.penatvty = 141
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Wales"
      }

      when: {
        sql: ${TABLE}.penatvty = 142
          ;;
        label: "Northern Ireland"
      }

      when: {
        sql: ${TABLE}.penatvty = 147
          ;;
        label: "Yugoslavia"
      }

      when: {
        sql: (${TABLE}.penatvty = 148
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 155
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Czech Republic"
      }

      when: {
        sql: (${TABLE}.penatvty = 149
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 156
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Slovakia"
      }

      when: {
        sql: ${TABLE}.penatvty = 150
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Bosnia & Herzegovina"
      }

      when: {
        sql: ${TABLE}.penatvty = 151
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Croatia"
      }

      when: {
        sql: ${TABLE}.penatvty = 152
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Macedonia"
      }

      when: {
        sql: ${TABLE}.penatvty = 154
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Serbia"
      }

      when: {
        sql: (${TABLE}.penatvty = 156
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 183
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Latvia"
      }

      when: {
        sql: (${TABLE}.penatvty = 157
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 184
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lithuania"
      }

      when: {
        sql: (${TABLE}.penatvty = 158
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 185
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armenia"
      }

      when: {
        sql: ${TABLE}.penatvty = 159
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Azerbaijan"
      }

      when: {
        sql: ${TABLE}.penatvty = 160
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Belarus"
      }

      when: {
        sql: ${TABLE}.penatvty = 161
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Georgia"
      }

      when: {
        sql: ${TABLE}.penatvty = 162
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Moldova"
      }

      when: {
        sql: (${TABLE}.penatvty = 163
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 192
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Russia"
      }

      when: {
        sql: (${TABLE}.penatvty = 164
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 195
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ukraine"
      }

      when: {
        sql: (${TABLE}.penatvty = 165
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 180
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "USSR"
      }

      when: {
        sql: (${TABLE}.penatvty = 166
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 148
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Europe,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 167
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kosovo"
      }

      when: {
        sql: ${TABLE}.penatvty = 200
          ;;
        label: "Afghanistan"
      }

      when: {
        sql: ${TABLE}.penatvty = 202
          ;;
        label: "Bangladesh"
      }

      when: {
        sql: ${TABLE}.penatvty = 205
          ;;
        label: "Myanmar (Burma)"
      }

      when: {
        sql: ${TABLE}.penatvty = 206
          ;;
        label: "Cambodia"
      }

      when: {
        sql: ${TABLE}.penatvty = 207
          ;;
        label: "China"
      }

      when: {
        sql: ${TABLE}.penatvty = 208
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cyprus"
      }

      when: {
        sql: ${TABLE}.penatvty = 209
          ;;
        label: "Hong Kong"
      }

      when: {
        sql: ${TABLE}.penatvty = 210
          ;;
        label: "India"
      }

      when: {
        sql: ${TABLE}.penatvty = 211
          ;;
        label: "Indonesia"
      }

      when: {
        sql: ${TABLE}.penatvty = 212
          ;;
        label: "Iran"
      }

      when: {
        sql: ${TABLE}.penatvty = 213
          ;;
        label: "Iraq"
      }

      when: {
        sql: ${TABLE}.penatvty = 214
          ;;
        label: "Israel"
      }

      when: {
        sql: ${TABLE}.penatvty = 215
          ;;
        label: "Japan"
      }

      when: {
        sql: ${TABLE}.penatvty = 216
          ;;
        label: "Jordan"
      }

      when: {
        sql: ${TABLE}.penatvty = 217
          ;;
        label: "Korea"
      }

      when: {
        sql: (${TABLE}.penatvty = 220
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 218
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "South Korea"
      }

      when: {
        sql: ${TABLE}.penatvty = 222
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Kuwait"
      }

      when: {
        sql: (${TABLE}.penatvty = 223
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 221
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Laos"
      }

      when: {
        sql: (${TABLE}.penatvty = 224
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 222
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lebanon"
      }

      when: {
        sql: (${TABLE}.penatvty = 226
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 224
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Malaysia"
      }

      when: {
        sql: ${TABLE}.penatvty = 229
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Nepal"
      }

      when: {
        sql: (${TABLE}.penatvty = 231
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 229
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pakistan"
      }

      when: {
        sql: (${TABLE}.penatvty = 233
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 231
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Philippines"
      }

      when: {
        sql: (${TABLE}.penatvty = 235
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 233
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Saudi Arabia"
      }

      when: {
        sql: (${TABLE}.penatvty = 236
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 234
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Singapore"
      }

      when: {
        sql: ${TABLE}.penatvty = 238
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sri Lanka"
      }

      when: {
        sql: (${TABLE}.penatvty = 239
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 237
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Syria"
      }

      when: {
        sql: (${TABLE}.penatvty = 240
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 238
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Taiwan"
      }

      when: {
        sql: (${TABLE}.penatvty = 242
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 239
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Thailand"
      }

      when: {
        sql: (${TABLE}.penatvty = 243
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 240
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Turkey"
      }

      when: {
        sql: ${TABLE}.penatvty = 246
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uzbekistan"
      }

      when: {
        sql: (${TABLE}.penatvty = 247
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 242
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vietnam"
      }

      when: {
        sql: ${TABLE}.penatvty = 248
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Yemen"
      }

      when: {
        sql: (${TABLE}.penatvty = 249
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 245
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Asia,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 300
          ;;
        label: "Bermuda"
      }

      when: {
        sql: ${TABLE}.penatvty = 301
          ;;
        label: "Canada"
      }

      when: {
        sql: ${TABLE}.penatvty = 304
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "North America"
      }

      when: {
        sql: (${TABLE}.penatvty = 303
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 315
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Mexico"
      }

      when: {
        sql: ${TABLE}.penatvty = 310
          ;;
        label: "Belize"
      }

      when: {
        sql: ${TABLE}.penatvty = 311
          ;;
        label: "Costa Rica"
      }

      when: {
        sql: ${TABLE}.penatvty = 312
          ;;
        label: "El Salvador"
      }

      when: {
        sql: ${TABLE}.penatvty = 313
          ;;
        label: "Guatemala"
      }

      when: {
        sql: ${TABLE}.penatvty = 314
          ;;
        label: "Honduras"
      }

      when: {
        sql: (${TABLE}.penatvty = 315
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 316
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nicaragua"
      }

      when: {
        sql: (${TABLE}.penatvty = 316
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 317
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Panama"
      }

      when: {
        sql: ${TABLE}.penatvty = 318
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Central America"
      }

      when: {
        sql: ${TABLE}.penatvty = 321
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Antigua and Barbuda"
      }

      when: {
        sql: (${TABLE}.penatvty = 323
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 333
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bahamas"
      }

      when: {
        sql: (${TABLE}.penatvty = 324
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 334
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Barbados"
      }

      when: {
        sql: (${TABLE}.penatvty = 327
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 337
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cuba"
      }

      when: {
        sql: (${TABLE}.penatvty = 328
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 338
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominica"
      }

      when: {
        sql: (${TABLE}.penatvty = 329
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 339
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dominican Republic"
      }

      when: {
        sql: (${TABLE}.penatvty = 330
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 340
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Grenada"
      }

      when: {
        sql: (${TABLE}.penatvty = 332
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 342
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Haiti"
      }

      when: {
        sql: (${TABLE}.penatvty = 333
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 343
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Jamaica"
      }

      when: {
        sql: ${TABLE}.penatvty = 338
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Kitts-Nevis"
      }

      when: {
        sql: ${TABLE}.penatvty = 339
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Lucia"
      }

      when: {
        sql: ${TABLE}.penatvty = 340
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "St. Vincent and the Grenadines"
      }

      when: {
        sql: (${TABLE}.penatvty = 341
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 351
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Trinidad and Tobago"
      }

      when: {
        sql: (${TABLE}.penatvty = 343
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 353
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "West Indies,not specified"
      }

      when: {
        sql: (${TABLE}.penatvty = 360
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 375
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Argentina"
      }

      when: {
        sql: (${TABLE}.penatvty = 361
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 376
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bolivia"
      }

      when: {
        sql: (${TABLE}.penatvty = 362
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 377
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Brazil"
      }

      when: {
        sql: (${TABLE}.penatvty = 363
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 378
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Chile"
      }

      when: {
        sql: (${TABLE}.penatvty = 364
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 379
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Colombia"
      }

      when: {
        sql: (${TABLE}.penatvty = 365
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 380
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ecuador"
      }

      when: {
        sql: (${TABLE}.penatvty = 368
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 383
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Guyana"
      }

      when: {
        sql: ${TABLE}.penatvty = 369
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Paraguay"
      }

      when: {
        sql: (${TABLE}.penatvty = 370
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 385
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Peru"
      }

      when: {
        sql: (${TABLE}.penatvty = 372
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 387
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Uruguay"
      }

      when: {
        sql: (${TABLE}.penatvty = 373
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 388
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Venezuela"
      }

      when: {
        sql: (${TABLE}.penatvty = 374
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 389
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "South America,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 399
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Americas,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 400
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Algeria"
      }

      when: {
        sql: ${TABLE}.penatvty = 407
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cameroon"
      }

      when: {
        sql: ${TABLE}.penatvty = 408
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Cape Verde"
      }

      when: {
        sql: (${TABLE}.penatvty = 414
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 415
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Egypt"
      }

      when: {
        sql: (${TABLE}.penatvty = 416
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 417
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ethiopia"
      }

      when: {
        sql: ${TABLE}.penatvty = 417
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Eritrea"
      }

      when: {
        sql: ${TABLE}.penatvty = 421
          ;;
        label: "Ghana"
      }

      when: {
        sql: ${TABLE}.penatvty = 427
          ;;
        label: "Kenya"
      }

      when: {
        sql: ${TABLE}.penatvty = 429
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Liberia"
      }

      when: {
        sql: ${TABLE}.penatvty = 436
          ;;
        label: "Morocco"
      }

      when: {
        sql: ${TABLE}.penatvty = 440
          ;;
        label: "Nigeria"
      }

      when: {
        sql: ${TABLE}.penatvty = 444
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Senegal"
      }

      when: {
        sql: ${TABLE}.penatvty = 447
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sierra Leone"
      }

      when: {
        sql: ${TABLE}.penatvty = 448
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Somalia"
      }

      when: {
        sql: ${TABLE}.penatvty = 449
          ;;
        label: "South Africa"
      }

      when: {
        sql: ${TABLE}.penatvty = 451
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Sudan"
      }

      when: {
        sql: ${TABLE}.penatvty = 453
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tanzania"
      }

      when: {
        sql: ${TABLE}.penatvty = 457
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Uganda"
      }

      when: {
        sql: ${TABLE}.penatvty = 461
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Zimbabwe"
      }

      when: {
        sql: ${TABLE}.penatvty = 462
          ;;
        label: "Africa,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 468
          ;;
        label: "North Africa"
      }

      when: {
        sql: ${TABLE}.penatvty = 501
          ;;
        label: "Australia"
      }

      when: {
        sql: (${TABLE}.penatvty = 508
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 507
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fiji"
      }

      when: {
        sql: (${TABLE}.penatvty = 515
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 514
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "New Zealand"
      }

      when: {
        sql: ${TABLE}.penatvty = 523
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Tonga"
      }

      when: {
        sql: ${TABLE}.penatvty = 527
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008')
           ;;
        label: "Samoa"
      }

      when: {
        sql: (${TABLE}.penatvty = 528
          AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008'))
          OR
          (${TABLE}.penatvty = 527
          AND ${TABLE}.src_table in ('census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Oceania,not specified"
      }

      when: {
        sql: ${TABLE}.penatvty = 555
          ;;
        label: "Other"
      }
    }
  }

  dimension: prdasian {
    label: "Detailed Asian subgroup"
  }

  dimension: prdthsp {
    label: "Detailed Hispanic origin"

    case: {
      when: {
        sql: ${TABLE}.prdthsp = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Mexican"
      }

      when: {
        sql: ${TABLE}.prdthsp = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Puerto Rican"
      }

      when: {
        sql: ${TABLE}.prdthsp = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Cuban"
      }

      when: {
        sql: ${TABLE}.prdthsp = 4
          AND ${TABLE}.src_table in ('census_2014')
           ;;
        label: "Dominican"
      }

      when: {
        sql: ${TABLE}.prdthsp = 5
          AND ${TABLE}.src_table in ('census_2014')
           ;;
        label: "Salvadoran"
      }

      when: {
        sql: ${TABLE}.prdthsp = 6
          AND ${TABLE}.src_table in ('census_2014')
           ;;
        label: "Central American, excluding Salvadoran"
      }

      when: {
        sql: ${TABLE}.prdthsp = 7
          AND ${TABLE}.src_table in ('census_2014')
           ;;
        label: "South American"
      }

      when: {
        sql: ${TABLE}.prdthsp = 4
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Central/South American"
      }

      when: {
        sql: (${TABLE}.prdthsp = 8
          AND ${TABLE}.src_table in ('census_2014'))
          OR
          (${TABLE}.prdthsp = 5
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "Other Hispanic"
      }
    }
  }

  dimension: peafever_yesno {
    label: "Ever serve active duty in military (Yes/No)"
    view_label: "Demographic Variables"
    type: string
    sql: CASE
      WHEN (${TABLE}.puafever = 1
        AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
        OR (${TABLE}.peafever = 1
        AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      THEN 'Yes'
      WHEN (${TABLE}.puafever = 2
        AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
        OR (${TABLE}.peafever = 2
        AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      THEN 'No'
      END
       ;;
  }

  dimension: peafwhn1 {
    hidden: yes
    label: "When was your period of active duty (#1)"

    case: {
      when: {
        sql: ${TABLE}.peafwhn1 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "September 2001 or later"
      }

      when: {
        sql: ${TABLE}.peafwhn1 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "August 1990 to August 2001"
      }

      when: {
        sql: ${TABLE}.peafwhn1 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "May 1975 to July 1990"
      }

      when: {
        sql: (${TABLE}.peafwhn1 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
          OR
          (${TABLE}.peafwhen = 1
            AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vietnam Era (August 1964 to April 1975)"
      }

      when: {
        sql: ${TABLE}.peafwhn1 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "February 1955 to July 1964"
      }

      when: {
        sql: (${TABLE}.peafwhn1 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
          OR
          (${TABLE}.peafwhen = 2
            AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Korean War (July 1950) to January 1955)"
      }

      when: {
        sql: ${TABLE}.peafwhn1 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "January 1947 to June 1950"
      }

      when: {
        sql: (${TABLE}.peafwhn1 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
          OR
          (${TABLE}.peafwhen = 3
            AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "World War II (December 1941 to December 1946)"
      }

      when: {
        sql: ${TABLE}.peafwhn1 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
           ;;
        label: "November 1941 or earlier"
      }

      when: {
        sql: ${TABLE}.peafwhen = 4
          AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "World War I (4/17-11/18)"
      }

      when: {
        sql: ${TABLE}.peafwhen = 5
          AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Other Service (all Other Periods)"
      }

      else: "Nonveteran"
    }
  }

  dimension: serve_after_911 {
    hidden: yes
    label: "Did you serve in the military after 9/11?"
    view_label: "Demographic Labels"
    sql: CASE WHEN
      ${TABLE}.peafwhn1 = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
      OR
      ${TABLE}.peafwhn2 = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
      OR
      ${TABLE}.peafwhn3 = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
      OR
      ${TABLE}.peafwhn4 = 1
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006')
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: serve_vietnam {
    hidden: yes
    label: "Did you serve in the Vietnam Era?"
    view_label: "Demographic Labels"
    sql: CASE WHEN
      (${TABLE}.peafwhn1 = 4
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn2 = 4
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn3 = 4
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn4 = 4
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhen = 1
      AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: serve_korea {
    hidden: yes
    label: "Did you serve during the Korean War?"
    view_label: "Demographic Labels"
    sql: CASE WHEN
      (${TABLE}.peafwhn1 = 6
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn2 = 6
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn3 = 6
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn4 = 6
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhen = 2
      AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: serve_ww2 {
    hidden: yes
    label: "Did you serve during World War 2?"
    view_label: "Demographic Labels"
    sql: CASE WHEN
      (${TABLE}.peafwhn1 = 8
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn2 = 8
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn3 = 8
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhn4 = 8
      AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006'))
      OR
      (${TABLE}.peafwhen = 3
      AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: serve_ww1 {
    hidden: yes
    label: "Did you serve during World War 1?"
    view_label: "Demographic Labels"
    sql: CASE WHEN
      ${TABLE}.peafwhen = 4
      AND ${TABLE}.src_table in ('census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
      THEN 'Yes'
      ELSE 'No'
      END
       ;;
  }

  dimension: peafwhn2 {
    hidden: yes
    label: "When was your period of active duty (#2)"
  }

  dimension: peafwhn3 {
    hidden: yes
    label: "When was your period of active duty (#3)"
  }

  dimension: peafwhn4 {
    hidden: yes
    label: "When was your period of active duty (#4)"
  }

  dimension: pems123 {
    hidden: yes
    label: "Was Master's program 1, 2, or 3 years"
  }

  dimension: prnmchld {
    label: "How many of your own children are under 18"
    view_label: "Demographic Variables"
    type: number
    sql: CASE WHEN ${TABLE}.prnmchld between 0 AND 99 THEN ${TABLE}.prnmchld END ;;
  }

  dimension: prpertyp {
    hidden: yes
    label: "Person type"
    description: "Child or Adult; Civilian or Military"
  }

  dimension: prchld {
    hidden: yes
    label: "Ages of children by age group(s)"
  }

  dimension: prinuyer {
    hidden: yes
    label: "Year of immigration"
  }

  dimension: prcitshp {
    hidden: yes
    label: "United States citizenship group"
  }

  dimension: gestcen {
    label: "State"
    map_layer_name: us_states

    case: {
      when: {
        sql: (${TABLE}.gestcen = 11
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 23
           ;;
        label: "ME"
      }

      when: {
        sql: (${TABLE}.gestcen = 12
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 33
           ;;
        label: "NH"
      }

      when: {
        sql: (${TABLE}.gestcen = 13
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 50
           ;;
        label: "VT"
      }

      when: {
        sql: (${TABLE}.gestcen = 14
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 25
           ;;
        label: "MA"
      }

      when: {
        sql: (${TABLE}.gestcen = 15
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 44
           ;;
        label: "RI"
      }

      when: {
        sql: (${TABLE}.gestcen = 16
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 9
           ;;
        label: "CT"
      }

      when: {
        sql: (${TABLE}.gestcen = 21
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 36
           ;;
        label: "NY"
      }

      when: {
        sql: (${TABLE}.gestcen = 22
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 34
           ;;
        label: "NJ"
      }

      when: {
        sql: (${TABLE}.gestcen = 23
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 42
           ;;
        label: "PA"
      }

      when: {
        sql: (${TABLE}.gestcen = 31
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 39
           ;;
        label: "OH"
      }

      when: {
        sql: (${TABLE}.gestcen = 32
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 18
           ;;
        label: "IN"
      }

      when: {
        sql: (${TABLE}.gestcen = 33
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 17
           ;;
        label: "IL"
      }

      when: {
        sql: (${TABLE}.gestcen = 34
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 26
           ;;
        label: "MI"
      }

      when: {
        sql: (${TABLE}.gestcen = 35
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 55
           ;;
        label: "WI"
      }

      when: {
        sql: (${TABLE}.gestcen = 41
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 27
           ;;
        label: "MN"
      }

      when: {
        sql: (${TABLE}.gestcen = 42
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 19
           ;;
        label: "IA"
      }

      when: {
        sql: (${TABLE}.gestcen = 43
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 29
           ;;
        label: "MO"
      }

      when: {
        sql: (${TABLE}.gestcen = 44
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 38
           ;;
        label: "ND"
      }

      when: {
        sql: (${TABLE}.gestcen = 45
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 46
           ;;
        label: "SD"
      }

      when: {
        sql: (${TABLE}.gestcen = 46
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 31
           ;;
        label: "NE"
      }

      when: {
        sql: (${TABLE}.gestcen = 47
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 20
           ;;
        label: "KS"
      }

      when: {
        sql: (${TABLE}.gestcen = 51
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 10
           ;;
        label: "DE"
      }

      when: {
        sql: (${TABLE}.gestcen = 52
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 24
           ;;
        label: "MD"
      }

      when: {
        sql: (${TABLE}.gestcen = 53
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 11
           ;;
        label: "DC"
      }

      when: {
        sql: (${TABLE}.gestcen = 54
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 51
           ;;
        label: "VA"
      }

      when: {
        sql: (${TABLE}.gestcen = 55
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 54
           ;;
        label: "WV"
      }

      when: {
        sql: (${TABLE}.gestcen = 56
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 37
           ;;
        label: "NC"
      }

      when: {
        sql: (${TABLE}.gestcen = 57
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 45
           ;;
        label: "SC"
      }

      when: {
        sql: (${TABLE}.gestcen = 58
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 13
           ;;
        label: "GA"
      }

      when: {
        sql: (${TABLE}.gestcen = 59
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 12
           ;;
        label: "FL"
      }

      when: {
        sql: (${TABLE}.gestcen = 61
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 21
           ;;
        label: "KY"
      }

      when: {
        sql: (${TABLE}.gestcen = 62
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 47
           ;;
        label: "TN"
      }

      when: {
        sql: (${TABLE}.gestcen = 63
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 1
           ;;
        label: "AL"
      }

      when: {
        sql: (${TABLE}.gestcen = 64
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 28
           ;;
        label: "MS"
      }

      when: {
        sql: (${TABLE}.gestcen = 71
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 5
           ;;
        label: "AR"
      }

      when: {
        sql: (${TABLE}.gestcen = 72
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 22
           ;;
        label: "LA"
      }

      when: {
        sql: (${TABLE}.gestcen = 73
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 40
           ;;
        label: "OK"
      }

      when: {
        sql: (${TABLE}.gestcen = 74
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 48
           ;;
        label: "TX"
      }

      when: {
        sql: (${TABLE}.gestcen = 81
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 30
           ;;
        label: "MT"
      }

      when: {
        sql: (${TABLE}.gestcen = 82
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 16
           ;;
        label: "ID"
      }

      when: {
        sql: (${TABLE}.gestcen = 83
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 56
           ;;
        label: "WY"
      }

      when: {
        sql: (${TABLE}.gestcen = 84
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 8
           ;;
        label: "CO"
      }

      when: {
        sql: (${TABLE}.gestcen = 85
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 35
           ;;
        label: "NM"
      }

      when: {
        sql: (${TABLE}.gestcen = 86
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 4
           ;;
        label: "AZ"
      }

      when: {
        sql: (${TABLE}.gestcen = 87
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 49
           ;;
        label: "UT"
      }

      when: {
        sql: (${TABLE}.gestcen = 88
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 32
           ;;
        label: "NV"
      }

      when: {
        sql: (${TABLE}.gestcen = 91
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 53
           ;;
        label: "WA"
      }

      when: {
        sql: (${TABLE}.gestcen = 92
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 41
           ;;
        label: "OR"
      }

      when: {
        sql: (${TABLE}.gestcen = 93
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 6
           ;;
        label: "CA"
      }

      when: {
        sql: (${TABLE}.gestcen = 94
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 2
           ;;
        label: "AK"
      }

      when: {
        sql: (${TABLE}.gestcen = 95
          AND ${TABLE}.src_table in ('census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004', 'census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
          OR
          ${cps_2014_geo.gestfips} = 15
           ;;
        label: "HI"
      }
    }
  }

  dimension: us_regions {
    label: "US Regions"
    type: string

    case: {
      when: {
        sql: ${gestcen} IN ('CT','ME','MA','NH','RI','VT')
          ;;
        label: "New England"
      }

      when: {
        sql: ${gestcen} IN ('DE','DC','MD','NJ','NY','PA')
          ;;
        label: "Mideast"
      }

      when: {
        sql: ${gestcen} IN ('IL','IN','MI','OH','WI')
          ;;
        label: "Great Lakes"
      }

      when: {
        sql: ${gestcen} IN ('IA','KS','MO','MN','NE','ND','SD')
          ;;
        label: "Plains"
      }

      when: {
        sql: ${gestcen} IN ('AL','AR','FL','GA','KY','LA','MS','NC','SC','TN','VA','WV')
          ;;
        label: "Southeast"
      }

      when: {
        sql: ${gestcen} IN ('AZ','NM','OK','TX')
          ;;
        label: "Southwest"
      }

      when: {
        sql: ${gestcen} IN ('CO','ID','MT','UT','WY')
          ;;
        label: "Rocky Mountain"
      }

      when: {
        sql: ${gestcen} IN ('AK','CA','HI','NV','OR','WA')
          ;;
        label: "Far  West"
      }
    }
  }

  filter: state_select {
    hidden: yes
    view_label: "State comparisons"
    suggest_explore: cps_clean
    suggest_dimension: cps_clean.gestcen
    full_suggestions: yes
  }

  filter: region_select {
    hidden: yes
    view_label: "Region comparisons"
    suggest_explore: cps_clean
    suggest_dimension: cps_clean.us_regions
    full_suggestions: yes
  }

  dimension: state_comparitor {
    hidden: yes
    view_label: "State comparisons"
    description: "Use in conjunction with state select filter to compare to other states"
    sql: CASE
        WHEN {% condition state_select %} ${gestcen} {% endcondition %}
          THEN  ${gestcen}
        WHEN {% condition region_select %} ${us_regions} {% endcondition %}
          THEN CONCAT('Rest of ', ${us_regions})
      ELSE 'Rest of US'
      END
       ;;
  }

  dimension: msa_size {
    label: "Metropolitan Statistical Area size"
    view_label: "Geography Variables"
    type: string

    case: {
      when: {
        sql: (${TABLE}.gtcbsasz = 0
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 0
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not Identified or Non-Metropolitan"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "100,000 - 249,999"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 3
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "250,000 - 499,999"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 4
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "500,000 - 999,999"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 5
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "1,000,000 - 2,499,999"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 6
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "2,500,000 - 4,999,999"
      }

      when: {
        sql: (${TABLE}.gtcbsasz = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.gtmsasz = 7
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "5,000,000+"
      }
    }
  }

  dimension: peernhro {
    hidden: yes
    label: "# hours usually worked weekly (for workers paid hourly)"
    view_label: "Earnings Variables"
    type: tier
    tiers: [
      0,
      10,
      20,
      30,
      40,
      50
    ]
    sql: CASE
        WHEN ${peernper} = 'Hourly'
        THEN ${TABLE}.peernhro
        ELSE NULL
      END
       ;;
  }

  dimension: peernwkp {
    hidden: yes
    label: "# paid weeks per year (for workers paid hourly/annually)"
    view_label: "Earnings Variables"
    type: tier
    tiers: [
      1,
      8,
      16,
      24,
      32,
      40,
      48
    ]
    sql: CASE WHEN ${TABLE}.peernwkp between 1 AND 52 THEN ${TABLE}.peernwkp END ;;
  }

  dimension: pternh2 {
    label: "Hourly pay rate at main job (hourly workers)"
    sql: CASE WHEN ${TABLE}.pternh2 between 0.0 AND 99.99 THEN ${TABLE}.pternh2 END ;;
  }

  dimension: prwernal {
    hidden: yes
  }

  dimension: peernvr1 {
    hidden: yes
  }

  dimension: peernvr3 {
    hidden: yes
  }

  dimension: puernvr4 {
    hidden: yes
  }

  dimension: prerelg {
    hidden: yes
  }

  dimension: peernuot {
    hidden: yes
  }

  dimension: prhernal {
    hidden: yes
  }

  dimension: ptwk {
    hidden: yes
  }

  dimension: huprscnt {
    hidden: yes
  }

  dimension: huprscnt_census_1998 {
    hidden: yes
  }

  dimension: huprscnt_census_1996 {
    hidden: yes
  }

  dimension: huprscnt_census_1994 {
    hidden: yes
  }

  dimension: huprscnt_census_2000 {
    hidden: yes
  }

  dimension: huprscnt_census_2002 {
    hidden: yes
  }

  dimension: family_income {
    label: "Total family income in past 12 months"
    view_label: "Earnings Variables"
    type: string

    case: {
      when: {
        sql: ${TABLE}.hufaminc = -3
          ;;
        label: "Refused"
      }

      when: {
        sql: ${TABLE}.hufaminc = -2
          ;;
        label: "Don't Know"
      }

      when: {
        sql: ${TABLE}.hufaminc = -1
          ;;
        label: "Blank"
      }

      when: {
        sql: ${TABLE}.hufaminc = 1 OR ${TABLE}.hefaminc = 1
          ;;
        label: "Less Than $5,000"
      }

      when: {
        sql: ${TABLE}.hufaminc = 2 OR ${TABLE}.hefaminc = 2
          ;;
        label: "5,000 To 7,499"
      }

      when: {
        sql: ${TABLE}.hufaminc = 3 OR ${TABLE}.hefaminc = 3
          ;;
        label: "7,500 To 9,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 4 OR ${TABLE}.hefaminc = 4
          ;;
        label: "10,000 To 12,499"
      }

      when: {
        sql: ${TABLE}.hufaminc = 5 OR ${TABLE}.hefaminc = 5
          ;;
        label: "12,500 To 14,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 6 OR ${TABLE}.hefaminc = 6
          ;;
        label: "15,000 To 19,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 7 OR ${TABLE}.hefaminc = 7
          ;;
        label: "20,000 To 24,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 8 OR ${TABLE}.hefaminc = 8
          ;;
        label: "25,000 To 29,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 9 OR ${TABLE}.hefaminc = 9
          ;;
        label: "30,000 To 34,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 10 OR ${TABLE}.hefaminc = 10
          ;;
        label: "35,000 To 39,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 11 OR ${TABLE}.hefaminc = 11
          ;;
        label: "40,000 To 49,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 12 OR ${TABLE}.hefaminc = 12
          ;;
        label: "50,000 To 59,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 13 OR ${TABLE}.hefaminc = 13
          ;;
        label: "60,000 To 74,999"
      }

      when: {
        sql: ${TABLE}.hufaminc = 14
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "75,000 Or More"
      }

      when: {
        sql: (${TABLE}.hefaminc = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          OR
          (${TABLE}.hufaminc = 14
          AND ${TABLE}.src_table in ('census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "75,000 To 99,999"
      }

      when: {
        sql: (${TABLE}.hefaminc = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          OR
          (${TABLE}.hufaminc = 15
          AND ${TABLE}.src_table in ('census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "100,000 To 149,999"
      }

      when: {
        sql: (${TABLE}.hefaminc = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010'))
          OR
          (${TABLE}.hufaminc = 16
          AND ${TABLE}.src_table in ('census_2008', 'census_2006', 'census_2004'))
           ;;
        label: "150,000 or More"
      }
    }
  }

  dimension: peio1cow {
    label: "Class of worker"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.peio1cow in (-1,127) OR ${TABLE}.peio1cow is NULL
          ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.peio1cow = 1
          ;;
        label: "Government - Federal"
      }

      when: {
        sql: ${TABLE}.peio1cow = 2
          ;;
        label: "Government - State"
      }

      when: {
        sql: ${TABLE}.peio1cow = 3
          ;;
        label: "Government - Local"
      }

      when: {
        sql: ${TABLE}.peio1cow = 4
          ;;
        label: "Private, For Profit"
      }

      when: {
        sql: ${TABLE}.peio1cow = 5
          ;;
        label: "Private, Nonprofit"
      }

      when: {
        sql: ${TABLE}.peio1cow = 6
          ;;
        label: "Self-Employed, Incorporated"
      }

      when: {
        sql: ${TABLE}.peio1cow = 7
          ;;
        label: "Self-Employed, Unincorporated"
      }

      when: {
        sql: ${TABLE}.peio1cow = 8
          ;;
        label: "Without Pay"
      }
    }
  }

  dimension: peio2cow {
    hidden: yes
    label: "Class of worker"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.peio2cow in (-1,127) OR ${TABLE}.peio1cow is NULL
          ;;
        label: "Not in Universe"
      }

      when: {
        sql: ${TABLE}.peio2cow = 1
          ;;
        label: "Government - Federal"
      }

      when: {
        sql: ${TABLE}.peio2cow = 2
          ;;
        label: "Government - State"
      }

      when: {
        sql: ${TABLE}.peio2cow = 3
          ;;
        label: "Government - Local"
      }

      when: {
        sql: ${TABLE}.peio2cow = 4
          ;;
        label: "Private, For Profit"
      }

      when: {
        sql: ${TABLE}.peio2cow = 5
          ;;
        label: "Private, Nonprofit"
      }

      when: {
        sql: ${TABLE}.peio2cow = 6
          ;;
        label: "Self-Employed, Incorporated"
      }

      when: {
        sql: ${TABLE}.peio2cow = 7
          ;;
        label: "Self-Employed, Unincorporated"
      }

      when: {
        sql: ${TABLE}.peio2cow = 8
          ;;
        label: "Without Pay"
      }
    }
  }

  dimension: prcowpg {
    label: "Class of worker (private/government)"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prcowpg in (-1, 127)
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prcowpg = 1
          ;;
        label: "Private"
      }

      when: {
        sql: ${TABLE}.prcowpg = 2
          ;;
        label: "Government"
      }
    }
  }

  dimension: prcow1 {
    label: "Class of worker-recode"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prcow1 in (-1, 127)
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prcow1 = 1
          ;;
        label: "Federal govt"
      }

      when: {
        sql: ${TABLE}.prcow1 = 2
          ;;
        label: "State govt"
      }

      when: {
        sql: ${TABLE}.prcow1 = 3
          ;;
        label: "Local govt"
      }

      when: {
        sql: ${TABLE}.prcow1 = 4
          ;;
        label: "Private (incl. self-employed incorp.)"
      }

      when: {
        sql: ${TABLE}.prcow1 = 5
          ;;
        label: "Self-employed, unincorp."
      }

      when: {
        sql: ${TABLE}.prcow1 = 6
          ;;
        label: "Without pay"
      }
    }
  }

  dimension: prcow2 {
    hidden: yes
    label: "Class of worker-recode"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.prcow2 in (-1, 127)
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prcow2 = 1
          ;;
        label: "Federal govt"
      }

      when: {
        sql: ${TABLE}.prcow2 = 2
          ;;
        label: "State govt"
      }

      when: {
        sql: ${TABLE}.prcow2 = 3
          ;;
        label: "Local govt"
      }

      when: {
        sql: ${TABLE}.prcow2 = 4
          ;;
        label: "Private (incl. self-employed incorp.)"
      }

      when: {
        sql: ${TABLE}.prcow2 = 5
          ;;
        label: "Self-employed, unincorp."
      }

      when: {
        sql: ${TABLE}.prcow2 = 6
          ;;
        label: "Without pay"
      }
    }
  }

  dimension: prdtcow1 {
    label: "Detailed class of worker"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prdtcow1 in (-1, 127)
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 1
          ;;
        label: "Agri.,wage & Salary,private"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 2
          ;;
        label: "Agri,wage & Salary, Government"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 3
          ;;
        label: "Agri., Self-Employed"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 4
          ;;
        label: "Agri., Unpaid"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 5
          ;;
        label: "Nonag,ws,private,private Hhlds"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 6
          ;;
        label: "Nonag,ws,priv.,other Private"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 7
          ;;
        label: "Nonag,ws,govt,federal"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 8
          ;;
        label: "Nonag,ws,govt,state"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 9
          ;;
        label: "Nonag,ws,govt,local"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 10
          ;;
        label: "Nonag, Self-Employed"
      }

      when: {
        sql: ${TABLE}.prdtcow1 = 11
          ;;
        label: "Nonag, Unpaid"
      }
    }
  }

  dimension: prdtcow2 {
    hidden: yes
    label: "Detailed class of worker"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.prdtcow2 in (-1, 127)
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 1
          ;;
        label: "Agri.,wage & Salary,private"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 2
          ;;
        label: "Agri,wage & Salary, Government"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 3
          ;;
        label: "Agri., Self-Employed"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 4
          ;;
        label: "Agri., Unpaid"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 5
          ;;
        label: "Nonag,ws,private,private Hhlds"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 6
          ;;
        label: "Nonag,ws,priv.,other Private"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 7
          ;;
        label: "Nonag,ws,govt,federal"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 8
          ;;
        label: "Nonag,ws,govt,state"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 9
          ;;
        label: "Nonag,ws,govt,local"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 10
          ;;
        label: "Nonag, Self-Employed"
      }

      when: {
        sql: ${TABLE}.prdtcow2 = 11
          ;;
        label: "Nonag, Unpaid"
      }
    }
  }

  dimension: prsjmj {
    label: "Has one job or multiple jobs?"

    case: {
      when: {
        sql: ${TABLE}.prsjmj = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prsjmj = 1
          ;;
        label: "Single jobholder"
      }

      when: {
        sql: ${TABLE}.prsjmj = 2
          ;;
        label: "Multiple jobholder"
      }
    }
  }

  dimension: primind1 {
    label: "Detailed industry (22 groups)"
    # group_label: "Main job"
  }

  dimension: primind2 {
    hidden: yes
    label: "Detailed industry (22 groups)"
    group_label: "Second job"
  }

  dimension: prdtind1 {
    label: "Detailed industry (52 groups)"
    # group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prdtind1 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Agricultural"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Agricultural - Services"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Agricultural - Other"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 47
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Forestry, logging, fishing, hunting, and trapping"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 3
          ;;
        label: "Mining"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 4
          ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 7
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonmetallic mineral products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 in (8, 9)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Primary metals and fabricated metal products"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 10
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Manufacturing-Not Specified Metal Industries"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery manufacturing"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Computer and electronic products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical equipment, appliance manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 in (13, 14, 15)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation equipment manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 5
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wood products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 6
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and fixtures manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 in (16, 17, 18)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous and not specified manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 19
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 20
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beverage and tobacco products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 in (21, 22, 28)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile, apparel, and leather manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 17
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 23
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paper and printing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 18
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 26
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum and coal products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 19
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 25
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Chemical manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 20
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 27
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Plastics and rubber products"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 21
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 32
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wholesale trade"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 22
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 34
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail trade"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 23
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 29
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and warehousing"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 24
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 31
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Utilities"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 25
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 24
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Publishing industries (except internet)"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 26
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Motion picture and sound recording industries"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 27
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Broadcasting (except internet)"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 28
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet publishing and broadcasting"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 29
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 30
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Telecommunications"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 30
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet service providers and data processing services"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 31
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other information services"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 32
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 35
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Finance"
      }

      when: {
        sql: (${TABLE}.prdtind1 in (33, 34)
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 36
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Insurance"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 35
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Rental and leasing Services"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 36
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 46
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and technical services"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 37
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Management of companies and enterprises"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 38
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 49
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administrative and support services"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 39
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Waste management and remediation services"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 40
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 44
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Educational services"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 41
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 42
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hospitals"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 42
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 43
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Health care services, except hospitals"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 43
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 45
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Social assistance"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 44
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 41
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Arts, entertainment, and recreation"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 45
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Accommodation"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 46
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 33
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food services and drinking places"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 38
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Business services"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 47
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 39
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Repair and maintenance"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 48
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 40
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Personal and laundry services"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 49
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Membership associations and organizations"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 50
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 37
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Private households"
      }

      when: {
        sql: (${TABLE}.prdtind1 = 51
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind1 = 51
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public administration"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 52
          ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 48
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Justice, public order & safety"
      }

      when: {
        sql: ${TABLE}.prdtind1 = 50
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "National security & internal affairs"
      }
    }
  }

  dimension: prdtind2 {
    hidden: yes
    label: "Detailed industry (52 groups)"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.prdtind2 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Agricultural"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 1
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Agricultural - Services"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 2
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Agricultural - Other"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 47
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Forestry, logging, fishing, hunting, and trapping"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 3
          ;;
        label: "Mining"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 4
          ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 7
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonmetallic mineral products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 in (8, 9)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Primary metals and fabricated metal products"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 10
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Manufacturing-Not Specified Metal Industries"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery manufacturing"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Computer and electronic products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical equipment, appliance manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 in (13, 14, 15)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation equipment manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 5
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wood products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 6
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and fixtures manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 in (16, 17, 18)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous and not specified manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 19
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 20
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beverage and tobacco products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 in (21, 22, 28)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile, apparel, and leather manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 17
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 23
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paper and printing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 18
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 26
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum and coal products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 19
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 25
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Chemical manufacturing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 20
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 27
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Plastics and rubber products"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 21
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 32
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wholesale trade"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 22
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 34
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail trade"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 23
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 29
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and warehousing"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 24
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 31
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Utilities"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 25
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 24
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Publishing industries (except internet)"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 26
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Motion picture and sound recording industries"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 27
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Broadcasting (except internet)"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 28
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet publishing and broadcasting"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 29
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 30
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Telecommunications"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 30
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet service providers and data processing services"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 31
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other information services"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 32
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 35
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Finance"
      }

      when: {
        sql: (${TABLE}.prdtind2 in (33, 34)
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 36
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Insurance"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 35
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Rental and leasing Services"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 36
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 46
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and technical services"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 37
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Management of companies and enterprises"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 38
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 49
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administrative and support services"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 39
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Waste management and remediation services"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 40
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 44
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Educational services"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 41
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 42
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hospitals"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 42
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 43
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Health care services, except hospitals"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 43
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 45
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Social assistance"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 44
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 41
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Arts, entertainment, and recreation"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 45
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Accommodation"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 46
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 33
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food services and drinking places"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 38
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Business services"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 47
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 39
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Repair and maintenance"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 48
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 40
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Personal and laundry services"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 49
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Membership associations and organizations"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 50
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 37
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Private households"
      }

      when: {
        sql: (${TABLE}.prdtind2 = 51
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtind2 = 51
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public administration"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 52
          ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 48
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Justice, public order & safety"
      }

      when: {
        sql: ${TABLE}.prdtind2 = 50
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "National security & internal affairs"
      }
    }
  }

  dimension: puio1mfg {
    label: "In manufacturing/wholesale/retail?"
    group_label: "Main job"
  }

  dimension: puio2mfg {
    hidden: yes
    label: "In manufacturing/wholesale/retail?"
    group_label: "Second job"
  }

  dimension: pepdemp1 {
    label: "Individual has paid employees?"
    group_label: "Main job"
  }

  dimension: pepdemp2 {
    hidden: yes
    label: "Individual has paid employees?"
    group_label: "Second job"
  }

  dimension: prdtocc1 {
    label: "Detailed occupation groups - recode"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prdtocc1 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (1, 2, 3)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Management occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc1 in (24, 25, 26)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business and financial operations occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (5, 22)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Computer and mathematical science occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (4)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Architecture and engineering occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (6, 14)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Life, physical, and social science occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Community and social service occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (11)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Legal occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (8, 9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Education, training, and library occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Arts, design, entertainment, sports, and media occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (7,8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Healthcare practitioner and technical occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (13, 30)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Healthcare support occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (28)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Protective service occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (29)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food preparation and serving related occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (31)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Building and grounds cleaning and maintenance occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (27, 32)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Personal care and service occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc1 in (16, 17, 18, 19, 20)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sales and related occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 17
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc1 in (21, 23)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Office and administrative support occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 18
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (43, 44, 45)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farming, fishing, and forestry occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 19
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (34, 40)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction and extraction occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 20
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (33)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Installation, maintenance, and repair occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 21
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (35, 36, 37, 42)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Production occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 22
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (38, 39, 41)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and material moving occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc1 = 23
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc1 in (46)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Other professional specialty occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc1 = 15
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Technicians (except health, engineering & science)"
      }
    }
  }

  dimension: prdtocc2 {
    hidden: yes
    label: "Detailed occupation groups - recode"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.prdtocc2 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (1, 2, 3)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Management occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 2
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc2 in (24, 25, 26)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business and financial operations occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (5, 22)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Computer and mathematical science occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (4)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Architecture and engineering occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (6, 14)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Life, physical, and social science occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Community and social service occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (11)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Legal occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (8, 9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Education, training, and library occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Arts, design, entertainment, sports, and media occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (7,8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Healthcare practitioner and technical occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (13, 30)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Healthcare support occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (28)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Protective service occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (29)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Food preparation and serving related occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (31)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Building and grounds cleaning and maintenance occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 15
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (27, 32)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Personal care and service occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 16
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc2 in (16, 17, 18, 19, 20)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sales and related occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 17
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prdtocc2 in (21, 23)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Office and administrative support occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 18
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (43, 44, 45)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farming, fishing, and forestry occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 19
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (34, 40)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction and extraction occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 20
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (33)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Installation, maintenance, and repair occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 21
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (35, 36, 37, 42)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Production occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 22
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (38, 39, 41)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and material moving occupations"
      }

      when: {
        sql: (${TABLE}.prdtocc2 = 23
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prdtocc2 in (46)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Other professional specialty occupations"
      }

      when: {
        sql: ${TABLE}.prdtocc2 = 15
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Technicians (except health, engineering & science)"
      }
    }
  }

  dimension: peio1icd {
    label: "Industry code"
    # group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.peio1icd = -1
          ;;
        label: "Not in Universe"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 10
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Crop production (111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 111
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal production (112)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 31
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Forestry except logging (1131,1132)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 230
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Logging (1133)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 32
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fishing, hunting, and trapping (114)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 30
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Support activities for agriculture and forestry (115)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 42
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Oil and gas extraction (211)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 41
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Coal mining (2121)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 40
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metal ore mining (2122)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 50
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonmetallic mineral mining and quarrying (2123)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 0480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Not specified type of mining (Part of 21)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 0490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Support activities for mining (213)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 450
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electric power generation, transmission and distribution (Pt. 2211)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 451
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Natural gas distribution (Pt. 2212)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 452
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electric and gas, and other combinations  (Pts. 2211,2212)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 470
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Water, steam, air-conditioning, and irrigation systems (22131,22133)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 471
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sewage treatment facilities (22132)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 472
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified utilities (Part of 22)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 0770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 60
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 110
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal food, grain and oilseed milling (3111,3112)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 112
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sugar and confectionery products (3113)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 102
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fruit and vegetable preserving and specialty food manufacturing (3114)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 101
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dairy product manufacturing (3115)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 100
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal slaughtering and processing (3116)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 610
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail bakeries (311811)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 111
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bakeries, except retail (3118 exc. 311811)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 121
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Seafood and other miscellaneous foods, n.e.c. (3117,3119)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 122
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified food industries (Part of 311)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 120
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beverage manufacturing (3121)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 130
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Tobacco manufacturing (3122)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 142
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fiber, yarn, and thread mills (3131)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 1480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Fabric mills, except knitting (3132 exc. 31324)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 140
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile and fabric finishing and coating mills (3133)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 141
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Carpet and rug mills (31411)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (150, 152)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile product mills, except carpets and rugs (314 exc. 31411)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 132
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Knitting mills (31324, 3151)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 1680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Cut and sew apparel manufacturing (3152)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 151
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Apparel accessories and other apparel manufacturing (3159)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 221
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Footwear manufacturing  (3162)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (220, 222)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Leather tanning and products, except footwear manufacturing (3161,3169)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 160
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pulp, paper, and paperboard mills (3221)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 162
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paperboard containers and boxes (32221)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 1890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 161
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous paper and pulp products (32222,32223,32229)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 1990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Printing and related support activities (3231)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 200
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum refining (32411)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 201
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous petroleum and coal products (32419)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 180
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Resin, synthetic rubber and fibers, and filaments manufacturing (3252)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 191
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agricultural chemical manufacturing (3253)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 181
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pharmaceutical and medicine manufacturing (3254)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 190
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paint, coating, and adhesive manufacturing B46 (3255)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 182
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Soap, cleaning compound, and cosmetics manufacturing (3256)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 192
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Industrial and miscellaneous chemicals (3251,3259)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 212
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Plastics product manufacturing (3261)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 210
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Tire manufacturing (32621)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 211
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Rubber products, except tires, manufacturing (32622,32629)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 261
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pottery, ceramics, and related products manufacturing  (32711)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 252
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Structural clay product manufacturing (32712)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 250
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Glass and glass product manufacturing (3272)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 251
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cement, concrete, lime, and gypsum product manufacturing (3273,3274)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 262
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous nonmetallic mineral product manufacturing (3279)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = (270)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Iron and steel mills and steel product manufacturing (3311, 3312)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 272
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aluminum production and processing (3313)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 280
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonferrous metal, except aluminum, production and processing (3314)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 271
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Foundries (3315)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 291
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metal forgings and stampings (3321)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 281
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cutlery and hand tool manufacturing (3322)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 282
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Structural metals, and tank and shipping container manufacturing (3323,3324)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 290
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machine shops; turned product; screw, nut and bolt manufacturing (3327)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 2890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Coating, engraving, heat treating and allied activities (3328)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 292
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ordnance (332992 to 332995)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 300
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous fabricated metal products manufacturing (3325,3326,3329 exc. 332992,332993,332994,3329"
      }

      when: {
        sql: (${TABLE}.peio1icd = 2990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 301
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified metal industries (Part of 331 and 332)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 311
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agricultural implement manufacturing (33311)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 312
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction, mining and oil field machinery manufacturing (33312,33313)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 321
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Commercial and service industry machinery manufacturing (3333)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 320
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metalworking machinery manufacturing (3335)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 310
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Engines, turbines, and power transmission equipment manufacturing (3336)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 331
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery manufacturing, n.e.c. (3332, 3334,3339)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 332
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified machinery manufacturing (Part of 333)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3360
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 322
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Computer and peripheral equipment manufacturing (3341)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 341
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Communications, audio, and video equipment manufacturing (3342,3343)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 371
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Navigational, measuring, electromedical, and control instruments manufacturing (3345)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 342
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electronic component and product manufacturing, n.e.c. (3344,3346)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 340
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Household appliance manufacturing (3352)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 350
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical lighting, equipment, and supplies manufacturing, n.e.c. (3351, 3353,3359)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 351
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motor vehicles and motor vehicle equipment manufacturing (3361,3362,3363)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 352
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aircraft and parts manufacturing (336411 to 336413)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 362
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aerospace products and parts manufacturing (336414,336415,336419)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 361
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Railroad rolling stock manufacturing (3365)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 360
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ship and boat building (3366)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 370
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other transportation equipment manufacturing (3369)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 231
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sawmills and wood preservation (3211)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 3780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Veneer, plywood, and engineered wood products (3212)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 232
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Prefabricated wood buildings and mobile homes (321991,321992)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 241
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous wood products (3219 exc. 321991,321992)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 242
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and related product manufacturing (337)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3960
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 372
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Medical equipment and supplies manufacturing (3391)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 390
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Toys, amusement, and sporting goods manufacturing (33992, 33993)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (380, 381, 391)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous manufacturing, n.e.c. (3399 exc. 33992, 33993)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 3990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 392
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified manufacturing industries (Part of 31, 32, 33)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 500
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motor vehicles, parts and supplies, merchant wholesalers (4231)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 501
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and home furnishing, merchant wholesalers (4232)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 502
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lumber and other construction materials, merchant wholesalers (4233)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 510
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and commercial equipment and supplies, merchant wholesalers (4234)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 511
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metals and minerals, except petroleum, merchant wholesalers (4235)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 512
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical goods, merchant wholesalers (4236)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4260
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 521
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hardware, plumbing and heating equipment, and supplies, merchant wholesalers (4237)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 5530
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery, equipment, and supplies, merchant wholesalers (4238)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 531
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Recyclable material, merchant wholesalers (42393)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 532
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous durable goods, merchant wholesalers (4239 exc. 42393)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 540
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paper and paper products, merchant wholesalers (4241)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 541
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Drugs, sundries, and chemical and allied products, merchant wholesalers (4242, 4246)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 542
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Apparel, fabrics, and notions, merchant wholesalers (4243)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 550
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Groceries and related products, merchant wholesalers (4244)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 551
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farm product raw materials, merchant wholesalers (4245)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 552
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum and petroleum products, merchant wholesalers (4247)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4560
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 560
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Alcoholic beverages, merchant wholesalers (42480)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 561
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farm supplies, merchant wholesalers (42491)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 562
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous nondurable goods, merchant wholesalers (4249 exc. 42491)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 4585
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Wholesale electronic markets, agents and brokers (New industry 4251)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 571
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified wholesale trade(Part of 42)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 612
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automobile dealers (4411)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (590, 622)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other motor vehicle dealers (4412)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 620
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Auto parts, accessories, and tire stores  (4413)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 631
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and home furnishings stores (442)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 632
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Household appliance stores (443111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 633
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Radio, TV, and computer stores (443112,44312)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 580
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Building material and supplies dealers (4441 exc. 44413)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 581
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hardware stores (44413)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 582
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lawn and garden equipment and supplies stores (4442)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 601
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Grocery stores (4451)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (602, 611)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Specialty food stores (4452)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 4990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 650
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beer, wine, and liquor stores (4453)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 642
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pharmacies and drug stores (4461)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 5080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Health and personal care, except drug, stores (446 exc. 44611)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 621
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Gasoline stations (447)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 623
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Clothing and accessories, except shoe, stores (448 exc. 44821, 4483)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 790
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Dressmaking shops (part 7219)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 630
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Shoe stores (44821)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 660
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Jewelry, luggage, and leather goods stores (4483)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 651
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sporting goods, camera, and hobby and toy stores (44313, 45111, 45112)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 662
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sewing, needlework, and piece goods stores (45113)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 640
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Music stores (45114, 45122)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 652
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Book stores and news dealers (45121)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 591
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Department stores and discount stores (45211)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 600
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous general merchandise stores  (4529)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 592
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Variety stores (533)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 681
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail florists (4531)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 5480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Office supplies and stationery stores (45321)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 5490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Used merchandise stores (4533)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 661
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Gift, novelty, and souvenir shops (45322)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 682
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous retail stores (4539)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 5590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Electronic shopping   (New industry) (454111)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 5591
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Electronic auctions  (New industry) (454111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5592
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 663
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Mail order houses (454113)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 670
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vending machine operators (4542)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 672
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fuel dealers (45431)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 671
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other direct selling establishments (45439)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 5790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 691
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified retail trade (Part of 44,45)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 421
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Air transportation (481)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 400
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Rail transportation (482)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 420
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Water transportation (483)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 410
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Truck transportation (484)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 401
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bus service and urban transit (4851,4852,4854,4855,4859)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 402
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Taxi and limousine service (4853)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 422
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pipeline transportation (486)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Scenic and sightseeing transportation (487)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 432
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Services incidental to transportation (488)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 412
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Postal Service (491)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Couriers and messengers (492)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 411
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Warehousing and storage (493)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 171
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Newspaper publishers (51111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 172
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Publishing, except newspapers and software (5111 exc. 51111)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Software publishing (5112)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 800
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motion pictures and video industries (5121)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Sound recording industries (5122)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 440
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Radio and television broadcasting and cable (5151, 5152, 5175)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6675
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet publishing and broadcasting  (New industry) (5161)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 441
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wired telecommunications carriers (5171)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 442
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other telecommunications services (517 exc. 5171,5175)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6692
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet service providers (New industry) (5181)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6695
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 732
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Data processing, hosting, and related services  (5182)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 852
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Libraries and archives  (51912)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 6780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other information services (5191 exc. 51912)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 700
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Banking and related activities (521, 52211,52219)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 701
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Savings institutions, including credit unions (52212, 52213)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 702
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Non-depository credit and related activities (5222, 5223)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 710
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Securities, commodities, funds, trusts, and other financial investments(523, 525)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 6990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 711
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Insurance carriers and related activities (524)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 712
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Real estate (531)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 742
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automotive equipment rental and leasing   (5321)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 801
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Video tape and disk rental (53223)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other consumer goods rental (53221,53222,53229,5323)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Commercial, industrial, and other intangible assets rental and leasing (5324, 533)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 841
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Legal services (5411)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 890
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Accounting, tax preparation, bookkeeping, and payroll services (5412)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 882
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Architectural, engineering, and related services (5413)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Specialized design services (5414)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Computer systems design and related services (5415)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Management, scientific, and technical consulting services (5416)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7460
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 891
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Scientific research and development services (5417)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 721
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Advertising and related services (5418)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Veterinary services (54194)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 893
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other professional, scientific, and technical services (5419 exc. 54194)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 892
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Management of companies and enterprises (551)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 731
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Employment services (5613)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 741
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business support services (5614)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Travel arrangements and reservation services (5615)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 740
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Investigation and security services (5616)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 722
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Services to buildings and dwellings except cleaning during construction and immediately after constr"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 20
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Landscaping services (56173)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other administrative and other support services (5611,5612,5619)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 7790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Waste management and remediation services (562)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7860
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 842
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Elementary and secondary schools (6111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 850
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Colleges and universities, including junior colleges (6112, 6113)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 851
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business, technical, and trade schools and training (6114, 6115)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 860
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other schools, instruction, and educational services (6116, 6117)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 812
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of physicians (6211)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 820
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of dentists (6212)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 7990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 821
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of chiropractors (62131)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 822
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of optometrists (62132)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 830
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of other health practitioners (6213 exc. 62131, 62132)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Outpatient care centers (6214)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Home health care services (6216)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 840
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other health care services (6215, 6219)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 831
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hospitals (622)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 832
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nursing care facilities (6231)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 870
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Residential care facilities, without nursing  (6232, 6233, 6239)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Individual and family services (6241)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Community food and housing, and emergency services (6242)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 861
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vocational rehabilitation services (62430)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd in (862, 863)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Child day care services (6244)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8560
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Independent artists, performing arts, spectator sports, and related industries (711)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 872
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Museums, art galleries, historical sites, and similar institutions (712)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 802
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bowling centers (71395)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 810
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other amusement, gambling, and recreation industries (713 exc. 71395)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8660
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 762
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Traveler accommodation (7211)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 770
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Recreational vehicle parks and camps, and rooming and boarding houses (7212, 7213)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 641
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Restaurants and other food services (722 exc. 7224)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Drinking places, alcoholic beverages (7224)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 751
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automotive repair and maintenance (8111 exc. 811192)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 750
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Car washes (811192)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 752
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electronic and precision equipment repair and maintenance (8112)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Commercial and industrial machinery and equipment repair and maintenance (8113)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Personal and household goods repair and maintenance (8114 exc. 81143)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 782
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Footwear and leather goods repair (81143)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 780
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Barber shops (812111)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 8980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 772
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beauty salons (812112)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 8990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Nail salons and other personal care services (812113, 81219)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 771
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Drycleaning and laundry services (8123)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 781
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Funeral homes, cemeteries, and crematories (8122)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 791
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other personal services (8129)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9160
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 880
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Religious organizations (8131)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 881
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Civic, social, advocacy organizations, and grantmaking and giving services (8132, 8133, 8134)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 873
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Labor unions (81393)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 871
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business, professional, political, and similar organizations (8139 exc. 81393)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 761
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Private households (814)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 900
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Executive offices and legislative bodies  (92111, 92112, 92114, pt. 92115)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 921
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public finance activities (92113)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 901
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other general government and support (92119)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 910
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Justice, public order, and safety activities (922, pt. 92115)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 922
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of human resource programs (923)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 930
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of environmental quality and housing programs (924, 925)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 931
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of economic programs and space research (926, 927)"
      }

      when: {
        sql: (${TABLE}.peio1icd = 9590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio1icd = 932
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "National security and international affairs (928)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Army"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Air Force"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Navy"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Marines"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Coast Guard"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Armed Forces, Branch Not Specified"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Military Reserves or National Guard"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Problem referral"
      }

      when: {
        sql: ${TABLE}.peio1icd = 9990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Uncodable  (Includes Refused or reported Classified)"
      }

      when: {
        sql: ${TABLE}.peio1icd = 991
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Assigned to persons whose labor force status is unemployed and whose last job was Armed Forces"
      }
    }
  }

  dimension: peio2icd {
    hidden: yes
    label: "Industry code"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.peio2icd = -1
          ;;
        label: "Not in Universe"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 10
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Crop production (111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 111
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal production (112)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 31
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Forestry except logging (1131,1132)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 230
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Logging (1133)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 32
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fishing, hunting, and trapping (114)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 30
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Support activities for agriculture and forestry (115)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 42
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Oil and gas extraction (211)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 41
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Coal mining (2121)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 40
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metal ore mining (2122)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 50
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonmetallic mineral mining and quarrying (2123)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 0480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Not specified type of mining (Part of 21)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 0490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Support activities for mining (213)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 450
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electric power generation, transmission and distribution (Pt. 2211)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 451
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Natural gas distribution (Pt. 2212)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 452
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electric and gas, and other combinations  (Pts. 2211,2212)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 470
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Water, steam, air-conditioning, and irrigation systems (22131,22133)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 471
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sewage treatment facilities (22132)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 472
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified utilities (Part of 22)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 0770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 60
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 110
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal food, grain and oilseed milling (3111,3112)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 112
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sugar and confectionery products (3113)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 102
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fruit and vegetable preserving and specialty food manufacturing (3114)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 101
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Dairy product manufacturing (3115)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 100
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Animal slaughtering and processing (3116)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 610
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail bakeries (311811)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 111
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bakeries, except retail (3118 exc. 311811)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 121
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Seafood and other miscellaneous foods, n.e.c. (3117,3119)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 122
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified food industries (Part of 311)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 120
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beverage manufacturing (3121)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 130
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Tobacco manufacturing (3122)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 142
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fiber, yarn, and thread mills (3131)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 1480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Fabric mills, except knitting (3132 exc. 31324)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 140
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile and fabric finishing and coating mills (3133)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 141
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Carpet and rug mills (31411)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (150, 152)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Textile product mills, except carpets and rugs (314 exc. 31411)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 132
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Knitting mills (31324, 3151)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 1680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Cut and sew apparel manufacturing (3152)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 151
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Apparel accessories and other apparel manufacturing (3159)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 221
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Footwear manufacturing  (3162)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (220, 222)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Leather tanning and products, except footwear manufacturing (3161,3169)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 160
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pulp, paper, and paperboard mills (3221)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 162
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paperboard containers and boxes (32221)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 1890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 161
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous paper and pulp products (32222,32223,32229)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 1990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Printing and related support activities (3231)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 200
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum refining (32411)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 201
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous petroleum and coal products (32419)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 180
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Resin, synthetic rubber and fibers, and filaments manufacturing (3252)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 191
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agricultural chemical manufacturing (3253)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 181
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pharmaceutical and medicine manufacturing (3254)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 190
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paint, coating, and adhesive manufacturing B46 (3255)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 182
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Soap, cleaning compound, and cosmetics manufacturing (3256)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 192
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Industrial and miscellaneous chemicals (3251,3259)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 212
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Plastics product manufacturing (3261)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 210
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Tire manufacturing (32621)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 211
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Rubber products, except tires, manufacturing (32622,32629)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 261
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pottery, ceramics, and related products manufacturing  (32711)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 252
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Structural clay product manufacturing (32712)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 250
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Glass and glass product manufacturing (3272)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 251
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cement, concrete, lime, and gypsum product manufacturing (3273,3274)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 262
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous nonmetallic mineral product manufacturing (3279)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = (270)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Iron and steel mills and steel product manufacturing (3311, 3312)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 272
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aluminum production and processing (3313)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 280
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nonferrous metal, except aluminum, production and processing (3314)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 271
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Foundries (3315)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 291
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metal forgings and stampings (3321)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 281
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Cutlery and hand tool manufacturing (3322)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 282
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Structural metals, and tank and shipping container manufacturing (3323,3324)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 290
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machine shops; turned product; screw, nut and bolt manufacturing (3327)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 2890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Coating, engraving, heat treating and allied activities (3328)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 292
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ordnance (332992 to 332995)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 300
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous fabricated metal products manufacturing (3325,3326,3329 exc. 332992,332993,332994,3329"
      }

      when: {
        sql: (${TABLE}.peio2icd = 2990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 301
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified metal industries (Part of 331 and 332)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 311
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agricultural implement manufacturing (33311)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 312
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Construction, mining and oil field machinery manufacturing (33312,33313)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 321
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Commercial and service industry machinery manufacturing (3333)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 320
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metalworking machinery manufacturing (3335)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 310
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Engines, turbines, and power transmission equipment manufacturing (3336)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 331
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery manufacturing, n.e.c. (3332, 3334,3339)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 332
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified machinery manufacturing (Part of 333)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3360
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 322
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Computer and peripheral equipment manufacturing (3341)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 341
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Communications, audio, and video equipment manufacturing (3342,3343)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 371
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Navigational, measuring, electromedical, and control instruments manufacturing (3345)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 342
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electronic component and product manufacturing, n.e.c. (3344,3346)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 340
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Household appliance manufacturing (3352)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 350
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical lighting, equipment, and supplies manufacturing, n.e.c. (3351, 3353,3359)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 351
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motor vehicles and motor vehicle equipment manufacturing (3361,3362,3363)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 352
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aircraft and parts manufacturing (336411 to 336413)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 362
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Aerospace products and parts manufacturing (336414,336415,336419)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 361
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Railroad rolling stock manufacturing (3365)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 360
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Ship and boat building (3366)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 370
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other transportation equipment manufacturing (3369)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 231
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sawmills and wood preservation (3211)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 3780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Veneer, plywood, and engineered wood products (3212)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 232
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Prefabricated wood buildings and mobile homes (321991,321992)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 241
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous wood products (3219 exc. 321991,321992)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 242
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and related product manufacturing (337)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3960
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 372
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Medical equipment and supplies manufacturing (3391)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 390
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Toys, amusement, and sporting goods manufacturing (33992, 33993)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (380, 381, 391)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous manufacturing, n.e.c. (3399 exc. 33992, 33993)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 3990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 392
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified manufacturing industries (Part of 31, 32, 33)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 500
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motor vehicles, parts and supplies, merchant wholesalers (4231)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 501
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and home furnishing, merchant wholesalers (4232)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 502
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lumber and other construction materials, merchant wholesalers (4233)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 510
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and commercial equipment and supplies, merchant wholesalers (4234)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 511
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Metals and minerals, except petroleum, merchant wholesalers (4235)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 512
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electrical goods, merchant wholesalers (4236)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4260
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 521
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hardware, plumbing and heating equipment, and supplies, merchant wholesalers (4237)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 5530
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Machinery, equipment, and supplies, merchant wholesalers (4238)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 531
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Recyclable material, merchant wholesalers (42393)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 532
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous durable goods, merchant wholesalers (4239 exc. 42393)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 540
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Paper and paper products, merchant wholesalers (4241)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 541
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Drugs, sundries, and chemical and allied products, merchant wholesalers (4242, 4246)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 542
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Apparel, fabrics, and notions, merchant wholesalers (4243)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 550
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Groceries and related products, merchant wholesalers (4244)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 551
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farm product raw materials, merchant wholesalers (4245)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 552
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Petroleum and petroleum products, merchant wholesalers (4247)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4560
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 560
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Alcoholic beverages, merchant wholesalers (42480)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 561
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farm supplies, merchant wholesalers (42491)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 562
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous nondurable goods, merchant wholesalers (4249 exc. 42491)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 4585
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Wholesale electronic markets, agents and brokers (New industry 4251)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 571
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified wholesale trade(Part of 42)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 612
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automobile dealers (4411)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (590, 622)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other motor vehicle dealers (4412)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 620
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Auto parts, accessories, and tire stores  (4413)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 631
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Furniture and home furnishings stores (442)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 632
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Household appliance stores (443111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 633
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Radio, TV, and computer stores (443112,44312)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 580
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Building material and supplies dealers (4441 exc. 44413)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 581
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hardware stores (44413)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 582
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Lawn and garden equipment and supplies stores (4442)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 601
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Grocery stores (4451)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (602, 611)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Specialty food stores (4452)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 4990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 650
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beer, wine, and liquor stores (4453)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 642
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pharmacies and drug stores (4461)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 5080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Health and personal care, except drug, stores (446 exc. 44611)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 621
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Gasoline stations (447)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 623
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Clothing and accessories, except shoe, stores (448 exc. 44821, 4483)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 790
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Dressmaking shops (part 7219)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 630
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Shoe stores (44821)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 660
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Jewelry, luggage, and leather goods stores (4483)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 651
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sporting goods, camera, and hobby and toy stores (44313, 45111, 45112)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 662
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Sewing, needlework, and piece goods stores (45113)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 640
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Music stores (45114, 45122)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 652
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Book stores and news dealers (45121)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 591
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Department stores and discount stores (45211)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 600
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous general merchandise stores  (4529)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 592
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Variety stores (533)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 681
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Retail florists (4531)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 5480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Office supplies and stationery stores (45321)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 5490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Used merchandise stores (4533)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 661
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Gift, novelty, and souvenir shops (45322)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 682
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Miscellaneous retail stores (4539)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 5590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Electronic shopping   (New industry) (454111)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 5591
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Electronic auctions  (New industry) (454111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5592
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 663
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Mail order houses (454113)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 670
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vending machine operators (4542)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 672
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Fuel dealers (45431)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 671
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other direct selling establishments (45439)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 5790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 691
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Not specified retail trade (Part of 44,45)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 421
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Air transportation (481)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 400
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Rail transportation (482)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 420
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Water transportation (483)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 410
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Truck transportation (484)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 401
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bus service and urban transit (4851,4852,4854,4855,4859)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 402
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Taxi and limousine service (4853)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 422
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Pipeline transportation (486)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Scenic and sightseeing transportation (487)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 432
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Services incidental to transportation (488)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 412
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Postal Service (491)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Couriers and messengers (492)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 411
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Warehousing and storage (493)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 171
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Newspaper publishers (51111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 172
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Publishing, except newspapers and software (5111 exc. 51111)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Software publishing (5112)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 800
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Motion pictures and video industries (5121)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Sound recording industries (5122)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 440
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Radio and television broadcasting and cable (5151, 5152, 5175)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6675
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet publishing and broadcasting  (New industry) (5161)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 441
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wired telecommunications carriers (5171)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 442
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other telecommunications services (517 exc. 5171,5175)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6692
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Internet service providers (New industry) (5181)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6695
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 732
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Data processing, hosting, and related services  (5182)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 852
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Libraries and archives  (51912)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 6780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other information services (5191 exc. 51912)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 700
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Banking and related activities (521, 52211,52219)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 701
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Savings institutions, including credit unions (52212, 52213)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 702
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Non-depository credit and related activities (5222, 5223)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 710
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Securities, commodities, funds, trusts, and other financial investments(523, 525)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 6990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 711
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Insurance carriers and related activities (524)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 712
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Real estate (531)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 742
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automotive equipment rental and leasing   (5321)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 801
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Video tape and disk rental (53223)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other consumer goods rental (53221,53222,53229,5323)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Commercial, industrial, and other intangible assets rental and leasing (5324, 533)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 841
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Legal services (5411)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7280
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 890
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Accounting, tax preparation, bookkeeping, and payroll services (5412)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 882
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Architectural, engineering, and related services (5413)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Specialized design services (5414)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Computer systems design and related services (5415)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Management, scientific, and technical consulting services (5416)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7460
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 891
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Scientific research and development services (5417)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 721
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Advertising and related services (5418)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 12
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Veterinary services (54194)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 893
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other professional, scientific, and technical services (5419 exc. 54194)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 892
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Management of companies and enterprises (551)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 731
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Employment services (5613)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 741
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business support services (5614)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Travel arrangements and reservation services (5615)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 740
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Investigation and security services (5616)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 722
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Services to buildings and dwellings except cleaning during construction and immediately after constr"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 20
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Landscaping services (56173)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Other administrative and other support services (5611,5612,5619)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 7790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Waste management and remediation services (562)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7860
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 842
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Elementary and secondary schools (6111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 850
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Colleges and universities, including junior colleges (6112, 6113)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 851
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business, technical, and trade schools and training (6114, 6115)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 860
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other schools, instruction, and educational services (6116, 6117)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 812
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of physicians (6211)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 820
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of dentists (6212)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 7990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 821
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of chiropractors (62131)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 822
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of optometrists (62132)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 830
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Offices of other health practitioners (6213 exc. 62131, 62132)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Outpatient care centers (6214)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Home health care services (6216)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 840
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other health care services (6215, 6219)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 831
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Hospitals (622)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8270
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 832
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Nursing care facilities (6231)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 870
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Residential care facilities, without nursing  (6232, 6233, 6239)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Individual and family services (6241)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Community food and housing, and emergency services (6242)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 861
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Vocational rehabilitation services (62430)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd in (862, 863)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Child day care services (6244)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8560
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Independent artists, performing arts, spectator sports, and related industries (711)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 872
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Museums, art galleries, historical sites, and similar institutions (712)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8580
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 802
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Bowling centers (71395)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 810
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other amusement, gambling, and recreation industries (713 exc. 71395)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8660
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 762
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Traveler accommodation (7211)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 770
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Recreational vehicle parks and camps, and rooming and boarding houses (7212, 7213)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 641
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Restaurants and other food services (722 exc. 7224)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Drinking places, alcoholic beverages (7224)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 751
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Automotive repair and maintenance (8111 exc. 811192)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 750
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Car washes (811192)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 752
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Electronic and precision equipment repair and maintenance (8112)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Commercial and industrial machinery and equipment repair and maintenance (8113)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8880
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Personal and household goods repair and maintenance (8114 exc. 81143)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 782
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Footwear and leather goods repair (81143)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 780
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Barber shops (812111)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 8980
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 772
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Beauty salons (812112)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 8990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Nail salons and other personal care services (812113, 81219)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9070
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 771
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Drycleaning and laundry services (8123)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9080
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 781
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Funeral homes, cemeteries, and crematories (8122)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9090
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 791
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other personal services (8129)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9160
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 880
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Religious organizations (8131)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9170
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 881
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Civic, social, advocacy organizations, and grantmaking and giving services (8132, 8133, 8134)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9180
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 873
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Labor unions (81393)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9190
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 871
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Business, professional, political, and similar organizations (8139 exc. 81393)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9290
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 761
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Private households (814)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9370
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 900
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Executive offices and legislative bodies  (92111, 92112, 92114, pt. 92115)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9380
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 921
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public finance activities (92113)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9390
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 901
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other general government and support (92119)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9470
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 910
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Justice, public order, and safety activities (922, pt. 92115)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9480
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 922
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of human resource programs (923)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9490
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 930
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of environmental quality and housing programs (924, 925)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9570
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 931
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Administration of economic programs and space research (926, 927)"
      }

      when: {
        sql: (${TABLE}.peio2icd = 9590
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.peio2icd = 932
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "National security and international affairs (928)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9670
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Army"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9680
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Air Force"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9690
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Navy"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9770
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Marines"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9780
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Coast Guard"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9790
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "U. S. Armed Forces, Branch Not Specified"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9870
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Military Reserves or National Guard"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9890
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Armed Forces"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9970
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Problem referral"
      }

      when: {
        sql: ${TABLE}.peio2icd = 9990
          AND ${TABLE}.src_table in ('census_2010', 'census_2012', 'census_2014', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Uncodable  (Includes Refused or reported Classified)"
      }

      when: {
        sql: ${TABLE}.peio2icd = 991
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994')
           ;;
        label: "Assigned to persons whose labor force status is unemployed and whose last job was Armed Forces"
      }
    }
  }

  dimension: prmjind1 {
    label: "Industry, major groups"
    # group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prmjind1 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (1, 21)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agriculture, forestry, fishing, and hunting"
      }

      when: {
        sql: ${TABLE}.prmjind1 = 2
          ;;
        label: "Mining"
      }

      when: {
        sql: ${TABLE}.prmjind1 = 3
          ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (4, 5)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Manufacturing"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wholesale and retail trade"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (6, 8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and utilities"
      }

      when: {
        sql: ${TABLE}.prmjind1 = 7
          ;;
        label: "Information"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Financial activities"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (13)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and business services"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (16, 17, 18)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Educational and health services"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (15)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Leisure and hospitality"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (12, 14, 19, 20)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other services"
      }

      when: {
        sql: (${TABLE}.prmjind1 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind1 in (22)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public administration"
      }

      when: {
        sql: ${TABLE}.prmjind1 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prmjind1 in (23)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }
    }
  }

  dimension: prmjind2 {
    hidden: yes
    label: "Industry, major groups"
    group_label: "Second job"

    case: {
      when: {
        sql: ${TABLE}.prmjind2 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 1
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (1, 21)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Agriculture, forestry, fishing, and hunting"
      }

      when: {
        sql: ${TABLE}.prmjind2 = 2
          ;;
        label: "Mining"
      }

      when: {
        sql: ${TABLE}.prmjind2 = 3
          ;;
        label: "Construction"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 4
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (4, 5)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Manufacturing"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 5
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Wholesale and retail trade"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (6, 8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and utilities"
      }

      when: {
        sql: ${TABLE}.prmjind2 = 7
          ;;
        label: "Information"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Financial activities"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (13)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Professional and business services"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (16, 17, 18)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Educational and health services"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (15)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Leisure and hospitality"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 12
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (12, 14, 19, 20)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Other services"
      }

      when: {
        sql: (${TABLE}.prmjind2 = 13
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjind2 in (22)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Public administration"
      }

      when: {
        sql: ${TABLE}.prmjind2 = 14
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
          OR
          (${TABLE}.prmjind2 in (23)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }
    }
  }

  dimension: ptio1ocd {
    label: "Occupation code"
    group_label: "Main job"
  }

  dimension: ptio2ocd {
    hidden: yes
    label: "Occupation code"
    group_label: "Second job"
  }

  dimension: prmjocgr {
    label: "Occupation, 7 groups"
    group_label: "Main job"
  }

  dimension: prmjocc1 {
    label: "Occupation, major groups-recode"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prmjocc1 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prmjocc1 = 1
          ;;
        label: "Management, business, and financial occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc1 = 2
          ;;
        label: "Professional and related occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 in (6, 7, 8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Service occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc1 = 4
          ;;
        label: "Sales and related occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc1 = 5
          ;;
        label: "Office and administrative support occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 = 13
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farming, fishing, and forestry occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc1 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Construction and extraction occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 in (3, 12)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Installation, maintenance, and repair occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 in (9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Production occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and material moving occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc1 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc1 = 14
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }
    }
  }

  dimension: prmjocc2 {
    label: "Occupation, major groups-recode"
    group_label: "Main job"

    case: {
      when: {
        sql: ${TABLE}.prmjocc2 = -1
          ;;
        label: "In Universe, Met No Conditions To Assign"
      }

      when: {
        sql: ${TABLE}.prmjocc2 = 1
          ;;
        label: "Management, business, and financial occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc2 = 2
          ;;
        label: "Professional and related occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 3
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 in (6, 7, 8)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Service occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc2 = 4
          ;;
        label: "Sales and related occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc2 = 5
          ;;
        label: "Office and administrative support occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 6
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 = 13
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Farming, fishing, and forestry occupations"
      }

      when: {
        sql: ${TABLE}.prmjocc2 = 7
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004')
           ;;
        label: "Construction and extraction occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 8
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 in (3, 12)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Installation, maintenance, and repair occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 9
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 in (9, 10)
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Production occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 10
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 = 11
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Transportation and material moving occupations"
      }

      when: {
        sql: (${TABLE}.prmjocc2 = 11
          AND ${TABLE}.src_table in ('census_2014', 'census_2012', 'census_2010', 'census_2008', 'census_2006', 'census_2004'))
          OR
          (${TABLE}.prmjocc2 = 14
          AND ${TABLE}.src_table in ('census_2002', 'census_2000', 'census_1998', 'census_1996', 'census_1994'))
           ;;
        label: "Armed Forces"
      }
    }
  }

  dimension: is_teacher {
    hidden: yes
    label: "Currently works as teacher"
    sql: CASE
      WHEN
      ${TABLE}.ptio1ocd in (2300, 2310, 2320, 2330, 2340)
      AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006', 'census_2004')
      AND ${TABLE}.pemlr = 1
      AND ${TABLE}.peio1cow in (1, 2, 3)
      THEN 'Public school teacher'
      WHEN
      ${TABLE}.ptio1ocd in (2300, 2310, 2320, 2330, 2340)
      AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006', 'census_2004')
      AND ${TABLE}.pemlr = 1
      AND ${TABLE}.peio1cow in (4,5)
      THEN 'Private school teacher'
      ELSE 'other'
      END
       ;;
    type: string
    view_label: "Industry"
    # group_label: "Main job"
  }

  dimension: is_special_education_teacher {
    hidden: yes
    label: "Special Education Teacher"
    sql: CASE
      WHEN
      ${TABLE}.ptio1ocd = 2330
      AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006', 'census_2004')
      THEN 'Special Education Teacher'
      WHEN ${TABLE}.ptio1ocd in (2300, 2310, 2320, 2340)
      AND ${TABLE}.src_table in ('census_2010', 'census_2014', 'census_2012', 'census_2008', 'census_2006', 'census_2004')
      THEN 'Teacher'
      ELSE 'Not Teacher'
      END
       ;;
    type: string
    view_label: "Industry"
    # group_label: "Main job"
  }

  dimension: household_primary_key {
    hidden: yes
    sql: CONCAT(COALESCE(STRING(${TABLE}.HRHHID), ''), COALESCE(STRING(${TABLE}.HRHHID2), ''), COALESCE(STRING(${TABLE}.GESTCEN), '')) ;;
  }

  measure: cohort_population {
    label: "People"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
  }

  measure: cohort_population_2012 {
    hidden: yes
    label: "People"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: year_of_interview
      value: "2012"
    }
  }

  measure: cohort_population_2014 {
    label: "People in 2014"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: year_of_interview
      value: "2014"
    }
  }

  measure: cohort_population_home_owners {
    label: "Number of Homeowners"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: hetenure
      value: "Owned Or Being Bought By A Hh Member"
    }
  }

  measure: cohort_population_renters {
    label: "Number of Renters"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: hetenure
      value: "Rented for cash"
    }
  }

  measure: percent_change_homeowners {
    label: "% Change Population Owning Homes"
    view_label: "Population Counts"
    type: percent_of_previous
    sql: ${cohort_population_home_owners} ;;
  }

  measure: percent_change_renters {
    label: "% of Total Population Renting Homes"
    view_label: "Population Counts"
    type: percent_of_previous
    sql: ${cohort_population_renters} ;;
  }

  measure: percent_change_population_2014_vs_2012 {
    label: "% Change Population 2014 vs. 2012"
    view_label: "Population Counts"
    type: number
    sql: (${cohort_population_2014}-${cohort_population_2012})/${cohort_population_2012} ;;
    value_format_name: percent_1
  }

  measure: cohort_population_non_hispanic {
    label: "Population Count: Non-Hispanic"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: prhspnon_yesno
      value: "No"
    }
  }

  measure: cohort_population_hispanic {
    label: "Population Count: Hispanic"
    view_label: "Population Counts"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PWSSWGT ;;
    filters: {
      field: prhspnon_yesno
      value: "Yes"
    }
  }

  measure: percent_change_number_of_people {
    label: "% Change in Number of People"
    view_label: "Population Counts"
    type: percent_of_previous
    sql: ${cohort_population} ;;
    direction: "row"
  }

  measure: percent_of_previous_people_hispanic {
    label: "% Change in Number of People: Hispanic"
    view_label: "Population Counts"
    type: percent_of_previous
    sql: ${cohort_population_hispanic} ;;
    direction: "column"
  }

  measure: percent_change_people_non_hispanic {
    label: "% Change in Number of People: Non-Hispanic"
    view_label: "Population Counts"
    type: percent_of_previous
    sql: ${cohort_population_non_hispanic} ;;
    direction: "column"
  }

  measure: cohort_population_for_earnings {
    hidden: yes
    type: sum
    sql: CASE WHEN ${TABLE}.pternwa between 0.0 AND 2884.61 AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.PWSSWGT ELSE NULL END ;;
  }

  measure: cohort_population_for_earnings_2012 {
    hidden: yes
    type: sum
    sql: CASE WHEN ${TABLE}.pternwa between 0.0 AND 2884.61 AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.PWSSWGT ELSE NULL END ;;
    filters: {
      field: year_of_interview
      value: "2012"
    }
  }

  measure: cohort_population_for_earnings_2014 {
    hidden: yes
    type: sum
    sql: CASE WHEN ${TABLE}.pternwa between 0.0 AND 2884.61 AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.PWSSWGT ELSE NULL END ;;
    filters: {
      field: year_of_interview
      value: "2014"
    }
  }

  measure: cohort_households_for_earnings {
    hidden: yes
    type: sum
    sql: COALESCE(CAST(SUM(FLOAT(REGEXP_EXTRACT(UNIQUE(CONCAT(${household_primary_key}, '||', STRING(CASE WHEN ${TABLE}.pternwa between 0.0 AND 2884.61 AND ${TABLE}.HRMIS in (4, 8) THEN ${TABLE}.hwhhwgt ELSE NULL END))), r'\|\|([\d\.\-]+e?[\+\-]?\d*)$'))) AS FLOAT),0) ;;
  }

  measure: households {
    type: sum
    sql: COALESCE(CAST(SUM(FLOAT(REGEXP_EXTRACT(UNIQUE(CONCAT(${household_primary_key}, '||', STRING(${TABLE}.hwhhwgt))), r'\|\|([\d\.\-]+e?[\+\-]?\d*)$'))) AS FLOAT),0) ;;
    view_label: "Population Counts"
    value_format_name: decimal_0
  }

  measure: avg_people_in_hh {
    label: "Average number of People in Households"
    type: number
    sql: 1.0 * ${total_hh_members.people_in_households}/${households} ;;
    view_label: "Population Counts"
    value_format_name: decimal_2
  }
}
