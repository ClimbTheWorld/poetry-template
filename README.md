# README Poetry Project Bootstrap
This project shall help bootstrap a poetry project including the release process with the following features:
* git projet
* poetry project
* pre-commit hooks
  * ggshield for checking code for secrets prior to commit
  * black for code formatting
  * isort for sorting imports
  * flake8 for code checking
  * pylint for code checking
  * add whitespaces to the end of each line of a markdown file for the readability
* pytest for unit testing
* dotenv for environment variables
* vscode settings for debugging
* make.sh for deployment
  * create zip file from project on release
  * create Windows executable from the project
  * create shortcuts for Windows for Windows-Users to not have to pass the cli arguments
  * commit and tag the release (pushing is still manual)
* test project to unused code using vulture
* make.sh for release process
* push zip file to bitbucket Downloads (WIP)
## Start creating a new project
Create repo at github.com  
$ git clone <repo>  
$ cd <repo>  

## Create poetry environment
if you don't have the global poetry config set like this:
$ poetry config virtualenvs.in-project true

decide if you want to set it as global config or not.
$ poetry config virtualenvs.in-project true
or 
$ poetry config --local virtualenvs.in-project true

$ poetry new <projectname>  
$ poetry env use /usr/bin/python3.12  
or  
$ poetry env use python3.12  

## Update pyproject.toml
Copy paste the content of the file 'pyproject-toml' to the end of pyproject.toml. This does:
* config venv of the project
* add black, flake8, isort, pylint, pre-commit, ggshield as pre-commit hooks
* add pytest settings to use multiple workers on execution

### ggshield
Preserve your repo against secrets leaks. Secrets in the .env file are *not* scanned!

#### Known issues with dotenv-package
Because no versions of ggshield match >1.39.0,<2.0.0
 and ggshield (1.39.0) depends on python-dotenv (>=0.21.0,<0.22.0), ggshield (>=1.39.0,<2.0.0) requires python-dotenv (>=0.21.0,<0.22.0).
So, because testfield1 depends on both python-dotenv (^1.1.0) and ggshield (^1.39.0), version solving failed.

#### Run over all files
If introducing ggshield to an existing project run once:  
$ poetry run ggshield secret scan path . --recursive --use-gitignore

### Add scripts to pyproject.toml
If wished to call like: $ poetry run scriptname
Add the following to the pyproject.toml file:
```toml
[tool.poetry.scripts]
scriptname = "src.<projectname>.scriptname:main"
```

### Leftovers of pyproject.toml
Check:
* pythonpath = "src"
* if you want to filter warnings: 
  filterwarnings = ["ignore::DeprecationWarning",
    "ignore::FutureWarning"]

Pytest settings:
* -rfp: result with failed, passed
* -s: don't capture print output
* -v: verbose
* -n auto: use multiple workers for running tests (default is 8)

Install new poetry packages:
$ poetry update

Install pre-commit hooks:
$ poetry run pre-commit install  

### Adjustments to the new projectname
* .pylintrc: 
  * init-hook='import sys; sys.path.append("src/<packagename>")'
  * source-roots=src/<packagename>
* make.sh: review all lines with <packagename> need to be changed to the new projectname
* copy the dotenv-template.txt to .env
* insert ggshield API key in .env:GITGUARDIAN_API_KEY
* .vscode/launch.json:
  * packagename
  * args: ["arg1", "arg2"]
  * 'src' if not using src folder



## Deployment make.sh
When run in WSL2 under Windows, the executable need to be called with the file suffix, eg. poetry.exe, then the Windows environment is used.  
Adjust the make.sh to your needs:
* deploy()
* create_windows_shortcuts()
* 



# .vscode
## settings.json
Adjust path in settings.json to your system
  
[Poetry101](poetry101.md)