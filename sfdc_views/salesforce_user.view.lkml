view: salesforce_user {
  sql_table_name: `looker-private-demo.salesforce.user`  ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID;;
  }

  dimension: manager_id {
    #the user id of the manager, used to self join
    hidden: yes
    type: string
    sql: ${TABLE}.manager_id;;
  }

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
    sql: timestamp(${TABLE}.CREATED_DATE);;
  }

  dimension_group: on_quota  {
    label: "On Quota"
    description: "How long has the rep been on quota"
    type: duration
    intervals: [day, month, year]
    sql_start: ${quota__start_raw}  ;;
    sql_end: current_timestamp() ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL;;
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
    sql: concat(${first_name},' ',${last_name}) ;;
    link: {
      label: "Sales Rep Deep Dive"
       url: "{% if role_name._value == 'Inside Account Executive' or role_name._value == 'Outside Account Executive' %}
            /dashboards/zwaWaov6esPg8tNLVPtrkJ?Sales%20Rep%20Name={{ value }} {% endif %}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
    action: {
      label: "{% if role_name._value == 'Inside Account Executive' or role_name._value == 'Outside Account Executive' %} Message Sales Rep{% endif %}"
      url: "https://hooks.zapier"
      icon_url: "http://www.slack.com/favicon.ico"
      form_param: {
        name: "Message"
        type: textarea
        required: yes
        default:
        "Hi {{ first_name._value }}, I wanted to chat with you about a deal - do you have some time this week?"
      }
    }
    required_fields: [first_name]
  }


  dimension_group: hire {
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
    sql:timestamp(${TABLE}.HIRE__DATE___C);;
  }

  dimension: is_active {
    hidden: yes
    type: yesno
    sql: ${TABLE}.IS_ACTIVE;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.PHONE;;
  }

  dimension_group: quota__start {
    type: time
    timeframes: [
      raw,
      date,
      month,
      quarter,
      year,
      month_num
    ]
    convert_tz: no
    sql: timestamp(${TABLE}.QUOTA__START__DATE___C);;
  }

  dimension: role_name {
    label: "Title"
    type: string
    sql: case when ${TABLE}.ROLE__NAME___C = "Account Executive" then concat(${sales_team},' ',${TABLE}.ROLE__NAME___C)
            else ${TABLE}.ROLE__NAME___C end;;
  }

  dimension: sales_team {
    label: "Segment"
    description: "The business segment that the rep covers is on, either Inside, Outside, or Retention"
    type: string
    sql: ${TABLE}.SALES__TEAM___C;;
  }

  dimension: region {
    description: "The region the rep covers, either East, West or UK/Europe"
    type: string
    sql: case when ${TABLE}.AE_REGION_C = 'Global' then null else ${TABLE}.AE_REGION_C  end;;
  }

  dimension: team_alias {
    hidden: yes
    sql: lower(concat(${sales_team},'-', case when ${region} = 'UK/Europe' then 'EMEA' else ${region} end, '-managers@looker.com')) ;;
  }


  dimension: segment_region {
    drill_fields: [account.billing_state, sales_manager.name]
    label: "Team"
    description: "The segment and region that the rep is tied to"
    type: string
    sql: concat(${sales_team},' ',${region}) ;;
    link: {
      label: "Team Performance Dashboard"
      url: "https://demo.looker.com/dashboards/5716?Sales%20Team%20Segment={{ sales_team._value }}&Sales%20Team%20Region={{ region._value }}"
      icon_url: "https://looker.com/assets/img/images/logos/looker_grey.svg"
    }
    action: {
      url: "https://hooks.zapier.com/hooks/catch/5505451/oih24lt"
      label: "Schedule Team Planning Session"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Google_Calendar_icon.svg/1200px-Google_Calendar_icon.svg.png"
      form_param: {
        name: "Event Start Time"
        default: "{{ 'now' | date: '%s' | plus: 86400 | date: '%Y-%m-%d %H:00' }}"
        required: yes
      }
      form_param: {
        name: "Event End Time"
        default: "{{ 'now' | date: '%s' | plus: 86400 | date: '%Y-%m-%d %H:30' }}"
        required: yes
      }
      form_param: {
        name: "Organizer Email"
        required: yes
        default: "{{ _user_attributes['email'] }}"
      }
      form_param: {
        name: "Invite Users"
        default: "{{ team_alias._value }}"
        required: yes
      }
      form_param: {
        name: "Calendar Event Name"
        default: "{{ value }} Sales Strategy"
        required: yes
      }
      form_param: {
        name: "Calendar Event Description"
        default: "Hi team - I'm setting up some time for us to focus on strategy for how to meet this quarter's sales goals, let me know if this time does not work"
        required: no
        type: textarea
      }

    }
  }

  ### Goals ###

  #hardcoded just for demo purposes, these fields may be stored in a table or pulled in from other sources

  dimension: full_annual_arr_quota {
    hidden: yes
    type: number
    sql: case when ${sales_team} = 'Inside' then 20000*4 else 25000*4 end;;
  }

  dimension: full_annual_services_quota {
    hidden: yes
    type: number
    sql: case when ${sales_team} = 'Inside' then 5000*4 else 10000*4 end;;
  }

  dimension: annual_arr_quota {
    group_label: "Individual Goals"
    label: "License Quota"
    description: "The current annual license quota for the sales rep"
    type: number
    #adjust annual quota based on how long theyve bee on quota for
    sql: case when ${quota__start_year} = EXTRACT(YEAR FROM current_date()) then ${full_annual_arr_quota}
              when ${quota__start_year} < EXTRACT(YEAR FROM current_date()) then (${quota__start_month_num}/12)*${full_annual_arr_quota}
              else null end ;;
    value_format_name: usd_0
  }

  dimension: annual_services_quota {
    group_label: "Individual Goals"
    label: "Services Quota"
    description: "The current annual professional services quota for the sales rep"
    type: number
    #adjust annual quota based on how long theyve bee on quota for
    sql: case when ${quota__start_year} = EXTRACT(YEAR FROM current_date()) then ${full_annual_services_quota}
              when ${quota__start_year} < EXTRACT(YEAR FROM current_date()) then (${quota__start_month_num}/12)*${full_annual_services_quota}
              else null end ;;
    value_format_name: usd_0
  }

  dimension: acceptance_rate_goal {
    group_label: "Individual Goals"
    description: "The ideal acceptance rate"
    type: number
    sql: .9;;
    value_format_name: percent_0
 }

  dimension: self_generated_ops_goals {
    group_label: "Individual Goals"
    description: "Number of self-sources ops that should be generated by an AE each quarter"
    type: number
    sql: 3;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, user_role.id, user_role.name]
  }
}
