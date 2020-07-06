view: goals {
  view_label: "Company Goals"
  # https://docs.google.com/spreadsheets/d/1aSCKjGtnv2gvJomSLCrRVl5_0AjPp7fm2z6e41_U7z0/edit#gid=0
  sql_table_name: `looker-private-demo.salesforce.goals` ;;

  # The goals in the spread sheet are at different hierarchical levels, we can't simply sum up the indiviual team goals because
  # the finance team sets goals on a regional, business segement and team level - we need to use liquid to select the correct goal for the end user


  ### Raw dimensions ###

  dimension: goal_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.Goal_ID ;;
  }

  dimension: quarter {
    hidden: yes
    type: string
    sql: ${TABLE}.Quarter ;;
  }

  dimension: year {
    hidden: yes
    type: number
    sql: ${TABLE}.Year ;;
  }

  dimension: _inside_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Inside_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _inside_east_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Inside_East_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _inside_emea_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Inside_EMEA_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _inside_west_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Inside_West_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _outside_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Outside_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _outside_east_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Outside_East_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _outside_emea_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Outside_EMEA_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _outside_west_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Outside_West_Bookings_ ;;
    value_format_name: usd_0
  }

  dimension: _total_bookings_ {
    hidden: yes
    type: number
    sql: ${TABLE}._Total_Bookings_ ;;
    value_format_name: usd_0
  }

  ### Derived fields ###

  dimension: parameterized_license_goal {
    #this measure uses liquid to select the correct goal based on other fields the user has selected
    hidden: yes
    type: number
    sql:{% if sales_rep.region._in_query or sales_rep.segment_region._in_query %}
            {% if sales_rep.sales_team._in_query or sales_rep.segment_region._in_query%}
            --if both the region and the segment are in the query we select the relevant team goal
            case when ${sales_rep.region} = 'East' and ${sales_rep.sales_team} = 'Inside' then ${_inside_east_bookings_}
                  when ${sales_rep.region} = 'West' and ${sales_rep.sales_team} = 'Inside' then ${_inside_west_bookings_}
                  when ${sales_rep.region} = 'UK/Europe' and ${sales_rep.sales_team} = 'Inside' then ${_inside_emea_bookings_}
                  when ${sales_rep.region} = 'West' and ${sales_rep.sales_team} = 'Outside' then ${_outside_west_bookings_}
                  when ${sales_rep.region} = 'East' and ${sales_rep.sales_team} = 'Outside' then ${_outside_east_bookings_}
                  when ${sales_rep.region} = 'UK/Europe' and ${sales_rep.sales_team} = 'Outside' then ${_outside_emea_bookings_} else null end
            {% else  %}
            --if just the region is in the query
              case when ${sales_rep.region} = 'East' then ${_inside_east_bookings_} + ${_outside_east_bookings_}
                  when ${sales_rep.region} = 'West' then ${_inside_west_bookings_} + ${_outside_east_bookings_}
                  when ${sales_rep.region} = 'UK/Europe' then ${_inside_emea_bookings_} + ${_outside_emea_bookings_}
                 else null end
            {% endif %}
         {% elsif  sales_rep.sales_team._in_query%}
         --if just the team is in the query
         case when  ${sales_rep.sales_team} = 'Inside' then ${_inside_bookings_}
              when  ${sales_rep.sales_team} = 'Outside' then ${_outside_bookings_}
          else null end
        {% else  %}
        --if none are in the query select the entire company's goals
              ${_total_bookings_}
         {% endif %};;
    link: {
      icon_url: "http://ssl.gstatic.com/docs/spreadsheets/favicon3.ico"
      url: "https://docs.google.com/spreadsheets/d/15YLYvU5NWIByhmcLJvFlUqfPt3gixvnQixaVT0oMwfc/edit#gid=0&range=D:D"
      label: "Edit Value in Sheets"
    }
    value_format_name: usd_0
  }

  set: goal_fields {
    fields: [ account.account_source, account.industry, account.nps_score, account.number_of_employees, account.number_of_employees_tier,
    account.average_number_of_employees,opportunity.contract_years, opportunity_line_item.quantity, opportunity_line_item.price,
    opportunity_line_item.list_price, opportunity_line_item.list_price, opportunity_line_item.percent_discount, sales_manager.id,
    sales_manager.name, sales_manager.sales_team, sales_manager.region, sales_manager.title, sales_manager.phone, sales_manager.email,
    sales_rep.hire_date, sales_rep.hire_week,sales_rep.hire_month, sales_rep.hire_quarter, sales_rep.hire_year, sales_rep.phone,
    sales_rep.quota__start_date, sales_rep.quota__start_month, sales_rep.quota__start_quarter, sales_rep.quota__start_year, sales_rep.quota__start_month_num,
    sales_rep.days_on_quota, sales_rep.years_on_quota, sales_rep.months_on_quota,
    account.next_contract_renewal_date,account.next_contract_renewal_date_week,account.next_contract_renewal_date_month,
    account.next_contract_renewal_date_quarter,account.next_contract_renewal_date_year
  ]
}


}
