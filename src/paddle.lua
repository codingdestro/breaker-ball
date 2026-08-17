local Paddle = {}

local Colors = require("src.colors")
local Gfx = require("src.gfx")

local W = 390
local H = 844

local BASE_WIDTH = 48
local HEIGHT = 8
local SPEED = 340

local paddle = {}
local bullets = {}

local expandTime = 0
local laserTime = 0
local catchTime = 0
local laserCooldown = 0

local function width()
    if expandTime > 0 then
        return BASE_WIDTH * 1.5
    end
    return BASE_WIDTH
end

function Paddle.reset()
    paddle.x = W / 2
    paddle.y = H - 64
    paddle.width = BASE_WIDTH
    paddle.height = HEIGHT
    paddle.vx = 0
    bullets = {}
    expandTime = 0
    laserTime = 0
    catchTime = 0
    laserCooldown = 0
end

function Paddle.get()
    return paddle
end

function Paddle.getBullets()
    return bullets
end

function Paddle.width()
    return width()
end

function Paddle.applyBuff(kind, duration)
    if kind == "expand" then
        expandTime = duration
    elseif kind == "laser" then
        laserTime = duration
    elseif kind == "catch" then
        catchTime = duration
    end
end

function Paddle.hasCatch()
    return catchTime > 0
end

function Paddle.clearCatch()
    catchTime = 0
end

function Paddle.hasExpand()
    return expandTime > 0
end

function Paddle.hasLaser()
    return laserTime > 0
end

function Paddle.fireLaser()
    if laserTime > 0 and laserCooldown <= 0 then
        table.insert(bullets, { x = paddle.x, y = paddle.y - paddle.height / 2 - 3 })
        laserCooldown = 1 / 3
    end
end

function Paddle.update(dt)
    local prevX = paddle.x
    local left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
    local right = love.keyboard.isDown("right") or love.keyboard.isDown("d")

    if left and not right then
        paddle.x = paddle.x - SPEED * dt
    elseif right and not left then
        paddle.x = paddle.x + SPEED * dt
    end

    paddle.x = math.max(width() / 2, math.min(W - width() / 2, paddle.x))
    paddle.vx = (paddle.x - prevX) / dt
    paddle.width = width()

    expandTime = math.max(0, expandTime - dt)
    laserTime = math.max(0, laserTime - dt)
    catchTime = math.max(0, catchTime - dt)
    laserCooldown = math.max(0, laserCooldown - dt)

    -- Move and cull bullets.
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.y = b.y - 420 * dt
        if b.y < -8 then
            table.remove(bullets, i)
        end
    end
end

function Paddle.draw()
    local c = Colors.cyan
    if laserTime > 0 then
        c = Colors.magenta
    end
    Gfx.glowRect(paddle.x, paddle.y, paddle.width, paddle.height, c)
    Gfx.setColor(Colors.white, 0.8)
    love.graphics.rectangle("fill", paddle.x - paddle.width / 2, paddle.y - 2, paddle.width, 4)

    for _, b in ipairs(bullets) do
        Gfx.pixelCircle(b.x, b.y, 2, Colors.magenta)
    end
end

return Paddle
