#!/bin/bash
 
# Fetch all repositories in the organization with pagination
page=1
while true; do
  echo "Fetching page $page of repositories..."
  repos=$(gh repo list --json nameWithOwner --jq '.[].nameWithOwner' --limit 100 --page "$page")
 
  # Break the loop if no more repositories are returned
  if [ -z "$repos" ]; then
    break
  fi
 
  # Loop through each repository in the current page
  for repo in $repos; do
    echo "Processing repository: $repo"
 
    # Get the default branch name
default_branch=$(gh repo view "$repo" --json defaultBranchRef --jq '.defaultBranchRef.name')
 
    # Enable branch protection rules with required approval
    gh api -X PUT "repos/$repo/branches/$default_branch/protection" \
      --input - <<EOF
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
  "required_approving_review_count": 1, # Require at least one approval
  "dismiss_stale_reviews": false,
  "require_code_owner_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
 
    echo "Branch protection enabled for $repo:$default_branch (requires 1 approval)"
  done
 
  # Increment the page number
  page=$((page + 1))
done