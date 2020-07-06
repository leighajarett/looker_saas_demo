view: jira_user {
  sql_table_name: looker-private-demo.jira.user ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID ;;
  }


  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL ;;
  }

  dimension: locale {
    type: string
    sql: ${TABLE}.LOCALE ;;
  }

  dimension: name {
    label: "Assignee Name"
    type: string
    sql: ${TABLE}.NAME ;;
#     action: {
#       label: "Follow up with assignee"
#     }
  }

  dimension: time_zone {
    type: string
    sql: ${TABLE}.TIME_ZONE ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}.USERNAME ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      issue_assignee_history.count,
      issue_custom_multi_user.count,
      issue_custom_multi_user_history.count,
      issue_custom_single_user_history.count,
      issue_reporter_history.count,
      user_group.count
    ]
  }
}