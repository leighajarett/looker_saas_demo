view: event_logs {
  sql_table_name: `looker-private-demo.customer_usage.event_logs_event_sessions` ;;

### This PDT maps events back to the sessions table, and calculates the sequence of the event inside the session
#   derived_table: {
#     datagroup_trigger: event_trigger
#     publish_as_db_view: yes
#     cluster_keys: ["user_id"]
#     partition_keys: ["timestamp"]
#     sql: SELECT event_logs.*
#           , sessions.unique_session_id
#           , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY event_logs.timestamp) AS event_sequence_within_session
#           , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY event_logs.timestamp desc) AS inverse_event_sequence_within_session
#           FROM event_logs AS event_logs
#           INNER JOIN ${event_sessions.SQL_TABLE_NAME} AS sessions
#             ON event_logs.user_id = sessions.user_id
#             AND event_logs.log.cs_uri_stem.ip_address = sessions.ip_address
#             AND event_logs.timestamp  >= sessions.session_start
#             AND event_logs.timestamp  < sessions.next_session_start;;
#   }

  dimension: event_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.event_id ;;
  }

  dimension: sequence {
    description: "The sequence of the event in the sessions (e.g. 1 is the first event in the session)"
    type: number
    sql: ${TABLE}.event_sequence_within_session ;;
  }

  dimension: inverse_sequence {
    description: "The inverse sequence of the event in the sessions (e.g. 1 is the last event in the session)"
    type: number
    sql: ${TABLE}.inverse_event_sequence_within_session ;;
  }

  dimension: session_id {
    type: string
    hidden: no
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension: log {
    hidden: yes
    sql: ${TABLE}.log ;;
  }

  dimension: client_id {
    type: string
    sql: ${TABLE}.client_id ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: timestamp {
    label: "Event"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      hour
    ]
    sql: ${TABLE}.timestamp ;;
  }

  dimension_group: days_since_signup {
    type: duration
    sql_start: ${account.start_raw} ;;
    sql_end: ${timestamp_raw} ;;
  }

  dimension_group: days_before_churn {
    type: duration
    sql_start: ${timestamp_raw} ;;
    sql_end: ${account.end_raw} ;;
  }

  measure: first_event_time {
    ## used for NDT
    hidden: no
    type: date_time
    sql: MIN(${timestamp_raw}) ;;
  }

  measure: last_event_time {
    ## used for NDT
    hidden: no
    type: date_time
    sql: MAX(${timestamp_raw}) ;;
  }

  measure: count {
    label: "Number of Events"
    type: count
    drill_fields: []
  }

  measure: percent_of_total {
    label: "Percent of Total Events"
    description: "The percent of the number of events, for the displayed row"
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_id} ;;
  }
}

view: event_logs__log__cs_uri_query {
  dimension: crontab {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.crontab ;;
  }

  dimension: dashboard_id {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.dashboard_id ;;
  }

  dimension: dashboard_session {
    type: string
    sql: ${TABLE}.dashboard_session ;;
  }

  dimension: destination {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.destination ;;
  }

  dimension: destination_types {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.destination_types ;;
  }

  dimension: dialect {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.dialect ;;
  }

  dimension: export_format {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.export_format ;;
  }

  dimension: export_limit {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.export_limit ;;
  }

  dimension: format {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.format ;;
  }

  dimension: model_id {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.model_id ;;
  }

  dimension: project_id {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: referrer {
    type: string
    sql: ${TABLE}.referrer ;;
  }

  dimension: report_id {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.report_id ;;
  }

  dimension: result_apply_vis {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.result_apply_vis ;;
  }

  dimension: run_once {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.run_once ;;
  }

  dimension: schedule_id {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.schedule_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: uri {
    type: string
    sql: ${TABLE}.uri ;;
  }

  dimension: value_style {
    group_label: "Event Specific Parameters"
    type: string
    sql: ${TABLE}.value_style ;;
  }
}

view: event_logs__log__cs_uri_stem {
  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}.ip_address ;;
  }

  dimension: os_type {
    type: string
    sql: ${TABLE}.os_type ;;
  }


  measure: number_of_event_types {
    label: "Number of Distinct Event Types"
    type: count_distinct
    sql: ${event_type} ;;
  }

  measure: first_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(0)] ;;
  }

  measure: second_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(1)] ;;
  }

  measure: third_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(2)] ;;
  }

  measure: fourth_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(3)] ;;
  }

  measure: fifth_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(4)] ;;
  }


  measure: last_event {
    ## used for NDT
    hidden: yes
    type: string
    sql: ARRAY_AGG(${event_type} order by ${event_logs.sequence} asc)[SAFE_OFFSET(0)] ;;
  }

}

view: event_logs__log {
  dimension: cs_uri_query {
    hidden: yes
    sql: ${TABLE}.cs_uri_query ;;
  }

  dimension: cs_uri_stem {
    hidden: yes
    sql: ${TABLE}.cs_uri_stem ;;
  }

  dimension: time_taken {
    type: number
    sql: ${TABLE}.time_taken ;;
  }

  dimension: version {
    description: "The version of the product that the event occured within"
    type: string
    sql: ${TABLE}.version ;;
  }

  measure: average_time_taken {
    type: average
    sql: ${time_taken} ;;
  }

}
