VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
-- virtual resolution by making it look `old`

PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
PADDLE_SPEED = 140

BALL_SIZE = 4

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)

push = require 'push'
-- take the content of the push file and assign it to the var

player1 = {
    x = 10, y = 10, score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - 10 - PADDLE_WIDTH, y = VIRTUAL_HEIGHT - 10 - PADDLE_HEIGHT, score = 0
    --recall that rectangle gets drawn from the left up angle
}

ball = {
    x = VIRTUAL_WIDTH/2 - BALL_SIZE/2,
    y = VIRTUAL_HEIGHT/2 - BALL_SIZE/2,
    dx = 0, dy = 0
}

gameState = 'title'
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)

    resetBall()
end 

function love.update(dt)
    -- dt - delta time -> how much time passed between previous and last frame. dt depends on a computer 
    if love.keyboard.isDown('w') then -- if we keep holding `w` key
        player1.y = player1.y - PADDLE_SPEED * dt -- going up
    elseif love.keyboard.isDown('s') then
        player1.y = player1.y + PADDLE_SPEED * dt -- going down 
    end 

    if love.keyboard.isDown('up') then 
        player2.y = player2.y - PADDLE_SPEED * dt -- going up
    elseif love.keyboard.isDown('down') then 
        player2.y = player2.y + PADDLE_SPEED * dt -- going down 
    end 

    if gameState == 'play' then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Ball passing through the left edge
        if ball.x <= 0 then
            player2.score = player2.score + 1
            resetBall()
            gameState = 'serve' --for catching breath 

        -- Ball passing through the right edge
        elseif ball.x >= VIRTUAL_WIDTH - BALL_SIZE then
            player1.score = player1.score + 1
            resetBall()
            gameState = 'serve' --for catching breath 
        end

        if ball.y <= 0 or ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.dy = -ball.dy
        end

        if collides(player1, ball) then 
            ball.dx = -ball.dx
            ball.x = player1.x + PADDLE_WIDTH
        elseif collides(player2, ball) then
            ball.dx = -ball.dx
            ball.x = player2.x - BALL_SIZE
        end 

    end 
end

function love.keypressed(key) -- input
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'title' then 
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        end 
        
    end 
    --executes once 
end 

function love.draw() -- rendering + love.draw is called every frame after love.update
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 1)

    if gameState == 'title' then 
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Pre50 Pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH,'center')
    end 

    if gameState == 'serve' then 
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter to serve!', 0, 10, VIRTUAL_WIDTH,'center')
    end
    
    love.graphics.rectangle('fill', player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)

    love.graphics.setFont(LARGE_FONT)
    love.graphics.print(player1.score, VIRTUAL_WIDTH/2 - 36, VIRTUAL_HEIGHT/2 - 16)
    love.graphics.print(player2.score, VIRTUAL_WIDTH/2 + 16, VIRTUAL_HEIGHT/2 - 16)

    love.graphics.setFont(SMALL_FONT) -- just to be on the safe side 
    push:finish()
 end

function collides(paddle, ball)
    return not(paddle.x > ball.x + BALL_SIZE or paddle.y > ball.y + BALL_SIZE or ball.x > paddle.x + PADDLE_WIDTH or ball.y > paddle.y + PADDLE_HEIGHT)
end

 function resetBall()
    ball.x = VIRTUAL_WIDTH/2 - BALL_SIZE/2 -- go to the default location of a ball
    ball.y = VIRTUAL_HEIGHT/2 - BALL_SIZE/2

    ball.dx = 60 + math.random(60) -- to make faster
    if math.random(2) == 1 then --flipping the coin
        ball.dx = -ball.dx
    end 

    ball.dy = 30 + math.random(60) -- to make faster
    if math.random(2) == 1 then
        ball.dy = -ball.dy
    end 
end