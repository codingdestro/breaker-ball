local Brick = {}

local Colors = require("src.colors")
local Gfx = require("src.gfx")

local COLS = 10
local BRICK_WIDTH = 33
local BRICK_HEIGHT = 10
local PADDING = 2
local OFFSET_TOP = 100

local bricks = {}

local HIT_POINTS = {
  standard = 1,
  tough = 2,
  armored = 3,
  explosive = 1,
  moving = 1,
  indestructible = math.huge,
}

local CHAR_TO_TYPE = {
  S = "standard",
  T = "tough",
  A = "armored",
  E = "explosive",
  M = "moving",
  I = "indestructible",
}

local function gridWidth()
  return COLS * BRICK_WIDTH + (COLS - 1) * PADDING
end

local function offsetLeft()
  return (love.graphics.getWidth() - gridWidth()) / 2
end

-- Builds the brick field from an array of row strings.
function Brick.load(level)
  bricks = {}
  local left = offsetLeft()
  for rowIndex, rowStr in ipairs(level.bricks) do
    for col = 1, #rowStr do
      local ch = rowStr:sub(col, col)
      local brickType = CHAR_TO_TYPE[ch]
      if brickType then
        local brick = {
          x = left + (col - 1) * (BRICK_WIDTH + PADDING),
          y = OFFSET_TOP + (rowIndex - 1) * (BRICK_HEIGHT + PADDING),
          width = BRICK_WIDTH,
          height = BRICK_HEIGHT,
          type = brickType,
          hits = HIT_POINTS[brickType],
          alive = true,
          row = rowIndex,
          col = col,
          vx = (love.math.random() < 0.5) and 28 or -28,
        }
        table.insert(bricks, brick)
      end
    end
  end
end

function Brick.clear()
  bricks = {}
end

function Brick.getBricks()
  return bricks
end

-- Returns true if all breakable bricks are gone.
function Brick.allCleared()
  for _, b in ipairs(bricks) do
    if b.alive and b.type ~= "indestructible" then
      return false
    end
  end
  return true
end

function Brick.update(dt)
  local left = offsetLeft()
  local right = left + gridWidth()
  for _, b in ipairs(bricks) do
    if b.alive and b.type == "moving" then
      b.x = b.x + b.vx * dt
      if b.x - b.width / 2 < left or b.x + b.width / 2 > right then
        b.vx = -b.vx
        b.x = math.max(left + b.width / 2, math.min(right - b.width / 2, b.x))
      end
    end
  end
end

-- Finds the first alive brick overlapping a ball, plus the bounce axis.
function Brick.findBallHit(ball)
  for _, b in ipairs(bricks) do
    if b.alive then
      if
        ball.x + ball.radius > b.x
        and ball.x - ball.radius < b.x + b.width
        and ball.y + ball.radius > b.y
        and ball.y - ball.radius < b.y + b.height
      then
        local overlapLeft = ball.x + ball.radius - b.x
        local overlapRight = b.x + b.width - (ball.x - ball.radius)
        local overlapTop = ball.y + ball.radius - b.y
        local overlapBottom = b.y + b.height - (ball.y - ball.radius)

        local minOverlapX = math.min(overlapLeft, overlapRight)
        local minOverlapY = math.min(overlapTop, overlapBottom)

        if minOverlapX < minOverlapY then
          return b, "x"
        end
        return b, "y"
      end
    end
  end
  return nil, nil
end

-- Applies one hit to a brick. Returns true when the brick breaks.
function Brick.hit(brick)
  if not brick.alive or brick.type == "indestructible" then
    return false
  end
  brick.hits = brick.hits - 1
  if brick.hits <= 0 then
    brick.alive = false
    return true
  end
  return false
end

-- Destroys non-indestructible bricks adjacent to an explosive brick.
-- Returns the list of destroyed neighbors.
function Brick.explode(brick)
  local destroyed = {}
  for _, other in ipairs(bricks) do
    if other.alive and other ~= brick and other.type ~= "indestructible" then
      local dx = math.abs((other.x + other.width / 2) - (brick.x + brick.width / 2))
      local dy = math.abs((other.y + other.height / 2) - (brick.y + brick.height / 2))
      if dx <= brick.width * 1.3 and dy <= brick.height * 1.3 then
        other.alive = false
        table.insert(destroyed, other)
      end
    end
  end
  return destroyed
end

-- Finds the first alive brick hit by a laser bullet.
function Brick.findBulletHit(bullet)
  for _, b in ipairs(bricks) do
    if b.alive then
      if bullet.x > b.x and bullet.x < b.x + b.width and bullet.y > b.y and bullet.y < b.y + b.height then
        return b
      end
    end
  end
  return nil
end

function Brick.draw()
  for _, b in ipairs(bricks) do
    if b.alive then
      local c = Colors.brickColor(b)
      if b.type == "indestructible" then
        Gfx.rect(b.x + b.width / 2, b.y + b.height / 2, b.width, b.height, c, 0.7)
      else
        Gfx.glowRect(b.x + b.width / 2, b.y + b.height / 2, b.width - 2, b.height - 2, c)
      end
    end
  end
end

return Brick
