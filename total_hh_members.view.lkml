view: total_hh_members {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: SELECT
        COALESCE(STRING(HRHHID), '0') as hrhhid,
        COALESCE(STRING(HRHHID2), '0') as hrhhid2,
        COALESCE(STRING(GESTCEN), '0') as gestcen,
        SUM(PWSSWGT) as total_hh_members_weight,
        row_number() OVER () as id
      FROM
        [census.cps_full]
      GROUP BY 1, 2, 3
       ;;
    persist_for: "1000 hours"
  }

  #     Define your dimensions and measures here, like this:
  dimension: hrhhid {
    type: string
    sql: ${TABLE}.hrhhid ;;
    hidden: yes
  }

  dimension: hrhhid2 {
    type: string
    sql: ${TABLE}.hrhhid2 ;;
    hidden: yes
  }

  dimension: gestcen {
    type: string
    sql: ${TABLE}.gestcen ;;
    hidden: yes
  }

  dimension: id {
    hidden: yes
    primary_key: yes
  }

  measure: people_in_households {
    label: "Count of all People in Households"
    type: sum
    view_label: "Population Counts"
    value_format_name: decimal_0
    sql: ${TABLE}.total_hh_members_weight ;;
  }
}
