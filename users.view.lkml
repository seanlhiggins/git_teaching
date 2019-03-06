view: users {
  sql_table_name: public.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
#     label: "Campaign"
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [20,40,60,80]
    style: integer
    sql: ${age} ;;
  }

  dimension: is_user_under_35 {
    type: yesno
    sql: ${age} < 35 ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time, hour_of_day,
      date,
      week,
      month, month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: days_since_signup {
    type: duration_day
    sql_start: ${created_date} ;;
    sql_end: CURRENT_DATE ;;
  }

  dimension: is_older_than_7_days{
    type: yesno
    sql: ${days_since_signup} > 7 ;;
  }

  measure: count_users_older_than_7_days {
    type: count
    filters: {
      field: is_older_than_7_days
      value: "yes"
    }
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*, geo_fields*]
  }

  measure: count_users_from_facebook {
    type: count
    filters: {
      field: traffic_source
      value: "Facebook"
    }
  }

  measure: count_users_under_35 {
    type: count
    filters: {
      field: is_user_under_35
      value: "yes"
    }
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      first_name,
      last_name,
      aggregation.count,
      events.count,
      order_items.count
    ]
  }

  set: geo_fields { fields: [state,zip,latitude,longitude]}
}
