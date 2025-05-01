# Poetry101

Basic information for the work with poetry.

# Understanding of Python Environments under Windows 10/11

In PowerShell list all to PATH in Windows known python.exe
PS1> Get-Command -Name python.exe -All | Select-Object Source

In PowerShell find all python.exe on c:\ (also ones which aren't in the PATH env var)
PS1> Get-ChildItem -Path C:\ -Filter python.exe -Recurse -ErrorAction SilentlyContinue

Windows has since some time a launcher, also for python. This is a py.exe which is in c:\Windows\System32? and using this the main python.exe can be selected. Find launcher:
PS1> Get-Command -Name python.exe -All | Select-Object Source

List all python's known:
PS1> py.exe --list

# Todo

Poetry installation using pip




# Known Facts


| Keyword                                    | Notes                                                                                                                                                                                                                                                                                                | Link |
| -------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| poetry creates .venv in userpath           | There is a global config for poetry which needs to be added so the .venv's are created in the project: <br /> add this globally <br /> $ poetry config virtualenvs.in-project true <br /> or locally <br /> $ poetry config virtualenvs.in-project true --local <br />                                                                                                                                                                                                  |      |                                                                                                                                                                   |      |
| conda and poetry                           | conda creates .venv in c:\Users\<username>\.conda                                                                                                                                                                                                                                                    |      |
| poetry install raises python version issue | Project cannot be installed because Windows installed python<v>.exe is not the same version (I think higher):<br><br><br>> install python using winget to c:\python<v>\ <br><br>PS1> winget install Python.Python.3.12 --silent --override "/quiet InstallAllUsers=1 TargetDir=C:\Python\Python3.12" |      |
