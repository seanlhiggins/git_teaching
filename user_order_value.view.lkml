explore: user_order_value_snapshot {}
view: user_order_value_snapshot {
  derived_table: {
    sql_trigger_value: SELECT CURRENT_DATE ;;
    create_process: {
#       sql_step: DROP TABLE IF EXISTS profservices_scratch.oi_snapshot_date_{{'now' | date: "%s" | minus : 86400 | date: "%Y%m%d" }};;
      sql_step: CREATE TABLE teach_scratch.oi_snapshot_date_{{'now' | date: "%s" | minus : 86400 | date: "%Y%m%d" }} AS ${user_value_yesterday_data.SQL_TABLE_NAME} ;;
      sql_step: CREATE TABLE ${SQL_TABLE_NAME} AS SELECT * FROM teach_scratch.oi_snapshot_date_{{'now' | date: "%s" | minus : 86400 | date: "%Y%m%d" }} ;;
#       sql_step:  INSERT INTO teach_scratch.oi_snapshot_date ;;
    }

  }
  dimension: snapshot_date {
    type: date
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."user_id" ;;
  }

  dimension: customer_avg_order_value {
    description: "User's Average Order Value"
    type: number
    sql: ${TABLE}.customer_avg_order_value ;;
  }

  measure: total_avg_order_value {
    description: "Total Average Order Value across all orders"
    type: average
    sql: ${TABLE}.total_avg_order_value ;;
  }

  dimension: hvlv {
    type: string
    case: {
      when: {
        label: "High Value"
        sql: ${customer_avg_order_value} > (${TABLE}.total_avg_order_value*120/100) ;;
      }
      else: "Low Value"
    }
  }

  dimension: avg_time_between_orders {
    type: number
    sql: ${TABLE}.avg_time_between_orders;;
  }

  dimension: hflf {
    type: string
    case: {
      when: {
        label: "High Frequency"
        sql: ${avg_time_between_orders} > (59*120/100) ;;
      }
      else: "Low Frequency"
    }
  }

  measure: count_hvhf {
    type: count
    filters: {
      field: hvlv
      value: "High Value"
    }
    filters: {
      field: hflf
      value: "High Frequency"
    }
  }
  measure: count_hvlf {
    type: count
    filters: {
      field: hvlv
      value: "High Value"
    }
    filters: {
      field: hflf
      value: "Low Frequency"
    }
  }
  measure: count_lvhf {
    type: count
    filters: {
      field: hvlv
      value: "Low Value"
    }
    filters: {
      field: hflf
      value: "High Frequency"
    }
  }
  measure: count_lvlf {
    type: count
    filters: {
      field: hvlv
      value: "Low Value"
    }
    filters: {
      field: hflf
      value: "Low Frequency"
    }
  }
}

explore: user_value_yesterday_data {}
view: user_value_yesterday_data {
  derived_table: {
    explore_source: user_order_value {
      column: avg_time_between_orders {}
      column: customer_avg_order_value {}
      column: hflf {}
      column: hvlv {}
      column: snapshot_date {}
      column: user_id {}
      column: count_hvhf {}
      column: count_hvlf {}
      column: count_lvhf {}
      column: count_lvlf {}
      column: total_avg_order_value {}
    }
  }
  dimension: avg_time_between_orders {
    type: number
  }
  dimension: customer_avg_order_value {
    description: "User's Average Order Value"
    type: number
  }
  dimension: hflf {}
  dimension: hvlv {}
  dimension: snapshot_date {
    type: date
  }
  dimension: user_id {
    type: number
  }
  dimension: count_hvhf {
    type: number
  }
  dimension: count_hvlf {
    type: number
  }
  dimension: count_lvhf {
    type: number
  }
  dimension: count_lvlf {
    type: number
  }
  dimension: total_avg_order_value {
    description: "Total Average Order Value across all orders"
    type: number
  }
}

explore: user_order_value {}
view: user_order_value {
  derived_table: {
    distribution_style: all
    sortkeys: ["user_id","snapshot_date"]
    sql:  SELECT a.user_id
           ,max(created_at) as last_order
           ,avg(a.order_sale_price) as customer_avg_order_value
           ,avg(b."order_items.avg_revenue") as total_avg_order_value
           ,avg(datediff(day,a.lag_created_at,a.created_at)) as time_between_orders
           ,c.count AS orders_in_last_6_months
           ,CURRENT_DATE as snapshot_date
          FROM

            (SELECT
                user_id,
                order_items.sale_price as order_sale_price
                , order_items.created_at
                , lag(order_items.created_at,1) over (partition by user_id order by order_items.created_at) as lag_created_at
                FROM public.order_items  AS order_items
                GROUP BY 1,2,order_items.created_at
                ORDER BY 2 DESC) a

          LEFT OUTER JOIN

            (SELECT COUNT(*), user_id
            FROM public.order_items
            WHERE created_at > DATEADD(month,-6, DATE_TRUNC('month',GETDATE()))
            GROUP BY 2) c

          ON a.user_id = c.user_id

          CROSS JOIN

            (SELECT
            AVG(order_items.sale_price ) AS "order_items.avg_revenue"
            FROM public.order_items  AS order_items) b

          GROUP BY 1,6
       ;;
      sql_trigger_value: SELECT CURRENT_DATE ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: snapshot_date {
    type: date
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."user_id" ;;
  }

  dimension: customer_avg_order_value {
    description: "User's Average Order Value"
    type: number
    sql: ${TABLE}.customer_avg_order_value ;;
  }

  measure: total_avg_order_value {
    description: "Total Average Order Value across all orders"
    type: average
    sql: ${TABLE}.total_avg_order_value ;;
  }

  dimension: hvlv {
    type: string
    case: {
      when: {
        label: "High Value"
        sql: ${customer_avg_order_value} > (${TABLE}.total_avg_order_value*120/100) ;;
      }
      else: "Low Value"
    }
  }

  dimension: avg_time_between_orders {
    type: number
    sql: ${TABLE}.time_between_orders;;
  }

  dimension: hflf {
    type: string
    case: {
      when: {
        label: "High Frequency"
        sql: ${avg_time_between_orders} > (59*120/100) ;;
      }
      else: "Low Frequency"
    }
  }

  measure: count_hvhf {
    type: count
    filters: {
      field: hvlv
      value: "High Value"
    }
    filters: {
      field: hflf
      value: "High Frequency"
    }
  }
  measure: count_hvlf {
    type: count
    filters: {
      field: hvlv
      value: "High Value"
    }
    filters: {
      field: hflf
      value: "Low Frequency"
    }
  }
  measure: count_lvhf {
    type: count
    filters: {
      field: hvlv
      value: "Low Value"
    }
    filters: {
      field: hflf
      value: "High Frequency"
    }
  }
  measure: count_lvlf {
    type: count
    filters: {
      field: hvlv
      value: "Low Value"
    }
    filters: {
      field: hflf
      value: "Low Frequency"
    }
  }

  set: detail {
    fields: [user_id, customer_avg_order_value, total_avg_order_value, hvlv]
  }
}
