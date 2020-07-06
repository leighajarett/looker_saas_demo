view: satisfaction_ratings {
  view_label: "Ticket"
  sql_table_name: looker-private-demo.zendesk.satisfaction_ratings
    ;;
  drill_fields: [id]

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: assignee_id {
    hidden: yes
    type: string
    sql: ${TABLE}.ASSIGNEE_ID;;
  }

  dimension: group_id {
    type: string
    hidden: yes
    sql: ${TABLE}.GROUP_ID;;
  }

  dimension: requester_id {
    hidden: yes
    type: string
    sql: ${TABLE}.REQUESTER_ID;;
  }

  dimension: score_sort {
    hidden: yes
    type: string
    sql: case when ${TABLE}.SCORE = 'Very unsatisfied' then 1
              when ${TABLE}.SCORE = 'Unsatisfied' then 2
              when ${TABLE}.SCORE = 'Neutral' then 3
              when ${TABLE}.SCORE = 'Satisfied' then 4
              when ${TABLE}.SCORE = 'Very satisfied' then 5 else null end
              ;;
  }

  dimension: score {
    group_label: "Rating"
    label: "Customer Satisfaction Rationg"
    order_by_field: score_sort
    type: string
    sql: ${TABLE}.SCORE;;
    html:
    {% if value == 'Very unsatisfied' %}
    <div style="background: #FBB555; border-radius: 2px; color: #fff; display: inline-block; font-size: 11px; font-weight: bold; line-height: 1; padding: 3px 4px; width: 100%; text-align: center;">{{ rendered_value }}</div>
    {% elsif value == 'Unsatisfied' %}
        <div style="background: #FBB555; border-radius: 2px; color: #fff; display: inline-block; font-size: 11px; font-weight: bold; line-height: 1; padding: 3px 4px; width: 100%; text-align: center;">{{ rendered_value }}</div>
    {% elsif value == 'Neutral' %}
    <div style="background: #c9daf2; border-radius: 2px; color: #fff; display: inline-block; font-size: 11px; font-weight: bold; line-height: 1; padding: 3px 4px; width: 100%; text-align: center;">{{ rendered_value }}</div>
    {% elsif value == 'Satisfied' %}
    <div style="background: #8BC34A; border-radius: 2px; color: #fff; display: inline-block; font-size: 11px; font-weight: bold; line-height: 1; padding: 3px 4px; width: 100%; text-align: center;">{{ rendered_value }}</div>
    {% elsif value == 'Very satisfied' %}
    <div style="background:  #8BC34A; border-radius: 2px; color: #fff; display: inline-block; font-size: 11px; font-weight: bold; line-height: 1; padding: 3px 4px; width: 100%; text-align: center;">{{ rendered_value }}</div>
    {% endif %} ;;
  }


  dimension: ticket_id {
    type: string
    hidden: yes
    sql: substr(${TABLE}.ticket_id,0,10) ;;
  }

  dimension: comment {
    group_label: "Rating"
    type: string
    sql: ${TABLE}.comment;;
  }


  measure: average_csat {
    group_label: "Rating"
    label: "Average CSAT"
    description: "The average customer satisfaction score, on a scale of 1-5 with 1 being Very Unsatisfied"
    type: average
    sql: ${score_sort} ;;
    value_format_name: decimal_1
    drill_fields: [ticket.id, zendesk_user.name, account.name, average_csat]
  }

  measure: count {
    hidden: yes
    group_label: "Rating"
    label: "Number of Satisfaction Ratings"
    type: count
    drill_fields: [id, groups.id, groups.name, ticket.id]
  }

  measure: percent_tickets_with_rating {
    group_label: "Rating"
    type: number
    sql: 1.0*${count}/nullif(${ticket.count},0) ;;
    value_format_name: percent_1
  }

}