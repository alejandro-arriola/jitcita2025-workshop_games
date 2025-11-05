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
        rotation_deg = 0
    }

    function a:init()
        self.rotation_deg = math.random(0, 359)
        if self.size == asteroid.sizes.LARGE then
            self.sprite = asteroid_large_sprite
        end

        if self.size == asteroid.sizes.MEDIUM then
            self.sprite = asteroid_medium_sprite
        end

        if self.size == asteroid.sizes.SMALL then
            self.sprite = asteroid_small_sprite
        end
    end

    function a:update()
        self.rotation_deg = self.rotation_deg + 3
    end

    function a:draw()
       utils.draw_sprite(asteroid_large_sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)
    end

    return a
end

return asteroid