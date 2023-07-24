# ECR Repository

Helper scripts to assist users and CI agents to manipulate Docker images held in ECR.

Detailed instructions are provided within the script files themselves, however in general it's expected that you will combine two scripts as follows in order to effect a `docker login` without the need for passing credentials around:

```bash
get_login_password.py | docker login --username AWS --password-stdin `get_ecr_registry_uri.py`
```

This will log in the Docker client to the ECR registry for the current AWS account **with the same permissions in that registry as the IAM user whose access key was used when running the script**.

Note: 
* You'll need to be operating on the command line within a suitable virtual environment - setup details [are here](../README.md).
* The username is ALWAYS `AWS`
* The second script is evaluated in backticks (`)
