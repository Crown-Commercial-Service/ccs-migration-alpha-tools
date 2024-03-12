# Developer Access using AWS Tools

## Port Forwarding using SSM Session Manager

This documentation demonstrates how to use session manager for port forwarding to a remote host.
It establishes a secure connection to the remote host and forwards a local port to a port on the remote host.
This allows you to access services running on the remote host through your local machine.

Official documentation for [Session Manager Port Forwarding](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#sessions-start-port-forwarding)

### Steps for session manager port forwarding:
1. Install and configure the AWS CLI
  * Refer to documentation on how to do this
2. Install Session Manager plugin.
  * Download the installer:
   ```shell
   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
   ```
  * Create a per-user bin directory: `mkdir -p ~/.local/bin`
  * Run the installer:
  ```shell
  ./sessionmanager-bundle/install -i ~/.local/sessionmanagerplugin -b ~/.local/bin/session-manager-plugin
  ```
  * Edit (or create) `~/.bash_profile`, add this line: `export PATH=$HOME/.local/bin:$PATH`
  * Verify the plugin is installed and executable: `which session-manager-plugin`. The output should show the location of the plugin

Depending on whether you want to connect to a port on the container or a port on a remote host that the container has access to, do one of the following:

#### Connect to ports on the container

```shell
$ aws ssm start-session --target INSTANCE_ID --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}'
```
Then, in another terminal session:
```shell
$ curl localhost:8080
```

This will connect to port 8080 on the running container.

#### Connect to remote hosts accessible from the container, e.g. RDS databases

Obtain temporary security credentials from AWS and then set them as environment variables in the shell session.
* The `printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"` command is used to format the output from the `aws sts assume-role` command into a string that sets environment variables.
* `export $(...)` command exports the variables, setting them in your environment. Once these environment variables are set, any AWS CLI command or AWS SDK in your session will use these credentials by default.
* `aws sts assume role` allows you to assume an IAM role. When you assume a role, AWS STS (Security token service) returns a temporary security credentials(an access key ID, a secret access key, and a security token) that you can use to make AWS API calls.
* `--role-arn` is the ARN of the role you want to assume.
* `--role-session-name` names the session.
* `--query` command extracts the necessary credentials from the response.
* `--output text` formats the output as text.
```shell
export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::${AWS_ACCOUNT}:role/<AWS_ACCOUNT_NAME> \
--role-session-name MySessionName \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))
```
Start session using AWS Systems manager to establish port forwarding to a remote host.
* Target parameter `--target "ecs:<YOUR_ECS_CLUSTER_NAME>_<CLUSTER_ID>_<CLUSTER_RUNTIME_ID>"` specifies the target for the session.
* Document name `--document-name AWS-StartPortForwardingSessionToRemoteHost` specifies the name of the Systems manager document(SSM document) to define the session type.
* Parameters `--parameters '{"portNumber":["5432"],"localPortNumber":["5432"],"host":["<YOUR_RDS_ENDPOINT>.<REGION>.rds.amazonaws.com"]}'` specifies the parameters for the port forwarding session.
```shell
aws ssm start-session --target "ecs:<YOUR_ECS_CLUSTER_NAME>_<CLUSTER_ID>_<CLUSTER_RUNTIME_ID>" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["5432"],"localPortNumber":["5432"],"host":["<YOUR_RDS_ENDPOINT>.<REGION>.rds.amazonaws.com"]}'
```
Then, in another terminal session:
```shell
$ psql localhost:5432
```
This will open a Postgres Client session with the RDS instance accessible by the running container.

## IAM Database Authentication

It is possible to authenticate to RDS using an IAM user or role instead of a password assigned to a user in the database. This is more secure as it uses a temporary token with a life of 15 minutes, thereby eliminating the risk of password leakage. 

First, start a port-forwarding session, as described above. Once the session is listening on `localhost:5432`, you are ready to proceed. 

In another terminal session, perform these steps to authenticate:

```shell
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem # Downloads the RDS root CA certificate
export RDSHOST="<DATABASE_NAME>.<REGION>.rds.amazonaws.com"
export PGPASSWORD="$(aws rds generate-db-auth-token --hostname $RDSHOST --port 5432 --region eu-west-2 --username tester)"
psql "host=localhost port=5432 sslmode=require sslrootcert=global-bundle.pem dbname=ciiapi user=tester2 password=$PGPASSWORD"
```

## Shell access with ECS Exec:
```shell
aws ecs execute-command --cluster <CLUSTER_NAME> \    --task arn:aws:ecs:<REGION>:<AWS_ACCOUNT>:task/<YOUR_ECS_CLUSTER_NAME>/<TASK_DEFINITION_ARN>  \
    --container <CONTAINER_NAME> \
    --command "/bin/sh" \
    --interactive
```
#### To find ECS task ARNs and IDs in the console, you can follow these steps:

1. Open the AWS Management Console and navigate to the ECS service.
2. Select the cluster that contains the tasks you want to find.
3. In the cluster details page, click on the "Tasks" tab.
4. You will see a list of tasks running in the cluster. The ARN and ID of each task will be displayed in the table.

Note that the ARN is a unique identifier for each task, while the ID is a shorter identifier that can be used for referencing tasks within the cluster.

#### To find ECS Services, task ARNs and IDs using AWS CLI commands:

To list services in an AWS ECS cluster -
`aws ecs list-services --cluster <cluster_name>`

List tasks for a specific cluster -
`aws ecs list-tasks --cluster <cluster_name>`

List tasks in a specific service -
`aws ecs list-tasks --cluster <cluster_name> --service-name <service_name>`

Describe tasks to get more details -
`aws ecs describe-tasks --cluster <cluster_name> --tasks <task_id1> <task_id2> ...`
