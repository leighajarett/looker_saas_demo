view: campaign {
  sql_table_name: `looker-private-demo.salesforce.campaign`;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: ad_type {
    type: string
    sql: ${TABLE}.AD__TYPE___C;;
  }

  dimension: conversion_point {
    type: string
    sql: ${TABLE}.CONVERSION__POINT___C;;
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
    sql:timestamp( ${TABLE}.CREATED_DATE);;
  }

  dimension_group: end {
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
    sql: timestamp(${TABLE}.END_DATE);;
  }

  dimension: grouping {
    type: string
    sql: ${TABLE}.GROUPING___C;;
  }

  dimension: is_deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  dimension: initiative_type {
    type: string
    sql: ${TABLE}.OFFER__TYPE___C;;
  }

  dimension: owner_id {
    hidden: yes
    type: string
    sql: ${TABLE}.OWNER_ID;;
  }

  dimension: parent_id {
    hidden: yes
    type: string
    sql: ${TABLE}.PARENT_ID;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.REGION_C;;
  }

  dimension_group: start {
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
    sql: ${TABLE}.START_DATE;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.TYPE;;
  }

  measure: count {
    label: "Number of Campaigns"
    type: count
    drill_fields: [id, campaign_member.count, opportunity.count]
  }
}
