function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setIcon(love.image.newImageData("icon.png"))
    love.mouse.setVisible(true)
    love.window.setTitle("Virus")

    audio = love.audio.newSource("Lukrembo - Jay (freetouse.com).mp3", "stream")
    second_audio = love.audio.newSource("Hazelwood - Coming Of Age (freetouse.com).mp3", "stream")
    heeHee = love.audio.newSource("michael-jackson-hee-hee.mp3", "stream")
    close_popup_audio = love.audio.newSource("App_Exit_Notification.mp3", "stream")

    shaders = require("shaders")
    virusSprite = love.graphics.newImage("Violet_Virus.png")
    baranekSprite = love.graphics.newImage("sheep(good virus).png")
    fakeVirusSprite = love.graphics.newImage("fakeVirus.png")
    Ice_cream_popup = love.graphics.newImage("Ice-cream-pop-up.png")
    Hacked_popup = love.graphics.newImage("Hacked-pop-up.png")
    playButton = love.graphics.newImage("playButton.png")
    exitButton = love.graphics.newImage("exitButton.png")
    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        spd = 200,
        sprite = love.graphics.newImage("Gracz.png"),
        hp = 100
    }
    player.direction = 1
    popups = {}
    viruses = {}

    player_frames = {}
    player_frames.idle = {
        love.graphics.newImage("idle1.png"),
        love.graphics.newImage("idle2.png"),
        love.graphics.newImage("idle3.png")
    }
    player_frames.walk = {
        love.graphics.newImage("walk-right1.png"),
        love.graphics.newImage("walk-right2.png"),
        love.graphics.newImage("walk-right3.png"),
        love.graphics.newImage("walk-right4.png")
    }
    wirus = {
        x = math.random(0, love.graphics.getWidth() - 100),
        y = math.random(0, love.graphics.getHeight() - 50),
        type = "violet" or "baranek",
    }
    table.insert(viruses, wirus)

    stan = "menu"
    num_of_virus = 0
    cpuUsage = 0
    cpuFillWidth = math.min(200, cpuUsage * 2)
    cpuUsage = #viruses
    timer = 0
    gameTimer = 0
    time_to_spawn = 2
    points = 0
    xd = 0
    popup_timer = 0
    num_of_popup = 0
    real_type_of_popup = ""
    current_frame = 1
    anim_timer = 0
    type_of_popup = ""
    type_of_virus = ""
    isMoving = false
    delete = false
    close_to_end = false
    czcionka = love.graphics.newFont(32)
end

function love.update(dt)
    if stan == "game" then
        audio:play()
        audio:setVolume(0.25)
        if not audio:isPlaying() then
            second_audio:play()
            second_audio:setVolume(0.25)
        end
        -- 1. Sprawdzamy, czy stan ruchu się zmienił
        local wasMoving = isMoving
        isMoving = love.keyboard.isDown("a", "d", "w", "s")

        -- 2. Jeśli właśnie zacząłeś iść lub właśnie stanąłeś - zresetuj animację!
        if wasMoving ~= isMoving then
            current_frame = 1
            anim_timer = 0
        end

        -- 3. Timer animacji (zawsze na zewnątrz, żeby zawsze liczył czas)
        anim_timer = anim_timer + dt

        -- Wybieramy prędkość: chodzenie może być szybsze (0.1), idle wolniejsze (0.2)
        local speed = isMoving and 0.1 or 0.2

        if anim_timer >= speed then
            anim_timer = 0
            current_frame = current_frame + 1

            -- Sprawdzamy ile klatek ma OBECNA animacja
            local max_frames = 0
            if isMoving then
                max_frames = #player_frames.walk
            else
                max_frames = #player_frames.idle
            end

            if current_frame > max_frames then
                current_frame = 1
            end
        end

        type_of_virus = math.random(1, 10)
        if type_of_virus == 1 then
            real_type_of_virus = "baranek"
        elseif type_of_virus == 2 then
            real_type_of_virus = "fake"
        else
            real_type_of_virus = "violet"
        end
        num_of_popup = math.random(1, 3)
        if num_of_popup == 1 then
            real_type_of_popup = "hacked"
        else
            real_type_of_popup = "ice-cream"
        end
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
                type = real_type_of_virus
            }
            table.insert(viruses, nowy)
            timer = 0
        end

        if love.keyboard.isDown("d") then
            move_right(dt)
            isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown("a") then
            move_left(dt)
            isMoving = true
            player.direction = -1
        end
        if love.keyboard.isDown("w") then move_up(dt) end
        if love.keyboard.isDown("s") then move_down(dt) end

        if player.hp <= 0 then
            stan = "game_over"
        end

        if cpuUsage >= 100 then
            stan = "game_over"
        end

        if points >= 300 then
            stan = "game_win"
        end

        if points >= 150 then
            num_of_popup = math.random(1, 10)
            if num_of_popup == 1 or num_of_popup == 2 then
                type_of_popup = "ice-cream"
            else
                type_of_popup = "hacked"
            end
            popup_timer = popup_timer + dt
            if popup_timer >= 5 then
                new_popup = {
                    x = math.random(0, math.abs(love.graphics.getWidth() - 100)),
                    y = math.random(0, math.abs(love.graphics.getHeight() - 50)),
                    type = type_of_popup
                }
                table.insert(popups, new_popup)
                popup_timer = 0
            end
        end

        local pulse = math.max(10, player.hp * 1.5 + math.sin(love.timer.getTime() * 5) * 10)
        shaders.light:send("light_radius", math.max(5, pulse))
        shaders.light:send("light_center", { player.x, player.y })

        -- Supermoc baranka
        for i, v in ipairs(viruses) do
            if v.type == "baranek" then
                if love.keyboard.isDown("b") then
                    table.remove(viruses, i)
                    table.remove(viruses, math.random(1, #viruses))
                    delete = true
                    points = points + 15
                    xd = 0.1
                end
            end
        end

        -- kolizje z wirusami
        local playerScale = 3
        local virusScale = 5
        -- Używamy stałej, małej odległości kolizji (gdy sprite'y prawie się stykają)
        local collisionDistance = 25

        local minDist = math.huge
        for i = #viruses, 1, -1 do
            local v = viruses[i]

            local dx = player.x - v.x
            local dy = player.y - v.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if v.type == "violet" then
                local attackDistance = 60 -- Zwiększone, żeby wirus "dosięgał" gracza
                local attackPower = 5     -- Zabierze 20 HP na sekundę

                if dist <= attackDistance then
                    if love.keyboard.isDown("e") then
                        table.remove(viruses, i)
                        delete = true
                        points = points + 15
                        xd = 0.1
                    else
                        player.hp = player.hp - attackPower * dt
                        delete = false
                    end
                end
            end
            if v.type == "fake" then
                local attackDistance = 60

                if dist <= attackDistance then
                    if love.keyboard.isDown("e") then
                        table.remove(viruses, i)
                        delete = true
                        points = points + 15
                        xd = 0.1
                    else
                        -- 1. Usuwamy oryginał
                        table.remove(viruses, i)

                        -- 2. Tworzymy 3 nowe wirusy w losowych miejscach
                        for x = 1, 3 do
                            local klon = {
                                x = v.x + math.random(-50, 50), -- trochę obok starego
                                y = v.y + math.random(-50, 50),
                                type = "violet"                 -- lub inny typ
                            }
                            table.insert(viruses, klon)
                        end
                    end
                end
            end
        end

        -- Trzymaj gracza na ekranie (boundary collision)
        local playerHalfWidth = (player.sprite:getWidth() * playerScale) / 2
        local playerHalfHeight = (player.sprite:getHeight() * playerScale) / 2

        if xd > 0 then
            xd = xd - dt
        else
            delete = false
            xd = 0
        end

        if cpuUsage >= 80 then
            close_to_end = true
        else
            close_to_end = false
        end
        -- Przejście z prawej na lewą
        if player.x > love.graphics.getWidth() then
            player.x = 0
            -- Przejście z lewej na prawą
        elseif player.x < 0 then
            player.x = love.graphics.getWidth()
        end

        -- To samo dla góry i dołu (opcjonalnie)
        if player.y > love.graphics.getHeight() then
            player.y = 0
        elseif player.y < 0 then
            player.y = love.graphics.getHeight()
        end
    end

    if stan == "game_over" then
        if love.keyboard.isDown("r") then
            -- Resetuj całą grę
            player.hp = 100
            player.x = love.graphics.getWidth() / 2
            player.y = love.graphics.getHeight() / 2
            viruses = {}
            wirus = {
                x = math.random(0, love.graphics.getWidth() - 100),
                y = math.random(0, love.graphics.getHeight() - 50),
                type = real_type_of_virus,
            }
            table.insert(viruses, wirus)
            timer = 0
            points = 0
            gameTimer = 0
            time_to_spawn = 2
            cpuUsage = 0
            xd = 0
            delete = false
            close_to_end = false
            stan = "game"
        end
    end
    if stan == "game_win" then
        if love.keyboard.isDown("r") then
            -- Resetuj całą grę
            player.hp = 100
            player.x = love.graphics.getWidth() / 2
            player.y = love.graphics.getHeight() / 2
            viruses = {}
            wirus = {
                x = math.random(0, love.graphics.getWidth() - 100),
                y = math.random(0, love.graphics.getHeight() - 50),
                type = real_type_of_virus,
            }
            table.insert(viruses, wirus)
            timer = 0
            gameTimer = 0
            time_to_spawn = 2
            cpuUsage = 0
            xd = 0
            delete = false
            close_to_end = false
            points = 0
            stan = "game"
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
        heeHee:play()
    end

    function love.mousepressed(mx, my, button)
        if stan == "menu" then
            if button == 1 then -- Usunąłem cudzysłów wokół 1
                if mx >= 250 and mx <= 550 and my >= 200 and my <= 260 then
                    stan = "game"
                    if mj_sound then mj_sound:play() end -- Hee hee na start!
                    return                               -- Kończymy funkcję tutaj, żeby nie sprawdzać popupów od razu
                end
                if mx >= 250 and mx <= 550 and my >= 400 and my <= 460 then
                    love.event.quit()
                end
            end
        elseif stan == "game" then -- Używamy elseif, żeby stany się nie gryzły
            if button == 1 then
                local s = 4
                for i = #popups, 1, -1 do
                    local p = popups[i]
                    local bx = p.x + (53 * s)
                    local by = p.y + (1 * s)
                    local bSize = 8 * s

                    if mx >= bx and mx <= bx + bSize and my >= by and my <= by + bSize then
                        table.remove(popups, i)
                        if close_popup_audio then close_popup_audio:play() end
                        break
                    end
                end
            end
        end
    end

    function love.draw()
        love.graphics.setColor(1, 1, 1)

        if stan == "menu" then
            love.graphics.setBackgroundColor(1, 0.3, 0)
            love.graphics.setFont(czcionka)
            love.graphics.print("Terminator", 250, 10)

            -- Przyciski
            love.graphics.draw(playButton, 250, 200)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 250, 200, 300, 60)
            -- Kolejny
            love.graphics.draw(exitButton, 250, 400)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 250, 400, 300, 60)
        end

        love.graphics.setFont(czcionka)
        love.graphics.print("FPS:" .. love.timer.getFPS(), 650, 10)

        -- Tło
        if close_to_end then
            local red = 0.5 + math.sin(love.timer.getTime() * 5) * 0.5
            love.graphics.setBackgroundColor(red, 0.1, 0.1)
        else
            love.graphics.setBackgroundColor(0.2, 0.4, 0.8) -- A soft blue
        end

        if stan == "game_win" then
            love.graphics.setBackgroundColor(0, 1, 0)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(czcionka)
            love.graphics.print("You Win!", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 - 60)
            love.graphics.print("Press R to retry!", love.graphics.getWidth() / 2 - 60,
                love.graphics.getHeight() / 2 + 60)
        end

        if stan == "game" then
            love.graphics.print("Points: " .. points, 300, 10)
            cpuFillWidth = math.min(200, cpuUsage * 2)
            local playerScale = 3
            local virusScale = 5
            local playerRadius = (player.sprite:getWidth() * playerScale) / 2
            local ox = player.sprite:getWidth() / 2
            local oy = player.sprite:getHeight() / 2

            -- Gracz
            if delete == true then
                love.graphics.setShader(shaders.whiteout)
            end
            local img = player_frames.idle[current_frame]
            local offset_y = 0
            local offset_x = 0

            if isMoving then
                img = player_frames.walk[current_frame]
                offset_y = 7 * 4
                -- Używamy kierunku, żeby offset zawsze przesuwał w dobrą stronę!
                -- Spróbuj mniejszej liczby, np. 2 lub 3 zamiast 17
                offset_x = (2 * 4) * player.direction
            end

            local ox = img:getWidth() / 2
            local oy = img:getHeight() / 2

            -- Rysowanie
            love.graphics.draw(img, player.x + offset_x, player.y - offset_y, 0, 4 * player.direction, 4, ox, oy)


            love.graphics.setShader()
            love.graphics.setShader(shaders.light)
            shaders.light:send("light_center", { player.x, player.y })
            love.graphics.setColor(0, 0, 0, 0.75)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setShader()
            love.graphics.setColor(1, 1, 1)


            -- Wirusy
            love.graphics.setColor(1, 1, 1)
            for i, v in ipairs(viruses) do
                local vox = virusSprite:getWidth() / 2
                local voy = virusSprite:getHeight() / 2
                local baranekVox = baranekSprite:getWidth() / 2
                local baranekVoy = baranekSprite:getHeight() / 2
                local fVox = fakeVirusSprite:getWidth() / 2
                local fVoy = fakeVirusSprite:getHeight() / 2
                if v.type == "violet" then
                    love.graphics.draw(virusSprite, v.x, v.y, 0, 5, 5, vox, voy)
                end
                if v.type == "baranek" then
                    love.graphics.draw(baranekSprite, player.x - 160, player.y, 0, 5, 5, baranekVox, baranekVoy)
                end
                if v.type == "fake" then
                    love.graphics.draw(fakeVirusSprite, v.x, v.y, 0, 5, 5, fVox, fVoy)
                end
            end

            local virusRadius = (virusSprite:getWidth() * virusScale) / 2
            local collisionDistance = (playerRadius + virusRadius) * 0.3

            for i, v in ipairs(viruses) do
                local dx = player.x - v.x
                local dy = player.y - v.y
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist <= collisionDistance then
                    love.graphics.setFont(czcionka)
                    love.graphics.print("Press E to terminate", v.x, v.y - 15)
                end
            end

            -- Popup'y
            for i, p in ipairs(popups) do
                if p.type == "ice_cream" then
                    love.graphics.draw(Ice_cream_popup, p.x, p.y, 0, 4, 4)
                end
                if p.type == "hacked" then
                    love.graphics.draw(Hacked_popup, p.x, p.y, 0, 4, 4)
                end
            end

            -- Ramka
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", 10, 10, 200, 30)

            -- Pasek CPU
            if cpuUsage >= 80 then
                love.graphics.setColor(math.random(), math.random(), math.random())
            elseif cpuUsage >= 50 then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(1, 1, 0)
            end
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
            love.graphics.print("Press R to retry!", love.graphics.getWidth() / 2 - 60,
                love.graphics.getHeight() / 2 + 60)
        end
    end
end
