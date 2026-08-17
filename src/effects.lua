local Effects = {}

local Particles = require("src.particles")

local shakeTime = 0
local shakeIntensity = 0

function Effects.clear()
    Particles.clear()
    shakeTime = 0
    shakeIntensity = 0
end

function Effects.update(dt)
    Particles.update(dt)
    if shakeTime > 0 then
        shakeTime = math.max(0, shakeTime - dt)
    end
end

function Effects.shake(intensity, duration)
    shakeIntensity = intensity
    shakeTime = duration
end

function Effects.burst(x, y, color, count, speed)
    Particles.burst(x, y, color, count, speed)
end

-- Applies screen shake to the current transform.
function Effects.applyShake()
    if shakeTime > 0 then
        local f = shakeTime * shakeIntensity
        love.graphics.translate(
            love.math.random() * f - f / 2,
            love.math.random() * f - f / 2
        )
    end
end

function Effects.draw()
    Particles.draw()
end

return Effects
