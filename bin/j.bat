@echo off

echo %*|>nul findstr /rx \-.*
if ERRORLEVEL 1 (
  for /f %%G in ('python %~dp0\autojump %*') do set new_path=%%G
  if exist %new_path%/nul (
    cd %new_path%
  ) else (
    echo autojump: directory %* not found
    echo try `autojump --help` for more information
  )
  echo %new_path%
) else (
  python %~dp0\autojump %* 
)