local sniper = {}
local font = require 'font'
local util = require 'util'
local audio = require 'audio'

local initial_ammo = 5
sniper.ammo = initial_ammo

local crosshair = {
   line_color = { 1, 1, 1 },
   dot = {
      color = { 1, 0, 0 },
      width = 10,
   },
   radius = 160,
   line_width = 2,
   max_radius = 300,
   min_radius = 10,
   x = 0,
   y = 0,
}

sniper.clear = function(self)
   self.ammo = initial_ammo
end

sniper.update = function(self)
   crosshair.x = love.mouse.getX()
   crosshair.y = love.mouse.getY()
end

sniper.draw = function(self)
   love.graphics.setColor(crosshair.dot.color)
   love.graphics.rectangle('fill', crosshair.x - crosshair.dot.width/2, crosshair.y - crosshair.dot.width/2, crosshair.dot.width,
                           crosshair.dot.width)
   love.graphics.setColor(crosshair.line_color)
   love.graphics.setLineWidth(crosshair.line_width)
   love.graphics.circle('line', crosshair.x, crosshair.y, crosshair.radius)

   love.graphics.setFont(font)
   util.print_centered(self.ammo, 30, 40, 0, 0.5, 0.5)
end

sniper.handle_wheelmove = function (self, _, y)
   local new = crosshair.radius - y * 5
   crosshair.radius = new < crosshair.max_radius and new or crosshair.max_radius
   crosshair.radius = crosshair.radius > crosshair.min_radius and crosshair.radius or crosshair.min_radius
end

sniper.handle_shot = function (self)
   self.ammo = self.ammo - 1
   audio.shot:stop()
   audio.shot:play()
end

return sniper
