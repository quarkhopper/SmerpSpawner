TOOL_NAME = "Smerps"

STRINGS = {}

-- delimeters
STRINGS.DELIM_VEC = ":"
STRINGS.DELIM_STRINGS = "~"
STRINGS.DELIM_ENUM_PAIR = "&"
STRINGS.DELIM_REG_KEY = "."

-- registry related delimeters and strings
REG = {}
REG.DELIM = "."
REG.TOOL_KEY = "smerp_spawner"
REG.TOOL_NAME = "savegame.mod.tool." .. REG.TOOL_KEY .. ".quarkhopper"
REG.TOOL_KEYBIND = "keybind"
REG.PREFIX_TOOL_KEYBIND = REG.TOOL_NAME .. REG.DELIM .. REG.TOOL_KEYBIND

-- Keybinds
function setup_keybind(name, reg, default_key)
    local keybind = {["name"] = name, ["reg"] = reg}
    keybind.key = GetString(REG.PREFIX_TOOL_KEYBIND..REG.DELIM..keybind.reg)
    if keybind.key == "" then 
        keybind.key = default_key
        SetString(REG.PREFIX_TOOL_KEYBIND..REG.DELIM..keybind.reg, keybind.key)
    end
    return keybind
end

KEY = {}
KEY.SPAWN_GROUP = setup_keybind("Spawn 50 smerts", "spawn_group", "X")
KEY.DEATH_CAM_TOGGLE = setup_keybind("Toggle death cam on/off", "death_cam_toggle", "I")
KEY.OSD = setup_keybind("Toggle information (upper right) on/off", "osd", "P")

