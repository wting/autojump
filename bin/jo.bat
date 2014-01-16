@echo off
setlocal EnableDelayedExpansion

echo %*|>nul findstr /rx \-.*
if ERRORLEVEL 1 (
  for /f %%i in ('python %~dp0\autojump %*') do set new_path=%%i
  if exist !new_path!\nul (
    start !new_path!
  ) else (
    echo autojump: directory %* not found
    echo try `autojump --help` for more information
  )
) else (
  python %~dp0\autojump %* 
)