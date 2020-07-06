view: zendesk_user {
  sql_table_name: looker-private-demo.zendesk.users
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  parameter: chatter_filter {
    description: "Use this filter to compare a single chatter with the rest of the support team"
    suggest_dimension: name
  }

  dimension: is_chatter {
    type: yesno
    view_label: "Ticket Assignee"
    description: "Use with the chatter filter to compare one chatter with the rest of the support team"
    sql: {{ chatter_filter._parameter_value }} = ${name} ;;
  }

  dimension: active {
    hidden: yes
    type: yesno
    sql: ${TABLE}.ACTIVE;;
  }

  dimension_group: created {
    hidden: yes
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.CREATED_AT;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME;;
  }

  dimension: organization_id {
    type: string
    hidden: yes
    sql: ${TABLE}.ORGANIZATION_ID;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}.ROLE;;
  }

  dimension: suspended {
    hidden: yes
    type: yesno
    sql: ${TABLE}.SUSPENDED;;
  }

  dimension: time_zone {
    hidden: yes
    type: string
    sql: ${TABLE}.TIME_ZONE;;
  }

  dimension: verified {
    hidden: yes
    type: yesno
    sql: ${TABLE}.VERIFIED;;
  }

  measure: count {
    label: "Number of Users"
    type: count
    drill_fields: [id, name, organization.id]
  }
}