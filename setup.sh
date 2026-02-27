#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ "$SCRIPT_DIR" != "$(pwd)" ]; then
    echo "ERROR: Please run this script from the root of the project."
    exit 1
fi

# Ensure consistent locale for string operations
LC_ALL=C
export LC_ALL

echo "Please read README.md before using this template."
echo
echo "Project name will be used as CMake project name, variable/function/macro name prefix,"
echo "and also as the name of the main executable (if any)."
echo "Note, that variable/function/macro prefix will have underscores instead of dashes."
echo "Allowed characters: a-z, A-Z, 0-9, underscore (_), hyphen (-)."
read -r -p "Project Name: " project_name
if [[ "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]
then
    prefix="${project_name//-/_}"
    echo "Project name is '$project_name'. Variable/function/macro prefix is '$prefix'."
else
    echo "ERROR: Project name contains invalid characters."
    exit 1
fi
echo

echo "By default the template is set up for C++23 ('cxx_std_23' feature flag)."
echo "You can specify different feature flag here if desired (empty will leave it as C++23)."
echo "(For example, 'cxx_std_17', 'cxx_std_20', 'cxx_std_26', etc.)"
read -r -p "C++ standard flag: " cxx_std_flag
if [ -n "$cxx_std_flag" ]; then
    if [[ ! "$cxx_std_flag" =~ ^[a-zA-Z0-9_-]+$ ]]
    then
        echo "ERROR: C++ standard flag contains invalid characters."
        exit 1
    fi
    echo "C++ standard flag set to '$cxx_std_flag'."
    # Replace the C++ standard flags in all files.
    grep -lr 'cxx_std_23' . | xargs sed -i "s/cxx_std_23/${cxx_std_flag}/g"
else
    echo "Keeping the default C++23."
fi
echo

# Remove possible .git/ that is left over from cloning the template repository.
rm -rf .git/

# Replace the project name placeholders with the actual project name.
grep -lr 'x_PROJECT_NAME_x' . | xargs sed -i "s/x_PROJECT_NAME_x/${project_name}/g"
grep -lr 'x_NAME_x' . | xargs sed -i "s/x_NAME_x/${prefix}/g"

# Make project README the main README.md and retain the template usage instructions in a separate file.
mv README.md README-template.md
mv README-project.md README.md
echo "README.md has been replaced with actual project README template."
echo "Usage instructions for this CMake template have been retained as README-template.md."
echo

echo "This script will now delete itself since running it again would not work correctly."
echo "If you need to re-run the setup, please clone the repository again."
rm -- "$0"
