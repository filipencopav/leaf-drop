local M = {
   npcs = {}
}

local const   = require 'constants'
local util    = require 'util'
local animate = require 'lib.animate'

local character = const.character
local clamp = util.clamp
local npc_count = 35
local speed = const.speed

local update = function (self, dt)
   if self.timer <= 0 then
      if math.random(100) > 80 then
         x = math.random(-1, 1)
         y = math.random(-1, 1)
         self.timer = 3

         local len = math.sqrt(x*x + y*y)
         len = len ~= 0 and len or 1
         x = x/len
         y = y/len

         self.direction.x = x
         self.direction.y = y
      else
         self.timer = 1
      end
   end

   self.sprite:update(dt)
   self.x = clamp(self.x + self.direction.x * speed * dt, character.radius,
                  const.window_width - character.radius)
   self.y = clamp(self.y + self.direction.y * speed * dt, character.radius,
                  const.window_height - character.radius)
   self.timer = self.timer - dt
end

local draw = function (self)
   love.graphics.push()
   love.graphics.scale(const.scale)
   self.sprite:drawFrameCentered(self.x/const.scale, self.y/const.scale)
   love.graphics.pop()
end

M.get_decoy = function(self)
   for i, v in ipairs(self.npcs) do
      return table.remove(self.npcs, i)
   end
end

M.colormix = function(self)
   for _, npc in ipairs(self.npcs) do
      npc.sprite = animate('res/umbrellas.png', math.random(0, 3)*32,  0, 32, 32, 1, 0)
   end
end

M.clear = function(self)
   self.npcs = {}
   for i=1,npc_count do
      local new = {
         x = math.random(const.goal_radius*2,
                         const.window_width - const.goal_radius*2),
         y = math.random(const.goal_radius*2,
                         const.window_height - const.goal_radius*2),
         sprite = animate('res/umbrellas.png', math.random(0, 3)*32,  0, 32, 32, 1, 0),
         timer = math.random(),
         direction = { x = 0, y = 0 },
         update = update,
         draw = draw,
      }
      table.insert(self.npcs, new)
   end
end

M.update = function(self, dt)
   for _, npc in ipairs(self.npcs) do
      npc:update(dt)
   end
end

M.draw = function(self, dt)
   for _, npc in ipairs(self.npcs) do
      npc:draw()
   end
end

M.handle_shot = function (self, x, y)
   for i, npc in ipairs(self.npcs) do
      if util.test_collision_dot_circle(x, y, npc.x, npc.y, character.radius)
      then
         table.remove(self.npcs, i)
      end
   end
end

return M
