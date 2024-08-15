#!/bin/bash

####################################################################################################
#
# Calls github-pages executable to build the site using allowed plugins and supported configuration
#
####################################################################################################

SOURCE_DIRECTORY=${GITHUB_WORKSPACE}/$INPUT_SOURCE
DESTINATION_DIRECTORY=${GITHUB_WORKSPACE}/$INPUT_DESTINATION
PAGES_GEM_HOME=$BUNDLE_APP_CONFIG
JEKYLL_BIN=$PAGES_GEM_HOME/bin/jekyll
JEKYLL_CONFIG=/_config.out.yml

# Check if Gemfile's dependencies are satisfied or print a warning
if test -e "$SOURCE_DIRECTORY/Gemfile" && ! bundle check --dry-run --gemfile "$SOURCE_DIRECTORY/Gemfile"; then
  echo "::warning::The github-pages gem can't satisfy your Gemfile's dependencies. If you want to use a different Jekyll version or need additional dependencies, consider building Jekyll site with GitHub Actions: https://jekyllrb.com/docs/continuous-integration/github-actions/"
fi

echo "Configuring Jekyll..."
chmod +x /bin/merge_configs
if test -f "$SOURCE_DIRECTORY/_config.yml"; then
  /bin/merge_configs "$SOURCE_DIRECTORY/_config.yml"
elif test -f "${SOURCE_DIRECTORY}/_config.yaml"; then
  /bin/merge_configs "$SOURCE_DIRECTORY/_config.yaml"
elif test -f "${GITHUB_WORKSPACE}/_config.yml"; then
  /bin/merge_configs "${GITHUB_WORKSPACE}/_config.yml"
elif test -f "${GITHUB_WORKSPACE}/_config.yaml"; then
  /bin/merge_configs "${GITHUB_WORKSPACE}/_config.yaml"
else
  /bin/merge_configs
fi

cd "${GITHUB_WORKSPACE}" || exit

# Install ruby dependencies
if test -f "${GITHUB_WORKSPACE}/Gemfile"; then
  echo "Installing ruby dependencies..."
  bundle install
fi

# Install node dependencies
if test -f "${GITHUB_WORKSPACE}/package.json"; then
  echo "Installing node dependencies..."
  mkdir "${GITHUB_WORKSPACE}/node_modules"
  npm install --prefix "${GITHUB_WORKSPACE}"
fi

ls -a
ls -a ./node_modules/postcss
pwd

# Set environment variables required by supported plugins
export JEKYLL_ENV="production"
export JEKYLL_GITHUB_TOKEN=$INPUT_TOKEN
export PAGES_REPO_NWO=$GITHUB_REPOSITORY
export JEKYLL_BUILD_REVISION=$INPUT_BUILD_REVISION
export PAGES_API_URL=$GITHUB_API_URL

# Set verbose flag
if [ "$INPUT_VERBOSE" = 'true' ]; then
  VERBOSE='--verbose'
else
  VERBOSE=''
fi

# Set future flag
if [ "$INPUT_FUTURE" = 'true' ]; then
  FUTURE='--future'
else
  FUTURE=''
fi

{ cd "$PAGES_GEM_HOME" || { echo "::error::pages gem not found"; exit 1; }; }

# Run the command, capturing the output, allowing additional jekyll config if it exists
echo "Building..."
build_output="$($JEKYLL_BIN build "$VERBOSE" "$FUTURE" --source "$SOURCE_DIRECTORY" --destination "$DESTINATION_DIRECTORY" --config "$JEKYLL_CONFIG")"

# Capture the exit code
exit_code=$?

if [ $exit_code -ne 0 ]; then
  # Remove the newlines from the build_output as annotation not support multiline
  error=$(echo "$build_output" | tr '\n' ' ' | tr -s ' ')
  echo "::error::$error"
else
  # Display the build_output directly
  echo "$build_output"
fi

# Exit with the captured exit code
exit $exit_code
