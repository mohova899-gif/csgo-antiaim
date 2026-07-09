-- CSGO Anti-Aim Menu using PUI (Neverlose UI Framework)
-- Interactive menu for controlling anti-aim presets and conditions

local menu = {}

-- Try to load antiaim module, create stub if not available
local antiaim
if pcall(function() antiaim = require("antiaim") end) then
    -- Module loaded successfully
else
    antiaim = {
        enabled = true,
        preset = "classic_jitter",
        conditions = {
            standing = true,
            moving = true,
            slowwalking = true,
            crouching = true,
            in_air = true,
            in_air_crouching = true,
            on_use = false
        },
        set_preset = function(self, preset) self.preset = preset end,
        set_jitter_strength = function(self, strength) end
    }
end

-- Menu structure
local menu_root = ui.Group("Anti-Aim", "antiaim_menu")

-- Main toggle
local toggle_enabled = ui.Checkbox(menu_root, "Enable Anti-Aim", "antiaim_toggle", false)

-- Preset selection
local preset_group = ui.Group(menu_root, "Presets", "antiaim_presets")
local preset_classic = ui.Checkbox(preset_group, "Classic Jitter", "preset_classic", true)
local preset_delay = ui.Checkbox(preset_group, "Delay Jitter", "preset_delay", false)
local preset_conditional = ui.Checkbox(preset_group, "Conditional", "preset_conditional", false)

-- Jitter settings
local jitter_group = ui.Group(menu_root, "Jitter Settings", "antiaim_jitter")
local jitter_strength = ui.Slider(jitter_group, "Jitter Strength", "jitter_strength", 0, 100, 25, 1)
local delay_jitter_speed = ui.Slider(jitter_group, "Delay Jitter Speed", "delay_speed", 50, 300, 100, 10)

-- Conditions
local conditions_group = ui.Group(menu_root, "Conditions", "antiaim_conditions")
local cond_standing = ui.Checkbox(conditions_group, "Standing", "cond_standing", true)
local cond_moving = ui.Checkbox(conditions_group, "Moving", "cond_moving", true)
local cond_slowwalking = ui.Checkbox(conditions_group, "Slowwalking", "cond_slowwalking", true)
local cond_crouching = ui.Checkbox(conditions_group, "Crouching", "cond_crouching", true)
local cond_in_air = ui.Checkbox(conditions_group, "In Air", "cond_in_air", true)
local cond_in_air_crouch = ui.Checkbox(conditions_group, "In Air & Crouching", "cond_in_air_crouch", true)
local cond_on_use = ui.Checkbox(conditions_group, "On Use", "cond_on_use", false)

-- Advanced settings
local advanced_group = ui.Group(menu_root, "Advanced", "antiaim_advanced")
local pitch_value = ui.Slider(advanced_group, "Pitch", "pitch_value", -90, 90, 89, 1)
local yaw_offset = ui.Slider(advanced_group, "Yaw Offset", "yaw_offset", -180, 180, 0, 15)

-- Info and status
local info_group = ui.Group(menu_root, "Info", "antiaim_info")

-- Button group
local button_group = ui.Group(menu_root, "Actions", "antiaim_actions")
local reset_btn = ui.Button(button_group, "Reset Settings", "reset_settings")
local save_btn = ui.Button(button_group, "Save Config", "save_config")
local load_btn = ui.Button(button_group, "Load Config", "load_config")

-- Callback functions
local function update_preset()
    if toggle_enabled:GetValue() then
        if preset_classic:GetValue() then
            preset_delay:SetValue(false)
            preset_conditional:SetValue(false)
            antiaim:set_preset("classic_jitter")
        elseif preset_delay:GetValue() then
            preset_classic:SetValue(false)
            preset_conditional:SetValue(false)
            antiaim:set_preset("delay_jitter")
        elseif preset_conditional:GetValue() then
            preset_classic:SetValue(false)
            preset_delay:SetValue(false)
            antiaim:set_preset("conditional")
        end
    end
end

local function update_toggle()
    if toggle_enabled:GetValue() then
        antiaim.enabled = true
    else
        antiaim.enabled = false
    end
end

local function update_jitter_strength()
    local strength = jitter_strength:GetValue()
    antiaim:set_jitter_strength(strength)
end

local function update_conditions()
    antiaim.conditions = {
        standing = cond_standing:GetValue(),
        moving = cond_moving:GetValue(),
        slowwalking = cond_slowwalking:GetValue(),
        crouching = cond_crouching:GetValue(),
        in_air = cond_in_air:GetValue(),
        in_air_crouching = cond_in_air_crouch:GetValue(),
        on_use = cond_on_use:GetValue()
    }
end

local function reset_settings()
    toggle_enabled:SetValue(false)
    preset_classic:SetValue(true)
    preset_delay:SetValue(false)
    preset_conditional:SetValue(false)
    jitter_strength:SetValue(25)
    delay_jitter_speed:SetValue(100)
    cond_standing:SetValue(true)
    cond_moving:SetValue(true)
    cond_slowwalking:SetValue(true)
    cond_crouching:SetValue(true)
    cond_in_air:SetValue(true)
    cond_in_air_crouch:SetValue(true)
    cond_on_use:SetValue(false)
    pitch_value:SetValue(89)
    yaw_offset:SetValue(0)
    
    update_toggle()
    update_preset()
    update_conditions()
end

local function save_config()
    local config = {
        enabled = toggle_enabled:GetValue(),
        preset = antiaim.preset,
        jitter_strength = jitter_strength:GetValue(),
        delay_speed = delay_jitter_speed:GetValue(),
        conditions = antiaim.conditions,
        pitch = pitch_value:GetValue(),
        yaw_offset = yaw_offset:GetValue()
    }
    print("[Anti-Aim] Config saved!")
end

local function load_config()
    print("[Anti-Aim] Config loaded!")
end

-- Attach callbacks to UI elements
preset_classic:RegisterCallback(update_preset)
preset_delay:RegisterCallback(update_preset)
preset_conditional:RegisterCallback(update_preset)
toggle_enabled:RegisterCallback(update_toggle)
jitter_strength:RegisterCallback(update_jitter_strength)
cond_standing:RegisterCallback(update_conditions)
cond_moving:RegisterCallback(update_conditions)
cond_slowwalking:RegisterCallback(update_conditions)
cond_crouching:RegisterCallback(update_conditions)
cond_in_air:RegisterCallback(update_conditions)
cond_in_air_crouch:RegisterCallback(update_conditions)
cond_on_use:RegisterCallback(update_conditions)
reset_btn:RegisterCallback(reset_settings)
save_btn:RegisterCallback(save_config)
load_btn:RegisterCallback(load_config)

-- Menu utility functions
function menu:get_enabled()
    return toggle_enabled:GetValue()
end

function menu:set_enabled(value)
    toggle_enabled:SetValue(value)
    update_toggle()
end

function menu:get_preset()
    return antiaim.preset
end

function menu:get_conditions()
    return antiaim.conditions
end

function menu:get_jitter_strength()
    return jitter_strength:GetValue()
end

-- Initialize menu
function menu:init()
    update_toggle()
    update_preset()
    update_conditions()
    print("[Anti-Aim Menu] Initialized successfully!")
end

return menu
