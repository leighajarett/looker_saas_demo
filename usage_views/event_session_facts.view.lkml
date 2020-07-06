# If necessary, uncomment the line below to include explore_source.
# include: "sfdc_demo.model.lkml"

view: event_session_facts {
  derived_table: {
    datagroup_trigger: event_trigger
    publish_as_db_view: yes
    cluster_keys: ["client_id","user_id"]
    partition_keys: ["first_event_time"]
    explore_source: event_logs {
      column: client_id {field: event_logs.client_id}
      column: user_id {field: event_logs.user_id}
      column: unique_session_id { field: event_sessions.unique_session_id }
      column: event_count { field: event_logs.count }
      column: number_of_event_types { field: event_logs__log__cs_uri_stem.number_of_event_types }
      column: first_event { field: event_logs__log__cs_uri_stem.first_event }
      column: second_event { field: event_logs__log__cs_uri_stem.second_event }
      column: third_event { field: event_logs__log__cs_uri_stem.third_event }
      column: fourth_event { field: event_logs__log__cs_uri_stem.fourth_event }
      column: fifth_event { field: event_logs__log__cs_uri_stem.fifth_event }
      column: last_event { field: event_logs__log__cs_uri_stem.last_event }
      column: first_event_time {}
      column: last_event_time {}
    }
  }

  dimension: unique_session_id {
    type: string
    hidden: yes
    primary_key: yes
  }

  dimension: event_count {
    label: "Number of Events within Session"
    type: number
  }

  dimension: number_of_event_types {
    label: "Number of Distinct Event Types within Session"
    type: number
  }

  dimension: number_of_events_tier {
    type: tier
    sql: ${event_count} ;;
    tiers: [0,10,20,30,40,50]
  }

  dimension: first_event {
    group_label: "Event Funnel"
    type: string
  }

  dimension: second_event {
    description: "The second event type in the session, that is different than the first"
    group_label: "Event Funnel"
    type: string
  }

  dimension: third_event {
    group_label: "Event Funnel"
    type: string
  }

  dimension: fourth_event {
    group_label: "Event Funnel"
    type: string
  }

  dimension: fifth_event {
    group_label: "Event Funnel"
    type: string
  }

  dimension: last_event {
    group_label: "Event Funnel"
    type: string
  }

  dimension_group: first_event {
    hidden: yes
    label: "Session Start"
    type: time
    sql: ${TABLE}.first_event_time ;;
  }

  dimension_group: last_event {
    label: "Session End"
    type: time
    sql: ${TABLE}.last_event_time ;;
  }

  dimension_group: session_length {
    label: "Session Duration"
    type: duration
    sql_start: ${first_event_raw} ;;
    sql_end: ${last_event_raw} ;;
  }

  dimension: sesison_length_tier {
    description: "The session length in hours"
    type: tier
    sql: ${hours_session_length} ;;
    tiers: [1,2,3,4]
  }

  measure: average_number_events {
    type: average
    sql: ${event_count} ;;
  }

  measure: average_session_duration {
    type: average
    sql: ${minutes_session_length} ;;
  }

  measure: median_number_events {
    type: median
    sql: ${event_count} ;;
  }
}
