# CCS Migration Alpha Tools

This repository contains reusable sections of infrastructure code, intended for use solely within the Migration Alpha project.

As with all things in the Alpha, this is just one representation of a possible construct for use during a beta phase. It's illustrative rather than directive.

## Usage

It's intended to be used as a Git submodule within consuming projects. For example:

```bash
git submodule add git@github.com:Crown-Commercial-Service/ccs-migration-alpha-tools.git infrastructure/core
```

## Purpose

There are two primary purposes for collecting these elements together in a shared repository:

1. To provide a unified toolset across CCS deployments, and to reap the rewards that brings:
    * Predictable behaviours
    * Familiarity for engineers
2. Enforce an implementation-led architecture rather than a resource-led architecture

That second point is crucial in managing complex infrastructure through the use of code. Consider the following two ways of approaching this:

### 1. Resource-led architecture

* Characterised by decisions such as "we need CloudWatch logs. Let's create a `cloudwatch-logs.tf` file and declare all our Log Groups in there for the whole system"
* Individual `.tf` files become change bottlenecks and merge conflict hotspots as the codebase evolves or the team grows in size
* It becomes necessary to pass down a large number of references / variables into business-function-related modules, effective reversing the authority and creating interlocked dependencies between layers of the Terraform

### 2. Implementation-led architecture

* Top-level blocks describing a composed system (e.g. `compositions/full-application/`)
* Files within the above folder declaring the need for business-purpose components using common modules which declare (for example):
    * Multi-layer VPCs
    * ECS Tasks
    * S3 Buckets
* These common modules declare their own usual sub-resources, for example:
    * CloudWatch Log Groups
    * JSON documents describing IAM policies to allow common operations on the resources

By composing the architecture is such a top-down fashion, the declaration for many resources (for example, the Log Groups in the case of [the previous "Resource-led" example](#1-resource-led-architecture)) are declared "for free" and do not clutter up the IAC codebase for the project which imported this submodule.

## Structure

The following folders are in this repo:

* [validation](validation/README.md) - TF files to exercise the resource definitions held within. Even though this is an alpha, some degree of syntax / correctness checking would seem prudent.
* [resource-groups](resource-groups/README.md) - Common groupings of AWS resources, presented to reduce repetition during normal usage (e.g. a Fargate task will likely want access to some Cloudwatch logs)
* [modules](modules/README.md) - These are collections of resources (and resource groups) which together represent composed pieces of functionality with a specific architectural purpose
* [scripts](scripts/README.md) - A collection of command line scripts designed to present a vaguely homogenous API for CI and Deployment tasks

## Testing

There are no test scripts (alpha), even so it is recommended to validate any changes before committing them. There is a script provided to do this:

```bash
./validate_all.sh
```

This relies upon the developer ensuring there is an up-to-date a `.tf` file which relates to the change in the `environments/validation` folder beforehand. 🙂

Note there is no need to set up a backend for this validation process.
