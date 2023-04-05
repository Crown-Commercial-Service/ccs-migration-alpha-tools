# CCS Terraform Modules Alpha

This repository contains reusable sections of infrastructure code, intended for use solely within the Migration Alpha project.

It is recommended to validate any changes before committing them. There is a script provided to do this:

```bash
./validate_all.sh
```

This relies upon the developer ensuring there is an up-to-date a `.tf` file which relates to the change in the `environments/validation` folder beforehand. 🙂

Note there is no need to set up a backend for this validation process.
