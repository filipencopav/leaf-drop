local spy = {}
local const   = require 'constants'
local util    = require 'util'
local animate = require 'lib.animate'

local char = const.character

spy.speed = const.speed

spy.update = function (self, dt)
   local x = 0
   local y = 0

   local isDown = love.keyboard.isDown

   if isDown("left") then
      x = -1
   elseif isDown("right") then
      x = 1
   end

   if isDown("up") then
      y = -1
   elseif isDown("down") then
      y = 1
   end

   if not self.ability_used then
      if isDown("space") or (self.joystick and self.joystick:isGamepadDown('a'))
      then
         self.ability_used = true
         self:use_ability()
      end
   end

   if self.joystick then
      if self.joystick:isGamepadDown("dpleft") then
         x = -1
      elseif self.joystick:isGamepadDown("dpright") then
         x = 1
      end

      if self.joystick:isGamepadDown("dpup") then
         y = -1
      elseif self.joystick:isGamepadDown("dpdown") then
         y = 1
      end
   end

   local len = math.sqrt(x*x + y*y)
   len = len ~= 0 and len or 1
   x = x/len
   y = y/len

   self.x = util.clamp(self.x + x * self.speed * dt, const.character.radius,
                       const.window_width - const.character.radius)
   self.y = util.clamp(self.y + y * self.speed * dt, const.character.radius,
                       const.window_height - const.character.radius)
end

spy.draw = function (self)
   local scale = const.scale
   love.graphics.push()
   love.graphics.scale(scale)
   self.sprite:drawFrameCentered(self.x/scale, self.y/scale)
   love.graphics.pop()
end

spy.clear = function (self, ability)
   self.sprite = animate('res/umbrellas.png', (math.random(4)-1)*32,  0, 32, 32, 1, 0)
   self.x = math.random(const.goal_radius*2,
                        const.window_width - const.goal_radius*2)
   self.y = math.random(const.goal_radius*2,
                        const.window_height - const.goal_radius*2)
   self.ability = ability
   self.ability_used = false
end

spy.register_joystick = function (self, joystick)
   self.joystick = joystick
end

spy.change_up = function (self, decoy)
   self.sprite = decoy.sprite
   self.x = decoy.x
   self.y = decoy.y
end

spy.colormix = function (self)
   self.sprite = animate('res/umbrellas.png', math.random(0, 3)*32,  0, 32, 32, 1, 0)
end

spy.use_ability = function(self)
   if self.ability == 'flashbang' then
      game:flashbang()
   elseif self.ability == 'smokescreen' then
      game:smokescreen(self.x, self.y)
   elseif self.ability == 'colormix' then
      game:colormix()
   elseif self.ability == 'decoy' then
      self:change_up(game:get_decoy())
   end
end

return spy
