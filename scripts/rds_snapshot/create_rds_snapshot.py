import boto3
from botocore.exceptions import ClientError, BotoCoreError
import click
import os
from datetime import datetime


@click.command()
@click.argument("rds_instance_name")
@click.option(
    "--region-name",
    show_default=True,
    default="eu-west-2",
    help="The region in which your RDS Instance resides (defaults to eu-west-2)",
)
@click.option(
    "--desired-rds-instance-snapshot-status",
    show_default=True,
    default="available",
    help="The desired status for your RDS Instance to reach upon completion of this script (defaults to available)",
)
def create_rds_snapshot(rds_instance_name: str, region_name: str, desired_rds_instance_snapshot_status: str) -> str:
    boto3_rds_client, dt_string, rds_instance_snapshot_name = configure_prerequisites(
        rds_instance_name=rds_instance_name, region_name=region_name
    )
    click.echo(f"Creating RDS Snapshot for DB instance {rds_instance_name}")
    try:
        click.echo(
            f"Creating RDS Snapshot for DB instance {rds_instance_name}, snapshot name is: {rds_instance_snapshot_name}"
        )
        create_snapshot = boto3_rds_client.create_db_snapshot(
            DBSnapshotIdentifier=rds_instance_snapshot_name,
            DBInstanceIdentifier=rds_instance_name,
        )
        click.echo(f"CLI call made to create snapshot {rds_instance_snapshot_name}")
        rds_snapshot_instance_status = get_rds_snapshot_status(
            boto3_rds_client=boto3_rds_client,
            rds_instance_snapshot_name=rds_instance_snapshot_name,
        )
        compare_snapshot_status(rds_snapshot_instance_status,
                                desired_rds_instance_snapshot_status,
                                boto3_rds_client,
                                rds_instance_snapshot_name)
        click.echo(f"Snapshot {rds_instance_snapshot_name} in desired status")
    except ClientError as error:
        error_info = error.response['Error']
        click.echo(f"Error: {error_info['Code']}")
        click.echo(f"{error_info['Message']}")
    
def compare_snapshot_status(rds_snapshot_instance_status: str, desired_rds_instance_snapshot_status: str, boto3_rds_client: str, rds_instance_snapshot_name: str) -> str:
        while rds_snapshot_instance_status != desired_rds_instance_snapshot_status:
            current_rds_snapshot_instance_status = get_rds_snapshot_status(
                boto3_rds_client=boto3_rds_client,
                rds_instance_snapshot_name=rds_instance_snapshot_name,
            )

            if current_rds_snapshot_instance_status != desired_rds_instance_snapshot_status:
                click.echo(
                    f"Snapshot {rds_instance_snapshot_name} status is currently {current_rds_snapshot_instance_status}, desired status is {desired_rds_instance_snapshot_status}"
                )
                os.system("sleep 20")
            else:
                click.echo(
                    f"Snapshot {rds_instance_snapshot_name} status is {current_rds_snapshot_instance_status}"
                )
                break

def configure_prerequisites(rds_instance_name: str, region_name: str) -> str:
    try:
        click.echo("Creating RDS client...")
        boto3_rds_client = boto3.client("rds", region_name=region_name)
        click.echo("RDS client successfully created!")
        
    except BotoCoreError as error:
        click.echo(f"{error}")
        
    now = datetime.now()
    dt_string = now.strftime("date-%d-%m-%Y-time-%H-%M-%S")

    rds_instance_snapshot_name = rds_instance_name + "-" + dt_string
    return boto3_rds_client, dt_string, rds_instance_snapshot_name


def get_rds_snapshot_status(boto3_rds_client: str, rds_instance_snapshot_name: str) -> str:
    rds_instance_snapshot_status = boto3_rds_client.describe_db_snapshots(
        DBSnapshotIdentifier=rds_instance_snapshot_name
    )
    for rds_instance_snapshot in rds_instance_snapshot_status["DBSnapshots"]:
        rds_instance_snapshot_status = rds_instance_snapshot["Status"]

    return rds_instance_snapshot_status

if __name__ == "__main__":
    create_rds_snapshot()