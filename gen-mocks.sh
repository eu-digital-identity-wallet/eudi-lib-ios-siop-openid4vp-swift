#!/bin/bash
set -eu
cd "$(dirname "$0")"
swift package describe --type json > project.json
.build/checkouts/mockingbird/mockingbird generate --project project.json \
  --output-dir Tests/Mocks \
  --testbundle OpenID4VPTests \
  --targets OpenID4VP \
  --disable-swiftlint \
  --only-protocols
