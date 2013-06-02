complete -x -c j -a '(autojump --bash --complete (commandline -t))'

switch "$XDG_DATA_HOME"
    case "*$USER*"
        set -x AUTOJUMP_DATA_DIR "$XDG_DATA_HOME/autojump"
    case '*'
        set -x AUTOJUMP_DATA_DIR ~/.local/share/autojump
end

if not test -d $AUTOJUMP_DATA_DIR
    mkdir $AUTOJUMP_DATA_DIR
end

# local installation
if test -d ~/.autojump
    set -x PATH ~/.autojump/bin $PATH
end

set -x AUTOJUMP_HOME $HOME

function __aj_err
    echo $argv 1>&2; false
end

function __aj_not_found
    __aj_err "autojump: directory '"$argv"' not found"
    __aj_err "Try `autojump --help` for more information."
end

function __aj_add --on-variable PWD
    status --is-command-substitution; and return
    autojump -a (pwd) >/dev/null ^$AUTOJUMP_DATA_DIR/autojump_errors
end

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

function jc
    switch "$argv"
        case '-*'
            j $argv
        case '*'
            j (pwd) $argv
    end
end

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

function jco
    switch "$argv"
        case '-*'
            j $argv
        case '*'
            jo (pwd) $argv
    end
end
