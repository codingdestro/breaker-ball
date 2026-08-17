local Colors = {}

Colors.background = { 0.02, 0.02, 0.12 }
Colors.cyan = { 0.0, 0.898, 1.0 }
Colors.magenta = { 1.0, 0.176, 0.584 }
Colors.purple = { 0.63, 0.13, 0.94 }
Colors.white = { 1.0, 1.0, 1.0 }
Colors.black = { 0.0, 0.0, 0.0 }
Colors.gray = { 0.35, 0.35, 0.42 }
Colors.orange = { 1.0, 0.57, 0.0 }
Colors.red = { 1.0, 0.15, 0.15 }
Colors.yellow = { 1.0, 0.9, 0.2 }
Colors.steel = { 0.8, 0.85, 0.9 }

-- Per-row brick gradient for standard bricks (pink -> purple -> cyan).
local rowGradient = {
    { 1.0, 0.176, 0.584 },
    { 0.83, 0.22, 0.85 },
    { 0.63, 0.13, 0.94 },
    { 0.35, 0.34, 1.0 },
    { 0.0, 0.75, 1.0 },
    { 0.0, 0.898, 1.0 },
}

function Colors.brickColor(brick)
    if brick.type == "standard" then
        return rowGradient[math.min(brick.row, #rowGradient)]
    end
    if brick.type == "tough" then
        local c = Colors.orange
        if brick.hits == 1 then
            return { c[1], c[2] * 0.55, c[3] * 0.55 }
        end
        return c
    end
    if brick.type == "armored" then
        local c = Colors.steel
        local f = 1.0 - (brick.hits - 1) * 0.25
        return { c[1] * f, c[2] * f, c[3] * f }
    end
    if brick.type == "explosive" then
        return Colors.red
    end
    if brick.type == "moving" then
        return Colors.yellow
    end
    if brick.type == "indestructible" then
        return Colors.gray
    end
    return Colors.white
end

return Colors
