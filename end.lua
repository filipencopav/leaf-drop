game_end = {}
local font  = require 'font'
local util  = require 'util'

local window = {
   width = 1920,
   height = 1080,
}

function game_end:enter(old, text, next)
   self.gamestate_handle = old.gamestate_handle
   self.npcs = old.npcs
   self.spy = old.spy
   self.text = text
   self.timer = 2
   self.next = next
end

function game_end:draw()
   love.graphics.setFont(font)
   love.graphics.clear(0, 0, 0)
   self.npcs:draw()
   love.graphics.setColor(0, 0, 0, 0.7)
   love.graphics.rectangle('fill', 0, 0, window.width, window.height)
   love.graphics.setColor(1, 1, 1)
   self.spy:draw()
   util.print_centered(self.text, window.width/2, window.height/2, 0)
end

function game_end:update(dt)
   window.width = love.graphics.getWidth()
   window.height = love.graphics.getHeight()
   self.timer = self.timer - dt
end

function game_end:keyreleased()
   if self.timer <= 0 then
      return self.gamestate_handle.switch(start, self.gamestate_handle)
   end
end

function game_end:joystickpressed(j, b)
   if self.timer <= 0 then
      return self.gamestate_handle.switch(start, self.gamestate_handle)
   end
end

return game_end
