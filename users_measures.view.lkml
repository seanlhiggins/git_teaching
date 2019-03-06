include: "users.view.lkml"
view: users_measures {
  extends: [users]

  measure: average_ltv {}
}
