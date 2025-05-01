# RELEASE-Process

The following tasks are run in the release process and described in detail below.

Manual step before / test to unused code:
$ bash make.sh test_to_unused_code

## Implementation in make.sh deploy
* cleanup_dist
* TO_BE_ADDED: ggshield secret scan --all --fail
* stash_changes
* build new version
* poetry.exe lock --no-update
* poetry.exe check
* update_documentation
* create_windows_shortcuts
* build_executable
* create_zip_package
* git_commit_and_tag
* upload_to_bitbucket

## Implementation bitbucket-pipelines.yml
