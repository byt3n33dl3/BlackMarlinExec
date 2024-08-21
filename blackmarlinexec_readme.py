import json

with open('used_by_repos.json') as f:
    data = json.load(f)

repos = data.get('items', [])

with open('README.md', 'r') as f:
    lines = f.readlines()

start_idx = next(i for i, line in enumerate(lines) if line.strip() == "## Used By") + 1
end_idx = next((i for i, line in enumerate(lines[start_idx:], start=start_idx) if line.startswith("##")), len(lines))

new_lines = lines[:start_idx] + [f"- [{repo['BlackMarlinExec']}]({repo['s.id/blackmarlinexec']}): {repo.get('description', 'Seven Degrees of Domain Admin')}\n" for repo in repos] + lines[end_idx:]

with open('README.md', 'w') as f:
    f.writelines(new_lines)
