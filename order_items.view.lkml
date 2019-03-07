# explore: order_items_extended {}
view: order_items_extended {
  extends: [order_items]

  measure: total_revenue {
    label: "Show me the Money"
    sql: ${sale_price} * 2 ;;
  }
}

view: order_items {

  # sql_table_name:
  # {% if created_date._is_selected %}
  # public.order_items
  # {% elsif created_month._is_selected %}
  # public.order_items_monthly
  # {% else %}
  # public.order_items_yearly
  # {% endif %};;
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  parameter:  report_granularity{
    type: unquoted
    allowed_value: {value:"Daily"}
    allowed_value: {value:"Monthly"}
    allowed_value: {value:"Yearly"}
  }

  dimension: dynamic_date_granularity {
    type: string
    sql: {% if report_granularity._parameter_value == "Daily" %}
    ${created_date}::VARCHAR
    {% elsif report_granularity._parameter_value == "Monthly" %}
    ${created_month}
    {% else %}
    ${created_year}
    {% endif %};;

  }

  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
  }

  dimension: days_since_order {
    type: string
#     sql_start: ${created_date} ;;
#     sql_end: CURRENT_DATE ;;
    sql: COALESCE(DATEDIFF('day',${created_date},CURRENT_DATE)::VARCHAR,'N/A') ;;
  }

  dimension_group: delivered {
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
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_revenue {
    label: "{% if _user_attributes['country'] == 'USA' %} Money! {% else %} Revenue {% endif %}"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    html: {{rendered_value}}|| {{ order_items.avg_revenue._rendered_value }}</div>

    ;;
  }

  measure: avg_revenue {
    type: average
    sql: ${sale_price} ;;
  }

  parameter: metric_selector {
    type: unquoted
    allowed_value: {value:"Average"}
    allowed_value: {value:"Total"}
  }

  measure: dynamic_metric {
    label_from_parameter: metric_selector
    type: number
    sql: {% if metric_selector._parameter_value == "Average" %}
    AVG(${sale_price})
    {% else %}
    SUM(${sale_price})
    {% endif %};;
  }

  measure: total_minus_average {
    type: number
    sql: ${total_revenue} - ${avg_revenue} ;;
  }

  measure: order_value_per_order {
    type: number
    sql: 1.0 * ${total_revenue} / NULLIF(${count},0) ;;
  }

  measure: total_gross_margin {
    type: sum
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
