view: tags {
  view_label: "Tag"
  sql_table_name: `looker-private-demo.zendesk.tags`
    ;;
  drill_fields: [id]

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID ;;
  }

  dimension: action {
    hidden: yes
    type: string
    sql: ${TABLE}.ACTION ;;
  }

  dimension: raw_tag {
    hidden: yes
    type: string
    sql: ${TABLE}.tag ;;
  }

  dimension: topic_category {
    type: string
    sql: case when ${raw_tag} is not null then split(${raw_tag},'.')[OFFSET(1)] else 'unknown' end ;;
  }

  dimension: topic_tag {
    type: string
    sql: case when ${raw_tag} not null then split(${raw_tag},'.')[OFFSET(1)] else 'unknown' end ;;
  }

  dimension: ticket_id {
    type: string
    hidden: yes
    sql: substr(${TABLE}.ticket_id,0,10) ;;
  }

  dimension: updater_id {
    hidden: yes
    type: string
    sql: ${TABLE}.updater_id ;;
  }

  dimension: via {
    hidden: yes
    type: string
    sql: ${TABLE}.VIA ;;
  }

  measure: count {
    label: "Number of Topic Tags"
    type: count
    drill_fields: [id]
  }
}
