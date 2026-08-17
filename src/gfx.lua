local Gfx = {}

local Colors = require("src.colors")

local uiFont = nil
local smallFont = nil

function Gfx.load()
    uiFont = love.graphics.newFont(16)
    smallFont = love.graphics.newFont(11)
end

-- Sets a color with an optional alpha multiplier.
function Gfx.setColor(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or 1)
end

-- Draws a filled rectangle from center coordinates.
function Gfx.rect(cx, cy, w, h, c, alpha)
    Gfx.setColor(c, alpha)
    love.graphics.rectangle("fill", cx - w / 2, cy - h / 2, w, h)
end

-- Draws a filled rounded rectangle from center coordinates.
function Gfx.roundRect(cx, cy, w, h, radius, c, alpha)
    Gfx.setColor(c, alpha)
    love.graphics.rectangle("fill", cx - w / 2, cy - h / 2, w, h, radius, radius)
end

-- Draws a filled circle from center coordinates.
function Gfx.circle(cx, cy, r, c, alpha)
    Gfx.setColor(c, alpha)
    love.graphics.circle("fill", cx, cy, r)
end

-- Draws a soft neon circle: layered translucent circles behind the core.
function Gfx.glowCircle(cx, cy, r, c, alpha)
    Gfx.setColor(c, (alpha or 1) * 0.12)
    love.graphics.circle("fill", cx, cy, r + 4)
    Gfx.setColor(c, (alpha or 1) * 0.25)
    love.graphics.circle("fill", cx, cy, r + 2)
    Gfx.setColor(c, alpha)
    love.graphics.circle("fill", cx, cy, r)
end

-- Draws a filled square used for pixel-style circles.
function Gfx.pixelCircle(cx, cy, r, c, alpha)
    Gfx.setColor(c, alpha)
    love.graphics.rectangle("fill", cx - r, cy - r, r * 2, r * 2)
end

-- Draws a neon rectangle: a colored core with a layered glow behind it.
function Gfx.glowRect(cx, cy, w, h, c, alpha)
    local glow = { c[1], c[2], c[3] }
    Gfx.setColor(glow, (alpha or 1) * 0.12)
    love.graphics.rectangle("fill", cx - w / 2 - 5, cy - h / 2 - 5, w + 10, h + 10)
    Gfx.setColor(glow, (alpha or 1) * 0.25)
    love.graphics.rectangle("fill", cx - w / 2 - 2, cy - h / 2 - 2, w + 4, h + 4)
    Gfx.setColor(c, alpha)
    love.graphics.rectangle("fill", cx - w / 2, cy - h / 2, w, h)
end

-- Draws a neon rounded rectangle with layered glow.
function Gfx.glowRoundRect(cx, cy, w, h, radius, c, alpha)
    local glow = { c[1], c[2], c[3] }
    Gfx.setColor(glow, (alpha or 1) * 0.12)
    love.graphics.rectangle("fill", cx - w / 2 - 4, cy - h / 2 - 4, w + 8, h + 8, radius + 4, radius + 4)
    Gfx.setColor(glow, (alpha or 1) * 0.25)
    love.graphics.rectangle("fill", cx - w / 2 - 2, cy - h / 2 - 2, w + 4, h + 4, radius + 2, radius + 2)
    Gfx.setColor(c, alpha)
    love.graphics.rectangle("fill", cx - w / 2, cy - h / 2, w, h, radius, radius)
end

-- Draws neon glowing text by layering translucent copies behind the core text.
function Gfx.glowText(text, x, y, c, align, alpha)
    local a = alpha or 1
    love.graphics.setFont(uiFont)
    local width = uiFont:getWidth(text)
    if align == "center" then
        x = x - width / 2
    elseif align == "right" then
        x = x - width
    end
    Gfx.setColor(c, a * 0.25)
    love.graphics.print(text, x - 2, y - 2)
    love.graphics.print(text, x + 2, y + 2)
    Gfx.setColor(c, a * 0.5)
    love.graphics.print(text, x - 1, y - 1)
    love.graphics.print(text, x + 1, y + 1)
    Gfx.setColor(Colors.white, a)
    love.graphics.print(text, x, y)
end

-- Draws simple text using the default font.
function Gfx.text(text, x, y, c, align, alpha)
    love.graphics.setFont(uiFont)
    if align == "center" then
        x = x - uiFont:getWidth(text) / 2
    elseif align == "right" then
        x = x - uiFont:getWidth(text)
    end
    Gfx.setColor(c, alpha)
    love.graphics.print(text, x, y)
end

-- Draws simple text using the small font.
function Gfx.smallText(text, x, y, c, align, alpha)
    love.graphics.setFont(smallFont)
    if align == "center" then
        x = x - smallFont:getWidth(text) / 2
    elseif align == "right" then
        x = x - smallFont:getWidth(text)
    end
    Gfx.setColor(c, alpha)
    love.graphics.print(text, x, y)
end

-- Returns the current display size.
function Gfx.size()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

return Gfx
