locals {
  base_budgets = [
    {
      # At most 10% of nodes may be reclaimed at once
      nodes   = "10%"
      reasons = ["Empty", "Drifted"]
    },
    {
      # No more than one under-utilized node at a time
      nodes   = "1"
      reasons = ["Underutilized"]
    }
  ]

  prod_drift_budget = var.environment == "prod" ? [
    {
      # Block drift-based evictions during 9-17 Mon-Fri for Production
      nodes    = "0"
      reasons  = ["Drifted"]
      schedule = "0 9 * * mon-fri"
      duration = "8h"
    }
  ] : []

  events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}