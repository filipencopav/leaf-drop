start = {}

-- lib imports
local util  = require 'util'
local const = require 'constants'
local font  = require 'font'
local small_font = require 'small_font'

-- imports
local g = love.graphics
local wh = const.window_height
local ww = const.window_width

-- variables
local spy_is_ready = false
local sniper_is_ready = false
local spy_choices = {
   'flashbang',
   'decoy',
   'smokescreen',
   'colormix',
}
local sniper_choices = {
   'default',
   'other',
   'test'
}

local timer = {
   is_started = false,
   time = 1,
}

function len(array)
   local l = 0
   for _, _ in ipairs(array) do
      l = l + 1
   end
   return l
end

function start:spy_select()
   local select_next = function()
      self.spy_choice = (self.spy_choice + 1) % #spy_choices
   end

   local select_previous = function()
      self.spy_choice = (self.spy_choice - 1) % #spy_choices
   end

   local isDown = love.keyboard.isDown
   if isDown('left') then
      select_previous()
   elseif isDown('right') then
      select_next()
   end

   local j = self.spy_joystick
   if j then
      if j:isGamepadDown('a') then
         spy_is_ready = true
      end
      if j:isGamepadDown('x') then
         select_previous()
      elseif j:isGamepadDown('b') then
         select_next()
      end
   end
end

function start:enter(old, gamestate_handle)
   self.spy_joystick = love.joystick.getJoysticks()[1]
   self.spy_choice = 0
   self.sniper_choice = 0
   self.gamestate_handle = gamestate_handle or old.gamestate_handle
   self.start = self
   spy_is_ready = false
   sniper_is_ready = false
   timer.is_started = false
   timer.time = 1
end

function start:draw()
   g.clear(0, 0, 0)
   g.setFont(font)
   util.print_centered(string.format('select ability:\n%d. %s', self.spy_choice+1,
                                     spy_choices[self.spy_choice+1]),
                       const.window_width/10*3,
                       const.window_height/2)
   util.print_centered(string.format('select map:\n%d. %s', self.sniper_choice+1,
                                     sniper_choices[self.sniper_choice+1]),
                       const.window_width/10*7,
                       const.window_height/2)

   g.setFont(small_font)
   g.setColor(1, 0, 0)
   if sniper_is_ready then
      g.setColor(0, 1, 0)
   end

   g.print(string.format('ready%s', sniper_is_ready and '.' or '?'),
           const.window_width - small_font:getWidth('ready?'),
           const.window_height - small_font:getHeight()*2)

   g.setColor(1, 0, 0)
   if spy_is_ready then
      g.setColor(0, 1, 0)
   end

   g.print(string.format('ready%s', spy_is_ready and '.' or '?'), 0,
           const.window_height - small_font:getHeight()*2)

   g.setColor(1, 1, 1)
   g.print('spy', 0, const.window_height - small_font:getHeight())
   g.print('sniper', const.window_width - small_font:getWidth('sniper'),
           const.window_height - small_font:getHeight())
end

function start:update(dt)
   const.window_height = love.graphics.getHeight()
   const.window_width = love.graphics.getWidth()

   if spy_is_ready and sniper_is_ready then
      if not timer.is_started then
         timer.is_started = true
      else
         timer.time = timer.time - dt
      end
   end

   if timer.time <= 0 then
      self.gamestate_handle.switch(game, self.gamestate_handle,
                                   spy_choices[self.spy_choice+1],
                                   sniper_choices[self.sniper_choice+1])
   end
end

function start:keypressed(key)
   self:spy_select()
   if key == 'space' then
      spy_is_ready = true
   end
end

function start:joystickpressed(j, button)
   self:spy_select()
end

function start:wheelmoved(_, y)
   if y > 0 then
      self.sniper_choice = (self.sniper_choice + 1) % #sniper_choices
   elseif y < 0 then
      self.sniper_choice = (self.sniper_choice - 1) % #sniper_choices
   end
end

function start:mousepressed(_, _, button)
   if button == 1 then
      sniper_is_ready = true
   end
end

return start
