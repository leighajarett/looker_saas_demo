view: organization {
  sql_table_name: looker-private-demo.zendesk.organization
    ;;
  drill_fields: [id]

  #### Primary Key ####

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  #### Foreign Keys ####

  dimension: external_id {
    hidden: yes
    type: string
    sql: ${TABLE}.EXTERNAL_ID;;
  }

  dimension: group_id {
    type: string
    hidden: yes
    sql: ${TABLE}.GROUP_ID;;
  }

  dimension: salesforce_account_id {
    hidden: yes
    type: string
    sql: ${TABLE}.SALESFORCE_ACCOUNT_ID;;
  }

  #### Date Fields ####

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


}