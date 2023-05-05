#!/usr/bin/env bash
terraform -chdir=validation init
terraform -chdir=validation validate
