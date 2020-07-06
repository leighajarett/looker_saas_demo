view: issue_type{
  sql_table_name: looker-private-demo.jira.issue_type ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: subtask {
    type: yesno
    sql: ${TABLE}.SUBTASK ;;
  }

  dimension: is_bug {
    type: yesno
    sql: ${name} = 'Bug' ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}