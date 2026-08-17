local Ball = {}

local Colors = require("src.colors")
local Gfx = require("src.gfx")
local Audio = require("src.audio")

local RADIUS = 6
local baseSpeed = 350
local speedScale = 1
local slowTime = 0

local balls = {}

function Ball.reset(paddleX, paddleY)
    balls = {}
    speedScale = 1
    slowTime = 0
    local b = {
        x = paddleX,
        y = paddleY - RADIUS - 6,
        vx = 0,
        vy = 0,
        radius = RADIUS,
        launched = false,
    }
    table.insert(balls, b)
end

function Ball.getBalls()
    return balls
end

function Ball.setBaseSpeed(s)
    baseSpeed = s
end

function Ball.applySlow(duration)
    slowTime = duration
end

function Ball.count()
    return #balls
end

function Ball.getSpeed()
    return baseSpeed * speedScale
end

-- Adds a ball moving at the given speed and angle (angle from straight up).
function Ball.add(x, y, speed, angle)
    table.insert(balls, {
        x = x,
        y = y,
        vx = speed * math.sin(angle),
        vy = -speed * math.cos(angle),
        radius = RADIUS,
        launched = true,
    })
end

-- Launches the waiting ball with a slight random horizontal bias.
function Ball.launch()
    for _, b in ipairs(balls) do
        if not b.launched then
            b.launched = true
            local angle = love.math.random() * 0.4 - 0.2
            b.vx = baseSpeed * math.sin(angle)
            b.vy = -baseSpeed * math.cos(angle)
        end
    end
end

-- Returns true when a ball has fallen below the screen.
function Ball.fellBelow(ball)
    return ball.y - ball.radius > love.graphics.getHeight()
end

-- Bounces the ball off the paddle using hit position plus paddle velocity.
function Ball.paddleBounce(ball, paddle, paddleVx)
    local hitPos = (ball.x - paddle.x) / (paddle.width / 2)
    hitPos = math.max(-1, math.min(1, hitPos))
    local angle = hitPos * math.pi / 3

    local bias = paddleVx / 500
    bias = math.max(-1, math.min(1, bias))
    angle = angle + bias * (math.pi / 12)

    local maxAngle = math.pi / 2 - math.pi / 9
    angle = math.max(-maxAngle, math.min(maxAngle, angle))

    local speed = baseSpeed * speedScale
    ball.vx = speed * math.sin(angle)
    ball.vy = -speed * math.cos(angle)
end

-- Moves balls, handles wall collisions, and removes fallen balls.
-- Returns the number of balls that fell this frame.
function Ball.update(dt)
    slowTime = math.max(0, slowTime - dt)
    speedScale = (slowTime > 0) and 0.6 or 1

    local w = love.graphics.getWidth()
    local fallen = 0

    for i = #balls, 1, -1 do
        local b = balls[i]
        if b.launched then
            b.x = b.x + b.vx * dt
            b.y = b.y + b.vy * dt

            if b.x - b.radius <= 0 then
                b.x = b.radius
                b.vx = math.abs(b.vx)
                Audio.play("wall")
            elseif b.x + b.radius >= w then
                b.x = w - b.radius
                b.vx = -math.abs(b.vx)
                Audio.play("wall")
            end
            if b.y - b.radius <= 0 then
                b.y = b.radius
                b.vy = math.abs(b.vy)
                Audio.play("wall")
            end

            if Ball.fellBelow(b) then
                table.remove(balls, i)
                fallen = fallen + 1
            end
        end
    end

    return fallen
end

-- Re-attaches any unlaunched balls to the paddle.
function Ball.stick(ball, paddleX, paddleY)
    ball.x = paddleX
    ball.y = paddleY - ball.radius - 6
end

function Ball.draw()
    for _, b in ipairs(balls) do
        Gfx.glowCircle(b.x, b.y, b.radius, Colors.cyan)
        Gfx.circle(b.x, b.y, b.radius - 2, Colors.white)
    end
end

return Ball
