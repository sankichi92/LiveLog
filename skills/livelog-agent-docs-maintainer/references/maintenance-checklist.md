# Maintenance Checklist

## Goal

Keep these files synchronized with current repository reality:

- `AGENTS.md`
- `docs/project-map.md`
- `docs/infrastructure-inventory.md`
- `README.md` (AI agent docs links)

## Fact Collection Commands

### Structure and entry points

```bash
rg --files
sed -n '1,260p' config/routes.rb
sed -n '1,260p' README.md
```

### Environment-variable inventory

```bash
rg -n "ENV\\[|ENV\\.fetch" app config lib db spec -g '!app/assets/builds/**'
```

### External-service and infra couplings

```bash
rg -n "Heroku|MEMCACHIER|SENDGRID|ELASTICSEARCH_URL|AUTH0|Cloudinary|Sentry|Scout|barnes|SLACK_|TWITTER_" app config lib Gemfile Procfile* README.md docs
```

### CI and quality gates

```bash
sed -n '1,260p' .github/workflows/ruby.yml
sed -n '1,220p' .github/workflows/javascript.yml
cat package.json
ls -la bin
```

## Editing Rules

- Keep `AGENTS.md` short and link out to details.
- Keep architecture and behavior mapping in `docs/project-map.md`.
- Keep service inventory and env-vars mapping in `docs/infrastructure-inventory.md`.
- Keep README changes minimal; only maintain discoverability links.
- Do not add migration-target comparisons unless explicitly requested.

## Mandatory Assertions

- Production and external-service changes require explicit human approval.
- Side-effect tasks (posting, mailing, external writes) are opt-in only.

## Pre-Final Check

```bash
skills/livelog-agent-docs-maintainer/scripts/check_agent_docs.sh <repo-path>
```

Address all `[ERROR]` items before finalizing. Treat `[WARN]` items as review-required.

