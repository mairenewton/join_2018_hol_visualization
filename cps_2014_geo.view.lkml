view: cps_2014_geo {
  sql_table_name: census.cps_2014_geo ;;

  dimension: hrhhid {
    type: number
    sql: ${TABLE}.hrhhid ;;
    hidden: yes
  }

  dimension: hrhhid2 {
    type: number
    sql: ${TABLE}.hrhhid2 ;;
    hidden: yes
  }

  dimension: county {
    type: string
    sql: concat(lpad(${gestfips_str}, 2, '0'), lpad(${gtco}, 3, '0')) ;;
    map_layer_name: us_counties_fips
    hidden: yes
  }

  dimension: gestfips_str {
    type: string
    sql: string(${TABLE}.gestfips) ;;
    hidden: yes
  }

  dimension: gestfips {
    type: number
    sql: ${TABLE}.gestfips ;;
    hidden: yes
  }

  dimension: gtco {
    type: string
    sql: string(${TABLE}.GTCO) ;;
    hidden: yes
  }
}
