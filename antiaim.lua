-- CSGO Anti-Aim Script for Neverlose
-- Supports: Classic Jitter, Delay Jitter, Conditional presets
-- Conditions: Standing, Moving, Slowwalking, Crouching, In Air, In Air & Crouching, On Use

local antiaim = {
    preset = "classic_jitter",
    enabled = true,
    jitter_strength = 25,
    delay_jitter_speed = 100,
    conditions = {
        standing = true,
        moving = true,
        slowwalking = true,
        crouching = true,
        in_air = true,
        in_air_crouching = true,
        on_use = true
    },
    angles = {
        yaw = 0,
        pitch = 0,
        roll = 0
    }
}

-- Anti-Aim Presets
local presets = {
    -- Classic Jitter - Best for 2x2 tournaments
    classic_jitter = {
        name = "Classic Jitter",
        description = "Optimal for 2x2 tournament play",
        execute = function(local_player, cmd)
            if not local_player or not cmd then return end
            
            local current_time = globals.frametime()
            local jitter_value = math.sin(current_time * 200) * 45
            
            cmd.viewangles.y = jitter_value
            cmd.viewangles.x = 89
            
            return true
        end
    },
    
    -- Delay Jitter - Adds slight delay for unpredictability
    delay_jitter = {
        name = "Delay Jitter",
        description = "Delayed jitter for enhanced unpredictability",
        execute = function(local_player, cmd)
            if not local_player or not cmd then return end
            
            local current_time = globals.frametime()
            local delay = 0.05
            local jitter_value = math.sin((current_time - delay) * 200) * 45
            
            cmd.viewangles.y = jitter_value
            cmd.viewangles.x = math.cos(current_time * 150) * 15
            
            return true
        end
    },
    
    -- Conditional - Adapts based on player state
    conditional = {
        name = "Conditional",
        description = "Adapts anti-aim based on player state",
        execute = function(local_player, cmd)
            if not local_player or not cmd then return end
            
            local velocity = local_player:GetVelocity()
            local speed = velocity:Length()
            
            if speed < 5 then
                -- Standing
                cmd.viewangles.y = math.sin(globals.frametime() * 150) * 35
                cmd.viewangles.x = 89
            elseif speed < 50 then
                -- Slowwalking
                cmd.viewangles.y = math.sin(globals.frametime() * 180) * 40
                cmd.viewangles.x = 85
            elseif speed < 150 then
                -- Moving
                cmd.viewangles.y = math.sin(globals.frametime() * 200) * 45
                cmd.viewangles.x = 80
            else
                -- Fast moving
                cmd.viewangles.y = math.sin(globals.frametime() * 220) * 50
                cmd.viewangles.x = 75
            end
            
            -- Check if in air
            if not local_player:IsOnGround() then
                cmd.viewangles.x = math.cos(globals.frametime() * 200) * 60
                cmd.viewangles.y = math.sin(globals.frametime() * 200) * 60
            end
            
            -- Check if crouching
            if local_player:GetFlags() % 2 == 1 then
                cmd.viewangles.x = cmd.viewangles.x + 10
            end
            
            return true
        end
    }
}

-- Get current player state
local function get_player_state(local_player)
    if not local_player then return nil end
    
    local velocity = local_player:GetVelocity()
    local speed = velocity:Length()
    local flags = local_player:GetFlags()
    
    local state = {
        is_moving = speed > 5,
        is_slowwalking = speed > 5 and speed < 50,
        is_running = speed >= 150,
        is_crouching = (flags % 2 == 1),
        is_in_air = not local_player:IsOnGround(),
        velocity = speed
    }
    
    return state
end

-- Check if condition is active
local function is_condition_active(condition_name, player_state)
    if not player_state then return false end
    
    if condition_name == "standing" then
        return not player_state.is_moving and not player_state.is_in_air
    elseif condition_name == "moving" then
        return player_state.is_moving and not player_state.is_slowwalking
    elseif condition_name == "slowwalking" then
        return player_state.is_slowwalking
    elseif condition_name == "crouching" then
        return player_state.is_crouching
    elseif condition_name == "in_air" then
        return player_state.is_in_air and not player_state.is_crouching
    elseif condition_name == "in_air_crouching" then
        return player_state.is_in_air and player_state.is_crouching
    elseif condition_name == "on_use" then
        return false -- Requires additional implementation
    end
    
    return false
end

-- Main anti-aim function
function antiaim:apply(cmd)
    if not self.enabled then return end
    
    local local_player = entity_manager.GetLocalPlayer()
    if not local_player or local_player:IsDead() then return end
    
    local player_state = get_player_state(local_player)
    local current_preset = presets[self.preset]
    
    if not current_preset then return end
    
    -- Check if any active condition allows anti-aim
    local any_condition_active = false
    for condition_name, enabled in pairs(self.conditions) do
        if enabled and is_condition_active(condition_name, player_state) then
            any_condition_active = true
            break
        end
    end
    
    if any_condition_active or self.preset == "classic_jitter" then
        current_preset.execute(local_player, cmd)
    end
end

-- Callback for each frame
callback.Register("on_FrameStageNotify", function(stage)
    if stage == FRAME_NET_UPDATE_POSTDATAUPDATE_START then
        antiaim:apply(cmd)
    end
end)

-- Console commands for control
convar.Register("antiaim_enabled", "1", "Enable/disable anti-aim")
convar.Register("antiaim_preset", "classic_jitter", "Set anti-aim preset: classic_jitter, delay_jitter, conditional")
convar.Register("antiaim_jitter_strength", "25", "Jitter strength (0-100)")

-- Update settings from convars
callback.Register("on_FrameStageNotify", function(stage)
    if stage == FRAME_RENDER then
        antiaim.enabled = convar.GetInt("antiaim_enabled") == 1
        antiaim.preset = convar.GetString("antiaim_preset")
        antiaim.jitter_strength = convar.GetInt("antiaim_jitter_strength")
    end
end)

-- Utility functions
function antiaim:set_preset(preset_name)
    if presets[preset_name] then
        self.preset = preset_name
        return true
    end
    return false
end

function antiaim:toggle()
    self.enabled = not self.enabled
    return self.enabled
end

function antiaim:set_condition(condition_name, enabled)
    if self.conditions[condition_name] ~= nil then
        self.conditions[condition_name] = enabled
        return true
    end
    return false
end

function antiaim:get_info()
    return {
        enabled = self.enabled,
        preset = self.preset,
        conditions_active = self.conditions
    }
end

-- Return module
return antiaim