include: "opportunity.view.lkml"

view: opportunity_history {
  extends: [opportunity]
  sql_table_name: `looker-private-demo.salesforce.opportunity_history`;;


  dimension: opportunity_id {
    hidden: yes
    type: string
    # hidden: yes
    sql: ${TABLE}.OPPORTUNITY_ID;;
  }

}
