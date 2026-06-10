# Backup Vaults

Vaults to be used in backup policies

Cross Region Copy is only needed for RDS databases encrypted with AWS managed keys, it will essentially strip out the managed key and use the Vaults default key which is defined and shared from the backup management account. Once the cross region copy completes Eventbridge triggers the Lambda to transfer the snapshot into airgapped vault in the management account. The Lambda is able to read tags set by the backup policy to retain the retention period for the snapshot.
