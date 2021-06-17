terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# module "child" {
#     source=".//child"
# }


resource "random_pet" "name" {    
}

resource "random_integer" "number" {
    min=10
    max=99
}


resource "aws_budgets_budget" "monthly-budget" {
  # ...
  name              = "monthly-budget-${random_pet.name.id}-${random_integer.number.result}"
  budget_type       = "COST"
  limit_amount      = "12"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2021-06-15_00:01"

   notification {
     comparison_operator ="GREATER_THAN"
     threshold=100
     threshold_type="PERCENTAGE"
     notification_type="FORECASTED"
     subscriber_email_addresses=["saeidmousavi@yahoo.com"]
   }
} 





# resource "aws_budgets_budget" "my-second-budget" {
#   # ...
#   name              = "monthly-budget-${module.child.pet-name}-${module.child.number-result}"
#   budget_type       = "COST"
#   limit_amount      = "12"
#   limit_unit        = "USD"
#   time_unit         = "MONTHLY"
#   time_period_start = "2021-06-15_00:01"

#    notification {
#      comparison_operator ="GREATER_THAN"
#      threshold=100
#      threshold_type="PERCENTAGE"
#      notification_type="FORCASTED"
#      subscriber_email_addresses=["saeidmousavi@yahoo.com"]
#    }
# }

