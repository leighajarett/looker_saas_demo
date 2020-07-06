view: lead {
  sql_table_name: `looker-private-demo.salesforce.lead`;;

  dimension: called {
    type: yesno
    sql: ${TABLE}.CALLED_C;;
  }

  dimension: company_type {
    type: string
    sql: ${TABLE}.COMPANY__TYPE___C;;
  }

  dimension: converted_account_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CONVERTED_ACCOUNT_ID;;
  }

  dimension: converted_contact_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CONVERTED_CONTACT_ID;;
  }

  dimension_group: converted {
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
    sql: timestamp(${TABLE}.CONVERTED_DATE);;
  }

  dimension: converted_opportunity_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CONVERTED_OPPORTUNITY_ID;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.COUNTRY;;
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
    sql:timestamp(${TABLE}.CREATED_DATE);;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.DEPARTMENT___C;;
  }

  dimension: disqualified_reason {
    type: string
    sql: ${TABLE}.DISQUALIFIED__REASON___C;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL;;
  }

  dimension: first_name {
    hidden: yes
    type: string
    sql: ${TABLE}.FIRST_NAME;;
  }

  dimension: last_name {
    hidden: yes
    type: string
    sql: ${TABLE}.LAST_NAME;;
  }

  dimension: name {
    type: string
    sql: concat(${first_name},' ', ${last_name}) ;;
  }

  dimension: intro_meeting {
    type: yesno
    sql: ${TABLE}.INTRO__MEETING___C;;
  }

  dimension: is_deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  dimension: processing_status {
    type: string
    sql: ${TABLE}.LEAD__PROCESSING__STATUS___C;;
  }

  dimension: score_name {
    type: string
    sql: ${TABLE}.LEAD_SCORE_NAME_C;;
  }

  dimension: lead_source {
    type: string
    sql: ${TABLE}.LEAD_SOURCE;;
  }

  dimension: territory {
    type: string
    sql: COALESCE(${TABLE}.LEAD_TERRITORY_C", ${TABLE}.TERRITORY___C") ;;
  }

  dimension: owner_id {
    hidden: yes
    type: string
    sql: ${TABLE}.OWNER_ID;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.PHONE;;
  }

  dimension: postal_code {
    type: zipcode
    sql: ${TABLE}.POSTAL_CODE;;
  }

  dimension: sdr_assigned {
    hidden: yes
    type: string
    sql: ${TABLE}.SDR__ASSIGNED___C;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.STATUS;;
  }


  measure: count {
    label: "Number of Leads"
    type: count
    drill_fields: [last_name, first_name]
  }
}
