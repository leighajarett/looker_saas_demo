view: status {
  sql_table_name: looker-private-demo.jira.status ;;

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

  dimension: status_category_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.STATUS_CATEGORY_ID ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, status_category.id, issue_status_history.count]
  }
}