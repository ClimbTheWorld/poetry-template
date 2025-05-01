#!/usr/bin/bash

# Shell script used as a "Makefile-like" helper tool.
# Usage: Enter ". make.sh key" in the pycharm terminal,
# where "key" is one of the keywords below (e.g. "venv" or "unittest").
# Set up pycharm as described in the PACE_EVA/docs folder to access GitBash
# directly from pycharm terminal.

# when executables are called with the suffix .exe the script executes
# the Windows executable out of the wsl environment

# Troubleshooting:
# run 'dos2unix make.sh' if you get an error like:
# "bash: $'\r': command not found"

# Enable debugging
set -x

set -euo pipefail

# Call the script as to debug it (verbose output of variables, no stepping):
# $ bash -x make.sh <keyword>

function validate_version() {
  local version=$1
  if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Valid version: $version"
    return 0
  else
    echo "Invalid version: $version"
    return 1
  fi
}

set -e

function cleanup_dist() {
    rm -f dist/*
}

function stash_changes() {
    git.exe stash
}

function validate_bump_type() {
    local bump_type=$1
    if [[ ! "$bump_type" =~ ^(patch|minor|major)$ ]]; then
        echo "Error: Invalid version bump type. Use 'patch', 'minor', or 'major'."
        exit 1
    fi
}

function test_to_unused_code() {
    poetry run vulture src/ tests/
}

function get_current_version() {
    poetry.exe version | rev | cut -d " " -f 1 | rev | tr -d '\r'
}

function bump_version() {
    local bump_type=$1
    poetry.exe version "$bump_type" | rev | cut -d " " -f 1 | rev | tr -d '\r'
}

function update_documentation() {
    currentversion=$(get_current_version)
    sed -i 's/[[:space:]]*$/  /' Bedienungsanleitung.md
    sed -i "/^Datum:/c\Datum: $(date +%d.%m.%Y)" Bedienungsanleitung.md
    sed -i "/^Software Version:/c\Software Version: v${currentversion}" Bedienungsanleitung.md

    pandoc --standalone --toc --toc-depth=3 \
        --metadata title="Bedienungsanleitung Maschinenplaner" \
        --include-in-header=Bedienungsanleitung.css \
        Bedienungsanleitung.md -o Bedienungsanleitung.html

    wkhtmltopdf --load-error-handling ignore --page-size A4 --orientation Portrait \
        --margin-top 15 --margin-left 10 --margin-bottom 20 --margin-right 15 \
        --footer-font-size 8 --footer-center "Seite [page] von [toPage]" \
        --footer-right "[isodate]" --title "Bedienungsanleitung Maschinenplanner" \
        Bedienungsanleitung.html Bedienungsanleitung.pdf
}

function create_windows_shortcuts() {
    pwsh.exe -NoLogo -NoProfile -Command "
        \$WshShell = New-Object -ComObject WScript.Shell;
        \$Shortcut = \$WshShell.CreateShortcut((Join-Path (Get-Location) 'shortcutname-1.lnk'));
        \$Shortcut.TargetPath = (Join-Path (Get-Location) 'packagename.exe');
        \$Shortcut.Arguments = '-c';
        \$Shortcut.WorkingDirectory = (Get-Location).Path;
        \$Shortcut.Save();"

    pwsh.exe -NoLogo -NoProfile -Command "
        \$WshShell = New-Object -ComObject WScript.Shell;
        \$Shortcut = \$WshShell.CreateShortcut((Join-Path (Get-Location) 'shortcutname-2.lnk'));
        \$Shortcut.TargetPath = (Join-Path (Get-Location) 'packagename.exe');
        \$Shortcut.Arguments = '-i -g';
        \$Shortcut.WorkingDirectory = (Get-Location).Path;
        \$Shortcut.Save();"
}

function build_executable() {
    poetry.exe run pyinstaller -F ./src/packagename/app.py -n packagename --distpath ./dist
}

function create_zip_package() {
    zipfile="dist/packagename-v$newversion.zip"
    files=(
        "dist/packagename.exe"
        "Bedienungsanleitung.html"
        "Bedienungsanleitung.pdf"
        "Bedienungsanleitung.md"
        "pytest-report.html"
        "dotenv-template.txt"
    )

    md5sum "${files[@]}" > CHECKSUMS.md
    files+=("CHECKSUMS.md")

    zip -r "$zipfile" "${files[@]}" --exclude "dist/packagename.exe"
    zip -ur "$zipfile" dist/packagename.exe
}

function git_commit_and_tag() {
    for file in "${files[@]}"; do
        [[ "$file" != "dist/packagename.exe" && -f "$file" ]] && git.exe add "$file"
    done
    git.exe add dist/packagename-v$newversion.zip -f
    git.exe add CHECKSUMS.md
    git.exe add pyproject.toml

    md5=$(md5sum "$zipfile" | awk '{print $1}')
    message="Bump version to v$newversion
Add: packagename-v$newversion.zip
zipfile: $md5  packagename-v$newversion.zip"
    
    git.exe commit -m "$message" --no-verify
    git.exe tag -a v$newversion -m "$message"
}

function upload_to_bitbucket() {
    source .bitbucket
    curl --request POST \
        --url "https://api.bitbucket.org/2.0/repositories/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO}/downloads" \
        --user "${BITBUCKET_USER}:${BITBUCKET_APP_PASSWORD}" \
        --form files=@"$zipfile"
}

function deploy() {
    cleanup_dist
    stash_changes

    bump_type=${1:-patch}
    validate_bump_type "$bump_type"

    currentversion=$(get_current_version)
    echo "Current version: $currentversion"

    newversion=$(bump_version "$bump_type")
    echo "New version: $newversion"

    poetry.exe lock --no-update
    poetry.exe check

    update_documentation
    create_windows_shortcuts
    build_executable
    create_zip_package
    git_commit_and_tag
    upload_to_bitbucket
}


for KEYWORD in "$@"
do
    case "${KEYWORD}"
    in  "venv")  # User entered ". make.sh venv"
            # For pycharm users: Activate virtual environment
            poetry.exe shell
            ;;

        "install")  # User entered ". make.sh install"
            # install all modules to .venv (to be used after inital cloning of repo)
            poetry.exe install
            echo virtual environment populated
            ;;

        "locdep")  # Build of the package and install in the actual venv
            rm dist/*
            poetry.exe version patch
            poetry.exe lock --no-update
            poetry.exe check
            poetry.exe build
            ARTIFACT_LOCATION=$(ls dist/*.whl)
            echo Dep
            ;;

        "deploy")  # Build of the package and install in the venvs of the gwfpayloadtenant/fastapi-jaeger and gwfpayloadtenant/poc-mbwblue-parsing
            deploy "$2"
            ;;

        "test")
            # run python tests
            # Excecutes all sanity check funtions delared in .unittest/ folder
            poetry.exe run pytest -n auto  --timeout=180 --html=artifacts/reports/pytest-report.html

            # Usually, all py files in the tests/ folder are run, but this might
            # not work on some of the IDEs ued.
            # python -m pytest
            ;;

        "count_lines")
            # Count all self-written lines of python code within the repository
            # Exclude all files in .gitignore
            git.exe ls-files | grep py | xargs wc -l
            ;;
        
        "build_exe")
            # Run pyinstaller to build the executable
            poetry.exe run pyinstaller -F ./src/packagename/app.py -n packagename
            ;;
        
        "create_links")
            # Create Windows shortcuts for the executable
            create_windows_shortcuts
            ;;
        
        "create_Bedienungsanleitung")
            update_documentation
            ;;
        
        "test_to_unused_code")
            # run vulture to check for unused code
            test_to_unused_code
            ;;

        *)
            # default action if keyword not recognized, do nothing
            echo Make inactive, no keyword specified
            ;;
    esac
done
