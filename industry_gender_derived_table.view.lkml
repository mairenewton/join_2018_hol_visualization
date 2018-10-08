# explore: industry_gender_count {}

# view: industry_gender_count {
#   derived_table: {
#     #X# Invalid LookML inside "derived_table": {"persist":"10 hours"}
#     explore_source: cps_clean
#     #X# Invalid LookML inside "derived_table": {"columns":[{"column":"cohort_population"},{"column":"pesex"},{"column":"year_of_interview"},{"column":"race"},{"column":"average_yearly_earnings"}]}
#     #X# Invalid LookML inside "derived_table": {"filters":[{"field":"cps_clean.year_of_interview","value":">1990"},{"field":"cps_clean.primind1","value":"Professional and technical services"},{"field":"cps_clean.ptio1ocd","value":"%engineers%, %analysts%"}]}
#   }

#   dimension: cohort_population {
#     label: "Population Counts People"
#     hidden: yes
#     value_format: "#,##0"
#     type: number
#   }

#   measure: total_population {
#     type: sum
#     value_format: "#,##0"
#     sql: ${cohort_population} ;;
#   }

#   dimension: pesex {
#     label: "Demographic Variables Sex"
#   }

#   dimension: year_of_interview {
#     label: "Household Variables Year of Interview"
#     value_format: "0"
#     type: number
#   }

#   dimension: race {
#     label: "Demographic Variables Race"
#   }

#   dimension: yearly_earnings {
#     sql: ${TABLE}.average_yearly_earnings ;;
#     value_format: "$#,##0"
#     type: number
#   }

#   measure: total_yearly_earnings {
#     sql: ${yearly_earnings} * ${cohort_population} ;;
#     value_format: "$#,##0"
#     type: sum
#   }
# }
