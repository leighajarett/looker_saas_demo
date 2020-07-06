## The commented out PDT can be used to prototype the ETL so that sessions are incrementally added each day

view: event_sessions {
#   derived_table: {
#     datagroup_trigger: event_trigger
#     publish_as_db_view: yes
#     cluster_keys: ["user_id"]
#     partition_keys: ["session_start"]
#     sql: WITH lag AS
#         (SELECT
#                 event_logs.timestamp AS created_at
#                 , event_logs.user_id AS user_id
#                 , event_logs.log.cs_uri_stem.ip_address AS ip_address
#                 , TIMESTAMP_DIFF(
#                     LAG(timestamp) OVER (
#                         PARTITION BY event_logs.user_id, event_logs.log.cs_uri_stem.ip_address
#                         ORDER BY timestamp desc)
#                     ,timestamp, MINUTE) AS idle_time
#               FROM ${event_logs.SQL_TABLE_NAME} as event_logs
#               --dont include performance testing in the sessions
#               where event_logs.log.cs_uri_stem.event_type not in ('performance_timing', 'user_page_load_time_ms','periodic_status','run_query','api_call','api_query','render_job')
#           )
#         SELECT
#           lag.created_at AS session_start
#           , lag.idle_time AS idle_time
#           , lag.user_id AS user_id
#           , lag.ip_address AS ip_address
#           , GENERATE_UUID() AS unique_session_id
#           , ROW_NUMBER () OVER (PARTITION BY COALESCE(lag.user_id, lag.ip_address) ORDER BY lag.created_at) AS session_sequence
#           , COALESCE(
#                 LEAD(lag.created_at) OVER (PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.created_at)
#               , '6000-01-01') AS next_session_start
#         FROM lag
#         WHERE (lag.idle_time > 30 OR lag.idle_time IS NULL)
#        ;;
#   }

  sql_table_name: `looker-private-demo.customer_usage.event_logs_sessions` ;;

  measure: count {
    label: "Number of Sessions"
    type: count
    #drill_fields: [detail*]
  }

  dimension_group: session_start {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_start ;;
  }

  dimension: idle_time {
    type: number
    #value_format: "0"
    sql: ${TABLE}.idle_time ;;
  }

  dimension: unique_session_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension: session_sequence {
    type: number
    value_format_name: id
    sql: ${TABLE}.session_sequence ;;
  }

  dimension_group: next_session_start {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: case when ${TABLE}.next_session_start > current_date() then null else ${TABLE}.next_session_start end;;
  }


#
#   set: detail {
#     fields: [
#       session_start_at_time,
#       idle_time,
#       unique_session_id,
#       session_sequence,
#       next_session_start_at_time
#     ]
#   }
}
