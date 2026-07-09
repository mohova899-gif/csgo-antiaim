-- CSGO Anti-Aim Menu - Neverlose Script
-- Simple menu for controlling anti-aim presets and conditions

local menu = {}

-- Try to load antiaim module
local antiaim
if pcall(function() antiaim = require("antiaim") end) then
    -- Module loaded successfully
else
    -- Create stub if not available
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
        set_preset = function(self, preset) 
            self.preset = preset 
        end,
        set_jitter_strength = function(self, strength) 
        end
    }
end

-- Menu state storage
local menu_state = {
    enabled = false,
    preset = "classic_jitter",
    jitter_strength = 25,
    delay_speed = 100,
    conditions = {
        standing = true,
        moving = true,
        slowwalking = true,
        crouching = true,
        in_air = true,
        in_air_crouching = true,
        on_use = false
    }
}

-- Menu control functions
function menu:toggle()
    menu_state.enabled = not menu_state.enabled
    antiaim.enabled = menu_state.enabled
    local status = menu_state.enabled and "Enabled" or "Disabled"
    print("[Anti-Aim] " .. status)
    return menu_state.enabled
end

function menu:set_preset(preset_name)
    if preset_name == "classic" or preset_name == "classic_jitter" then
        menu_state.preset = "classic_jitter"
        antiaim:set_preset("classic_jitter")
        print("[Anti-Aim] Preset: Classic Jitter")
    elseif preset_name == "delay" or preset_name == "delay_jitter" then
        menu_state.preset = "delay_jitter"
        antiaim:set_preset("delay_jitter")
        print("[Anti-Aim] Preset: Delay Jitter")
    elseif preset_name == "conditional" then
        menu_state.preset = "conditional"
        antiaim:set_preset("conditional")
        print("[Anti-Aim] Preset: Conditional")
    else
        print("[Anti-Aim] Unknown preset: " .. tostring(preset_name))
    end
end

function menu:set_jitter_strength(strength)
    strength = tonumber(strength) or 25
    if strength >= 0 and strength <= 100 then
        menu_state.jitter_strength = strength
        antiaim:set_jitter_strength(strength)
        print("[Anti-Aim] Jitter Strength: " .. strength)
    else
        print("[Anti-Aim] Invalid strength value: " .. tostring(strength))
    end
end

function menu:toggle_condition(condition_name, enabled)
    if menu_state.conditions[condition_name] == nil then
        print("[Anti-Aim] Unknown condition: " .. tostring(condition_name))
        return false
    end
    
    if enabled == nil then
        menu_state.conditions[condition_name] = not menu_state.conditions[condition_name]
    else
        menu_state.conditions[condition_name] = enabled
    end
    
    antiaim.conditions[condition_name] = menu_state.conditions[condition_name]
    local status = menu_state.conditions[condition_name] and "Enabled" or "Disabled"
    print("[Anti-Aim] Condition '" .. condition_name .. "': " .. status)
    return menu_state.conditions[condition_name]
end

function menu:enable_all_conditions()
    for cond_name, _ in pairs(menu_state.conditions) do
        if cond_name ~= "on_use" then
            menu_state.conditions[cond_name] = true
            antiaim.conditions[cond_name] = true
        end
    end
    print("[Anti-Aim] All conditions enabled")
end

function menu:disable_all_conditions()
    for cond_name, _ in pairs(menu_state.conditions) do
        menu_state.conditions[cond_name] = false
        antiaim.conditions[cond_name] = false
    end
    print("[Anti-Aim] All conditions disabled")
end

function menu:get_status()
    return {
        enabled = menu_state.enabled,
        preset = menu_state.preset,
        jitter_strength = menu_state.jitter_strength,
        conditions = menu_state.conditions
    }
end

function menu:print_status()
    print("========== Anti-Aim Status ==========")
    print("Enabled: " .. (menu_state.enabled and "YES" or "NO"))
    print("Preset: " .. menu_state.preset)
    print("Jitter Strength: " .. menu_state.jitter_strength)
    print("Conditions:")
    for cond_name, enabled in pairs(menu_state.conditions) do
        print("  - " .. cond_name .. ": " .. (enabled and "ON" or "OFF"))
    end
    print("====================================")
end

function menu:reset()
    menu_state.enabled = false
    menu_state.preset = "classic_jitter"
    menu_state.jitter_strength = 25
    menu_state.delay_speed = 100
    menu_state.conditions = {
        standing = true,
        moving = true,
        slowwalking = true,
        crouching = true,
        in_air = true,
        in_air_crouching = true,
        on_use = false
    }
    
    antiaim.enabled = false
    antiaim:set_preset("classic_jitter")
    antiaim.conditions = menu_state.conditions
    
    print("[Anti-Aim] Settings reset to default")
end

-- Print help
function menu:print_help()
    print("========== Anti-Aim Menu Help ==========")
    print("Available functions:")
    print("  menu:toggle()                 - Toggle anti-aim on/off")
    print("  menu:set_preset(name)         - Set preset (classic_jitter, delay_jitter, conditional)")
    print("  menu:set_jitter_strength(val) - Set jitter strength (0-100)")
    print("  menu:toggle_condition(name)   - Toggle specific condition")
    print("  menu:enable_all_conditions()  - Enable all conditions")
    print("  menu:disable_all_conditions() - Disable all conditions")
    print("  menu:get_status()             - Get current status")
    print("  menu:print_status()           - Print current status")
    print("  menu:reset()                  - Reset to default")
    print("  menu:print_help()             - Print this help")
    print("")
    print("Conditions: standing, moving, slowwalking, crouching, in_air, in_air_crouching, on_use")
    print("=========================================")
end

-- Initialize
function menu:init()
    antiaim.enabled = menu_state.enabled
    antiaim.preset = menu_state.preset
    antiaim.conditions = menu_state.conditions
    print("[Anti-Aim Menu] Initialized successfully!")
    print("[Anti-Aim Menu] Type: menu:print_help() for available commands")
end

-- Auto-initialize on load
menu:init()

return menu
