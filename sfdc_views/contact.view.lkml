view: contact {
  sql_table_name: `looker-private-demo.salesforce.contact`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: account_id {
    type: string
    hidden: yes
    sql: ${TABLE}.ACCOUNT_ID;;
  }

  dimension: created_by_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CREATED_BY_ID;;
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

  dimension_group: customer_start {
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
    sql: timestamp(${TABLE}.CUSTOMER_START_DATE_C);;
  }

  dimension: department_picklist {
    type: string
    sql: ${TABLE}.DEPARTMENT__PICKLIST___C;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL;;
  }

  dimension: grouping {
    type: string
    sql: ${TABLE}.GROUPING___C;;
  }

  dimension: inactive {
    type: yesno
    sql: ${TABLE}.INACTIVE_C;;
  }

  dimension: intro__meeting {
    type: yesno
    sql: ${TABLE}.INTRO__MEETING___C;;
  }

  dimension: is_deleted {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  dimension_group: feedback_received {
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
    sql: COALESCE(${TABLE}.JUMPSTART_NPS_FEEDBACK_DATE_RECEIVED_C,${TABLE}.NPS_FEEDBACK_DATE_RECEIVED_C) ;;
  }

  dimension: nps_score {
    description: "Average NPS score from engagements with this contact"
    type: number
    sql: COALESCE(${TABLE}.JUMPSTART_NPS_SCORE_C,${TABLE}.NPS_SCORE_C) ;;
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
    sql: conact(${first_name},' ',${last_name}) ;;
  }

  dimension: lead_source {
    type: string
    sql: ${TABLE}.LEAD_SOURCE;;
  }

  dimension: active_product_user {
    type: yesno
    sql: ${TABLE}.LOOKER_ACTIVE_USER_C;;
  }

  dimension: uuid {
    hidden: yes
    type: string
    sql: ${TABLE}.LOOKER_UUID_C;;
  }

#   dimension_group: nps_feedback_date_received_c {
#     hidden: yes
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.NPS_FEEDBACK_DATE_RECEIVED_C;;
#   }
#
#   dimension: nps_score_c {
#     type: number
#     sql: ${TABLE}.NPS_SCORE_C;;
#   }

  dimension: owner_id {
    hidden: yes
    type: string
    sql: ${TABLE}.OWNER_ID;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.PHONE;;
  }

  dimension: primary_contract {
    type: yesno
    sql: ${TABLE}.PRIMARY__CONTACT___C;;
  }

  dimension: processing_status {
    type: string
    sql: ${TABLE}.PROCESSING_STATUS_C;;
  }

  dimension: territory {
    type: string
    sql: ${TABLE}.TERRITORY___C;;
  }

  dimension: zendesk_id {
    hidden: yes
    type: string
    sql: ${TABLE}.ZENDESK___ZENDESK__ID___C;;
  }

  measure: count {
    label: "Number of Contacts"
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      last_name,
      first_name,
      account.name,
      account.id,
      campaign_member.count
    ]
  }
}
