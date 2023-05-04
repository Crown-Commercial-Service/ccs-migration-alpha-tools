# CCS Terraform Modules Alpha

This repository contains reusable sections of infrastructure code, intended for use solely within the Migration Alpha project.

As with all things in the Alpha, this is just one representation of a possible construct for use during a beta phase. It's illustrative rather than directive.

## Usage

It's intended to be used as a Git submodule within consuming projects. For example:

```bash
git submodule add git@github.com:org/ccs-terraform-modules-alpha.git infrastructure/core  #TODO correct org & repo name when available
```

## Structure

The following folders are in this repo:

* [validation](validation/README.md) - TF files to exercise the resource definitions held within. Even though this is an alpha, some degree of syntax / correctness checking would seem prudent.
* [resource-groups](resource-groups/README.md) - Common groupings of AWS resources, presented to reduce repetition during normal usage (e.g. a Fargate task will likely want access to some Cloudwatch logs)
* [modules](modules/README.md) - These are collections of resources (and resource groups) which together represent composed pieces of functionality with a specific architectural purpose

## Testing

There are no test scripts (alpha), even so it is recommended to validate any changes before committing them. There is a script provided to do this:

```bash
./validate_all.sh
```

This relies upon the developer ensuring there is an up-to-date a `.tf` file which relates to the change in the `environments/validation` folder beforehand. 🙂

Note there is no need to set up a backend for this validation process.
