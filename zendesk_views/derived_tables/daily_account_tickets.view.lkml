view: daily_account_tickets {
  view_label: "Daily Support Activity"
    derived_table: {
      sql_trigger_value: SELECT max(created_at) from looker-private-demo.zendesk.ticket ;;
      explore_source: ticket {
        column: count {}
        column: urgent_tickets {}
        column: first_contact_resolution {}
        column: csat { field: satisfaction_ratings.average_csat }
        column: account_id { field: account.id }
        column: date {field:ticket.created_date}
        filters: {
          field: account.id
          value: "-NULL"
        }
      }
    }

    dimension: primary_key {
      primary_key: yes
      hidden: yes
      sql: concat(cast(${date_date} as string),${account_id});;
    }

    ### Foreign Keys ###

    dimension: account_id {
      hidden: yes
      label: "Customer Account ID"
    }

    dimension_group: date {
      hidden: yes
      type: time
      sql: timestamp(date(${TABLE}.date)) ;;
    }

    ### Dimensions ###

    dimension: count {
      label: "Number of Chats"
      type: number
    }

    dimension: number_chats_tier {
      style: integer
      type: tier
      sql: ${count} ;;
      tiers: [1,5,10,20]
    }

    dimension: urgent_tickets {
      label: "Number of Urgent Tickets"
      type: number
    }

    dimension: first_contact_resolution {
      label: "FCR Rate"
      description: "First contact resolution rate, the percentage of tickets that did not require an offline follow up"
      value_format_name: percent_1
      type: number
    }

    dimension: csat {
      label: "Average CSAT"
      description: "The average customer satisfaction score, on a scale of 1-5 with 1 being Very Unsatisfied"
      type: number
    }

    ### Measures ###

    measure: total_number_tickets {
      type: sum
      sql: ${count} ;;
    }

    measure: total_number_urgent_tickets {
      type: sum
      sql: ${urgent_tickets} ;;
    }

    measure: average_csat {
      type: average
      sql: ${csat} ;;
      value_format_name: decimal_1
    }

    measure: average_fcr_rate {
      type: average
      sql: ${first_contact_resolution} ;;
      value_format_name: percent_1
    }
  }