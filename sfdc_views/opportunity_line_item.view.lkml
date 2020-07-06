view: opportunity_line_item {
  view_label: "Opportunity Line Item"
  sql_table_name: `looker-private-demo.salesforce.opportunity_line_item` ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  ### dates ###

  dimension_group: cancellation {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: timestamp(${TABLE}.CANCELLATION__DATE___C);;
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
    sql: ${TABLE}.CREATED_DATE;;
  }

  dimension_group: end_date {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: timestamp(${TABLE}.END__DATE___C);;
  }

  dimension_group: service {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: timestamp(${TABLE}.SERVICE_DATE);;
  }


  dimension: is_deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  ### amounts ###

  dimension: quantity {
    description: "The line item quantity, which represents counts (users, licenses) or hours dependings on the product"
    type: number
    #fixing some salesforce error
    sql: case when ${TABLE}.QUANTITY = 0 then  1 else ${TABLE}.QUANTITY end;;
  }

  dimension: price {
    description: "The offered price for the line item"
    type: number
    sql: ${TABLE}.TOTAL_PRICE;;
  }

  dimension: list_price {
    description: "The calculated list price for the line item"
    value_format_name: usd
    type: number
    sql: case when ${product.product_type} = 'Recurring' then ${quantity}*12*${product.list_price} else
            ${quantity}*${product.list_price} end;;
  }

  dimension: percent_discount {
    description: "The percent discount, compared with the calculated list price, that was offered"
    type: number
    sql: (${list_price}-${price})/nullif(${list_price},0) ;;
    value_format_name: percent_0
  }

  ##foreign keys

  dimension: opportunity_id {
    type: string
    hidden: yes
    sql: ${TABLE}.OPPORTUNITY_ID;;
  }

  dimension: product_id {
    hidden: yes
    type: string
    sql: ${TABLE}.PRODUCT_2_ID;;
  }

  dimension: renewal_line_item {
    hidden: yes
    type: string
    sql: ${TABLE}.RENEWAL__LINE_ITEM___C;;
  }


### measures ###

  measure: count {
    hidden: yes
    type: count
  }

  measure: number_ps_engagements {
    label: "Number of PS Engagements"
    type: count
    filters: [product.product_type:"Fixed,Hourly",opportunity.stage_name: "Closed Won"]
  }

  measure: total_arr {
    label: "Total ARR"
    description: "The sum of each opportunity line item, where the product is billed on an annual recurring basis "
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring"]
    value_format_name: usd_0
    drill_fields: [opportunity.short_id, account.account_name, sales_rep.name, opportunity.close_date, total_arr]
  }

  measure: active_arr {
    hidden: yes
    label: "Total ARR"
    description: "The sum of each opportunity line item, where the product is billed on an annual recurring basis "
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring",opportunity.is_active_contract_calendar:"Yes"]
    value_format_name: usd_0
  }

  measure: total_nrr {
    label: "Total NRR"
    description: "The sum of each opportunity line item, where the product is only purhcased once (i.e. professional services)"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Fixed,Hourly"]
    value_format_name: usd_0
    drill_fields: [opportunity.short_id, account.name, sales_rep.name, opportunity.created_date, opportunity.close_date, total_arr, total_nrr]

  }

  measure: forecast_arr {
    group_label: "Forecast"
    description: "Sum of the ARR for opportunities where the forecast category is Forecast"
    label: "Forecast ARR"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring",opportunity.forecast_category: "Forecast"]
    value_format_name: usd_0
    drill_fields: [arr_detail*, opportunity.stage_name, opportunity.days_in_current_stage]
  }

  measure: pipeline_arr {
    description: "Sum of the ARR for opportunities where the forecast category is either Pipeline, Forecast or Upside"
    group_label: "Forecast"
    label: "Pipeline ARR"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring", opportunity.forecast_category: "Pipeline,Forecast,Upside"]
    value_format_name: usd_0
    drill_fields: [arr_detail*, opportunity.stage_name, opportunity.days_in_current_stage]
  }

  measure: upside_arr {
    group_label: "Forecast"
    label: "Upside ARR"
    description: "Sum of the ARR for opportunities where the forecast category is Upside"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring",opportunity.forecast_category: "Upside"]
    value_format_name: usd_0
    drill_fields: [arr_detail*, opportunity.stage_name, opportunity.days_in_current_stage]
  }

  measure: closed_won_arr {
    label: "Won ARR"
    description: "Sum of the ARR for opportunities where the opportunity was won"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Recurring",opportunity.stage_name: "Closed Won"]
    value_format_name: usd_0
    drill_fields: [arr_detail*]
  }

  measure: closed_won_nrr {
    label: "Won NRR"
    description: "Sum of the NRR for opportunities where the opportunity was won"
    type: sum
    sql: ${price} ;;
    filters: [product.product_type:"Fixed,Hourly",opportunity.stage_name: "Closed Won"]
    value_format_name: usd_0
    drill_fields: [nrr_detail*]
  }


  set: arr_detail {
    fields: [opportunity.short_id, account.account_name, sales_rep.team, sales_rep.name, opportunity.close_date, closed_won_arr]
  }

  set: nrr_detail {
    fields: [arr_detail*, -closed_won_arr, product.name, closed_won_nrr]
  }

}
