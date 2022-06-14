#!/bin/sh

set -e
base_formula_name="observiq-otel-collector"
base_file="Formula/$base_formula_name.rb"

# Verify expected Environemnt variables are set
if [ -z "$NEW_VERSION" ] ; then
    echo "Must specify next collector version via NEW_VERSION"
    exit 1
fi 

if [ -z "$OLD_VERSION" ]; then
    echo "Must specify old collector version via OLD_VERSION"
    exit 1
fi

# Update current live fomrula to old version
old_file="Formula/$base_formula_name@$OLD_VERSION.rb"
new_file="Formula/$base_formula_name@$NEW_VERSION.rb"

# Verify formula for version doesn't exits
if [ -f "$old_file" ]; then
    echo "Formula already exists for version: $OLD_VERSION"
    exit 1
fi

# Verify formula for 
if [ ! -f "$new_file" ]; then
    echo "No formula found for version: $NEW_VERSION"
    exit 1
fi

# Remove Symlink
rm "Aliases/$base_formula_name@$OLD_VERSION"

# Rename base formula
mv "$base_file" "$old_file"

# Remove dots from old version
brew_old_version="$(echo "$OLD_VERSION" | sed 's/\.//g')" 

# Add versions to file
sed  -i 's/class ObserviqOtelCollector </'"class ObserviqOtelCollectorAT$brew_old_version"' </' "$old_file"
sed  -i 's+observiq/observiq-otel-collector/observiq-otel-collector+'"observiq/observiq-otel-collector/observiq-otel-collector@$OLD_VERSION"'+g' "$old_file"

# Upated new version to current live

# Rename to base formula
mv $new_file "$base_file"

# Remove dots from new version
brew_new_version="$(echo "$NEW_VERSION" | sed 's/\.//g')"

# Remove versions from file
sed  -i 's/'"class ObserviqOtelCollectorAT$brew_new_version <"'/class ObserviqOtelCollector </' "$base_file"
sed  -i 's+'"observiq/observiq-otel-collector/observiq-otel-collector@$NEW_VERSION"'+observiq/observiq-otel-collector/observiq-otel-collector+g' "$base_file"

# Create symlink
cd Aliases && ln -s "../$base_file" "observiq-otel-collector@$NEW_VERSION"
