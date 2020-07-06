# If necessary, uncomment the line below to include explore_source.
# include: "sfdc_demo.model.lkml"

view: daily_active_accounts {
  derived_table: {
    sql_trigger_value: select current_date();;
    explore_source: opportunity_line_item {
      column: active_arr {}
      column: activity_date { field: activity_calendar.activity_date }
      column: id { field: account.id }
      derived_column: primary_key {
        sql: CONCAT(activity_date,id) ;;
      }
    }
  }

  dimension: primary_key {
    hidden: yes
    primary_key: yes
  }

  dimension: id {
    label: "Account ID"
  }

  dimension: activity_date {}

  dimension_group: calendar {
    convert_tz: no
    type: time
    timeframes: [raw,date,day_of_week,day_of_month,month_name,year,day_of_year]
    sql: timestamp(${activity_date}) ;;
  }

  dimension_group: year_ago {
    convert_tz: no
    hidden: yes
    type: time
    datatype: date
    sql: date_add(${calendar_date}, INTERVAL -1 YEAR) ;;
  }

  dimension: active_arr {
    label: "Account Active ARR"
    type: number
    value_format_name: usd
  }

  dimension: total_arr_year_ago {
    label: "Account ARR One Year Ago"
    type: number
    value_format_name: usd
    sql: ${year_ago_daily_active_accounts.active_arr} ;;
  }


  measure: total_active_arr {
    label: "Total ARR Active"
    type: sum
    sql: ${active_arr} ;;
    value_format_name: usd
  }

  measure: year_ago_active_arr {
    label: "Total ARR Active 1 Year Ago"
    type: sum
    sql: ${total_arr_year_ago} ;;
    value_format_name: usd
  }

  measure: total_active_term_arr {
    description: "Total Active ARR from Accounts that were booked at least 1 year ago"
    type: sum
    sql: ${active_arr} ;;
    value_format_name: usd
    filters: [total_arr_year_ago: ">0"]
  }

  measure: net_retention {
    type: number
    description: "Dollar Based Net Retention: the Total Term ARR / Year Ago Active ARR"
    sql: ${total_active_term_arr}/nullif(${year_ago_active_arr},0);;
    value_format_name: percent_1
    drill_fields: [account.account_name, account.end_date, year_ago_active_arr,total_active_arr]
  }

}
