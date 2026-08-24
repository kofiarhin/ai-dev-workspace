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
source_root="$repository_root/skills"
skill_names=(setup-workspace ticket spec plan implement-plan)

if [[ ! -d "$source_root" ]]; then
  printf 'Skills source directory was not found: %s\n' "$source_root" >&2
  exit 1
fi

project_root="$(cd "$project_path" && pwd)"
skills_directory="$project_root/.claude/skills"
legacy_destination="$skills_directory/setup-prd-workspace"
existing=()

for skill_name in "${skill_names[@]}"; do
  destination="$skills_directory/$skill_name"
  if [[ -e "$destination" ]]; then
    existing+=("$destination")
  fi
done
if [[ -e "$legacy_destination" ]]; then
  existing+=("$legacy_destination")
fi

if (( ${#existing[@]} > 0 )) && [[ "$force" != true ]]; then
  printf 'One or more delivery skills are already installed. Rerun with --force to replace them:\n' >&2
  printf '  %s\n' "${existing[@]}" >&2
  exit 1
fi

mkdir -p -- "$skills_directory"

if [[ "$force" == true ]]; then
  for path in "${existing[@]}"; do
    rm -rf -- "$path"
  done
fi

for skill_name in "${skill_names[@]}"; do
  source_directory="$source_root/$skill_name"
  destination="$skills_directory/$skill_name"

  if [[ ! -f "$source_directory/SKILL.md" ]]; then
    printf 'Skill source is incomplete: %s\n' "$source_directory" >&2
    exit 1
  fi

  cp -R -- "$source_directory" "$destination"

  if [[ ! -f "$destination/SKILL.md" ]]; then
    printf 'Installation failed for skill: %s\n' "$skill_name" >&2
    exit 1
  fi
done

printf 'Installed software-delivery skills at: %s\n' "$skills_directory"
printf 'Start with: /setup-workspace PRD.md\n'
printf 'Then use: /ticket -> /spec -> /plan -> /implement-plan\n'
