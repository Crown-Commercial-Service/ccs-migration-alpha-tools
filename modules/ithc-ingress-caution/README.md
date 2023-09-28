# ITHC Ingress - Caution!

This module introduces resources which deliberately bypass and / or reduce the efficacy of existing security measures.

It's intended for use during an IT Health Check / Penetration Test situation.

> You are **STRONGLY** advised never to use this module in production.

## Adding Ingress in your project

This module is designed to be reusable and temporary. To optimise on both these attributes it's advised to implement it as follows:

### Locate the module invocation separately

Invoke the module using the typical Terraform `module` construct.

It's advised to put this block into the top-level of your environment folder, as a separate file with a name such as `ithc_ingress.tf` (so, for example, `environments/staging/ithc_ingress.tf`). There are a few reasons for this approach:

1. It shows with a glance of the folder that this environment has ITHC ingress set up
2. It stops the `main.tf` becoming cluttered
3. When you are finished testing, each of the resources and components can be removed from your platform by simply deleting this file and re-applying the Terraform. 
