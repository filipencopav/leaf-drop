local M = {}

local util = require 'util'
local const = require 'constants'
local animate = require 'lib.animate'

local death_radius = const.goal_radius
local targets = {}

local new_target = function(x, y)
   local new = {
      x = x,
      y = y,
      sprite = animate('res/umbrellas.png', 5*32,  0, 32, 32, 1, 0),
      death_timer = 5,
      is_marked = false,
      radius = 32,
   }

   new.handle_spy_pos = function(self, sx, sy)
      if not self.is_marked then
         self.is_marked = util.test_circles_collide(sx, sy,
                                                    const.character.radius,
                                                    self.x,
                                                    self.y,
                                                    death_radius)
      end
   end
   new.update = function (self, dt)
      self.sprite:rotate(dt)
      if self.is_marked then
         self.death_timer = self.death_timer - dt
      end
      self.x = util.clamp(self.x, death_radius, const.window_width - death_radius)
      self.y = util.clamp(self.y, death_radius, const.window_height - death_radius)
   end

   new.expired = function (self)
      return self.death_timer <= 0
   end

   new.draw = function (self)
      love.graphics.setColor(1, 1, 1, 0.2)
      love.graphics.circle('fill', self.x, self.y, death_radius)
      love.graphics.setColor(1, 1, 1)
      love.graphics.push()
      local scale = const.scale
      love.graphics.scale(scale)
      self.sprite:drawFrameCentered(self.x/scale, self.y/scale)
      love.graphics.pop()
   end

   return new
end

M.clear = function(self)
   targets = {}
   local rad = death_radius
   local wh = const.window_height
   local ww = const.window_width
   table.insert(targets, new_target(rad, wh - rad))
   table.insert(targets, new_target(rad, rad))
   table.insert(targets, new_target(ww - rad, wh - rad))
   table.insert(targets, new_target(ww - rad, rad))
end

M.update = function(self, dt)
   for i, target in ipairs(targets) do
      target:update(dt)
      if target:expired() then
         table.remove(targets, i)
      end
   end
end

M.handle_spy_pos = function(self, sx, sy)
   for _, target in ipairs(targets) do
      target:handle_spy_pos(sx, sy)
   end
end

M.draw = function(self)
   for i, target in ipairs(targets) do
      target:draw()
   end
end

M.expired_all = function(self)
   for _, target in ipairs(targets) do
      if not target:expired() then return false end
   end
   return true
end

return M
