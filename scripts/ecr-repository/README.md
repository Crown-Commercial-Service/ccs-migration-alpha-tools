# ECR Repository

Helper scripts to assist users and CI agents to manipulate Docker images held in ECR.

## Logging in a Docker client to ECR

Detailed instructions are provided within the script files themselves, however in general it's expected that you will combine two scripts as follows in order to effect a `docker login` without the need for passing credentials around:

```bash
get_login_password.py | docker login --username AWS --password-stdin `get_ecr_registry_uri.py`
```

This will log in the Docker client to the ECR registry for the current AWS account **with the same permissions in that registry as the IAM user whose access key was used when running the script**.

Note: 
* You'll need to be operating on the command line within a suitable virtual environment - setup details [are here](../README.md).
* The username is ALWAYS `AWS`
* The second script is evaluated in backticks (`)

## Performing the push

### Tagging the Docker image

To perform the push you'll need to tag the Docker image which will involve knowing the fully-qualified name of the Docker repository inside ECR.

To assist in this, a script `get_ecr_repository_uri.py` has been provided which can be used as follows:

```bash
docker tag SOURCE_IMAGE `get_ecr_repository_uri.py uploader`
```

### Pushing the Docker image

Once tagged you can then push this image to the ECR repository with the usual Docker command - you will of course need the repository URI again

```bash
docker push `get_ecr_repository_uri.py uploader`
```

You may wish to use local shell variables or similar to cut down on the script calls, however bear in mind that the scripts are here to minmise the amount of configuration and ops programming required.
