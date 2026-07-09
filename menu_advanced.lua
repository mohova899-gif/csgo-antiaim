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
    -- Нові параметри
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
    last_toggle_time = 0,
    hotkeys_enabled = true
}

-- ================================================================
-- ЛОГУВАННЯ
-- ================================================================
local function log(message, level)
    level = level or "INFO"
    local prefix = "[Anti-Aim Advanced]"
    local color = level == "ERROR" and "\27[91m" or level == "WARN" and "\27[93m" or "\27[92m"
    print(color .. prefix .. " [" .. level .. "] " .. tostring(message) .. "\27[0m")
end

-- ================================================================
-- ОСНОВНІ ФУНКЦІЇ
-- ================================================================
function menu:toggle()
    menu_state.enabled = not menu_state.enabled
    menu_state.statistics.toggles = menu_state.statistics.toggles + 1
    menu_state.last_toggle_time = os.time()
    antiaim.enabled = menu_state.enabled
    
    local status = menu_state.enabled and "✓ Увімкнено" or "✗ Вимкнено"
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
        log("Невідомий пресет: " .. tostring(preset_name), "WARN")
        return false
    end
    
    menu_state.preset = preset
    antiaim:set_preset(preset)
    menu_state.statistics.preset_changes = menu_state.statistics.preset_changes + 1
    
    log("Пресет змінено на: " .. preset)
    return true
end

function menu:set_jitter_strength(strength)
    strength = tonumber(strength) or 25
    if strength < 0 or strength > 100 then
        log("Невалідне значення: " .. strength .. " (0-100)", "WARN")
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
        log("Невалідний pitch: " .. value .. " (-90 до 90)", "WARN")
        return false
    end
    
    menu_state.pitch_value = value
    log("Pitch: " .. value)
    return true
end

function menu:set_yaw_offset(value)
    value = tonumber(value) or 0
    if value < -180 or value > 180 then
        log("Невалідний yaw: " .. value .. " (-180 до 180)", "WARN")
        return false
    end
    
    menu_state.yaw_offset = value
    log("Yaw Offset: " .. value)
    return true
end

function menu:toggle_condition(condition_name, enabled)
    if menu_state.conditions[condition_name] == nil then
        log("Невідома умова: " .. tostring(condition_name), "WARN")
        return false
    end
    
    if enabled == nil then
        menu_state.conditions[condition_name] = not menu_state.conditions[condition_name]
    else
        menu_state.conditions[condition_name] = enabled
    end
    
    antiaim.conditions[condition_name] = menu_state.conditions[condition_name]
    menu_state.statistics.condition_changes = menu_state.statistics.condition_changes + 1
    
    local status = menu_state.conditions[condition_name] and "ВКЛ" or "ВИМК"
    log("Умова '" .. condition_name .. "': " .. status)
    return menu_state.conditions[condition_name]
end

-- ================================================================
-- ПРОФІЛІ
-- ================================================================
function menu:load_profile(profile_name)
    local profile = menu_state.profiles[profile_name]
    if not profile then
        log("Профіль не знайдено: " .. tostring(profile_name), "WARN")
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
    
    log("Профіль завантажено: " .. profile_name)
    return true
end

function menu:save_profile(profile_name, description)
    menu_state.profiles[profile_name] = {
        preset = menu_state.preset,
        jitter_strength = menu_state.jitter_strength,
        conditions = table.copy(menu_state.conditions),
        description = description or "",
        saved_at = os.date("%Y-%m-%d %H:%M:%S")
    }
    log("Профіль збережено: " .. profile_name)
    return true
end

function menu:delete_profile(profile_name)
    if menu_state.profiles[profile_name] then
        menu_state.profiles[profile_name] = nil
        log("Профіль видалено: " .. profile_name)
        return true
    end
    log("Профіль не знайдено: " .. profile_name, "WARN")
    return false
end

function menu:list_profiles()
    log("=== Доступні профілі ===")
    for name, profile in pairs(menu_state.profiles) do
        local desc = profile.description or "Без опису"
        log("  • " .. name .. " - " .. desc)
    end
    log("======================")
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
    log("Усі умови активовані")
end

function menu:disable_all_conditions()
    for cond_name, _ in pairs(menu_state.conditions) do
        menu_state.conditions[cond_name] = false
        antiaim.conditions[cond_name] = false
    end
    log("Усі умови деактивовані")
end

-- ================================================================
-- ДИНАМІЧНИЙ РЕЖИМ
-- ================================================================
function menu:toggle_dynamic_mode()
    menu_state.dynamic_mode = not menu_state.dynamic_mode
    local status = menu_state.dynamic_mode and "ВКЛ" or "ВИМК"
    log("Динамічний режим: " .. status)
    return menu_state.dynamic_mode
end

function menu:apply_dynamic_mode()
    if not menu_state.dynamic_mode then return end
    
    -- Приклад: автоматично міняй пресет залежно від умов
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
    return table.copy(menu_state.statistics)
end

function menu:print_statistics()
    local stats = menu_state.statistics
    log("========== СТАТИСТИКА ==========")
    log("Включень: " .. stats.toggles)
    log("Змін пресету: " .. stats.preset_changes)
    log("Змін умов: " .. stats.condition_changes)
    log("Активне час: " .. stats.uptime .. " сек")
    log("================================")
end

function menu:reset_statistics()
    menu_state.statistics = {
        toggles = 0,
        preset_changes = 0,
        condition_changes = 0,
        uptime = 0
    }
    log("Статистика скинута")
end

-- ================================================================
-- СТАТУС
-- ================================================================
function menu:get_status()
    return {
        enabled = menu_state.enabled,
        preset = menu_state.preset,
        jitter_strength = menu_state.jitter_strength,
        pitch = menu_state.pitch_value,
        yaw_offset = menu_state.yaw_offset,
        conditions = table.copy(menu_state.conditions),
        profile = menu_state.current_profile,
        dynamic_mode = menu_state.dynamic_mode,
        statistics = table.copy(menu_state.statistics)
    }
end

function menu:print_status()
    log("========== СТАТУС ANTI-AIM ==========")
    log("Стан: " .. (menu_state.enabled and "✓ ВКЛ" or "✗ ВИМК"))
    log("Пресет: " .. menu_state.preset)
    log("Jitter Strength: " .. menu_state.jitter_strength)
    log("Pitch: " .. menu_state.pitch_value)
    log("Yaw Offset: " .. menu_state.yaw_offset)
    log("Профіль: " .. menu_state.current_profile)
    log("Динамічний режим: " .. (menu_state.dynamic_mode and "ВКЛ" or "ВИМК"))
    log("")
    log("--- Умови ---")
    for cond_name, enabled in pairs(menu_state.conditions) do
        log("  " .. cond_name .. ": " .. (enabled and "ВКЛ" or "ВИМК"))
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
    
    log("Усі налаштування скинуті на стандартні")
end

-- ================================================================
-- ДОПОМОГА
-- ================================================================
function menu:print_help()
    log("========== ANTI-AIM MENU HELP ==========")
    log("")
    log("--- ОСНОВНІ КОМАНДИ ---")
    log("menu:toggle()                      - Включити/вимкнути")
    log("menu:set_preset(name)              - Встановити пресет")
    log("menu:set_jitter_strength(val)      - Встановити силу (0-100)")
    log("menu:set_pitch(val)                - Встановити pitch (-90 до 90)")
    log("menu:set_yaw_offset(val)           - Встановити yaw offset (-180 до 180)")
    log("")
    log("--- УМОВИ ---")
    log("menu:toggle_condition(name)        - Переключити умову")
    log("menu:enable_all_conditions()       - Активувати усі умови")
    log("menu:disable_all_conditions()      - Деактивувати усі умови")
    log("")
    log("--- ПРОФІЛІ ---")
    log("menu:load_profile(name)            - Завантажити профіль")
    log("menu:save_profile(name, desc)      - Зберегти профіль")
    log("menu:delete_profile(name)          - Видалити профіль")
    log("menu:list_profiles()               - Список профілів")
    log("")
    log("--- ДИНАМІЧНИЙ РЕЖИМ ---")
    log("menu:toggle_dynamic_mode()         - Переключити динамічний режим")
    log("menu:apply_dynamic_mode()          - Застосувати динамічний режим")
    log("")
    log("--- СТАТИСТИКА ---")
    log("menu:get_statistics()              - Отримати статистику")
    log("menu:print_statistics()            - Показати статистику")
    log("menu:reset_statistics()            - Скинути статистику")
    log("")
    log("--- ІНШІ ---")
    log("menu:get_status()                  - Отримати статус (таблиця)")
    log("menu:print_status()                - Показати статус")
    log("menu:reset()                       - Скинути всі налаштування")
    log("menu:print_help()                  - Ця справка")
    log("")
    log("--- УМОВИ ---")
    log("standing, moving, slowwalking, crouching, in_air, in_air_crouching, on_use")
    log("")
    log("--- ПРЕСЕТИ ---")
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
    
    log("Anti-Aim Menu Advanced ініціалізовано!")
    log("Введи: menu:print_help() для списку команд")
    
    return true
end

-- ================================================================
-- HELPER FUNCTIONS
-- ================================================================
function table.copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- ================================================================
-- AUTO-INITIALIZATION
-- ================================================================
menu:init()

return menu
