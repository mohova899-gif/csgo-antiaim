-- CSGO Anti-Aim Menu Advanced - Neverlose Script with PUI
-- Покращене меню anti-aim з графічним інтерфейсом

local pui = require("neverlose/pui")
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
            conditions = {standing = true, moving = true, slowwalking = false, crouching = true, in_air = true, in_air_crouching = true, on_use = false},
            description = "Maximum protection while moving"
        },
        defensive = {
            preset = "classic_jitter",
            jitter_strength = 50,
            conditions = {standing = true, moving = true, slowwalking = true, crouching = true, in_air = true, in_air_crouching = true, on_use = true},
            description = "Full protection in all situations"
        },
        balanced = {
            preset = "conditional",
            jitter_strength = 45,
            conditions = {standing = true, moving = true, slowwalking = true, crouching = true, in_air = true, in_air_crouching = true, on_use = false},
            description = "Balanced for all combat"
        }
    },
    current_profile = "balanced",
    last_toggle_time = 0
}

-- ================================================================
-- ЛОГУВАННЯ
-- ================================================================
local function log(message, level)
    level = level or "INFO"
    local prefix = "[Anti-Aim Advanced]"
    print(prefix .. " [" .. level .. "] " .. tostring(message))
end

-- ================================================================
-- SIDEBAR
-- ================================================================
local sidebar_name = "Anti-Aim Advanced"
local sidebar_len  = #sidebar_name

events.render(function()
    if pui.get_alpha() == 0 then return end
    local c1     = pui.get_style("Active Text")
    local c2     = pui.get_style("Link Active")
    local result = ""
    for i = 1, sidebar_len do
        local ch = sidebar_name:sub(i, i)
        local t  = math.abs(math.sin(globals.realtime() + (i - 1) / sidebar_len * 1.5))
        local c  = c2:lerp(c1, t)
        result   = result .. string.format("\a%s%s", c:to_hex(), ch)
    end
    pui.sidebar(result, "link")
end)

-- ================================================================
-- PUI MENU SETUP
-- ================================================================
local tab = pui.create("Anti-Aim Advanced", "Visuals", 1)

-- Main controls
local enable = tab:switch("Enable", false)
local preset_combo = tab:combo("Preset", {"Classic Jitter", "Delay Jitter", "Conditional"})
local jitter_slider = tab:slider("Jitter Strength", 0, 100, 25, 1)
local pitch_slider = tab:slider("Pitch", -90, 90, 89, 1)
local yaw_slider = tab:slider("Yaw Offset", -180, 180, 0, 1)
local delay_slider = tab:slider("Delay Speed", 0, 200, 100, 5)

-- Profile management
tab:separator()
local profile_combo = tab:combo("Profile", {"Aggressive", "Defensive", "Balanced"})
local load_profile_btn = tab:button("Load Profile", function()
    menu:load_profile_from_combo()
end)
local save_profile_btn = tab:button("Save as Custom", function()
    menu:save_profile("custom_" .. os.time(), "Custom Profile")
end)

-- Conditions
tab:separator()
tab:label("Conditions:")
local cond_standing = tab:switch("Standing", true)
local cond_moving = tab:switch("Moving", true)
local cond_slowwalking = tab:switch("Slow Walking", true)
local cond_crouching = tab:switch("Crouching", true)
local cond_in_air = tab:switch("In Air", true)
local cond_in_air_crouch = tab:switch("In Air Crouch", true)
local cond_on_use = tab:switch("On Use", false)

-- Advanced options
tab:separator()
local dynamic_mode = tab:switch("Dynamic Mode", false)
local show_stats = tab:switch("Show Statistics", false)

-- ================================================================
-- УМОВИ -> PUI MAPPING
-- ================================================================
local condition_switches = {
    standing = cond_standing,
    moving = cond_moving,
    slowwalking = cond_slowwalking,
    crouching = cond_crouching,
    in_air = cond_in_air,
    in_air_crouching = cond_in_air_crouch,
    on_use = cond_on_use
}

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

function menu:load_profile_from_combo()
    local combo_index = profile_combo:get()
    local profile_names = {"aggressive", "defensive", "balanced"}
    if profile_names[combo_index] then
        menu:load_profile(profile_names[combo_index])
    end
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
function menu:print_statistics()
    local stats = menu_state.statistics
    log("========== STATISTICS ==========")
    log("Toggles: " .. stats.toggles)
    log("Preset changes: " .. stats.preset_changes)
    log("Condition changes: " .. stats.condition_changes)
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
-- MAIN UPDATE LOOP
-- ================================================================
events.net_update_end(function()
    -- Read from PUI controls
    menu_state.enabled = enable:get()
    antiaim.enabled = menu_state.enabled
    
    -- Preset
    local preset_index = preset_combo:get()
    local presets = {"classic_jitter", "delay_jitter", "conditional"}
    if presets[preset_index] then
        menu_state.preset = presets[preset_index]
        antiaim:set_preset(menu_state.preset)
    end
    
    -- Sliders
    menu_state.jitter_strength = jitter_slider:get()
    menu_state.pitch_value = pitch_slider:get()
    menu_state.yaw_offset = yaw_slider:get()
    menu_state.delay_speed = delay_slider:get()
    
    antiaim:set_jitter_strength(menu_state.jitter_strength)
    
    -- Conditions
    menu_state.conditions.standing = cond_standing:get()
    menu_state.conditions.moving = cond_moving:get()
    menu_state.conditions.slowwalking = cond_slowwalking:get()
    menu_state.conditions.crouching = cond_crouching:get()
    menu_state.conditions.in_air = cond_in_air:get()
    menu_state.conditions.in_air_crouching = cond_in_air_crouch:get()
    menu_state.conditions.on_use = cond_on_use:get()
    
    antiaim.conditions = menu_state.conditions
    
    -- Dynamic mode
    menu_state.dynamic_mode = dynamic_mode:get()
    if menu_state.dynamic_mode then
        menu:apply_dynamic_mode()
    end
    
    -- Statistics display
    if show_stats:get() then
        menu:print_statistics()
    end
end)

-- ================================================================
-- ДОПОМОГА
-- ================================================================
function menu:print_help()
    log("========== ANTI-AIM MENU HELP ==========")
    log("Use the menu in Visuals tab!")
    log("menu:print_status() - Print status")
    log("menu:reset() - Reset all to default")
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
    log("Menu is available in Visuals tab")
    
    return true
end

menu:init()

return menu
