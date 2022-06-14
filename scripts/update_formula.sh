#!/bin/sh

set -e
base_formula_name="observiq-otel-collector"
base_file="Formula/$base_formula_name.rb"

# Parse old version from current symlink
old_version="$(find ./Aliases -type l | sed 's+^./Aliases/observiq-otel-collector@++' | xargs -n 1)"

echo "Replacing formula for version: $old_version"

# Verify expected Environemnt variables are set
if [ -z "$NEW_VERSION" ] ; then
    echo "Must specify next collector version via NEW_VERSION"
    exit 1
fi 

# Update current live formula to old version
old_file="Formula/$base_formula_name@$old_version.rb"
new_file="Formula/$base_formula_name@$NEW_VERSION.rb"

# Verify formula for version doesn't exist
if [ -f "$old_file" ]; then
    echo "Formula already exists for version: $old_version"
    exit 1
fi

# Verify formula for 
if [ ! -f "$new_file" ]; then
    echo "No formula found for version: $NEW_VERSION"
    exit 1
fi

# Remove Symlink
rm "Aliases/$base_formula_name@$old_version"

# Rename base formula
mv "$base_file" "$old_file"

# Remove dots from old version
brew_old_version="$(echo "$old_version" | sed 's/\.//g')" 

# Add versions to file
sed  -i 's/class ObserviqOtelCollector </'"class ObserviqOtelCollectorAT$brew_old_version"' </' "$old_file"
sed  -i 's+observiq/observiq-otel-collector/observiq-otel-collector+'"observiq/observiq-otel-collector/observiq-otel-collector@$old_version"'+g' "$old_file"

# Upated new version to current live

# Rename to base formula
mv "$new_file" "$base_file"

# Remove dots from new version
brew_new_version="$(echo "$NEW_VERSION" | sed 's/\.//g')"

# Remove versions from file
sed  -i 's/'"class ObserviqOtelCollectorAT$brew_new_version <"'/class ObserviqOtelCollector </' "$base_file"
sed  -i 's+'"observiq/observiq-otel-collector/observiq-otel-collector@$NEW_VERSION"'+observiq/observiq-otel-collector/observiq-otel-collector+g' "$base_file"

# Create symlink
cd Aliases && ln -s "../$base_file" "observiq-otel-collector@$NEW_VERSION"
