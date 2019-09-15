Set-Alias -Name ll -Value ls
Function .. {cd ..}
Function ... {cd ../..}
Function .... {cd ../../..}
Function ..... {cd ../../../..}
Function ...... {cd ../../../../..}
Function ....... {cd ../../../../../..}
Function ........ {cd ../../../../../../..}
Function ......... {cd ../../../../../../../..}
Function .......... {cd ../../../../../../../../..}

Function j {
    $jumpdir = autojump $args
    echo "$jumpdir"
    cd $jumpdir
}

Function jc {
    j "$pwd" @args
}

Function g {
    $repo_root = git rev-parse --show-toplevel
    j $repo_root @args
}

Set-PSBreakpoint -Variable pwd -Mode Write -Action {
    autojump --add "$pwd"
} | out-null
