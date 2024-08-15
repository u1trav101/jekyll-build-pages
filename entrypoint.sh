#!/bin/bash

####################################################################################################
#
# Calls jekyll executable to build the site using any plugins
#
####################################################################################################

SOURCE_DIRECTORY=${GITHUB_WORKSPACE}/$INPUT_SOURCE
DESTINATION_DIRECTORY=${GITHUB_WORKSPACE}/$INPUT_DESTINATION
PAGES_GEM_HOME=$BUNDLE_APP_CONFIG
JEKYLL_BIN=$PAGES_GEM_HOME/bin/jekyll
JEKYLL_CONFIG=/_config.out.yml

# Marking binaries as executables
chmod +x /bin/merge_jekyll_configs
chmod +x /bin/merge_gemfiles

# Merging jekyll configurations if needed
echo "Configuring Jekyll..."
if test -f "$SOURCE_DIRECTORY/_config.yml"; then
  /bin/merge_jekyll_configs "$SOURCE_DIRECTORY/_config.yml"
elif test -f "$SOURCE_DIRECTORY/_config.yaml"; then
  /bin/merge_jekyll_configs "$SOURCE_DIRECTORY/_config.yaml"
elif test -f "$GITHUB_WORKSPACE/_config.yml"; then
  /bin/merge_jekyll_configs "${GITHUB_WORKSPACE}/_config.yml"
elif test -f "$GITHUB_WORKSPACE/_config.yaml"; then
  /bin/merge_jekyll_configs "${GITHUB_WORKSPACE}/_config.yaml"
else
  /bin/merge_jekyll_configs
fi

# Merging Gemfiles if needed
echo "Checking for Gemfile merge..."
if test -f "$SOURCE_DIRECTORY/Gemfile"; then
  /bin/merge_gemfiles "${SOURCE_DIRECTORY}./Gemfile"
else
  mv /Gemfile "$SOURCE_DIRECTORY/Gemfile"

fi

# Change to working directory 
cd "$SOURCE_DIRECTORY" || exit

# Install ruby dependencies, merging Gemfiles if needed
if test -f ./Gemfile; then
  bundle install
fi

# Install node dependencies
if test -f ./package.json; then
  echo "Installing node dependencies..."
  mkdir ./node_modules
  npm install --prefix "${GITHUB_WORKSPACE}"
fi

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
