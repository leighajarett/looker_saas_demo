view: status_category {
  view_label: "Issue"
  sql_table_name: looker-private-demo.jira.status_category ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, status.count]
  }
}