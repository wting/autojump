if [ $SHELL = "/bin/bash" ]; then
    export PROMPT_COMMAND="$PROMPT_COMMAND"';autojump -a "$(pwd -P)"'
    alias jstat="autojump --stat"
    function j { new_path=$(autojump $@);if [ -n "$new_path" ]; then echo -e "\\033[31m${new_path}\\033[0m"; echo; cd "$new_path";fi }
fi
