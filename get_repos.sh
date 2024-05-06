#!/bin/bash

# NAME: get_repos.sh
# TYPE: Bash
# WHOM: XXX Xxxxxxxx (MC)
# DATE: 2024-05-05
# DESC: Script to get a list of repositories from GES. Assumes that the number of
#       repositories spans multiple URL pages, so uses the "last" page reference
#       to step through all the pages. In this script we define the per_page qty
#       to avoid surprises

# NOTE:
# Untested syntax of api for orgs in enterprise

# TASK:
# 1. Harden credentials input
# 2. Update for multiple orgs

# REFS:
# https://www.baeldung.com/linux/jq-json-print-data-single-line#:~:text=json.,raw%20format%20without%20additional%20formatting.
# https://www.gnu.org/software/sed/manual/html_node/Back_002dreferences-and-Subexpressions.html#Back_002dreferences-and-Subexpressions

echo -e "\n$(basename $0) : started $(date)"

PAT=$(awk '/auth_clientx/{ print $NF }' ~/.creds)
PERP=2
NEXT=1
LAST=1
BASE="."
TEMP=$BASE/temp.get
REPO=$BASE/repo.txt

rm -f $TEMP $REPO 2>/dev/null

while [ $NEXT -le $LAST ]
do
	echo -e "\ncurl https://api.github.com/user/repos?per_page=${PERP}&page=${NEXT}"

	curl -s -i -L \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $PAT" \
	"https://api.github.com/user/repos?per_page=${PERP}&page=${NEXT}" | tr -d '\r' > $TEMP

	sed -n '/^\[/,/^\]/'p $TEMP | jq -r '.[] | "\(.id):\(.name)"' | tee -a $REPO

	CHCK=$(grep ^link.*last $TEMP | wc -l)
	if [ $CHCK -gt 0 ]
	then
		LAST=$(sed -E -n 's/^link.*per_page=[0-9]+&page=([0-9]+)>; rel="last"(.+|$)/\1/'p $TEMP)
	fi

	((NEXT++))
done

rm -f $TEMP 2>/dev/null

echo -e "\n$(basename $0) : finished $(date)"
echo -e "$(basename $0) : repo list file $REPO\n"
