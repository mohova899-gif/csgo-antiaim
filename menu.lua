-- CSGO Anti-Aim Menu using PUI (Neverlose UI Framework)
-- Interactive menu for controlling anti-aim presets and conditions

local menu = {}
local antiaim = require("antiaim")

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
local anti_aim_key = ui.Keybind(advanced_group, "Anti-Aim Key", "antiaim_key")

-- Info and status
local info_group = ui.Group(menu_root, "Info", "antiaim_info")
local status_label = ui.Label(info_group, "Status: Disabled")
local current_preset_label = ui.Label(info_group, "Preset: None")

-- Button group
local button_group = ui.Group(menu_root, "Actions", "antiaim_actions")
local reset_btn = ui.Button(button_group, "Reset Settings", "reset_settings")
local save_btn = ui.Button(button_group, "Save Config", "save_config")
local load_btn = ui.Button(button_group, "Load Config", "load_config")

-- Callbacks for preset selection
local function update_preset()
    local classic = ui.GetValue(preset_classic)
    local delay = ui.GetValue(preset_delay)
    local conditional = ui.GetValue(preset_conditional)
    
    if classic then
        ui.SetValue(preset_delay, false)
        ui.SetValue(preset_conditional, false)
        antiaim:set_preset("classic_jitter")
        ui.SetValue(current_preset_label, "Preset: Classic Jitter")
    elseif delay then
        ui.SetValue(preset_classic, false)
        ui.SetValue(preset_conditional, false)
        antiaim:set_preset("delay_jitter")
        ui.SetValue(current_preset_label, "Preset: Delay Jitter")
    elseif conditional then
        ui.SetValue(preset_classic, false)
        ui.SetValue(preset_delay, false)
        antiaim:set_preset("conditional")
        ui.SetValue(current_preset_label, "Preset: Conditional")
    end
end

-- Callbacks for toggle
local function update_toggle()
    local enabled = ui.GetValue(toggle_enabled)
    antiaim.enabled = enabled
    
    if enabled then
        ui.SetValue(status_label, "Status: Enabled ✓")
    else
        ui.SetValue(status_label, "Status: Disabled ✗")
    end
end

-- Callback for jitter strength
local function update_jitter_strength()
    local strength = ui.GetValue(jitter_strength)
    antiaim:set_jitter_strength(strength)
end

-- Callback for conditions
local function update_conditions()
    local conditions = {
        standing = ui.GetValue(cond_standing),
        moving = ui.GetValue(cond_moving),
        slowwalking = ui.GetValue(cond_slowwalking),
        crouching = ui.GetValue(cond_crouching),
        in_air = ui.GetValue(cond_in_air),
        in_air_crouching = ui.GetValue(cond_in_air_crouch),
        on_use = ui.GetValue(cond_on_use)
    }
    
    antiaim.conditions = conditions
end

-- Callback for reset
local function reset_settings()
    ui.SetValue(toggle_enabled, false)
    ui.SetValue(preset_classic, true)
    ui.SetValue(preset_delay, false)
    ui.SetValue(preset_conditional, false)
    ui.SetValue(jitter_strength, 25)
    ui.SetValue(delay_jitter_speed, 100)
    ui.SetValue(cond_standing, true)
    ui.SetValue(cond_moving, true)
    ui.SetValue(cond_slowwalking, true)
    ui.SetValue(cond_crouching, true)
    ui.SetValue(cond_in_air, true)
    ui.SetValue(cond_in_air_crouch, true)
    ui.SetValue(cond_on_use, false)
    ui.SetValue(pitch_value, 89)
    ui.SetValue(yaw_offset, 0)
    
    update_toggle()
    update_preset()
    update_conditions()
end

-- Callback for save config
local function save_config()
    local config = {
        enabled = ui.GetValue(toggle_enabled),
        preset = antiaim.preset,
        jitter_strength = ui.GetValue(jitter_strength),
        delay_speed = ui.GetValue(delay_jitter_speed),
        conditions = {
            standing = ui.GetValue(cond_standing),
            moving = ui.GetValue(cond_moving),
            slowwalking = ui.GetValue(cond_slowwalking),
            crouching = ui.GetValue(cond_crouching),
            in_air = ui.GetValue(cond_in_air),
            in_air_crouch = ui.GetValue(cond_in_air_crouch),
            on_use = ui.GetValue(cond_on_use)
        },
        pitch = ui.GetValue(pitch_value),
        yaw_offset = ui.GetValue(yaw_offset)
    }
    
    -- Save to file (implementation depends on Neverlose API)
    -- This is a placeholder
    print("[Anti-Aim] Config saved!")
end

-- Callback for load config
local function load_config()
    -- Load from file (implementation depends on Neverlose API)
    -- This is a placeholder
    print("[Anti-Aim] Config loaded!")
end

-- Register callbacks
ui.RegisterCallback(toggle_enabled, "on_change", update_toggle)
ui.RegisterCallback(preset_classic, "on_change", update_preset)
ui.RegisterCallback(preset_delay, "on_change", update_preset)
ui.RegisterCallback(preset_conditional, "on_change", update_preset)
ui.RegisterCallback(jitter_strength, "on_change", update_jitter_strength)
ui.RegisterCallback(cond_standing, "on_change", update_conditions)
ui.RegisterCallback(cond_moving, "on_change", update_conditions)
ui.RegisterCallback(cond_slowwalking, "on_change", update_conditions)
ui.RegisterCallback(cond_crouching, "on_change", update_conditions)
ui.RegisterCallback(cond_in_air, "on_change", update_conditions)
ui.RegisterCallback(cond_in_air_crouch, "on_change", update_conditions)
ui.RegisterCallback(cond_on_use, "on_change", update_conditions)
ui.RegisterCallback(reset_btn, "on_click", reset_settings)
ui.RegisterCallback(save_btn, "on_click", save_config)
ui.RegisterCallback(load_btn, "on_click", load_config)

-- Menu utility functions
function menu:get_enabled()
    return ui.GetValue(toggle_enabled)
end

function menu:set_enabled(value)
    ui.SetValue(toggle_enabled, value)
    update_toggle()
end

function menu:get_preset()
    return antiaim.preset
end

function menu:get_conditions()
    return antiaim.conditions
end

function menu:get_jitter_strength()
    return ui.GetValue(jitter_strength)
end

function menu:update_status(message)
    ui.SetValue(status_label, "Status: " .. message)
end

-- Initialize menu
function menu:init()
    update_toggle()
    update_preset()
    update_conditions()
    print("[Anti-Aim Menu] Initialized successfully!")
end

-- Return module
return menu