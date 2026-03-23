function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Terminator")

    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        spd = 200,
        sprite = love.graphics.newImage("Gracz.png")
    }
end

function love.update(dt)
    if love.keyboard.isDown("d") then move_right(dt) end
    if love.keyboard.isDown("a") then move_left(dt) end
end

function move_right(dt)
    player.x = player.x + player.spd * dt
end

function move_left(dt)
    player.x = player.x - player.spd * dt
end

function love.draw()
    -- Tło
    love.graphics.setBackgroundColor(0, 1, 0.8)

    local ox = player.sprite:getWidth() / 2
    local oy = player.sprite:getHeight() / 2

    -- Gracz
    love.graphics.draw(player.sprite, player.x, player.y, 0, 3, 3, ox, oy)
end
