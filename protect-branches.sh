#!/bin/bash

# GitHub API token
GITHUB_TOKEN=${{ secrets.PAT_TOKEN }}
ORG_NAME="Test-branch"

# Function to protect branches
protect_branch() {
  local repo=$1
  local default_branch=$2

  curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$ORG_NAME/$repo/branches/$default_branch/protection \
    -d '{
      "required_status_checks": null,
      "enforce_admins": true,
      "required_pull_request_reviews": {
        "dismiss_stale_reviews": false,
        "require_code_owner_reviews": true,
        "required_approving_review_count": 1
      },
      "restrictions": null,
      "allow_force_pushes": false,
      "allow_deletions": false
    }'
}

# Get all repositories in the organization
page=1
while :; do
  repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG_NAME/repos?per_page=100&page=$page" | jq -r '.[].name')

  # Break the loop if no more repositories are found
  if [ -z "$repos" ]; then
    break
  fi

  for repo in $repos; do
    # Get default branch for the repository
    default_branch=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/$ORG_NAME/$repo | jq -r .default_branch)

    # Protect the default branch
    protect_branch $repo $default_branch
  done

  # Increment the page number
  page=$((page + 1))
done