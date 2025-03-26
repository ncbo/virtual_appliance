#!/usr/bin/env bash
# Create AG repostiory and user for ontoportal
set -euo pipefail

CREDS='super:super'
HOST='http://localhost:10035'

function run_curl() {
  local description=$1
  local allow_statuses="$2"
  shift 2

  echo "🔧 $description..."

  response=$(curl -sS -w "\nHTTP_STATUS:%{http_code}" -u"$CREDS" "$@" || true)
  body=$(echo "$response" | sed -n '/^HTTP_STATUS:/!p')
  status=$(echo "$response" | sed -n 's/^HTTP_STATUS://p')

  if [[ -n "$body" ]]; then
    echo "📨 Server response:"
    echo "$body"
  fi

  # Check if status is in allowed statuses
  for code in $allow_statuses; do
    if [[ "$status" == "$code" ]]; then
      echo "✅ $description succeeded (HTTP $status)"
      return 0
    fi
  done

  echo "❌ $description failed (HTTP $status)"
  exit 1
}

run_curl "check status'" "200"\
  -X GET "$HOST/version"

run_curl "Creating repository 'ontoportal'" "204" \
  -X PUT "$HOST/repositories/ontoportal"

run_curl "Setting suppressDuplicates to true" "204" \
  -X PUT "$HOST/repositories/ontoportal/suppressDuplicates?value=true"

run_curl "Deleting anonymous user (if it exists)" "204 404" \
  -X DELETE "$HOST/users/anonymous"

run_curl "Creating anonymous user" "204" \
  -X PUT "$HOST/users/anonymous?password="

run_curl "Granting read access to 'ontoportal' for anonymous user" "204" \
  -X PUT "$HOST/users/anonymous/access?read=true&write=false&repositories=ontoportal"

run_curl "Listing all repositories" "200" \
  -X GET "$HOST/repositories"

echo "🎉 Setup complete!"
