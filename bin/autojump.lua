local HOME = clink.get_env("USERPROFILE") .."\\"
local AUTOJUMP_BIN = HOME .. ".autojump\\bin\\autojump"

function autojump_add_to_database() 
  os.execute("python " .. AUTOJUMP_BIN .. " --add " .. clink.get_cwd())
end

clink.prompt.register_filter(autojump_add_to_database, 99)
