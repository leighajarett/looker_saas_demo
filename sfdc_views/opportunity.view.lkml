view: opportunity {
  sql_table_name: `looker-private-demo.salesforce.opportunity`;;

  ### primary keys ###

  dimension: id {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: short_id {
    label: "Opportunity ID"
    sql: SUBSTR(${id},0,15) ;;
    #hard coded to match a fake opportunity in our demo salesforce
    link: {
      icon_url: "https://cdn.iconscout.com/icon/free/png-512/salesforce-3-569548.png"
      label: "View Opportunity in Salesforce"
      url: "https://looker--zapier.cs22.my.salesforce.com/0061700000L27Wr"
    }
    action: {
      label: "Update SFDC Opportunity"
      url: "https://hooks.zapier.com/hooks/catch/3604151/ourykab/"
      icon_url: "https://cdn.iconscout.com/icon/free/png-512/salesforce-3-569548.png"

      param: {
        name: "Opportunity Id"
       value: "0061700000L27XzAAJ"
      }
      form_param: {
        name: "Sales Stage"
        type: select
        option: {
          name: "Qualify"
        }
        option: {
          name: "Develop"
        }
        option: {
          name: "Develop Positive"
        }
        option: {
          name: "Negotiate"
        }
        default: "{{ opportunity.stage_name }}"
      }

      form_param: {
        name: "Next Steps"
        type: textarea
      }
      form_param: {
        name: "Next Steps Date"
        type: string
        description: "Format mm/dd/yyyy"
      }
    }
    required_fields: [ probability, amount, stage_name]
  }

  ###  foreign keys  ###

  dimension: account_id {
    type: string
    hidden: yes
    sql: ${TABLE}.ACCOUNT_ID;;
  }

  dimension: campaign_id {
    type: string
    hidden: yes
    sql: ${TABLE}.CAMPAIGN_ID;;
  }

  dimension: created_by_id {
    hidden: yes
    type: string
    sql: ${TABLE}.CREATED_BY_ID;;
  }

  dimension: license {
    hidden: yes
    type: string
    sql: ${TABLE}.LICENSE___C;;
  }

  dimension: owner_id {
    hidden: yes
    type: string
    sql: ${TABLE}.OWNER_ID;;
  }

  dimension: renewal_opportunity_id {
    type: string
    #sql: ${TABLE}.RENEWAL__OPPORTUNITY___C;;
    #shortetning the ID for display
    sql: SUBSTR( ${TABLE}.RENEWAL__OPPORTUNITY___C,0,15) ;;
    #hard coded to match a fake opportunity in our demo salesforce
    link: {
      icon_url: "https://cdn.iconscout.com/icon/free/png-512/salesforce-3-569548.png"
      label: "View Opportunity in Salesforce"
      url: "https://looker--zapier.cs22.my.salesforce.com/0061700000L27Wr"
    }
  }

  ### details of opp ###

  dimension: is_deleted {
    hidden: no
    type: yesno
    sql: ${TABLE}.IS_DELETED;;
  }

  dimension: type {
    description: "Type of opportunity (i.e. New Business, Renewal)"
    type: string
    sql: ${TABLE}.TYPE;;
  }

  dimension: is_active_contract {
    description: "This field tells if the contract is currently active (i.e. it has already closed won and the current date is in beteween the start and end dates"
    type: yesno
    sql:  ${stage_name} = 'Closed Won'
    and ${start_date} <= current_date()
    and (coalesce(${cancellation_date},${end_date}) is NULL or coalesce(${cancellation_date},${end_date}) > current_date() );;
  }

  dimension: is_active_contract_calendar {
    hidden: no
    #used in NDT to find active accounts
    type: yesno
    sql:  ${stage_name} = 'Closed Won'
        --add buffer window
          and ${start_date} <= ${activity_calendar.activity_date}
          --buffer window for renewals
          and (coalesce(${cancellation_date},${end_date}) is NULL or date_add(coalesce(${cancellation_date},${end_date}), interval 30 day) > ${activity_calendar.activity_date});;
  }

  dimension: amount {
    description: "Annual Contract Value for the first year (i.e. this includes ARR + NRR)"
    label: "ACV"
    type: number
    sql: ${TABLE}.AMOUNT;;
    value_format_name: usd_0
    action: {
      label: "Update Salesforce Amount"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://c2.sfdcstatic.com/etc/designs/sfdc-www/en_us/favicon.ico"
      param: {
        name: "id"
        value: "{{ row['opportunities.id'] }}"
      }
      param: {
        name: "Content-Type"
        value: "application/x-www-form-urlencoded"
      }
      form_param: {
        type: string
        name: "Update Amount"
        required:  yes
      }
    }
  }

  dimension: is_ae_accepted {
    type: yesno
    label: "Is AE Accepted"
    description: "The opportunity was accepted into stage 2 or above"
    sql: ${stage_name_sort} >= 2;;
  }

  ### salesforce info ###

  dimension: forecast_category {
    type: string
    sql: case when ${TABLE}.FORECAST_CATEGORY_NAME = 'BestCase' then 'Upside' else ${TABLE}.FORECAST_CATEGORY_NAME end;;
  }

  dimension: is_self_sourced {
    description: "Is the opportunity sourced from the ownder?"
    type: yesno
    sql:${created_by_id} = ${owner_id};;
  }

  dimension: probability {
    type: number
    sql: ${TABLE}.PROBABILITY;;
  }

  dimension: stage_name_sort {
    hidden: yes
    type: number
    sql: case
              when ${TABLE}.STAGE_NAME like '%Qualif%' then 2
              when ${TABLE}.STAGE_NAME like '%Lead%' or ${TABLE}.STAGE_NAME like '%Prospect%' then 1
              when ${TABLE}.STAGE_NAME like '%Trial%' then 3
              when ${TABLE}.STAGE_NAME like '%Commit%' or ${TABLE}.STAGE_NAME like '%Developed%' then 4
              when ${TABLE}.STAGE_NAME like '%Negotiation%' or ${TABLE}.STAGE_NAME like '%Proposal%' then 5
          else 5 end ;;
  }

  dimension: stage_name {
    order_by_field: stage_name_sort
    type: string
    sql: case
              when ${TABLE}.STAGE_NAME like '%Qualif%' then 'Qualified'
              when ${TABLE}.STAGE_NAME like '%Lead%' or ${TABLE}.STAGE_NAME like '%Prospect%' then 'Active Lead'
              when ${TABLE}.STAGE_NAME like '%Trial%' then 'In Trial'
              when ${TABLE}.STAGE_NAME like '%Negotiation%' or ${TABLE}.STAGE_NAME like '%Proposal%' then 'Negotiation'
              when ${TABLE}.STAGE_NAME like '%Commit%' or ${TABLE}.STAGE_NAME like '%Developed%' then 'Developed'
          else ${TABLE}.STAGE_NAME end;;
#     action: {
#       label: "Change Opportunity Stage"
#       url: "https://hooks.zapier.com/hooks/catch/5505451/oim8n3h/"
#       icon_url: "https://cdn.iconscout.com/icon/free/png-512/salesforce-3-569548.png"
# #       form_param: {
#         name: "New Stage Name"
#         option: {
#           name: "Active Lead"
#         }
#         option: {
#           name: "Qualified"
#         }
#         option: {
#           name: "In Trial"
#         }
#      }
#     }
  }

  ### date fields ###

  dimension_group: created {
    label: "  Created"
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
    convert_tz: no
    sql:timestamp(${TABLE}.CREATED_DATE);;
  }

  dimension_group: close {
    label: "  Closed"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year,
      quarter_of_year,
      day_of_month,
      month_num
    ]
    convert_tz: no
    sql: timestamp(${TABLE}.CLOSE_DATE);;
  }

  dimension: end_of_week {
    group_label: "  Closed Date"
    description: "Is the close day the last day of a calendar week (Saturday)?"
    label: "Closed at End of Week"
    type: yesno
    sql: EXTRACT(DAYOFWEEK FROM ${close_date}) = 7;;
  }

  dimension: end_of_month {
    group_label: "  Closed Date"
    description: "Is the close day the last day of the month?"
    label: "Closed at End of Month"
    #group_label: "End of [Period]"
    type: yesno
    sql: ${close_date} = DATE_ADD(DATE_ADD(DATE_TRUNC(${close_date}, month), INTERVAL 1 MONTH), INTERVAL -1 DAY) ;;
  }

  dimension: end_of_quarter {
    group_label: "  Closed Date"
    label: "Closed at End of Quarter"
    description: "Is the close day the last day of the quarter?"
    type: yesno
    sql: ${close_date} = DATE_ADD(DATE_ADD(DATE_TRUNC(${close_date}, month), INTERVAL 1 MONTH), INTERVAL -1 DAY)
      AND ${close_date} in (3,6,9,12);;
  }

  dimension: end_of_year {
    description: "Is the close day the last day of the year?"
    group_label: "  Closed Date"
    label: "Closed at End of Year"
    type: yesno
    sql: ${close_date} = DATE_ADD(DATE_ADD(DATE_TRUNC(${close_date}, month), INTERVAL 1 MONTH), INTERVAL -1 DAY)
      AND ${close_month_num} = 12;;
  }

  dimension: days_left_in_quarter {
    group_label: "  Closed Date"
    label: "Days Left in Quarter at Close"
    type: duration_day
    description: "How many days were left in the quarter when the deal closed?"
    sql_start: ${close_raw} ;;
    sql_end: timestamp_add(TIMESTAMP_TRUNC(timestamp(date_add(${close_date}, interval 1 QUARTER)), QUARTER), interval -1 DAY);; #last day of next quarter
  }

  dimension: days_left_in_year {
    group_label: "  Closed Date"
    label: "Days Left in Year at Close"
    type: duration_day
    description: "How many days were left in the year when the deal closed?"
    sql_start: ${close_raw} ;;
    sql_end: timestamp_add(TIMESTAMP_TRUNC(timestamp(date_add(${close_date}, interval 1 YEAR)), YEAR), interval -1 DAY);; #last day of next year
  }

  dimension_group: start {
    label: "Contract   Start"
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
    sql: timestamp(${TABLE}.START_DATE_2_0_C);;
  }

  dimension_group: end {
    label: "Contract  End"
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
    #if the end date is more than 10 years away its probably a mistake so default to 1 year after start
    sql: case when (${TABLE}.END_DATE_2_0_C > date_add(current_date(), interval 10 year) or ${TABLE}.END_DATE_2_0_C is null)
          then timestamp(date_add(${TABLE}.START_DATE_2_0_C, interval 365 day))
           else timestamp(${TABLE}.END_DATE_2_0_C) end;;
  }

  dimension: duration_days {
    hidden: yes
    type: duration_day
    sql_start: ${start_raw};;
    sql_end: ${end_raw} ;;
  }

  dimension: contract_years {
    label: "Contract Duration"
    description: "The number of years the contract is for"
    type: number
    #sometimes the dates are off by 1 or 2 days, so we need to adjust for that
    sql: round(${duration_days}/365);;
  }

  dimension_group: cancellation {
    label: "Contract Cancellation"
#     description: "The date that a specific opportunity was cancelled, if applicable"
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
    sql: timestamp(${TABLE}.CANCELLATION__DATE___C);;
  }

  dimension: first_qualified_date {
    type: date
    group_label: "Stage Dates"
    sql: (select min(h.created_date) from `looker-private-demo.salesforce.opportunity_history` as h where ${id} = h.opportunity_id and h.stage_name like '%Qualif%');;
  }

  dimension: first_trial_date {
    type: date
    group_label: "Stage Dates"
    sql: (select min(h.created_date) from `looker-private-demo.salesforce.opportunity_history` as h where ${id} = h.opportunity_id and h.stage_name like '%Trial%');;
  }

  dimension: first_develop_date {
    type: date
    group_label: "Stage Dates"
    sql: (select min(h.created_date) from `looker-private-demo.salesforce.opportunity_history` as h where ${id} = h.opportunity_id and (
    h.stage_name like '%Commit%' or h.stage_name like '%Develop%'));;
  }

  dimension: first_negotiate_date {
    type: date
    group_label: "Stage Dates"
    sql: (select min(h.created_date) from `looker-private-demo.salesforce.opportunity_history` as h where ${id} = h.opportunity_id and h.stage_name like '%Qualif%');;
  }

  dimension: days_in_current_stage {
    group_label: "Stage Dates"
    type: duration_day
    sql_start: timestamp((select max(h.created_date) from `looker-private-demo.salesforce.opportunity_history` as h where ${id} = h.opportunity_id));;
    sql_end: current_timestamp() ;;
  }

  dimension: days_in_current_stage_tier {
    group_label: "Stage Dates"
    type: tier
    tiers: [14,28,42,56]
    style: integer
    sql: ${days_in_current_stage} ;;
  }

  dimension: is_stale_opportunity {
    group_label: "Stage Dates"
    description: "Opportunity stage has not been changed in 56 days"
    type: yesno
    sql: ${days_in_current_stage}>56 ;;
  }

  dimension: days_between_qualified_and_develop {
    group_label: "Stage Dates"
    type: duration_day
    sql_start: timestamp(${first_qualified_date}) ;;
    sql_end: timestamp(${first_develop_date}) ;;
  }

  dimension: days_between_develop_and_negotiate {
    group_label: "Stage Dates"
    type: duration_day
    sql_start: timestamp(${first_develop_date});;
    sql_end: timestamp(${first_negotiate_date}) ;;
  }

  dimension: days_between_qualified_and_negotiate {
    group_label: "Stage Dates"
    type: duration_day
    sql_start: timestamp(${first_qualified_date}) ;;
    sql_end: timestamp(${first_negotiate_date});;
  }

  dimension: days_between_created_and_closed {
    group_label: "Stage Dates"
    type: duration_day
    sql_start: timestamp(${created_raw}) ;;
    sql_end: timestamp(${close_raw}) ;;
  }

  ##### Measures

  measure: count {
    label: "Number of Opportunities"
    type: count
    drill_fields: [detail*]
  }

  measure: count_accepted {
    label: "Number of Accepted Opportunities"
    type: count
    filters: [is_ae_accepted: "yes"]
    drill_fields: [detail*]
  }

  measure: count_won {
    label: "Number of Won Opportunities"
    type: count
    filters: [stage_name: "Closed Won"]
    drill_fields: [detail*]
  }

  measure: count_self_sources {
    label: "Number of Self Sourced Opportunities"
    type: count
    filters: [is_self_sourced: "yes"]
    drill_fields: [detail*]
  }

  measure: percent_of_opportunities_accepted {
    label: "Acceptance Rate"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_accepted}/nullif(${count},0) ;;
  }

  measure: win_rate {
    label: "Win Rate"
    type: number
    value_format_name: percent_1
    sql: 1.0*${count_won}/nullif(${count},0) ;;
  }

  measure: total_amount {
    label: "Total ACV"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    drill_fields: [account.account_name, total_amount]
  }

  measure: average_amount {
    label: "Average ACV per Opportunity"
    type: average
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  ### Date Measures

  measure: average_days_in_current_stage {
    group_label: "Stage Dates"
    type: average
    sql: ${days_in_current_stage} ;;
    value_format_name: decimal_1
  }

  measure: average_days_between_qualified_and_develop {
    group_label: "Stage Dates"
    type: average
    sql: ${days_between_qualified_and_develop};;
    value_format_name: decimal_1
  }

  measure: average_days_between_develop_and_negotiate {
    group_label: "Stage Dates"
    type: average
    sql: ${days_between_develop_and_negotiate};;
    value_format_name: decimal_1
  }

  measure: average_days_between_qualified_and_negotiate {
    group_label: "Stage Dates"
    type: average
    sql: ${days_between_qualified_and_negotiate};;
    value_format_name: decimal_1
  }

  measure: average_days_between_created_and_closed {
    group_label: "Stage Dates"
    type: average
    sql: ${days_between_created_and_closed};;
    value_format_name: decimal_1
  }



  # Sets of fields
  set: detail {
    fields: [
      short_id,
      account.name,
      sales_rep.name,
      days_in_current_stage,
      stage_name,
      close_date,
      total_amount
    ]
  }


}
