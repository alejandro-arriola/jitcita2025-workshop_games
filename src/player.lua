utils = require("src.utils")
player = {}

function player.new_player(x, y)
    local p = {
        x = x;
        y = y;
        vx = 0; -- component x of velocity
        vy = 0; -- component y of velocity
        accel = 0.05;
        friction = 0.98;
        rotation_deg = 0,
        nombre = "pancho"
    }

    function p:init()
        self.sprite = player_sprite
    end

    function p:update()
        local move_right = love.keyboard.isDown("right")
        local move_left = love.keyboard.isDown("left")
        local move_up = love.keyboard.isDown("up")

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

        --deaccelerate
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction

        --apply velocity
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        --screen wrapping
        utils.screen_wrap(self)
    end

    function p:draw()
       utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true) 
    end

    return p
end

return player