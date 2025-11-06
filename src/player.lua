utils = require("src.utils")
player = {}

function player.new_player(x, y)
    local p = {
        x = x,
        y = y,
        vx = 0, -- componente x de vector
        vy = 0, -- = y
        accel = 0.05,
        friction = 0.98,
        rotation_deg = 0,
        shoot_cooldown = 15, -- 1/4 de segundo
        counter = 0,
        bbox = hc.rectangle(0, 0, 6, 6),
        type = utils.object_types.PLAYER
    }

    function p:init()
        self.bbox.owner = self
        self.sprite = player_sprite
    end

    function p:update()
        --decrementar el contador
        if self.counter > 0 then
            self.counter = self.counter - 1
        end

        local move_right = love.keyboard.isDown("right")
        local move_left = love.keyboard.isDown("left")
        local move_up = love.keyboard.isDown("up")
        local shoot_button = love.keyboard.isDown("space")

        if move_right then
            self.rotation_deg = self.rotation_deg + 5
        end

        if move_left then
            self.rotation_deg = self.rotation_deg - 5
        end

        if move_up then
            self.vx = self.vx + math.cos(math.rad(self.rotation_deg)) * self.accel
            self.vy = self.vy + math.sin(math.rad(self.rotation_deg)) * self.accel
        end

        -- disparar
        if shoot_button and self.counter <= 0 then
            -- asignamos el contador
            self.counter = self.shoot_cooldown

            if self.on_shoot then
                local angle = self.rotation_deg + math.random(-10, 10)
                self.on_shoot(self.x, self.y, math.rad(angle))
            end
        end

        --deaccelerate
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction

        --apply velocity
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        --mover colisiones
        if self.bbox ~= nil then
            self.bbox:moveTo(self.x,self.y)
            self.bbox:setRotation(math.rad(self.rotation_deg), self.x, self.y)
        end

        --screen wrapping
        utils.screen_wrap(self)
    end

    function p:draw()
        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)

        if self.bbox ~= nil then
            utils.debug_draw(self.bbox)
        end
    end

    return p
end

return player