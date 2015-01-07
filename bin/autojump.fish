set -x AUTOJUMP_SOURCED 1

# set user installation path
if test -d ~/.autojump
    set -x PATH ~/.autojump/bin $PATH
end


# enable tab completion
complete -x -c j -a '(autojump --complete (commandline -t))'


# set error file location
if test (uname) = "Darwin"
    set -x AUTOJUMP_ERROR_PATH ~/Library/autojump/errors.log
else if test -d "$XDG_DATA_HOME"
    set -x AUTOJUMP_ERROR_PATH $XDG_DATA_HOME/autojump/errors.log
else
    set -x AUTOJUMP_ERROR_PATH ~/.local/share/autojump/errors.log
end

if test ! -d (dirname $AUTOJUMP_ERROR_PATH)
    mkdir -p (dirname $AUTOJUMP_ERROR_PATH)
end


# change pwd hook
function __aj_add --on-variable PWD
    status --is-command-substitution; and return
    autojump --add (pwd) >/dev/null 2>>$AUTOJUMP_ERROR_PATH &
end


# misc helper functions
function __aj_err
    # TODO(ting|#247): set error file location
    echo $argv 1>&2; false
end

# default autojump command
function j
    switch "$argv"
        case '-*' '--*'
            autojump $argv
        case '*'
            set -l output (autojump $argv)
            if test -d "$output"
                set_color red
                echo $output
                set_color normal
                cd $output
            else
                __aj_err "autojump: directory '"$argv"' not found"
                __aj_err "\n$output\n"
                __aj_err "Try `autojump --help` for more information."
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
    set -l output (autojump $argv)
    if test -d "$output"
        __aj_err "autojump: directory '"$argv"' not found"
        __aj_err "\n$output\n"
        __aj_err "Try `autojump --help` for more information."
    else
        switch (sh -c 'echo ${OSTYPE}')
            case 'linux*'
                xdg-open (autojump $argv)
            case 'darwin*'
                open (autojump $argv)
            case cygwin
                cygstart "" (cygpath -w -a (pwd))
            case '*'
                __aj_error "Unknown operating system: '"$OSTYPE"'"
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
