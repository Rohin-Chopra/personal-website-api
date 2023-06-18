#!/bin/bash

npx esbuild \
    --bundle src/handler.ts \
    --target=node16 \
    --format=cjs \
    --external:aws-sdk \
    --outfile=.esbuild/index.js

cd terraform

terraform apply