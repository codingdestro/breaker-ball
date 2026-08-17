local Audio = {}

local sfx = {}

local SAMPLE_RATE = 44100

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

-- Generates a short mono sound into a SoundData.
local function generate(duration, fn)
    local samples = math.floor(SAMPLE_RATE * duration)
    local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        local progress = samples > 1 and (i / (samples - 1)) or 1
        local v = fn(t, progress)
        data:setSample(i, clamp(v, -1, 1))
    end
    return data
end

local function tone(t, freq, decay, volume)
    local env = math.exp(-t * decay)
    local f = freq + 60 * math.sin(t * freq * 0.4) * env
    return volume * env * math.sin(2 * math.pi * f * t)
end

local function noiseBurst(t, progress, decay, volume)
    local env = math.exp(-progress * decay)
    return (love.math.random() * 2 - 1) * volume * env
end

local function makeSfx(soundData)
    local source = love.audio.newSource(soundData, "static")
    return source
end

function Audio.load()
    sfx.paddle = makeSfx(generate(0.09, function(t)
        return tone(t, 220, 30, 0.5)
    end))
    sfx.wall = makeSfx(generate(0.06, function(t)
        return tone(t, 180, 40, 0.4)
    end))
    sfx.brick = makeSfx(generate(0.1, function(t)
        return tone(t, 520, 35, 0.5) + noiseBurst(t, t / 0.1, 6, 0.3)
    end))
    sfx.tough = makeSfx(generate(0.06, function(t)
        return tone(t, 300, 45, 0.45)
    end))
    sfx.armored = makeSfx(generate(0.06, function(t)
        return tone(t, 150, 45, 0.5)
    end))
    sfx.explosive = makeSfx(generate(0.25, function(t)
        return noiseBurst(t, t / 0.25, 9, 0.8) + tone(t, 90, 18, 0.4)
    end))
    sfx.powerup = makeSfx(generate(0.12, function(t)
        return tone(t, 600, 25, 0.45) + tone(t, 900, 25, 0.3)
    end))
    sfx.buff = makeSfx(generate(0.15, function(t)
        return tone(t, 500 + 500 * (t / 0.15), 12, 0.4)
    end))
    sfx.lifeLost = makeSfx(generate(0.3, function(t)
        return tone(t, 250 - 150 * (t / 0.3), 8, 0.5)
    end))
    sfx.levelClear = makeSfx(generate(0.4, function(t)
        local f = t < 0.2 and 440 or (t < 0.3 and 660 or 880)
        return tone(t, f, 12, 0.4)
    end))
    sfx.gameOver = makeSfx(generate(0.6, function(t)
        return tone(t, 200 - 120 * (t / 0.6), 6, 0.45)
    end))
    sfx.victory = makeSfx(generate(0.7, function(t)
        local f = t < 0.2 and 523 or (t < 0.4 and 659 or 784)
        return tone(t, f, 10, 0.4)
    end))
    sfx.select = makeSfx(generate(0.05, function(t)
        return tone(t, 800, 40, 0.35)
    end))
end

function Audio.play(name)
    local s = sfx[name]
    if s then
        s:stop()
        s:play()
    end
end

return Audio
