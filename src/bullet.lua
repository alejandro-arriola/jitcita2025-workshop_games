utils = require("src.utils")

--MODULO
bullet = {}

function bullet.new_bullet(x, y, rotation_rad)
    --CLASE
    local b = {
        x = x,
        y = y,
        rotation_rad = rotation_rad,
        accel = 5.0,
        vx = 0,
        vy = 0,
        bbox = hc.rectangle(0, 0, 8, 4)
    }

    function b:init()
        self.vx = math.cos(self.rotation_rad) * self.accel
        self.vy = math.sin(self.rotation_rad) * self.accel
    end

    function b:update(dt)
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        if self.bbox == nil then
            self.bbox.moveTo(self.x, self.y)
            self.bbox.setRotation(self.rotation_rad, self.x, self.y)
        end
    end

    function b:draw()
        utils.draw_sprite(bullet_sprite, self.x, self.y, self.rotation_rad, 1, 1, true) 
    end

    return b
end

return bullet