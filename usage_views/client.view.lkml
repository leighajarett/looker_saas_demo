view: client {
  sql_table_name: `looker-private-demo.customer_usage.license_client`;;
  drill_fields: [id]

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID ;;
  }

  dimension: salesforce_account_id {
    hidden: yes
    type: string
    sql: ${TABLE}.SALESFORCE_ACCOUNT_ID ;;
  }
}
