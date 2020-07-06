view: daily_user_count {
  sql_table_name: `looker-private-demo.customer_usage.daily_user_count`;;

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(cast(${event_date} as string),'|'${client_id}) ;;
  }

  dimension: client_id {
    hidden: yes
    type: string
    sql: ${TABLE}.client_id ;;
  }

  dimension_group: event {
    type: time
    sql: timestamp(${TABLE}.date) ;;
  }

  dimension: named_user_count {
    description: "The number of users available in contract for that day"
    type: number
    sql: ${TABLE}.user_count ;;
  }

  ### Customer Health Score ###

  dimension: usage_score {
    ##how much time are users spending in the tool
    type: number
    description: "Score from 1-5 on total event usage per user"
    sql:case when ${daily_client_usage.total_event_count}/${daily_client_usage.distinct_users} < 50 then 1
         when ${daily_client_usage.total_event_count}/${daily_client_usage.distinct_users} < 100 then 2
         when ${daily_client_usage.total_event_count}/${daily_client_usage.distinct_users} < 500 then 3
        when ${daily_client_usage.total_event_count}/${daily_client_usage.distinct_users} < 1000 then 4
        else 5 end ;;
  }

  dimension: user_score {
    ##how many users are logging into the tool
    type: number
    view_label: "Daily Account Health Scores"
    description: "Score from 1-5 on percent of users that are active"
    sql: case when ${daily_client_usage.percent_active_users}*100 < 25 then 1
              when ${daily_client_usage.percent_active_users}*100 < 50 then 2
              when ${daily_client_usage.percent_active_users}*100 < 75 then 3
              when ${daily_client_usage.percent_active_users}*100 < 100 then 4 else 5 end;;
  }

  dimension: support_score {
    type: number
    view_label: "Daily Account Health Scores"
    sql: case when ${daily_account_tickets.count} > 10 then 1
              when ${daily_account_tickets.count} > 5 then 2
              when ${daily_account_tickets.count} > 2 then 3
              when ${daily_account_tickets.count} > 0 then 4
              else 5 end;;
  }

  dimension: csat_score {
    hidden: yes
    type: number
    sql: case when ${daily_account_tickets.csat} < 3 then 1
              when ${daily_account_tickets.csat} < 2.5 then 2
              when ${daily_account_tickets.csat} < 3 then 3
              when ${daily_account_tickets.csat} < 3.5 then 4
              else 5 end;;
  }


  dimension: overall_health_score {
    view_label: "Daily Account Health Scores"
    description: "Weighted average of Usage, User, Support and CSAT Scores, range from 1-5"
    type: number
    sql: (${usage_score}*2+${user_score}*2+${support_score}+${csat_score})/6 ;;
    value_format_name: decimal_1
  }

  dimension: overall_health {
    view_label: "Daily Account Health Scores"
    type: string
    sql: case when ${overall_health_score} < 3 then 'At Risk' when ${overall_health_score} < 4 then 'Fair' else 'Good' end ;;
  }


  measure: average_health_score {
    view_label: "Daily Account Health Scores"
    type: average
    sql: ${overall_health_score} ;;
    value_format_name: decimal_1
  }


 }
