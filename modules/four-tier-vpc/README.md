# Four-tier VPC

## Overview

This module provides a standardised four-tier subnet VPC which complies with the guidelines set out in [the standards doc](https://crowncommercialservice.atlassian.net/wiki/spaces/GPaaS/pages/3561685032/AWS+3+Tier+Reference+Architecture).

## Network ACLs, and customisation of

The module enforces a basic Network ACL to each subnet as per recommendations outlined in the above doc. In general these will be compatible with many apps' requirements but there will of course be a need to customise the rules for specific cases. The need to customise may be triggered by such requirements as (for example):

* A service in a web subnet requires direct database access, thus needing to "leap-frog" the application subnets
* An app adds an EFS volume and needs to allow cross-subnet traffic on the NFS port

Therefore in order to allow apps to customise these ACLs, we provide the following:

* The IDs of the network ACLs for each of the subnets is exposed in a module output called `network_acl_ids`
* The rule numbers are given in specific regions, see below

### Rule Numbering

Rules are matched in numerical order, and matching stops when a rule is found which matches the traffic being evaluated. The scheme in this core module leaves space for individual apps to add rules which are guaranteed to be evaluated either _before_ or _after_ the core rules, whichever is more appropriate.

The following number ranges should therefore be observed for ACL rules:

* 0 - 4999 Customisation by apps for rules which should _override_ core rules
* 5000 - 9999 Rules defined by the core rulesets in this module
* \>= 10000 Customisation by apps for rules which should _augment_ core rules

Note of course that ingress and egress rules are numbered independently and so while a rule in either set must be uniquely numbered within that set, there may co-exist two separate rules with the same rule number if one is an ingress rule and the other an egress rule.

### Rule Naming

If providing extra rules in an app, please follow the naming convention in place for the Terraform `aws_network_acl_rule` resources, which is four components:

1. The type of the subnet with which this rule's ACL is associated (e.g. `public`, `database`)
2. Double underscore
3. `allow` or `deny`
4. The type of traffic (e.g. `http`, `ephemeral`)
5. The 'other' subnet (e.g. `public_b`)
6. The direction of traffic (`in` or `out`)

So, for example: `web__allow_ephemeral_public_b_out`.
