function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Terminator")
    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        spd = 200,
        sprite = love.graphics.newImage("Gracz.png")
    }
    viruses = {}

    wirus = {
        x = math.random(0, love.graphics.getWidth() - 100),
        y = math.random(0, love.graphics.getHeight() - 50),
        type = "green"
    }
    table.insert(viruses, wirus)

    cpuUsage = 0
    timer = 0
end

function love.update(dt)
    timer = timer + dt
    if timer >= 2 then
        nowy = {
            x = math.random(0, love.graphics.getWidth() - 100),
            y = math.random(0, love.graphics.getHeight() - 50),
            type =
            "green"
        }
        table.insert(viruses, nowy)
        timer = 0
    end

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

    -- Wirusy
    for i, v in ipairs(viruses) do
        if v.type == "green" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", v.x, v.y, 15, 15)
        end
    end

    -- Ramka
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 10, 10, 200, 30)

    -- Pasek
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", 10, 10, cpuUsage * 2, 30)
end
