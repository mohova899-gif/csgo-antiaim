-- CSGO Anti-Aim Menu using Neverlose Script API
-- Simple menu for controlling anti-aim presets and conditions

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

-- Console variables for menu control
convar.Register("antiaim_enabled", "0", "Enable/disable anti-aim")
convar.Register("antiaim_preset", "classic_jitter", "Anti-aim preset: classic_jitter, delay_jitter, conditional")
convar.Register("antiaim_jitter_strength", "25", "Jitter strength (0-100)")
convar.Register("antiaim_delay_speed", "100", "Delay jitter speed (50-300)")

-- Conditions
convar.Register("antiaim_cond_standing", "1", "Enable on standing")
convar.Register("antiaim_cond_moving", "1", "Enable on moving")
convar.Register("antiaim_cond_slowwalking", "1", "Enable on slowwalking")
convar.Register("antiaim_cond_crouching", "1", "Enable on crouching")
convar.Register("antiaim_cond_in_air", "1", "Enable on in air")
convar.Register("antiaim_cond_in_air_crouch", "1", "Enable on in air crouching")
convar.Register("antiaim_cond_on_use", "0", "Enable on use")

-- Advanced
convar.Register("antiaim_pitch", "89", "Pitch angle")
convar.Register("antiaim_yaw_offset", "0", "Yaw offset")

-- Menu control functions
function menu:toggle()
    local enabled = convar.GetInt("antiaim_enabled") == 1
    convar.SetValue("antiaim_enabled", enabled and "0" or "1")
    antiaim.enabled = not enabled
    print("[Anti-Aim] " .. (not enabled and "Enabled" or "Disabled"))
end

function menu:set_preset(preset_name)
    if preset_name == "classic" or preset_name == "classic_jitter" then
        convar.SetValue("antiaim_preset", "classic_jitter")
        antiaim:set_preset("classic_jitter")
        print("[Anti-Aim] Preset: Classic Jitter")
    elseif preset_name == "delay" or preset_name == "delay_jitter" then
        convar.SetValue("antiaim_preset", "delay_jitter")
        antiaim:set_preset("delay_jitter")
        print("[Anti-Aim] Preset: Delay Jitter")
    elseif preset_name == "conditional" then
        convar.SetValue("antiaim_preset", "conditional")
        antiaim:set_preset("conditional")
        print("[Anti-Aim] Preset: Conditional")
    end
end

function menu:set_jitter_strength(strength)
    if strength >= 0 and strength <= 100 then
        convar.SetValue("antiaim_jitter_strength", tostring(strength))
        antiaim:set_jitter_strength(strength)
        print("[Anti-Aim] Jitter Strength: " .. strength)
    end
end

function menu:toggle_condition(condition_name, enabled)
    local cvar_name = "antiaim_cond_" .. condition_name
    if enabled ~= nil then
        convar.SetValue(cvar_name, enabled and "1" or "0")
    end
    
    antiaim.conditions[condition_name] = convar.GetInt(cvar_name) == 1
    print("[Anti-Aim] Condition '" .. condition_name .. "': " .. (antiaim.conditions[condition_name] and "Enabled" or "Disabled"))
end

function menu:get_status()
    return {
        enabled = convar.GetInt("antiaim_enabled") == 1,
        preset = convar.GetString("antiaim_preset"),
        jitter_strength = convar.GetInt("antiaim_jitter_strength"),
        conditions = antiaim.conditions
    }
end

function menu:reset()
    convar.SetValue("antiaim_enabled", "0")
    convar.SetValue("antiaim_preset", "classic_jitter")
    convar.SetValue("antiaim_jitter_strength", "25")
    convar.SetValue("antiaim_delay_speed", "100")
    convar.SetValue("antiaim_cond_standing", "1")
    convar.SetValue("antiaim_cond_moving", "1")
    convar.SetValue("antiaim_cond_slowwalking", "1")
    convar.SetValue("antiaim_cond_crouching", "1")
    convar.SetValue("antiaim_cond_in_air", "1")
    convar.SetValue("antiaim_cond_in_air_crouch", "1")
    convar.SetValue("antiaim_cond_on_use", "0")
    convar.SetValue("antiaim_pitch", "89")
    convar.SetValue("antiaim_yaw_offset", "0")
    
    print("[Anti-Aim] Settings reset to default")
end

-- Console commands for easy menu control
print("========== Anti-Aim Menu ==========")
print("Available commands:")
print("  antiaim_toggle       - Toggle anti-aim on/off")
print("  antiaim_preset       - Set preset (classic_jitter, delay_jitter, conditional)")
print("  antiaim_jitter_strength - Set jitter strength (0-100)")
print("  antiaim_delay_speed  - Set delay speed (50-300)")
print("")
print("Conditions (1=on, 0=off):")
print("  antiaim_cond_standing")
print("  antiaim_cond_moving")
print("  antiaim_cond_slowwalking")
print("  antiaim_cond_crouching")
print("  antiaim_cond_in_air")
print("  antiaim_cond_in_air_crouch")
print("  antiaim_cond_on_use")
print("===================================")

-- Initialize
function menu:init()
    antiaim.enabled = convar.GetInt("antiaim_enabled") == 1
    antiaim.conditions = {
        standing = convar.GetInt("antiaim_cond_standing") == 1,
        moving = convar.GetInt("antiaim_cond_moving") == 1,
        slowwalking = convar.GetInt("antiaim_cond_slowwalking") == 1,
        crouching = convar.GetInt("antiaim_cond_crouching") == 1,
        in_air = convar.GetInt("antiaim_cond_in_air") == 1,
        in_air_crouching = convar.GetInt("antiaim_cond_in_air_crouch") == 1,
        on_use = convar.GetInt("antiaim_cond_on_use") == 1
    }
    print("[Anti-Aim Menu] Initialized successfully!")
end

return menu
