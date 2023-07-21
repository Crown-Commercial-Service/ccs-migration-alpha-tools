#!/usr/bin/env python3
import base64

import boto3
import click


@click.command()
def get_login_password():
    """
    Get an ECR "login password" for the current IAM user.

    To call this AWS API, the acting IAM user needs to have the following
    permission:
        - ecr:GetAuthorizationToken

    Note that the "password" returned, when used to log in, will automagically give the
    Docker client access which is consistent with the IAM permissions of the user whose access
    key was used during the running of this script.

    [ In other words, it is not enough simply to log in - the IAM user also requires the
    appropriate permissions to push to the Docker repo. ]

    The password is written to stdout (with no newline) and so it's intended that the output
    of this script is piped directly into `docker login`, like this:

    Example use:
        get_login_password.py | docker login --username AWS --password-stdin ECR_REGISTRY_URI

        where ECR_REGISTRY_URI is of the form: REGISTRY_ID.dkr.ecr.REGION.amazonaws.com

    Note that the Docker username is _always_ `AWS`, regardless of the IAM user's name.

    """
    ecr_client = boto3.client("ecr")
    response = ecr_client.get_authorization_token()
    auth_token = response["authorizationData"][0]["authorizationToken"]
    _, password = base64.b64decode(auth_token).split(b":")
    click.echo(password, nl=False)


if __name__ == "__main__":
    get_login_password()
