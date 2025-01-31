#!/bin/bash

# Replace these variables with your own values
ORG_NAME="OptumInsight-Provider"
BRANCH_NAME=("main" "master")

# Get the list of repositories in the organization
repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORG_NAME/repos" | jq -r '.[].name')

# Loop through each repository and enable branch protection
for repo in $repos; do
  echo "Enabling branch protection for $repo"

  curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$ORG_NAME/$repo/branches/$BRANCH_NAME/protection" \
    -d '{
      "required_status_checks": {
        "strict": true,
        "contexts": []
      },
      "enforce_admins": true,
      "required_pull_request_reviews": {
        "dismiss_stale_reviews": true,
        "require_code_owner_reviews": true,
        "required_approving_review_count": 2
      },
      "restrictions": null
    }'
done

echo "Branch protection enabled for all repositories in the organization."