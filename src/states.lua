local StateMachine = {}

local Colors = require("src.colors")
local Gfx = require("src.gfx")
local Audio = require("src.audio")
local Save = require("src.save")
local Background = require("src.background")
local Effects = require("src.effects")
local Paddle = require("src.paddle")
local Ball = require("src.ball")
local Brick = require("src.brick")
local Powerup = require("src.powerup")
local Levels = require("src.levels")

local W, H = 960, 540

local state = "title"
local titleSelection = 1

local levelIndex = 1
local lives = 3
local score = 0
local levelStartScore = 0
local combo = 1
local transitionTime = 0
local pendingState = nil
local nextLevelIndex = nil

local POWERUP_DROP_CHANCE = 0.18

local SCORE_VALUES = {
    standard = 50,
    tough = 150,
    armored = 250,
    explosive = 200,
    moving = 125,
    indestructible = 0,
}

local function currentLevel()
    return Levels.list[levelIndex]
end

local function startLevel(index)
    levelIndex = index
    levelStartScore = score
    local level = currentLevel()
    Paddle.reset()
    Ball.reset(Paddle.get().x, Paddle.get().y)
    Brick.load(level)
    Powerup.clear()
    Effects.clear()
    Ball.setBaseSpeed(level.ballSpeed)
    combo = 1
    transitionTime = 0
end

local function startCampaign()
    levelIndex = 1
    lives = 3
    score = 0
    levelStartScore = 0
    startLevel(1)
    state = "transition"
    transitionTime = 1.2
    pendingState = "playing"
end

local function loseLife()
    lives = lives - 1
    combo = 1
    Audio.play("lifeLost")
    Effects.shake(4, 0.4)
    if lives <= 0 then
        state = "gameover"
        Save.submit(score)
        Audio.play("gameOver")
    else
        Paddle.reset()
        Ball.reset(Paddle.get().x, Paddle.get().y)
    end
end

local function nextLevel()
    if levelIndex >= #Levels.list then
        state = "victory"
        Save.submit(score)
        Audio.play("victory")
    else
        levelIndex = levelIndex + 1
        startLevel(levelIndex)
        state = "transition"
        transitionTime = 1.2
        pendingState = "playing"
        Audio.play("levelClear")
    end
end

local function breakBrick(brick)
    local cx = brick.x + brick.width / 2
    local cy = brick.y + brick.height / 2
    local c = Colors.brickColor(brick)

    Effects.burst(cx, cy, c, 12, 120)

    if brick.type == "explosive" then
        Audio.play("explosive")
        Effects.shake(5, 0.3)
        local destroyed = Brick.explode(brick)
        for _, other in ipairs(destroyed) do
            score = score + 25
            local oc = Colors.brickColor(other)
            Effects.burst(other.x + other.width / 2, other.y + other.height / 2, oc, 8, 100)
        end
        score = score + SCORE_VALUES.explosive * combo
        combo = math.min(8, combo + 1)
    else
        local s = SCORE_VALUES[brick.type] or 0
        score = score + s * combo
        combo = math.min(8, combo + 1)
    end

    -- Roll for a power-up drop.
    if brick.type ~= "indestructible" and love.math.random() < POWERUP_DROP_CHANCE then
        Powerup.spawn(cx, cy)
    end
end

local function handleBrickHit(brick, axis)
    if brick.type == "indestructible" then
        -- Bounce only, no damage, no score.
        return axis
    end

    local broke = Brick.hit(brick)

    if broke then
        breakBrick(brick)
        if brick.type == "tough" or brick.type == "armored" or brick.type == "standard" or brick.type == "moving" then
            Audio.play("brick")
        end
    else
        -- Non-breaking hit.
        if brick.type == "tough" then
            Audio.play("tough")
        elseif brick.type == "armored" then
            Audio.play("armored")
        end
    end

    if Brick.allCleared() then
        nextLevel()
    end

    return axis
end

local function handleBullets(dt)
    local bullets = Paddle.getBullets()
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        local brick = Brick.findBulletHit(bullet)
        if brick then
            table.remove(bullets, i)
            local broke = Brick.hit(brick)
            if broke then
                breakBrick(brick)
                Audio.play("brick")
            else
                Audio.play("tough")
            end
            if Brick.allCleared() then
                nextLevel()
            end
        end
    end
end

local function handlePowerups(dt)
    Powerup.update(dt)
    local p = Powerup.findCaught(Paddle.get())
    if p then
        Audio.play("powerup")
        if p.kind == "life" then
            lives = lives + 1
        elseif p.kind == "multiball" then
            local current = Ball.getBalls()
            local count = 0
            for _, b in ipairs(current) do
                local angle = (love.math.random() * 0.6 - 0.3)
                if count < 2 and Ball.count() < 5 then
                    Ball.add(b.x, b.y, Ball.getSpeed(), angle)
                    count = count + 1
                end
            end
        elseif p.kind == "expand" then
            Paddle.applyBuff("expand", 15)
            Audio.play("buff")
        elseif p.kind == "slow" then
            Ball.applySlow(12)
            Audio.play("buff")
        elseif p.kind == "laser" then
            Paddle.applyBuff("laser", 10)
            Audio.play("buff")
        elseif p.kind == "catch" then
            Paddle.applyBuff("catch", 10)
            Audio.play("buff")
        end
    end
end

local function handleBricksAndBalls()
    local balls = Ball.getBalls()
    for _, ball in ipairs(balls) do
        if ball.launched then
            local brick, axis = Brick.findBallHit(ball)
            if brick then
                axis = handleBrickHit(brick, axis)
                if axis == "x" then
                    ball.vx = -ball.vx
                else
                    ball.vy = -ball.vy
                end
            end
        end
    end
end

local function updatePlaying(dt)
    Background.update(dt)
    Effects.update(dt)
    Paddle.update(dt)

    -- Fire lasers continuously while buff active.
    if Paddle.hasLaser() then
        Paddle.fireLaser()
    end

    local paddle = Paddle.get()
    local balls = Ball.getBalls()

    -- Stick unlaunched balls to the paddle.
    for _, ball in ipairs(balls) do
        if not ball.launched then
            Ball.stick(ball, paddle.x, paddle.y)
        end
    end

    -- Paddle collision for launched balls.
    for _, ball in ipairs(balls) do
        if ball.launched and ball.vy > 0 and
           ball.y + ball.radius >= paddle.y - paddle.height / 2 and
           ball.y - ball.radius <= paddle.y + paddle.height / 2 and
           ball.x + ball.radius >= paddle.x - paddle.width / 2 and
           ball.x - ball.radius <= paddle.x + paddle.width / 2 then

            if Paddle.hasCatch() then
                ball.launched = false
                Ball.stick(ball, paddle.x, paddle.y)
            else
                Ball.paddleBounce(ball, paddle, paddle.vx)
                Audio.play("paddle")
            end
        end
    end

    local fallen = Ball.update(dt)
    if fallen > 0 then
        -- Life is lost only when all balls are gone.
        if Ball.count() == 0 then
            loseLife()
        end
    end

    Brick.update(dt)
    handleBricksAndBalls()
    handleBullets(dt)
    handlePowerups(dt)
end

local function drawHUD()
    Gfx.text("SCORE " .. score, 16, 10, Colors.white, "left")
    Gfx.text("LIVES " .. lives, W - 16, 10, Colors.white, "right")
    Gfx.text("LEVEL " .. levelIndex .. "/" .. #Levels.list, W / 2, 10, Colors.cyan, "center")
    Gfx.text("x" .. combo, W / 2, 40, Colors.magenta, "center")
end

local function drawPlaying()
    Background.draw()
    Effects.applyShake()
    Brick.draw()
    Paddle.draw()
    Ball.draw()
    Powerup.draw()
    Effects.draw()
    drawHUD()

    local balls = Ball.getBalls()
    local anyUnlaunched = false
    for _, b in ipairs(balls) do
        if not b.launched then
            anyUnlaunched = true
            break
        end
    end
    if anyUnlaunched then
        Gfx.glowText("SPACE LAUNCH", W / 2, H / 2 + 60, Colors.cyan, "center")
    end
end

local function drawTitle()
    Background.draw()
    Gfx.glowText("BREAKER", W / 2, H / 2 - 120, Colors.cyan, "center")
    Gfx.glowText("NEON CAMPAIGN", W / 2, H / 2 - 80, Colors.magenta, "center")

    local options = { "START GAME", "QUIT" }
    for i, label in ipairs(options) do
        local c = (i == titleSelection) and Colors.white or Colors.gray
        Gfx.glowText(label, W / 2, H / 2 + (i - 1) * 36, c, "center")
    end

    Gfx.smallText("HIGH SCORE " .. Save.getHighScore(), W / 2, H - 60, Colors.yellow, "center")
    Gfx.smallText("ARROWS / A D MOVE   SPACE LAUNCH", W / 2, H - 36, Colors.gray, "center")
end

local function drawTransition()
    Background.draw()
    local level = currentLevel()
    Gfx.glowText("LEVEL " .. levelIndex, W / 2, H / 2 - 40, Colors.cyan, "center")
    Gfx.glowText(level.name, W / 2, H / 2, Colors.magenta, "center")
    Gfx.glowText("GET READY", W / 2, H / 2 + 40, Colors.white, "center")
end

local function drawPause()
    Background.draw()
    Gfx.glowText("PAUSED", W / 2, H / 2 - 80, Colors.cyan, "center")
    local options = { "RESUME", "RESTART LEVEL", "QUIT TO TITLE" }
    for i, label in ipairs(options) do
        local c = (i == titleSelection) and Colors.white or Colors.gray
        Gfx.glowText(label, W / 2, H / 2 + (i - 1) * 30, c, "center")
    end
end

local function drawGameOver()
    Background.draw()
    Gfx.glowText("GAME OVER", W / 2, H / 2 - 60, Colors.red, "center")
    Gfx.glowText("SCORE " .. score, W / 2, H / 2 - 20, Colors.white, "center")
    Gfx.glowText("HIGH SCORE " .. Save.getHighScore(), W / 2, H / 2 + 10, Colors.yellow, "center")
    Gfx.glowText("ENTER TO RETRY", W / 2, H / 2 + 60, Colors.cyan, "center")
end

local function drawVictory()
    Background.draw()
    Gfx.glowText("CAMPAIGN CLEAR", W / 2, H / 2 - 60, Colors.cyan, "center")
    Gfx.glowText("SCORE " .. score, W / 2, H / 2 - 20, Colors.white, "center")
    Gfx.glowText("HIGH SCORE " .. Save.getHighScore(), W / 2, H / 2 + 10, Colors.yellow, "center")
    Gfx.glowText("ENTER TO RETURN", W / 2, H / 2 + 60, Colors.magenta, "center")
end

local stateDraw = {
    title = drawTitle,
    playing = drawPlaying,
    transition = drawTransition,
    pause = drawPause,
    gameover = drawGameOver,
    victory = drawVictory,
}

local stateUpdate = {
    title = function(dt)
        Background.update(dt)
    end,
    playing = updatePlaying,
    transition = function(dt)
        Background.update(dt)
        Effects.update(dt)
        transitionTime = transitionTime - dt
        if transitionTime <= 0 and pendingState then
            state = pendingState
            pendingState = nil
        end
    end,
    pause = function(dt)
        Background.update(dt)
    end,
    gameover = function(dt)
        Background.update(dt)
    end,
    victory = function(dt)
        Background.update(dt)
    end,
}

local function restartLevel()
    score = levelStartScore
    startLevel(levelIndex)
    state = "playing"
end

local function toTitle()
    titleSelection = 1
    state = "title"
end

local stateKey = {
    title = function(key)
        if key == "up" or key == "w" then
            titleSelection = titleSelection - 1
            if titleSelection < 1 then titleSelection = 2 end
            Audio.play("select")
        elseif key == "down" or key == "s" then
            titleSelection = titleSelection + 1
            if titleSelection > 2 then titleSelection = 1 end
            Audio.play("select")
        elseif key == "return" or key == "space" then
            Audio.play("select")
            if titleSelection == 1 then
                startCampaign()
            else
                love.event.quit()
            end
        end
    end,
    playing = function(key)
        if key == "space" then
            Ball.launch()
        elseif key == "escape" or key == "p" then
            titleSelection = 1
            state = "pause"
        elseif key == "r" then
            restartLevel()
        end
    end,
    transition = function(key)
        -- Allow skipping the transition.
        if key == "return" or key == "space" then
            if pendingState then
                state = pendingState
                pendingState = nil
            end
        end
    end,
    pause = function(key)
        if key == "up" or key == "w" then
            titleSelection = titleSelection - 1
            if titleSelection < 1 then titleSelection = 3 end
            Audio.play("select")
        elseif key == "down" or key == "s" then
            titleSelection = titleSelection + 1
            if titleSelection > 3 then titleSelection = 1 end
            Audio.play("select")
        elseif key == "return" or key == "space" then
            Audio.play("select")
            if titleSelection == 1 then
                state = "playing"
            elseif titleSelection == 2 then
                restartLevel()
            else
                toTitle()
            end
        elseif key == "escape" or key == "p" then
            state = "playing"
        end
    end,
    gameover = function(key)
        if key == "return" or key == "space" then
            startCampaign()
        end
    end,
    victory = function(key)
        if key == "return" or key == "space" then
            toTitle()
        end
    end,
}

function StateMachine.load()
    state = "title"
    titleSelection = 1
end

function StateMachine.update(dt)
    stateUpdate[state](dt)
end

function StateMachine.draw()
    stateDraw[state]()
end

function StateMachine.keypressed(key)
    if key == "escape" and state ~= "playing" and state ~= "pause" then
        love.event.quit()
        return
    end
    stateKey[state](key)
end

function StateMachine.mousepressed(x, y, button)
end

return StateMachine
