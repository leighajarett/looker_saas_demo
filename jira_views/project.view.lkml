view: project_core {
  extension: required
  sql_table_name: looker-private-demo.jira.project ;;

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

  dimension: project_category_id {
    type: number
    sql: ${TABLE}.PROJECT_CATEGORY_ID ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, component.count, issue_project_history.count, version.count]
  }
}