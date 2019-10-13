local screen = {}
local audio = {}
local racket = {}
local ball = {}
local bricks = {}
local heart = {}
local border = {}
local gameover = {}
local victory = {}

function love.load()

    screen.width = love.graphics.getWidth()
    screen.height = love.graphics.getHeight()
    screen.current = "game"

    audio.volumeTouch = false 
    audio.collisionSong = love.audio.newSource("audio/songs/bong.mp3", "static")
    audio.playlist = {}
    audio.playlist[1] = love.audio.newSource("audio/musics/mission-impossible-themefull.mp3", "stream")
    for i=1, #audio.playlist, 1 do
        audio.playlist[i]:play()
        audio.playlist[i]:setLooping(true)
        audio.playlist[i]:setVolume(0)
    end

    border.left = {}
    border.right = {}
    border.top = {}
    border.left.image = love.graphics.newImage("images/border_left.png")
    border.left.width = border.left.image:getWidth()
    border.left.height = border.left.image:getHeight()
    border.right.image = love.graphics.newImage("images/border_right.png")
    border.right.width = border.right.image:getWidth()
    border.right.height = border.right.image:getHeight()
    border.top.image = love.graphics.newImage("images/border_top.png")
    border.top.width = border.top.image:getWidth()
    border.top.height = border.top.image:getHeight()

    bricks.levels = {}
    bricks.bloc = 1
    bricks.nbLevel = 3
    for i=1, bricks.nbLevel, 1 do
        bricks.levels[i] = {}
    end
    bricks.blue = love.graphics.newImage("images/blue_brick.png")
    bricks.width = bricks.blue:getWidth()
    bricks.height = bricks.blue:getHeight()
    bricks.nbColumns = math.floor((screen.width - (border.left.width + border.right.width)) / bricks.width)
    bricks.nbLines = 7
    bricks.nbBricks = 0
    
    ball.nbLifes = 3  
    
    heart.image = love.graphics.newImage("images/heart.png")
    heart.width = heart.image:getWidth()
    heart.height = heart.image:getHeight()    

    victory.image = love.graphics.newImage("images/victory.png")
    victory.width = victory.image:getWidth()
    victory.height = victory.image:getHeight()
    victory.x = screen.width / 2
    victory.y = screen.height / 2
    victory.select = 1
    victory.rectangle = {}
    victory.rectangle.x = (screen.width / 2) - 45
    victory.rectangle.y = screen.height - 112
    victory.rectangle.width = 100
    victory.rectangle.height = 20

    gameover.images = {}
    gameover.images[1] = love.graphics.newImage("/images/gameover/gameover_pink.png")
    gameover.images[2] = love.graphics.newImage("/images/gameover/gameover_green.png")
    gameover.images[3] = love.graphics.newImage("/images/gameover/gameover_lightblue.png")
    gameover.images[4] = love.graphics.newImage("/images/gameover/gameover_yellow.png")
    frameGameover = 1

    initRacket()
    initBall()

    initBricksLevel2()

end

function love.update(dt)

    if screen.current == "start" then
    end
    
    if screen.current == "game" then
        
        if not audio.volumeTouch and audio.playlist[1]:getVolume() <= 0.5 then
            audio.playlist[1]:setVolume(audio.playlist[1]:getVolume() + (0.5 * dt))           
        end

        if love.keyboard.isDown("kp-") then
            audio.volumeTouch = true
            if audio.playlist[1]:getVolume() >= 0 then
                audio.playlist[1]:setVolume(audio.playlist[1]:getVolume() - (0.5 * dt))
            end
        end

        if love.keyboard.isDown("kp+") then
            audio.volumeTouch = true
            if audio.playlist[1]:getVolume() <= 0.5 then
                audio.playlist[1]:setVolume(audio.playlist[1]:getVolume() + (0.5 * dt))
            end
        end

        if racket.x <= screen.width - racket.width and racket.x >= 0 then
            racket.x = love.mouse.getX() - racket.half.x
        end
        
        -- handle racket movement on x 
        if racket.x + racket.width > screen.width - border.right.width then
            racket.x = (screen.width - border.right.width) - racket.width
        elseif racket.x < 0 + border.left.width then
            racket.x = 0 + border.right.width
        end

        -- case in the ball is in the racket
        if ball.stick == true then
            ball.x = racket.x + racket.half.x
            if racket.x + racket.half.x < screen.width / 2 then
                ball.vx = -200          
            else
                ball.vx = 200
            end
        -- case in the ball is launched
        else
            ball.y = ball.y - ball.vy * dt
            if ball.x + ball.radius <= screen.width - border.right.width and ball.x - ball.radius >= 0 + border.left.width then
                ball.x = ball.x + ball.vx * dt
            end
            if ball.x + ball.radius > screen.width - border.right.width then
                ball.x = (screen.width - border.right.width) - ball.radius
                ball.vx = 0 - ball.vx
            end
            if ball.x - ball.radius < 0 + border.left.width then
                ball.x = (0 + border.left.width) + ball.radius
                ball.vx = 0 - ball.vx
            end
            if ball.y - ball.radius <= 0 + border.top.height then            
                ball.y = (0 + border.top.height) + ball.radius
                ball.vy = 0 - ball.vy
            end
            if ball.y > racket.y then
                
                ball.nbLifes = ball.nbLifes - 1
                if ball.nbLifes > 0 then
                    initBall()
                else
                    screen.current = "gameover"
                end
            end
            if ball.x >= racket.x and ball.x <= racket.x + racket.width and ball.y + ball.radius >= racket.y then
                ball.y = racket.y - ball.radius
                ball.vy = 0 - ball.vy
            end
        
            collisionBallWithBricks(bricks.levels[bricks.bloc])
            print(bricks.nbBricks)

        end
    end

    -- game over
    if screen.current == "gameover" then
        frameGameover = frameGameover + (2 * dt)
        if frameGameover > #gameover.images + 1 then
            frameGameover = 1
        end
        print(frameGameover)
        gameover.screen = gameover.images[math.floor(frameGameover)]
    end

    -- victory
    if screen.current == "victory" then
        local getY = love.mouse.getY()
        local getX = love.mouse.getX()

        if getX >= victory.rectangle.x and getX <= victory.rectangle.x + victory.rectangle.width then
            if getY >= screen.height - 110 then
                victory.select = 1
            end
            if getY >= screen.height - 90 then            
                victory.select = 2
            end
            if getY >= screen.height - 70 then
                victory.select = 3
            end
        end
    end

end

function love.draw()

    if screen.current == "start" then

    end

    if screen.current == "game" or screen.current == "pause" then

        -- conturing
        love.graphics.draw(border.left.image)
        love.graphics.draw(border.right.image, screen.width - border.right.image:getWidth())
        love.graphics.draw(border.top.image)

        love.graphics.draw(racket.image, racket.x, racket.y)
        love.graphics.draw(ball.image, ball.x, ball.y, 0, 1, 1, ball.width / 2, ball.height / 2)

        -- bricks
        for l=1, bricks.nbLines, 1 do
            for c=1, bricks.nbColumns, 1 do
                if bricks.levels[bricks.bloc][l][c] == 1 then
                    love.graphics.draw(bricks.blue, ((c - 1) * bricks.width) + border.left.width, ((l - 1) * bricks.height) + border.top.height)
                end
            end
        end

        for i=1, ball.nbLifes, 1 do
            love.graphics.draw(heart.image, ((i * (heart.width * 0.1)) - (heart.width * 0.1)) + border.left.width, screen.height - (heart.height * 0.1), 0, 0.1, 0.1)
        end
    end

    -- victory screen
    if screen.current == "victory" then

        love.graphics.draw(victory.image, victory.x, victory.y, 0, 0.4, 0.4, victory.width / 2, victory.height / 2)

        if victory.select == 1 then
            love.graphics.rectangle("fill", victory.rectangle.x, victory.rectangle.y, victory.rectangle.width, victory.rectangle.height)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("Niveau suivant", (screen.width / 2) - 40, screen.height - 110)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Recommencer", (screen.width / 2) - 39, screen.height - 90)
            love.graphics.print("Quitter", (screen.width / 2) - 20, screen.height - 70)
        end
        if victory.select == 2 then
            love.graphics.rectangle("fill", victory.rectangle.x, victory.rectangle.y + (1 * victory.rectangle.height), victory.rectangle.width, victory.rectangle.height)
            love.graphics.print("Niveau suivant", (screen.width / 2) - 40, screen.height - 110)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("Recommencer", (screen.width / 2) - 39, screen.height - 90)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Quitter", (screen.width / 2) - 20, screen.height - 70)
        end
        if victory.select == 3 then
            love.graphics.rectangle("fill", victory.rectangle.x, victory.rectangle.y + (2 * victory.rectangle.height), victory.rectangle.width, victory.rectangle.height)
            love.graphics.print("Niveau suivant", (screen.width / 2) - 40, screen.height - 110)
            love.graphics.print("Recommencer", (screen.width / 2) - 39, screen.height - 90)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("Quitter", (screen.width / 2) - 20, screen.height - 70)
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- game over screen
    if screen.current == "gameover" then
        love.graphics.draw(gameover.screen, screen.width / 2, screen.height / 2, 0, 1, 1, gameover.screen:getWidth() / 2, gameover.screen:getHeight() / 2)
        love.graphics.print("")
    end

end

function love.keypressed(key, scancode, isRepeat)

    print(key)

    if screen.current == "game" and key == "escape" then
        screen.current = "pause"
        audio.playlist[1]:pause()
    end

    if screen.current == "pause" and key == "space" then
        screen.current = "game"
        audio.playlist[1]:play()
    end
    
end

function love.mousepressed(x, y, button)

    if screen.current == "game" then
        if button == 1 then
            ball.stick = false        
        end
    end

    if screen.current == "victory" then
        if button == 1 then
            if x >= victory.rectangle.x and x <= victory.rectangle.x + victory.rectangle.width then
                if y >= screen.height - 110 and y <= (screen.height - 110) + victory.rectangle.height then
                    initRacket()
                    initBall()
                    if bricks.bloc == 1 then
                        initBricksLevel2()
                    end
                    if bricks.bloc == 2 then
                        initBricksLevel3()
                    end
                    screen.current = "game"
                end
                if y >= screen.height - 90 and (screen.height - 90) + victory.rectangle.height then
                    initRacket()
                    initBall()
                    if bricks.bloc == 1 then
                        initBricksLevel1()
                    end
                    if bricks.bloc == 2 then
                        initBricksLevel2()
                    end        
                    screen.current = "game"
                end
                if y >= screen.height - 70 and y <= (screen.height - 70) + victory.rectangle.height then
                    love.event.quit()
                end
            end
        end
    end

end

function initRacket()

    racket.image = love.graphics.newImage("images/Racket.png")
    racket.width = racket.image:getWidth()
    racket.height = racket.image:getHeight()
    racket.half = {x = racket.width/2, y = racket.height/2}
    racket.x = screen.width/2 - racket.half.x
    racket.y = screen.height - 100

end

function initBall()

    ball.image = love.graphics.newImage("images/Ball.png")
    ball.width = ball.image:getWidth()
    ball.height = ball.image:getHeight()
    ball.radius = ball.width / 2
    ball.x = racket.x + racket.half.x
    ball.y = racket.y - (ball.height / 2)
    ball.stick = true
    ball.vx = 200
    ball.vy = 200

end

function initBricksLevel1()

    bricks.bloc = 1

    bricks.nbBricks = 0

    for l=1, bricks.nbLines, 1 do
        bricks.levels[1][l] = {}
        for c=1, bricks.nbColumns, 1 do
            if l % 2 == 0 and c % 2 == 0 then
                bricks.levels[1][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end            
        end
    end

end

function initBricksLevel2()

    bricks.bloc = 2

    bricks.nbBricks = 0

    for l=1, bricks.nbLines, 1 do
        bricks.levels[2][l] = {}
        for c=1, bricks.nbColumns, 1 do
            if l == 2 and c == 4 then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 3 and (c == 3 or c == 4 or c == 5) then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 4 and (c ~= 1 and c ~= 7) then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 5 and (c ~= 1 and c ~= 7) then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 6 and (c == 3 or c == 4 or c == 5) then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 7 and c == 4 then
                bricks.levels[2][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end    
            
        end
    end

end

function initBricksLevel3()

    bricks.bloc = 3

    bricks.nbBricks = 0

    for l=1, bricks.nbLines, 1 do
        bricks.levels[3][l] = {}
        for c=1, bricks.nbColumns, 1 do
            if l == 2 and c == 8 then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 3 and (c == 11 or c == 8 or c == 9) then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 4 and (c == 5 or c == 12) then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 5 and (c == 5 and c == 11) then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 6 and (c == 7 or c == 8 or c == 9) then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end
            if l == 7 and c == 8 then
                bricks.levels[3][l][c] = 1
                bricks.nbBricks = bricks.nbBricks + 1
            end    
            
        end
    end

end

function collisionBallWithBricks(currentLevel)
    
    for l=1, bricks.nbLines, 1 do
        for c=1, bricks.nbColumns, 1 do
            if currentLevel[l][c] == 1 then

                -- collision from bottom and only from bottom
                if ball.y - ball.radius <= (l * bricks.height) + border.top.height and ball.y + ball.radius >= (l * bricks.height) + border.top.height then 
                    -- check if the center of the ball is between left and right side of the brick
                    if ball.x >= ((bricks.width * c) + border.left.width) - bricks.width and ball.x <= (c * bricks.width) + border.right.width then
                        audio.collisionSong:play() 
                        currentLevel[l][c] = 0
                        bricks.nbBricks = bricks.nbBricks - 1
                        ball.vy = 0 - ball.vy
                        if bricks.nbBricks == 0 then
                            screen.current = "victory"
                        end
                    end
                end

                -- collision from top and only from top
                if ball.y + ball.radius >= ((l * bricks.height) - bricks.height) + border.top.height and ball.y - ball.radius <= ((l * bricks.height) - bricks.height) + border.top.height then 
                    -- check if the center of the ball is between left and right side of the brick
                    if ball.x >= ((bricks.width * c) + border.left.width) - bricks.width and ball.x <= (c * bricks.width) + border.right.width then
                        audio.collisionSong:play()
                        currentLevel[l][c] = 0
                        bricks.nbBricks = bricks.nbBricks - 1
                        ball.vy = 0 - ball.vy
                        if bricks.nbBricks == 0 then
                            screen.current = "victory"
                        end                    
                    end
                end

                -- collision from left side and only from left side
                if ball.x + ball.radius >= ((c * bricks.width) - bricks.width) + border.left.width and ball.x - ball.radius <= ((c * bricks.width) - bricks.width) + border.right.width then 
                    -- check if the center of the ball is between top and bot of the brick
                    if ball.y >= ((l * bricks.height) - bricks.height) + border.top.height and ball.y <= (l * bricks.height) + border.top.height then
                        audio.collisionSong:play()
                        currentLevel[l][c] = 0
                        bricks.nbBricks = bricks.nbBricks - 1
                        ball.vx = 0 - ball.vx
                        if bricks.nbBricks == 0 then
                            screen.current = "victory"
                        end
                    end
                end
                
                if ball.x - ball.radius <= (c * bricks.width) + border.left.width and ball.x + ball.radius >= (c * bricks.width) + border.right.width then -- collision from right side and only from right side
                    if ball.y >= ((l * bricks.height) - bricks.height) + border.top.height and ball.y <= (l * bricks.height) + border.top.height then -- check if the center of the ball is between top and bot of the brick
                        audio.collisionSong:play()
                        currentLevel[l][c] = 0
                        bricks.nbBricks = bricks.nbBricks - 1
                        ball.vx = 0 - ball.vx
                        if bricks.nbBricks == 0 then
                            screen.current = "victory"
                        end
                    end
                end
                                                                            
            end
        end
    end

end