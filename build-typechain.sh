#!/bin/bash
set -e

mkdir -p typechain-types/dist
touch typechain-types/dist/index.js

npx hardhat typechain
(cd typechain-types && npx tsc)

echo "Typechain build complete 🎉"