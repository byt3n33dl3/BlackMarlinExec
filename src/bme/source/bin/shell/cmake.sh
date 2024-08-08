#!/bin/bash

set -e

# Define the range of years
start_year=*-*-*-*
end_year=*-*-*-*
commits_per_year=2

# Set your GitHub username, email, and repository name
github_username="*-*-*-*"
github_email="*-*-*-*"
repository_name="*-*-*-*"

# Set Git config
git config user.name "*-*-*-*"
git config user.email "*-*-*-*"

for year in $(seq $start_year $end_year); do
    for i in $(seq 1 $commits_per_year); do
        # Generate a random date within the year
        month=$(printf "%02d" $((RANDOM % 12 + 1)))
        day=$(printf "%02d" $((RANDOM % 28 + 1)))
        hour=$(printf "%02d" $((RANDOM % 24)))
        minute=$(printf "%02d" $((RANDOM % 60)))
        second=$(printf "%02d" $((RANDOM % 60)))
        date="$year-$month-$day $hour:$minute:$second"

        # Create a commit with the generated date
        echo "Commit for $date" > file-$year-$i.*-*-*-*
        git add file-$year-$i.*-*-*-*
        GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "Backdated commit for $date"
    done
done

# Push the changes to the repository
git push origin main
