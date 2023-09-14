local target = {}

local const = require 'constants'
local util = require 'util'
local animate = require 'lib.animate'

local random = math.random
local speed = const.speed
local character = const.character
local clamp = util.clamp
local death_radius = 100

target.clear = function(self)
   self.x = random(const.window_width)
   self.y = random(const.window_height)
   self.direction = { x = 0, y = 0 }
   self.timer = random()
   self.death_timer = 5
   self.is_dead = false
   self.is_marked_for_execution = false
   self.sprite = animate(const.char_sprites[1], 32*4, 0, 32, 32, 1, 0)
end

target.draw = function(self)
   if not self.is_dead then
      local scale = const.scale
      love.graphics.setColor(1, 1, 1)
      love.graphics.push()
      love.graphics.scale(scale)
      self.sprite:drawFrameCentered(self.x/scale, self.y/scale)
      love.graphics.pop()
      love.graphics.setColor(1, 1, 0)
      util.print_centered('target', self.x,
                          self.y - character.radius*2, 0, 0.5, 0.5)
   end
end

target.update = function(self, dt)
   if not self.is_dead then
      if self.timer <= 0 then
         if math.random(100) > 80 then
            self.direction.x = random() - 0.5
            self.direction.y = random() - 0.5
            self.timer = random(1, 3)
         else
            self.direction.x = 0
            self.direction.y = 0
            self.timer = 1
         end
      end

      self.x = clamp(self.x + self.direction.x * speed * dt, 0, const.window_width - character.width)
      self.y = clamp(self.y + self.direction.y * speed * dt, 0, const.window_height - character.height)
      self.timer = self.timer - dt

      if self.is_marked_for_execution then
         self.death_timer = self.death_timer - dt
         if self.death_timer <= 0 then
            self.is_dead = true
         end
      end
   end
end

target.handle_spy_pos = function(self, sx, sy)
   if not self.is_marked_for_execution then
      self.is_marked_for_execution = util.test_circles_collide(sx, sy,
                                                               character.radius,
                                                               self.x,
                                                               self.y,
                                                               death_radius)
   end
end

return target
