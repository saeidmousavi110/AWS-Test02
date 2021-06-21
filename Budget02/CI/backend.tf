terraform {
  backend "remote" {
    organization = "saeidmousavi110"
    workspaces {
        name = "monthly-budget"
    }
}
}