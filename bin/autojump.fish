# set user installation path
if test -d ~/.autojump
    set -x PATH ~/.autojump/bin $PATH
end


# enable tab completion
complete -x -c j -a '(autojump --complete (commandline -t))'


# change pwd hook
function __aj_add --on-variable PWD
    status --is-command-substitution; and return
    autojump -a (pwd) >/dev/null &
end


# misc helper functions
function __aj_err
    # TODO(ting|#247): set error file location
    echo $argv 1>&2; false
end

function __aj_not_found
    __aj_err "autojump: directory '"$argv"' not found"
    __aj_err "Try `autojump --help` for more information."
end


# default autojump command
function j
    switch "$argv"
        case '-*' '--*'
            autojump $argv
        case '*'
            set -l new_path (autojump $argv)
            if test -d "$new_path"
                set_color red
                echo $new_path
                set_color normal
                cd $new_path
            else
                __aj_not_found $argv
            end
    end
end


# jump to child directory (subdirectory of current path)
function jc
    switch "$argv"
        case '-*'
            j $argv
        case '*'
            j (pwd) $argv
    end
end


# open autojump results in file browser
function jo
    if test -z (autojump $argv)
        __aj_not_found $argv
    else
        switch (sh -c 'echo ${OSTYPE}')
            case linux-gnu
                xdg-open (autojump $argv)
            case 'darwin*'
                open (autojump $argv)
            case cygwin
                cygstart "" (cygpath -w -a (pwd))
            case '*'
                __aj_error "Unknown operating system."
        end
        echo end
    end
end


# open autojump results (child directory) in file browser
function jco
    switch "$argv"
        case '-*'
            j $argv
        case '*'
            jo (pwd) $argv
    end
end
