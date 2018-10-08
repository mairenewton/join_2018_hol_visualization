# This reads from a google spreadsheet all the questions and answers
#  entered.

explore: questions {
  persist_for: "30 seconds"
}

view: questions {
  derived_table: {
    sql: SELECT * FROM [census_qa.questions] LIMIT 1000
      ;;
    # refresh every two minutes
    sql_trigger_value: select INTEGER(NOW()/(1000000*60*2)) ;;
  }

  dimension_group: timestamp {
    type: time
    sql: ${TABLE}.timestamp ;;
  }

  dimension: question {
    html: {{value}} (<b><a href="{{url._value}}" target="funstuff">Answer</a></b>)
      ;;
  }

  dimension: url {}
  dimension: email {}

  dimension: comment {
    label: "Observation (What did you notice?)"
  }
}
