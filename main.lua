utils = require("src.utils")
player = require("src.player")
asteroid = require("src.asteroid")

--globals
screen_width, screen_height = 128, 128

--love.run override to lock game to 60 fps
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    
    -- Fixed timestep variables
    local fps = 60
    local frame_time = 1 / fps
    local lag = 0
    local last_time = love.timer.getTime()
    
    -- We don't want the first frame's dt to include time taken by love.load
    if love.timer then love.timer.step() end
    
    -- Main loop - return a function that gets called each frame
    return function()
        -- Calculate delta time
        local now = love.timer.getTime()
        local dt = now - last_time
        last_time = now
        
        -- Cap dt to prevent "spiral of death"
        if dt > 0.25 then
            dt = 0.25
        end
        
        lag = lag + dt
        
        -- Process events
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end
        
        -- Update at fixed timestep
        while lag >= frame_time do
            if love.update then
                love.update(frame_time)
            end
            lag = lag - frame_time
        end
        
        -- Draw
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            
            if love.draw then
                love.draw()
            end
            
            love.graphics.present()
        end
        
        -- Lock framerate
        local elapsed = love.timer.getTime() - now
        if elapsed < frame_time then
            love.timer.sleep(frame_time - elapsed)
        end
    end
end

function love.load()
    --setup window
    love.window.setMode(screen_width, screen_height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = 512,
        minheight = 512
    })

    --scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)

    player_sprite = utils.load_sprite("ship")
    Player = player.new_player(screen_width / 2, screen_height / 2)
    Player:init()

    asteroid_small_sprite = utils.load_sprite("asteroid_small")
    asteroid_medium_sprite = utils.load_sprite("asteroid_medium")
    asteroid_large_sprite = utils.load_sprite("asteroid_large")

    --definir asteroide
    Asteroid = asteroid.new_asteroid(20, 20, asteroid.sizes.LARGE)
    Asteroid:init()
end

function love.update(dt)
    Player:update()
    Asteroid:update()
end

function love.draw()
    local win_w, win_h = love.graphics.getDimensions()
    local scale_x = win_w / screen_width
    local scale_y = win_h / screen_height

    -- uniform scaling (preserves aspect ratio, no stretching)
    local scale = math.min(scale_x, scale_y)

    --start drawing
    love.graphics.push()
    love.graphics.scale(scale, scale)

    -- center the game world in the window
    local offset_x = (win_w/scale - screen_width) / 2
    local offset_y = (win_h/scale - screen_height) / 2

    love.graphics.translate(offset_x, offset_y)

    --aca se dibuja el mundo
    Player:draw()
    Asteroid:draw()

    --stop drawing
    love.graphics.pop()
end