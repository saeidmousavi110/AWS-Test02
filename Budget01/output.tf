output "budget-name" {
    description = "The name of the budget"
    value=aws_budgets_budget.monthly-budget.name
}

output "budget-limit_amount" {
    description="The budget limit"
    value=aws_budgets_budget.monthly-budget.limit_amount
    sensitive=true
} 