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

if [[ ! -d "$source_root" ]]; then
  printf 'Skills source directory was not found: %s\n' "$source_root" >&2
  exit 1
fi

skill_names=()
while IFS= read -r source_directory; do
  if [[ -f "$source_directory/SKILL.md" ]]; then
    skill_names+=("$(basename "$source_directory")")
  fi
done < <(find "$source_root" -mindepth 1 -maxdepth 1 -type d -print | sort)

if (( ${#skill_names[@]} == 0 )); then
  printf 'No installable skills containing SKILL.md were found under: %s\n' "$source_root" >&2
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
  printf 'One or more workspace skills are already installed. Rerun with --force to replace them:\n' >&2
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

  cp -R -- "$source_directory" "$destination"

  if [[ ! -f "$destination/SKILL.md" ]]; then
    printf 'Installation failed for skill: %s\n' "$skill_name" >&2
    exit 1
  fi
done

printf 'Installed %d AI software-delivery skills at: %s\n' "${#skill_names[@]}" "$skills_directory"
printf 'Installed skills: %s\n' "${skill_names[*]}"
printf 'Start with: /setup-workspace PRD.md\n'
printf 'Audit consistency with: /workspace-health\n'
printf 'Queue the next evidence-backed ticket with: /morning-brief\n'
printf 'Deliver a ticket end to end with: /deliver-ticket\n'
printf 'Manual control remains: /ticket -> /spec -> /plan -> /implement-plan\n'
printf 'Reset owned operating state with: /reset-workspace\n'
