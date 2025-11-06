utils = require("src.utils")
player = require("src.player")
asteroid = require("src.asteroid")
bullet = require("src.bullet")
particle = require("src.particle")

--globals
screen_width, screen_height = 128, 128
debug_draw = false
score = 0

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

    --callback
    function shoot_bullet(x, y, rotation)
        local b = bullet.new_bullet(x, y, rotation)
        b:init()
        table.insert(bullets, b)
    end

    Player.on_shoot = shoot_bullet

    asteroid_small_sprite = utils.load_sprite("asteroid_small")
    asteroid_medium_sprite = utils.load_sprite("asteroid_medium")
    asteroid_large_sprite = utils.load_sprite("asteroid_large")

    bullet_sprite = utils.load_sprite("bullet_2")

    --definir lista de asteroides
    asteroids = {}
    -- definir lista de balas
    bullets = {}
    -- definir lista de particulas
    particles = {}

    -- solo para test
    local a1 = asteroid.new_asteroid(20, 20, asteroid.sizes.LARGE)
    a1:init()
    table.insert(asteroids, a1)
    local a2= asteroid.new_asteroid(20, 40, asteroid.sizes.MEDIUM)
    a2:init()
    table.insert(asteroids, a2)
    local a3 = asteroid.new_asteroid(20, 60, asteroid.sizes.SMALL)
    a3:init()
    table.insert(asteroids, a3)
end

function love.update(dt)
    Player:update()

    if love.keyboard.isDown("z") then
        create_explosion()
    end

    utils.check_all_collisions()

    -- actualizar asteroides
    for i = #asteroids, 1, -1 do
        local current_asteroid = asteroids[i]
        if (current_asteroid.flag_for_deletion) then
            hc.remove(current_asteroid.bbox)
            table.remove(asteroids, i)
        else
            current_asteroid:update()
        end
    end

    -- actualizar balas
    for i = #bullets, 1, -1 do
        local current_bullet = bullets[i]
        if (current_bullet:is_offscreen()) then
            if current_bullet.bbox then
                hc.remove(current_bullet.bbox)
            end 
            table.remove(bullets, i)
        else
            current_bullet:update()
        end
    end

    -- actualizar particulas
    for i = #particles, 1, -1 do
        local current_particle = particles[i]
        if current_particle.flag_for_deletion then
            table.remove(particles, i)
        else
            current_particle:update()
        end
    end

    if #asteroids == 0 then
        spawn_asteroid()
    end
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

    -- dibujar asteroides
    for i = #asteroids, 1, -1 do
        local current_asteroid = asteroids[i]
        current_asteroid:draw()
    end

    -- dibujar balas
    for i = #bullets, 1, -1 do
        local current_bullet = bullets[i]
        current_bullet:draw()
    end

    for i = #particles, 1, -1 do
        local current_particle = particles[i]
        current_particle:draw()
    end

    utils.set_draw_color(utils.colors.RED)
    love.graphics.print(score, 10, 10)
    utils.reset_draw_color()

    --stop drawing
    love.graphics.pop()
end

function create_explosion(x, y)
    for i = 1, 20, 1 do
        create_particle(x, y)
    end
end

function create_particle(x, y)
    local part = particle.new_particle(x, y)
    part:init()
    table.insert(particles, part)
end

function spawn_asteroid()
    for i = 1, 5, 1 do
        local a = asteroid.new_asteroid(20, 20, asteroid.sizes.LARGE)
        a:init()
        a.explosion = create_explosion
        table.insert(asteroids, a)
    end
end