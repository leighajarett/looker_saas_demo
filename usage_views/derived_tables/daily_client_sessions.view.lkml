view: daily_client_sessions {
  view_label: "Daily Product Usage"
  derived_table: {
    datagroup_trigger: event_trigger
    partition_keys: ["event_date"]
    sql: SELECT
          date(session_start) as event_date,
          client_id as client_id,
          COUNT(DISTINCT unique_session_id ) AS event_sessions_count,
          avg((select timestamp_diff(max(timestamp),min(timestamp), MINUTE)
                          from ${event_logs.SQL_TABLE_NAME}  where unique_session_id = event_session_facts.unique_session_id
                          )) as average_session_duration
      FROM  ${event_sessions.SQL_TABLE_NAME} AS event_session_facts
      GROUP BY 1, 2
       ;;
  }

  dimension: primary_key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(cast(${event_date} as string),'|'${client_id}) ;;
  }

  dimension_group: event {
    hidden: yes
    type: time
    sql: timestamp(${TABLE}.event_date);;
  }

  dimension: client_id {
    hidden: yes
    type: string
    sql: ${TABLE}.client_id ;;
  }

  dimension: session_count {
    group_label: "Daily Event Counts"
    label: "Number of Sessions"
    type: number
    sql: ${TABLE}.event_sessions_count ;;
  }

  dimension: session_per_user {
    label: "Average Daily Sessions per User"
    type: number
    sql: ${session_count}/nullif(${daily_client_usage.distinct_users},0) ;;
    value_format_name: decimal_1
  }

  dimension: session_duration {
    label: "Average Session Length (min)"
    type: number
    sql:${TABLE}.average_session_duration;;
    value_format_name: decimal_1
  }

  measure: total_sessions {
    group_label: "Event Counts"
    type: sum
    sql: ${session_count};;
  }

  measure: median_average_session_per_user {
    group_label: "Average Daily Event Counts"
    description: "The median of the average daily sessions per user"
    type: median
    sql: ${session_per_user} ;;
    value_format_name: decimal_1
  }

  measure: median_session_duration {
    group_label: "Average Daily Event Counts"
    description: "The median of the average session length"
    type: median
    sql: ${session_duration} ;;
    value_format_name: decimal_1
  }

  measure: estimated_usage_time {
    group_label: "Average Daily Event Counts"
    description: "The median session duration mutiplied by the number of sessions"
    type: number
    sql: ${median_session_duration}*${total_sessions};;
    value_format_name: decimal_1
  }

}
