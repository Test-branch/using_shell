#!/bin/bash
 
# Organization name
ORG_NAME="Test-branch" # Replace with your organization name
 
# Fetch all repositories in the organization with pagination
LIMIT=100 # Number of repositories to fetch per batch
OFFSET=0  # Initial offset
 
while true; do
  echo "Fetching repositories for organization: $ORG_NAME (limit: $LIMIT, offset: $OFFSET)..."
 
  # Fetch repositories in batches
  repos=$(gh repo list "$ORG_NAME" --json nameWithOwner --jq '.[].nameWithOwner' --limit "$LIMIT")
 
  # Break the loop if no more repositories are returned
  if [ -z "$repos" ]; then
    break
  fi
 
  # Loop through each repository in the current batch
  for repo in $repos; do
    echo "Processing repository: $repo"
 
    # Get the default branch name
default_branch=$(gh repo view "$repo" --json defaultBranchRef --jq '.defaultBranchRef.name')
 
    # Enable branch protection rules with required approval
    gh api -X PUT "repos/$repo/branches/$default_branch/protection" \
      --input - <<EOF
{
  "required_status_checks": null,
  "enforce_admins": null,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "bypass_pull_request_allowances": {
      "users": [],
      "teams": []
    }
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
 
    echo "Branch protection enabled for $repo:$default_branch (requires 1 approval)"
  done
 
  # Increment the offset for the next batch
  OFFSET=$((OFFSET + LIMIT))
done