# ACM Certificate

Resources to manage the provision of and DNS-based validation of an ACM certificate.

Currently assumes same provider and therefore same region as the general workload account (and so will not work for CloudFront distributions since these require certs to be in us-east-1, and it's likely the workload account is not in that region).
