#!/bin/bash

# NAME: post_org.sh
# TYPE: Bash
# WHOM: XXX Xxxxxxxx (MC)
# DATE: 2024-05-05
# DESC: Script to create organisation in GES

# NOTE:
# Untested syntax of api for orgs in enterprise

# TASK:
# Harden credentials input

PAT=$(awk '/auth_clientx/{ print $NF }' ~/.creds)
ORG="org-test"
NAME="name-test"
DESC="this is a new org called test"
HOME="https://github.com"

DATA=$(cat <<EOV
'{"name":"$NAME","description":"$DESC","homepage":"$HOME","private":false,"has_issues":true,"has_projects":true,"has_wiki":true}'
EOV
)

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT" \
  https://api.github.com/orgs/$ORG/repos \
  -d $DATA

