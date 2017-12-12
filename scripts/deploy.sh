#!/bin/bash -e

# When we publish to npm, the published files are available in the root
# directory, which allows for a clean include or require of sub-modules.
#
#    var language = require('react-apollo/server');
#

# Clear the built output
rm -rf ./lib

# Compile new files
npm run build

# Make sure the ./npm directory is empty
rm -rf ./npm
mkdir ./npm

# Copy all files from ./lib to /npm
cd ./lib && cp -r ./ ../npm/
# Copy also the umd bundle with the source map file
cp bundle.umd.js ../npm/ && cp bundle.umd.js.map ../npm/

# Back to the root directory
cd ../

# Ensure a vanilla package.json before deploying so other tools do not interpret
# The built output as requiring any further transformation.
node -e "var package = require('./package.json'); \
  delete package.babel; \
  delete package[\"lint-staged\"]; \
  delete package.jest; \
  delete package.bundlesize; \
  delete package.scripts; \
  delete package.options; \
  package.main = 'index.js'; \
  package.browser = 'bundle.umd.js'; \
  package.module = 'index.js'; \
  package['jsnext:main'] = 'index.js'; \
  package.typings = 'index.d.ts'; \
  var origVersion = 'local';
  var fs = require('fs'); \
  fs.writeFileSync('./npm/package.json', JSON.stringify(package, null, 2)); \
  "

# Copy few more files to ./npm
cp README.md npm/
cp LICENSE npm/

echo 'deploying to npm...'
cd npm && npm publish
