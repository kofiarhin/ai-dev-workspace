#!/usr/bin/env bash
set -euo pipefail

force=false
project_path="."

for argument in "$@"; do
  case "$argument" in
    --force)
      force=true
      ;;
    *)
      project_path="$argument"
      ;;
  esac
done

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "$script_directory/.." && pwd)"
source_directory="$repository_root/skill"

if [[ ! -d "$source_directory" ]]; then
  printf 'Skill source directory was not found: %s\n' "$source_directory" >&2
  exit 1
fi

project_root="$(cd "$project_path" && pwd)"
skills_directory="$project_root/.claude/skills"
destination="$skills_directory/setup-prd-workspace"

if [[ -e "$destination" ]]; then
  if [[ "$force" != true ]]; then
    printf "The skill is already installed at '%s'. Rerun with --force to replace it.\n" "$destination" >&2
    exit 1
  fi

  rm -rf -- "$destination"
fi

mkdir -p -- "$skills_directory"
cp -R -- "$source_directory" "$destination"

if [[ ! -f "$destination/SKILL.md" ]]; then
  printf 'Installation failed because SKILL.md was not copied.\n' >&2
  exit 1
fi

printf 'Installed setup-prd-workspace at: %s\n' "$destination"
printf 'Open the project in Claude Code and run: /setup-prd-workspace PRD.md\n'
