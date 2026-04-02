# MAQA GitHub Projects Integration

> **Credits:** This extension is a local integration of [maqa-github-projects](https://github.com/GenieRobot/spec-kit-maqa-github-projects) by [GenieRobot](https://github.com/GenieRobot), licensed under MIT. Original listed at [speckit-community.github.io/extensions/maqa-github-projects](https://speckit-community.github.io/extensions/maqa-github-projects).

GitHub Projects v2 integration for the [MAQA](https://github.com/GenieRobot/spec-kit-maqa-ext) spec-kit extension.

Tracks feature progress in a GitHub Projects v2 board. Items move through your Status field as features progress. Task lists are managed as GitHub markdown checkboxes in the issue body.

## Requirements

- [maqa](https://github.com/GenieRobot/spec-kit-maqa-ext) extension installed
- GitHub token with `project` scope: `GH_TOKEN` (or `gh auth login` — setup uses `gh auth token` as fallback)

## Commands

| Command | Description |
|---------|-------------|
| `/speckit.maqa-github-projects.setup` | Bootstrap config: lists your projects, maps Status field options, writes `maqa-github-projects/github-projects-config.yml`. Run once per project. |
| `/speckit.maqa-github-projects.populate` | Populate project from `specs/*/tasks.md`. Creates one draft issue per feature with a markdown task list. Skips existing items. Safe to re-run. |

## Setup

```
/speckit.maqa-github-projects.setup
```

Lists your GitHub Projects, maps Status field options to MAQA workflow slots (Todo → In Progress → In Review → Done), writes `maqa-github-projects/github-projects-config.yml`.

## Notes

GitHub Projects v2 does not have Trello-style checklists. Tasks are tracked as GitHub markdown task lists (`- [ ] item`) in the issue/draft body. The feature agent updates the body to check off items as they complete.

## License

MIT — see upstream [LICENSE](https://github.com/GenieRobot/spec-kit-maqa-github-projects/blob/main/LICENSE).
