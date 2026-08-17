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
        vy = 120,
        kind = Powerup.randomKind(),
    })
end

function Powerup.update(dt)
    for i = #powerups, 1, -1 do
        local p = powerups[i]
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
        labelFont = love.graphics.newFont(10)
    end
    for _, p in ipairs(powerups) do
        local c = KIND_COLORS[p.kind]
        Gfx.pixelCircle(p.x, p.y, 9, c)
        Gfx.pixelCircle(p.x, p.y, 5, Colors.white, 0.7)
        love.graphics.setColor(Colors.white)
        love.graphics.setFont(labelFont)
        love.graphics.print(KIND_CHARS[p.kind], p.x - 3, p.y - 5)
    end
end

return Powerup
