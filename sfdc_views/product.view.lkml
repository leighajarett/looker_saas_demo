view: product {
  sql_table_name: `looker-private-demo.salesforce.product`  ;;
  drill_fields: [id]

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: created_by_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CREATED_BY_ID;;
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
    sql: timestamp(${TABLE}.CREATED_DATE);;
  }

  dimension: family {
    group_label: "Product Details"
    description: "Services, Platform, Users or Add-on"
    type: string
    sql: case when ${name} like '%Users%' then 'Users'
              when ${name} like '%Professional Services%' then 'Services'
              when ${name} like '%Platform%' then 'Platform' else 'Add-on' end;;
  }

  dimension: is_active {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_ACTIVE;;
  }

  dimension: is_deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  dimension: name {
    label: "Product Name"
    group_label: "Product Details"
    type: string
    sql: ${TABLE}.NAME;;
  }

  dimension: product_type {
    group_label: "Product Details"
    description: "Fixed or Recurring"
    type: string
    sql: ${TABLE}.PRODUCT__TYPE___C;;
  }

  dimension: list_price {
    group_label: "Product Details"
    description: "Price of a single, monthly unit"
    type: number
    sql: ${TABLE}.LIST_PRICE;;
    value_format_name: usd
  }

  measure: count {
    hidden: yes
    label: "Number of Products"
    type: count
    drill_fields: [id, name]
  }
}
