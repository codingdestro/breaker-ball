-- Breaker: a neon synthwave breakout campaign.

Colors = require("src.colors")
Gfx = require("src.gfx")
Audio = require("src.audio")
Save = require("src.save")
Background = require("src.background")

Paddle = require("src.paddle")
Ball = require("src.ball")
Brick = require("src.brick")
Powerup = require("src.powerup")

Levels = require("src.levels")

Effects = require("src.effects")
StateMachine = require("src.states")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.math.setRandomSeed(os.time())
    Gfx.load()
    Audio.load()
    Save.load()
    Background.load()
    StateMachine.load()
end

function love.update(dt)
    StateMachine.update(dt)
end

function love.draw()
    StateMachine.draw()
end

function love.keypressed(key)
    StateMachine.keypressed(key)
end

function love.mousepressed(x, y, button)
    StateMachine.mousepressed(x, y, button)
end
