view: users_orders_facts {
  derived_table: {
    sql: SELECT
        users.email  AS "users.email",
        TO_CHAR(DATE_TRUNC('month', order_items.created_at ), 'YYYY-MM') AS "order_items.created_month",
        COUNT(*) AS "order_items.count"
      FROM public.order_items  AS order_items
      LEFT JOIN public.users  AS users ON order_items.user_id = users.id

      GROUP BY 1,DATE_TRUNC('month', order_items.created_at )
      ORDER BY 1

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: users_email {
    type: string
    sql: ${TABLE}."users.email" ;;
  }

  dimension: order_items_created_month {
    type: date_month
    sql: ${TABLE}."order_items.created_month" ;;
  }

  dimension: order_items_count {
    type: number
    sql: ${TABLE}."order_items.count" ;;
  }

  set: detail {
    fields: [users_email, order_items_created_month, order_items_count]
  }
}
