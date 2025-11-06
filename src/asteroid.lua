asteroid = {}
utils = require("src.utils")

asteroid.sizes = {
    SMALL = "SMALL",
    MEDIUM = "MEDIUM",
    LARGE = "LARGE"
}

function asteroid.new_asteroid(x, y, size)
    local a = {
        x = x,
        y = y,
        size = size,
        rotation_deg = 0,
        flag_for_deletion = false,
        type = utils.object_types.ASTEROID,
        speed = 0.5,
    }

    function a:init()
        self.rotation_deg = math.random(0, 359)

        self.vx = math.cos(math.rad(self.rotation_deg)) * self.speed
        self.vy = math.sin(math.rad(self.rotation_deg)) * self.speed

        if self.size == asteroid.sizes.LARGE then
            self.sprite = asteroid_large_sprite
            self.bbox = hc.circle(self.x, self.y, 5)
            self.points = 30
        end

        if self.size == asteroid.sizes.MEDIUM then
            self.sprite = asteroid_medium_sprite
            self.bbox = hc.circle(self.x, self.y, 4)
            self.points = 20
        end

        if self.size == asteroid.sizes.SMALL then
            self.sprite = asteroid_small_sprite
            self.bbox = hc.circle(self.x, self.y, 2)
            self.points = 10
        end

        self.bbox.owner = self
    end

    function a:update()
        if self.flag_for_deletion then
            return
        end

        self.rotation_deg = self.rotation_deg + 3

        self.x = self.x + self.vx
        self.y = self.y + self.vy

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x,self.y)
        end

        utils.screen_wrap(self)
    end

    function a:draw()
        if self.flag_for_deletion then
            return
        end

       utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)

        if self.bbox ~= nil then
            utils.debug_draw(self.bbox)
        end
    end

    function a:take_damage()
        self.flag_for_deletion = true

        --aca vamos a correr efectos visuales
        if self.explosion then
            self.explosion(self.x, self.y)
        end

        --aumentamos puntos del jugador
        score = score + self.points
    end

    return a
end

return asteroid