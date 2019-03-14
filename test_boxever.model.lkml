connection: "events_ecommerce"

# include all the views
include: "*.view"

datagroup: etl_cycle {
  sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "24 hours"
}
# test comment
# another test comment
# access_grant:  {}
explore: aggregation {
  required_access_grants: []
  join: users {
    type: left_outer
    sql_on: ${aggregation.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: distribution_centers {}

explore: etl_jobs {}

explore: events {
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: foo {}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

access_grant: country {
  user_attribute: country
  allowed_values: ["UK"]
}

# explore: order_items_with_events {
#   required_access_grants: [country]
#   fields: [ALL_FIELDS*,-order_items.total_gross_margin]
#   extends: [order_items]
#   join: events {
#     sql_on: ${events.created_date} = ${order_items.created_date} ;;
#   }
# }



explore: order_items {
  label: "Orders, Users, Inventory Items"
  description: "Contains Ecommerce Data, use freely, here's some more info"
  fields: [ALL_FIELDS*,-order_items.total_gross_margin]

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_value {

    sql_on: ${user_order_value.user_id} = ${users.id};;
    type: left_outer
    relationship: one_to_one
  }


}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: users {
  join: user_order_value {
    sql_on: ${user_order_value.user_id} = ${users.id};;
    type: left_outer
    relationship: one_to_one
  }

}
