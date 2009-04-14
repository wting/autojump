#This shell snippet sets the prompt command and the necessary aliases
_autojump() 
{
        local cur
        COMPREPLY=()
        unset COMP_WORDS[0] #remove "j" from the array
        cur=${COMP_WORDS[*]}
        IFS=$'\n' read -d '' -a COMPREPLY < <(autojump --completion "$cur")
        return 0
}
complete -F _autojump j
AUTOJUMP='(autojump -a "$(pwd -P)"&)>/dev/null'
if [[ ! $PROMPT_COMMAND =~ autojump ]]; then
  export PROMPT_COMMAND="${PROMPT_COMMAND:-:} && $AUTOJUMP"
fi 
alias jumpstat="autojump --stat"
function j { new_path="$(autojump $@)";if [ -n "$new_path" ]; then echo -e "\\033[31m${new_path}\\033[0m"; cd "$new_path";fi }
