local Save = {}

local path = "breaker_highscore.lua"
local highScore = 0

function Save.load()
    local ok, chunk = pcall(love.filesystem.load, path)
    if ok and chunk then
        local ok2, result = pcall(chunk)
        if ok2 and type(result) == "number" then
            highScore = result
        end
    end
end

function Save.getHighScore()
    return highScore
end

function Save.submit(score)
    if score > highScore then
        highScore = score
        love.filesystem.write(path, tostring(highScore))
        return true
    end
    return false
end

return Save
