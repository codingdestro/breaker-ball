local Powerup = {}

local Colors = require("src.colors")
local Gfx = require("src.gfx")

local powerups = {}
local labelFont = nil

local KIND_COLORS = {
    expand = Colors.cyan,
    multiball = Colors.purple,
    slow = Colors.yellow,
    laser = Colors.magenta,
    life = Colors.white,
    catch = Colors.orange,
}

local KIND_CHARS = {
    expand = "E",
    multiball = "M",
    slow = "S",
    laser = "L",
    life = "1",
    catch = "C",
}

local KIND_WEIGHTS = {
    expand = 25,
    multiball = 20,
    slow = 15,
    laser = 15,
    life = 5,
    catch = 20,
}

function Powerup.clear()
    powerups = {}
end

function Powerup.getPowerups()
    return powerups
end

-- Rolls a random power-up kind by weight.
function Powerup.randomKind()
    local total = 0
    for _, w in pairs(KIND_WEIGHTS) do
        total = total + w
    end
    local roll = love.math.random() * total
    for kind, w in pairs(KIND_WEIGHTS) do
        roll = roll - w
        if roll <= 0 then
            return kind
        end
    end
    return "expand"
end

function Powerup.spawn(x, y)
    table.insert(powerups, {
        x = x,
        y = y,
        vy = 90,
        kind = Powerup.randomKind(),
        t = love.math.random() * math.pi * 2,
        pulse = 0.7 + love.math.random() * 0.7,
    })
end

function Powerup.update(dt)
    for i = #powerups, 1, -1 do
        local p = powerups[i]
        p.t = p.t + dt * p.pulse * 2.4
        p.y = p.y + p.vy * dt
        if p.y > love.graphics.getHeight() + 20 then
            table.remove(powerups, i)
        end
    end
end

-- Returns the power-up caught by the paddle, or nil.
function Powerup.findCaught(paddle)
    for i, p in ipairs(powerups) do
        if p.x > paddle.x - paddle.width / 2 and p.x < paddle.x + paddle.width / 2 and
           p.y > paddle.y - paddle.height / 2 and p.y < paddle.y + paddle.height / 2 then
            table.remove(powerups, i)
            return p
        end
    end
    return nil
end

function Powerup.draw()
    if not labelFont then
        labelFont = love.graphics.newFont(8)
    end
    for _, p in ipairs(powerups) do
        local c = KIND_COLORS[p.kind]
        local bob = math.sin(p.t) * 1.5
        local pulse = 0.9 + 0.12 * math.sin(p.t * 2.0)
        local x = p.x
        local y = p.y + bob

        -- Tail glow while falling.
        Gfx.glowCircle(x, y - 6, 4, c, 0.15)
        Gfx.glowCircle(x, y - 11, 3, c, 0.1)

        -- Core orb with pulse.
        Gfx.glowCircle(x, y, 6 * pulse, c, 0.95)
        Gfx.circle(x, y, 4.2, Colors.white, 0.85)
        Gfx.circle(x - 1.6, y - 1.6, 1.1, c, 0.8)

        -- Outer halo ring.
        Gfx.setColor(c, 0.5)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", x, y, 7.4 + 0.5 * math.sin(p.t * 2.6))

        love.graphics.setColor(Colors.white)
        love.graphics.setFont(labelFont)
        love.graphics.print(KIND_CHARS[p.kind], x - 2, y - 4)
    end
end

return Powerup
