local Background = {}

local Colors = require("src.colors")

local stars = {}
local gridY = 0

local STAR_COUNT = 90

local function randomStar()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    return {
        x = love.math.random() * w,
        y = love.math.random() * h,
        speed = 20 + love.math.random() * 70,
        size = 1 + love.math.random() * 2,
        alpha = 0.3 + love.math.random() * 0.6,
        color = love.math.random() < 0.5 and Colors.cyan or Colors.magenta,
    }
end

function Background.load()
    stars = {}
    for _ = 1, STAR_COUNT do
        table.insert(stars, randomStar())
    end
    gridY = 0
end

function Background.update(dt)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    gridY = (gridY + 60 * dt) % 60
    for _, s in ipairs(stars) do
        s.y = s.y + s.speed * dt
        if s.y > h + s.size then
            s.y = -s.size
            s.x = love.math.random() * w
        end
    end
end

-- Draws a scrolling perspective grid in the lower half.
local function drawGrid()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local horizon = h * 0.45
    local bottom = h

    love.graphics.setLineWidth(1)

    -- Horizontal lines.
    for i = 0, 7 do
        local t = i / 7
        local y = horizon + (bottom - horizon) * (t * t)
        local a = 0.12 + t * 0.25
        local c = (i % 2 == 0) and Colors.magenta or Colors.cyan
        love.graphics.setColor(c[1], c[2], c[3], a)
        love.graphics.line(0, y, w, y)
    end

    -- Vertical converging lines.
    local cx = w / 2
    for i = -6, 6 do
        local a = 0.1 + math.abs(i) * 0.02
        local c = (i % 2 == 0) and Colors.cyan or Colors.magenta
        love.graphics.setColor(c[1], c[2], c[3], a)
        local bottomX = cx + i * 140
        love.graphics.line(cx + i * 20, horizon, bottomX, bottom)
    end

    -- A slow vertical scroll shimmer.
    local c = Colors.cyan
    love.graphics.setColor(c[1], c[2], c[3], 0.06)
    love.graphics.line(0, horizon + gridY, w, horizon + gridY)
end

function Background.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(Colors.background)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Vignette glow near the bottom.
    local c = Colors.purple
    love.graphics.setColor(c[1], c[2], c[3], 0.06)
    love.graphics.rectangle("fill", 0, h * 0.7, w, h * 0.3)

    drawGrid()

    for _, s in ipairs(stars) do
        love.graphics.setColor(s.color[1], s.color[2], s.color[3], s.alpha)
        love.graphics.rectangle("fill", s.x, s.y, s.size, s.size)
    end
end

return Background
