#!/usr/bin/env python3
import sys

import boto3
import click


@click.command()
@click.argument("repo_name")
def get_ecr_repository_uri(repo_name):
    """
    Get the Docker URI for an ECR repo.

    REPO_NAME is the name given to the particular repo for which you wish to find the URI.

    To call this AWS API, the acting IAM user requires the following permission for
    the ECR Repository for which they seek the URI:
      - ecr:DescribeRepositories

    The URI is written to stdout without a newline, so you may incorporate it into other
    commands.

    Example use, stand-alone:
        get_ecr_repository_uri.py uploader

    Example use within a tagging operation:
        docker tag SOURCE_IMAGE `get_ecr_repository_uri.py uploader`

    Example use within a push operation:
        docker push `get_ecr_repository_uri.py uploader`

    """
    ecr_client = boto3.client("ecr")

    try:
        response = ecr_client.describe_repositories(repositoryNames=[repo_name])
    except ecr_client.exceptions.ClientError:
        click.echo(
            f"Could not retrieve info for an ECR repo with name '{repo_name}'. Either it "
            + "does not exist or you do not have the appropriate permissions to retrieve its "
            + "details.",
            err=True,
        )
        sys.exit(1)

    repo_uri = response["repositories"][0]["repositoryUri"]
    click.echo(repo_uri, nl=False)


if __name__ == "__main__":
    get_ecr_repository_uri()
