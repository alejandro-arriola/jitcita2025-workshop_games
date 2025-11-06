utils = require("src.utils")

particle = {}

function particle.new_particle(x, y)
    local p = {
        x = x,
        y = y,
        lifetime = 5,
        flag_for_deletion = false,
        radius = math.random(2,4),
        possible_colors = {
            utils.colors.DARKGREY,
            utils.colors.ORANGE,
            utils.colors.YELLOW, 
            utils.colors.WHITE, 
        },
    }

    function p:init()
        self.rotation_rad = math.rad(math.random(359))
        self.speed_x = love.math.random(1, 2)
        self.speed_y = love.math.random(1, 2)

        self.vx = math.cos(self.rotation_rad) * self.speed_x
        self.vy = math.sin(self.rotation_rad) * self.speed_y
    end

    function p:update()
        -- logica de actualizacion de particula
        if self.lifetime > 0 then
            self.lifetime = self.lifetime - 0.1
        else
            self.flag_for_deletion = true
        end

        self.color_index = math.random(1, math.floor(self.lifetime))

        if self.radius > 0 then
            self.radius = self.radius - 0.1

            self.x = self.x + self.speed_x
            self.y = self.y + self.speed_y
        end
    end

    function p:draw()
        if self.radius > 0 then
            if self.color_index then
                utils.set_draw_color(self.possible_colors[self.color_index])
            end

            love.graphics.circle("fill", self.x, self.y, self.radius)
            utils.reset_draw_color()
        end
    end

    return p
end

return particle