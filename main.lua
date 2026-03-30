function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Terminator")

    shaders = require("shaders")
    virusSprite = love.graphics.newImage("Violet_Virus.png")
    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        spd = 200,
        sprite = love.graphics.newImage("Gracz.png"),
        hp = 100
    }
    viruses = {}

    wirus = {
        x = math.random(0, love.graphics.getWidth() - 100),
        y = math.random(0, love.graphics.getHeight() - 50),
        type = "violet",
        sprite = virusSprite
    }
    table.insert(viruses, wirus)

    stan = "game"
    cpuUsage = 0
    cpuFillWidth = math.min(200, cpuUsage * 2)
    cpuUsage = #viruses
    timer = 0
    gameTimer = 0
    time_to_spawn = 2
    czcionka = love.graphics.newFont(32)
end

function love.update(dt)
    if stan == "game" then
        cpuUsage = #viruses
        gameTimer = gameTimer + dt
        timer = timer + dt
        if gameTimer >= 180 then
            time_to_spawn = 1.2
        elseif gameTimer >= 120 then
            time_to_spawn = 1.6
        elseif gameTimer >= 60 then
            time_to_spawn = 1.8
        end

        if timer >= time_to_spawn then
            nowy = {
                x = math.random(0, math.abs(love.graphics.getWidth() - 100)),
                y = math.random(0, math.abs(love.graphics.getHeight() - 50)),
                type =
                "violet",
                sprite = virusSprite
            }
            table.insert(viruses, nowy)
            timer = 0
        end

        if love.keyboard.isDown("d") then move_right(dt) end
        if love.keyboard.isDown("a") then move_left(dt) end
        if love.keyboard.isDown("w") then move_up(dt) end
        if love.keyboard.isDown("s") then move_down(dt) end

        if player.hp <= 0 then
            stan = "game_over"
        end

        if cpuUsage >= 100 then
            stan = "game_over"
        end

        local pulse = player.hp * 1.5 + math.sin(love.timer.getTime() * 5) * 10
        shaders.light:send("light_radius", math.abs(pulse))

        for i = #viruses, 1, -1 do
            local v = viruses[i]
            if math.abs(player.x - v.x) < 55 and math.abs(player.y - v.y) < 55 then
                if love.keyboard.isDown("e") then
                    table.remove(viruses, i)
                end
            end
            if math.abs(player.x - v.x) < 40 and math.abs(player.y - v.y) < 40 then
                player.hp = player.hp - 0.1 * dt
            end
        end
    end
end

function move_right(dt)
    player.x = player.x + player.spd * dt
end

function move_left(dt)
    player.x = player.x - player.spd * dt
end

function move_up(dt)
    player.y = player.y - player.spd * dt
end

function move_down(dt)
    player.y = player.y + player.spd * dt
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    -- Tło
    love.graphics.setBackgroundColor(0.2, 0.4, 0.8) -- A soft blue

    if stan == "game" then
        cpuFillWidth = math.min(200, cpuUsage * 2)
        local ox = player.sprite:getWidth() / 2
        local oy = player.sprite:getHeight() / 2


        -- Gracz
        love.graphics.draw(player.sprite, player.x, player.y, 0, 3, 3, ox, oy)

        -- Wirusy (przed nakładką — w kole światła widać je normalnie przez wycięcie)
        love.graphics.setColor(1, 1, 1)
        for i, v in ipairs(viruses) do
            local vox = v.sprite:getWidth() / 2
            local voy = v.sprite:getHeight() / 2
            if v.type == "violet" then
                love.graphics.draw(v.sprite, v.x, v.y, 0, 5, 5, vox, voy)
            end
        end

        -- nakładka (światło na pozycji gracza)
        love.graphics.setShader(shaders.light)
        shaders.light:send("light_center", { player.x, player.y })
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
        love.graphics.setColor(1, 1, 1)

        for i, v in ipairs(viruses) do
            if math.abs(player.x - v.x) < 55 and math.abs(player.y - v.y) < 55 then
                love.graphics.setFont(czcionka)
                love.graphics.print("Press E to terminate", v.x, v.y - 15)
            end
        end

        -- Ramka
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 10, 10, 200, 30)

        -- Pasek
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.rectangle("fill", 10, 10, cpuFillWidth, 30)

        -- HP Ramka
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 10, 560, 200, 30)

        -- Pasek HP
        if player.hp <= 50 then
            love.graphics.setColor(1, 1, 0.25)
        else
            love.graphics.setColor(1, 0.2, 0)
        end
        if player.hp <= 35 then
            love.graphics.setColor(0, 0.8, 1)
        end
        love.graphics.rectangle("fill", 10, 560, player.hp * 2, 30)
    end

    -- Koniec gry
    if stan == "game_over" then
        love.graphics.setBackgroundColor(0, 0.2, 0.2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(czcionka)
        love.graphics.print("Game Over", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 - 60)
    end
end
