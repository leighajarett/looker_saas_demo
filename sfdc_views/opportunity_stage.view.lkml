view: opportunity_stage {
  sql_table_name: `looker-private-demo.salesforce.opportunity_stage` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension_group: created {
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
    sql: timestamp(${TABLE}.CREATED_DATE);;
  }

  dimension: default_probability {
    type: number
    sql: ${TABLE}.DEFAULT_PROBABILITY;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION;;
  }

  dimension: forecast_category {
    type: string
    sql: ${TABLE}.FORECAST_CATEGORY;;
  }

  dimension: forecast_category_name {
    type: string
    sql: ${TABLE}.FORECAST_CATEGORY_NAME;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.IS_ACTIVE;;
  }

  dimension: is_closed {
    type: yesno
    sql: ${TABLE}.IS_CLOSED;;
  }

  dimension: is_won {
    type: yesno
    sql: ${TABLE}.IS_WON;;
  }

  dimension: master_label {
    type: string
    sql: ${TABLE}.MASTER_LABEL;;
  }

  dimension: sort_order {
    type: number
    sql: ${TABLE}.SORT_ORDER;;
  }

  measure: count {
    type: count
    drill_fields: [id, forecast_category_name]
  }
}
