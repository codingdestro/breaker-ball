local Particles = {}

local list = {}

function Particles.clear()
    list = {}
end

function Particles.burst(x, y, color, count, speed)
    for _ = 1, count do
        local angle = love.math.random() * math.pi * 2
        local v = speed * (0.3 + love.math.random() * 0.7)
        table.insert(list, {
            x = x,
            y = y,
            vx = math.cos(angle) * v,
            vy = math.sin(angle) * v,
            life = 0.3 + love.math.random() * 0.4,
            maxLife = 0.7,
            size = 1 + love.math.random() * 2,
            color = color,
        })
    end
end

function Particles.update(dt)
    for i = #list, 1, -1 do
        local p = list[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vx = p.vx * 0.96
        p.vy = p.vy * 0.96
        if p.life <= 0 then
            table.remove(list, i)
        end
    end
end

function Particles.draw()
    for _, p in ipairs(list) do
        local a = math.max(0, p.life / p.maxLife)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], a)
        love.graphics.rectangle("fill", p.x - p.size / 2, p.y - p.size / 2, p.size, p.size)
    end
end

return Particles
