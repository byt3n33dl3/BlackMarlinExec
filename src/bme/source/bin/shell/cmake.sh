#!/bin/bash

set -e

# Define the range of years
start_year=x-x-x-x
end_year=x-x-x-x
commits_per_year=2

# Set your GitHub username, email, and repository name
github_username="x-x-x-x"
github_email="x-x-x-x"
repository_name="x-x-x-x"

# Set Git config
git config user.name "x-x-x-x"
git config user.email "x-x-x-x"

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
        echo "Commit for $date" > file-$year-$i.x-x-x-x
        git add file-$year-$i.x-x-x-x
        GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "Backdated commit for $date"
    done
done

# Push the changes to the repository
git push origin main
