local HOME = clink.get_env("USERPROFILE") .."\\"
local AUTOJUMP_BIN = HOME .. ".autojump\\bin\\autojump"

function autojump_add_to_database() 
  os.execute("python " .. AUTOJUMP_BIN .. " --add " .. clink.get_cwd())
end

clink.prompt.register_filter(autojump_add_to_database, 99)

function autojump_completion(word)
  for line in io.popen("python " .. AUTOJUMP_BIN .. " --complete " .. word):lines() do
    clink.add_match(line)
  end
  return {} 
end

local autojump_parser = clink.arg.new_parser()
autojump_parser:set_arguments({ autojump_completion })

clink.arg.register_parser("j", autojump_parser)