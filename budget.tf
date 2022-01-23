# This code is defining only a small budget for testing in AWS.
# It will be used as a safety measure, against big cost of expences.

resource "aws_budgets_budget" "cost" {
  budget_type  = "COST"
  limit_amount = "10"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  name         = "Monthly AWS Overall Cost Budget"
}