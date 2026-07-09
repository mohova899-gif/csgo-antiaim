-- CSGO Anti-Aim Menu Advanced - Neverlose Script
-- Покращене меню anti-aim з повним функціоналом

local menu = {}

-- ================================================================
-- МОДУЛЬНЕ ЗАВАНТАЖЕННЯ
-- ================================================================
local antiaim
if pcall(function() antiaim = require("antiaim") end) then
    -- Модуль завантажений успішно
else
    -- Заглушка при відсутності модуля
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

-- ================================================================
-- СТАН МЕНЮ
-- ================================================================
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
    },
    pitch_value = 89,
    yaw_offset = 0,
    dynamic_mode = false,
    statistics = {
        toggles = 0,
        preset_changes = 0,
        condition_changes = 0,
        uptime = 0
    },
    profiles = {
        aggressive = {
            preset = "delay_jitter",
            jitter_strength = 75,
            conditions = {standing = true, moving = true, slowwalking = false, crouching = true, in_air = true, in_air_crouching = true, on_use = false}
        },
        defensive = {
            preset = "classic_jitter",
            jitter_strength = 50,
            conditions = {standing = true, moving = true, slowwalking = true, crouching = true, in_air = true, in_air_crouching = true, on_use = true}
        },
        balanced = {
            preset = "conditional",
            jitter_strength = 45,
            conditions = {standing = true, moving = true, slowwalking = true, crouching = true, in_air = true, in_air_crouching = true, on_use = false}
        }
    },
    current_profile = "balanced",
    last_toggle_time = 0
}

-- ================================================================
-- ЛОГУВАННЯ БЕЗ ANSI КОДІВ
-- ================================================================
local function log(message, level)
    level = level or "INFO"
    local prefix = "[Anti-Aim Advanced]"
    print(prefix .. " [" .. level .. "] " .. tostring(message))
end

-- ================================================================
-- ОСНОВНІ ФУНКЦІЇ
-- ================================================================
function menu:toggle()
    menu_state.enabled = not menu_state.enabled
    menu_state.statistics.toggles = menu_state.statistics.toggles + 1
    menu_state.last_toggle_time = os.time()
    antiaim.enabled = menu_state.enabled
    
    local status = menu_state.enabled and "ENABLED" or "DISABLED"
    log("Anti-Aim " .. status)
    return menu_state.enabled
end

function menu:set_preset(preset_name)
    local valid_presets = {
        ["classic"] = "classic_jitter",
        ["classic_jitter"] = "classic_jitter",
        ["delay"] = "delay_jitter",
        ["delay_jitter"] = "delay_jitter",
        ["conditional"] = "conditional"
    }
    
    local preset = valid_presets[preset_name]
    if not preset then
        log("Unknown preset: " .. tostring(preset_name), "WARN")
        return false
    end
    
    menu_state.preset = preset
    antiaim:set_preset(preset)
    menu_state.statistics.preset_changes = menu_state.statistics.preset_changes + 1
    
    log("Preset changed to: " .. preset)
    return true
end

function menu:set_jitter_strength(strength)
    strength = tonumber(strength) or 25
    if strength < 0 or strength > 100 then
        log("Invalid value: " .. strength .. " (0-100)", "WARN")
        return false
    end
    
    menu_state.jitter_strength = strength
    antiaim:set_jitter_strength(strength)
    log("Jitter Strength: " .. strength)
    return true
end

function menu:set_pitch(value)
    value = tonumber(value) or 89
    if value < -90 or value > 90 then
        log("Invalid pitch: " .. value .. " (-90 to 90)", "WARN")
        return false
    end
    
    menu_state.pitch_value = value
    log("Pitch: " .. value)
    return true
end

function menu:set_yaw_offset(value)
    value = tonumber(value) or 0
    if value < -180 or value > 180 then
        log("Invalid yaw: " .. value .. " (-180 to 180)", "WARN")
        return false
    end
    
    menu_state.yaw_offset = value
    log("Yaw Offset: " .. value)
    return true
end

function menu:toggle_condition(condition_name, enabled)
    if menu_state.conditions[condition_name] == nil then
        log("Unknown condition: " .. tostring(condition_name), "WARN")
        return false
    end
    
    if enabled == nil then
        menu_state.conditions[condition_name] = not menu_state.conditions[condition_name]
    else
        menu_state.conditions[condition_name] = enabled
    end
    
    antiaim.conditions[condition_name] = menu_state.conditions[condition_name]
    menu_state.statistics.condition_changes = menu_state.statistics.condition_changes + 1
    
    local status = menu_state.conditions[condition_name] and "ON" or "OFF"
    log("Condition '" .. condition_name .. "': " .. status)
    return menu_state.conditions[condition_name]
end

-- ================================================================
-- ПРОФІЛІ
-- ================================================================
function menu:load_profile(profile_name)
    local profile = menu_state.profiles[profile_name]
    if not profile then
        log("Profile not found: " .. tostring(profile_name), "WARN")
        return false
    end
    
    menu_state.current_profile = profile_name
    menu_state.preset = profile.preset
    menu_state.jitter_strength = profile.jitter_strength
    
    for cond_name, value in pairs(profile.conditions) do
        menu_state.conditions[cond_name] = value
    end
    
    antiaim:set_preset(profile.preset)
    antiaim:set_jitter_strength(profile.jitter_strength)
    antiaim.conditions = menu_state.conditions
    
    log("Profile loaded: " .. profile_name)
    return true
end

function menu:save_profile(profile_name, description)
    local new_profile = {}
    for k, v in pairs(menu_state.conditions) do
        new_profile[k] = v
    end
    
    menu_state.profiles[profile_name] = {
        preset = menu_state.preset,
        jitter_strength = menu_state.jitter_strength,
        conditions = new_profile,
        description = description or "",
        saved_at = os.date("%Y-%m-%d %H:%M:%S")
    }
    log("Profile saved: " .. profile_name)
    return true
end

function menu:delete_profile(profile_name)
    if menu_state.profiles[profile_name] then
        menu_state.profiles[profile_name] = nil
        log("Profile deleted: " .. profile_name)
        return true
    end
    log("Profile not found: " .. profile_name, "WARN")
    return false
end

function menu:list_profiles()
    log("========== Available Profiles ==========")
    for name, profile in pairs(menu_state.profiles) do
        local desc = profile.description or "No description"
        log("  * " .. name .. " - " .. desc)
    end
    log("=========================================")
end

-- ================================================================
-- УМОВИ
-- ================================================================
function menu:enable_all_conditions()
    for cond_name, _ in pairs(menu_state.conditions) do
        if cond_name ~= "on_use" then
            menu_state.conditions[cond_name] = true
            antiaim.conditions[cond_name] = true
        end
    end
    log("All conditions enabled")
end

function menu:disable_all_conditions()
    for cond_name, _ in pairs(menu_state.conditions) do
        menu_state.conditions[cond_name] = false
        antiaim.conditions[cond_name] = false
    end
    log("All conditions disabled")
end

-- ================================================================
-- ДИНАМІЧНИЙ РЕЖИМ
-- ================================================================
function menu:toggle_dynamic_mode()
    menu_state.dynamic_mode = not menu_state.dynamic_mode
    local status = menu_state.dynamic_mode and "ON" or "OFF"
    log("Dynamic mode: " .. status)
    return menu_state.dynamic_mode
end

function menu:apply_dynamic_mode()
    if not menu_state.dynamic_mode then return end
    
    local moving = menu_state.conditions.moving
    local crouching = menu_state.conditions.crouching
    
    if moving and crouching then
        menu:set_preset("delay_jitter")
    elseif moving then
        menu:set_preset("classic_jitter")
    else
        menu:set_preset("conditional")
    end
end

-- ================================================================
-- СТАТИСТИКА
-- ================================================================
function menu:get_statistics()
    local copy = {}
    for k, v in pairs(menu_state.statistics) do
        copy[k] = v
    end
    return copy
end

function menu:print_statistics()
    local stats = menu_state.statistics
    log("========== STATISTICS ==========")
    log("Toggles: " .. stats.toggles)
    log("Preset changes: " .. stats.preset_changes)
    log("Condition changes: " .. stats.condition_changes)
    log("Uptime: " .. stats.uptime .. " sec")
    log("================================")
end

function menu:reset_statistics()
    menu_state.statistics = {
        toggles = 0,
        preset_changes = 0,
        condition_changes = 0,
        uptime = 0
    }
    log("Statistics reset")
end

-- ================================================================
-- СТАТУС
-- ================================================================
function menu:get_status()
    local cond_copy = {}
    for k, v in pairs(menu_state.conditions) do
        cond_copy[k] = v
    end
    
    return {
        enabled = menu_state.enabled,
        preset = menu_state.preset,
        jitter_strength = menu_state.jitter_strength,
        pitch = menu_state.pitch_value,
        yaw_offset = menu_state.yaw_offset,
        conditions = cond_copy,
        profile = menu_state.current_profile,
        dynamic_mode = menu_state.dynamic_mode
    }
end

function menu:print_status()
    log("========== ANTI-AIM STATUS ==========")
    log("State: " .. (menu_state.enabled and "ON" or "OFF"))
    log("Preset: " .. menu_state.preset)
    log("Jitter Strength: " .. menu_state.jitter_strength)
    log("Pitch: " .. menu_state.pitch_value)
    log("Yaw Offset: " .. menu_state.yaw_offset)
    log("Profile: " .. menu_state.current_profile)
    log("Dynamic mode: " .. (menu_state.dynamic_mode and "ON" or "OFF"))
    log("")
    log("--- CONDITIONS ---")
    for cond_name, enabled in pairs(menu_state.conditions) do
        log("  " .. cond_name .. ": " .. (enabled and "ON" or "OFF"))
    end
    log("====================================")
end

-- ================================================================
-- RESET
-- ================================================================
function menu:reset()
    menu_state.enabled = false
    menu_state.preset = "classic_jitter"
    menu_state.jitter_strength = 25
    menu_state.delay_speed = 100
    menu_state.pitch_value = 89
    menu_state.yaw_offset = 0
    menu_state.dynamic_mode = false
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
    
    log("All settings reset to default")
end

-- ================================================================
-- ДОПОМОГА
-- ================================================================
function menu:print_help()
    log("========== ANTI-AIM MENU HELP ==========")
    log("")
    log("--- MAIN COMMANDS ---")
    log("menu:toggle() - Toggle ON/OFF")
    log("menu:set_preset(name) - Set preset (classic_jitter, delay_jitter, conditional)")
    log("menu:set_jitter_strength(val) - Set strength 0-100")
    log("menu:set_pitch(val) - Set pitch -90 to 90")
    log("menu:set_yaw_offset(val) - Set yaw -180 to 180")
    log("")
    log("--- CONDITIONS ---")
    log("menu:toggle_condition(name) - Toggle condition")
    log("menu:enable_all_conditions() - Enable all")
    log("menu:disable_all_conditions() - Disable all")
    log("")
    log("--- PROFILES ---")
    log("menu:load_profile(name) - Load profile")
    log("menu:save_profile(name, desc) - Save profile")
    log("menu:delete_profile(name) - Delete profile")
    log("menu:list_profiles() - List all profiles")
    log("")
    log("--- DYNAMIC MODE ---")
    log("menu:toggle_dynamic_mode() - Toggle dynamic mode")
    log("menu:apply_dynamic_mode() - Apply dynamic mode")
    log("")
    log("--- STATISTICS ---")
    log("menu:get_statistics() - Get statistics table")
    log("menu:print_statistics() - Print statistics")
    log("menu:reset_statistics() - Reset statistics")
    log("")
    log("--- STATUS ---")
    log("menu:get_status() - Get current status")
    log("menu:print_status() - Print status")
    log("menu:reset() - Reset all to default")
    log("")
    log("--- CONDITIONS LIST ---")
    log("standing, moving, slowwalking, crouching, in_air, in_air_crouching, on_use")
    log("")
    log("--- PRESETS ---")
    log("classic_jitter, delay_jitter, conditional")
    log("========================================")
end

-- ================================================================
-- ІНІЦІАЛІЗАЦІЯ
-- ================================================================
function menu:init()
    antiaim.enabled = menu_state.enabled
    antiaim.preset = menu_state.preset
    antiaim.conditions = menu_state.conditions
    
    log("Anti-Aim Menu Advanced initialized!")
    log("Type: menu:print_help() for commands")
    
    return true
end

-- ================================================================
-- AUTO-INITIALIZATION
-- ================================================================
menu:init()

return menu
