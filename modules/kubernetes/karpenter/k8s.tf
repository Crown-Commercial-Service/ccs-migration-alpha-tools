resource "kubernetes_namespace" "karpenter_namespace" {
  metadata {
    name = var.namespace
  }
}

# When deploying into a brand-new cluster, these manifest resources must be commented out
# for the first Terraform apply
resource "kubernetes_manifest" "nodepool_prod" {
  provider = kubernetes

  count = var.environment == "prod" ? 1 : 0

  lifecycle {
    create_before_destroy = true
  }

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "${var.cluster_name}-nodepool"
    }
    spec = {
      template = {
        spec = {
          requirements = [
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
            },
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = ["c", "m", "r", "t"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "NotIn"
              values   = ["nano", "micro", "small"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot"]
            },
          ]

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "${var.cluster_name}-nodeclass"
          }

          # Recycle nodes every 24 hours to ensure patches are up to date
          expireAfter = "24h"

          # Allow pods upto 15m to gracefully terminate
          terminationGracePeriod = "15m"
        }
      }

      # if you need to enforce overall limits, uncomment and adjust
      # limits = {
      #   cpu    = "1000"
      #   memory = "1000Gi"
      # }

      disruption = {
        # Consolidate both empty and under-utilized nodes
        consolidationPolicy = "WhenEmptyOrUnderutilized"

        # Wait 30m after pod events before considering consolidation
        consolidateAfter = "30m"

        # Set budgets
        budgets = concat(local.base_budgets, local.prod_drift_budget)
      }
    }
  }
}

resource "kubernetes_manifest" "nodepool_non_prod" {
  provider = kubernetes

  count = var.environment != "prod" ? 1 : 0

  lifecycle {
    create_before_destroy = true
  }

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "${var.cluster_name}-nodepool"
    }
    spec = {
      template = {
        spec = {
          requirements = [
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
            },
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = ["t"]
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = ["medium", "large"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot"]
            },
          ]

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "${var.cluster_name}-nodeclass"
          }

          # Recycle nodes every 24 hours to ensure patches are up to date
          expireAfter = "24h"

          # Allow pods upto 15m to gracefully terminate
          terminationGracePeriod = "15m"
        }
      }

      # if you need to enforce overall limits, uncomment and adjust
      # limits = {
      #   cpu    = "1000"
      #   memory = "1000Gi"
      # }

      disruption = {
        # Consolidate both empty and under-utilized nodes
        consolidationPolicy = "WhenEmptyOrUnderutilized"

        # Wait 3m after pod events before considering consolidation
        consolidateAfter = "3m"

        # Set budgets
        budgets = concat(local.base_budgets, local.prod_drift_budget)
      }
    }
  }
}

resource "kubernetes_manifest" "nodeclass" {
  provider = kubernetes

  lifecycle {
    create_before_destroy = true
  }

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "${var.cluster_name}-nodeclass"
    }
    spec = {
      instanceProfile = "KarpenterNodeInstanceProfile-${var.cluster_name}"
      amiFamily       = "AL2023"
      amiSelectorTerms = [
        {
          alias = "al2023@v20250304"
        },
      ]

      # blockDeviceMappings = [
      #   {
      #     deviceName = "/dev/xvda"
      #     rootVolume = true
      #     ebs = {
      #       deleteOnTermination = true
      #       encrypted           = true
      #       volumeType          = "gp3"
      #       volumeSize          = "20Gi"
      #     }
      #   },
      # ]

      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = "${var.cluster_name}"
          }
        },
      ]

      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = "${var.cluster_name}"
          }
        },
      ]
    }
  }
}
