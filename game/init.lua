game = {}
local util = require 'util'
local font = require 'font'
local const = require 'constants'
local animate = require 'lib.animate'

local character = const.character
local bg_color = { 0, 0.11, 0 }
game.sniper = require 'game.sniper'
game.spy = require 'game.spy'
game.npcs = require 'game.npc'
game.target = require 'game.target'
game.goals = require 'game.goals'
local initial_timer = 240

function game:get_decoy()
   return self.npcs:get_decoy()
end

function game:flashbang()
   self.fb.active = true
end

function game:smokescreen(x, y)
   self.smk.active = true

   for i=0,20 do
      local part = {
         sprite = animate('res/smoke.png', 0, 0, 32, 32),
         x = math.random(x - 300, x + 300),
         y = math.random(y - 300, y + 300),
         rotation = math.random(-2, 2)
      }
      local scale = math.random(const.scale*1, const.scale*2.5)
      part.sprite:setScale(scale, scale)
      table.insert(self.smk.particles, part)
   end
end

function game:colormix()
   self.clr.active = true
   self.clr.timeout = 5
   self.clr.timer = 0
end

function game:enter(old, gamestate_handle, spy_choice, sniper_choice)
   love.graphics.setDefaultFilter('nearest', 'nearest', 0)
   local player_joystick = love.joystick.getJoysticks()[1]
   self.bg = love.graphics.newImage('res/bg-game.png')
   self.npcs:clear()
   self.spy:clear(spy_choice)
   self.spy:register_joystick(player_joystick)
   self.sniper:clear(sniper_choice)
   self.target:clear()
   self.goals:clear()
   self.timer = initial_timer
   self.gamestate_handle = old.gamestate_handle

   self.fb = {
      active = false,
      timer = 3,
      fade = 1,
   }

   self.smk = {
      active = false,
      in_fade = 0,
      timer = 3,
      out_fade = 1,
      particles = {},
      c = {
         1,
         1,
         1,
         1,
      }
   }

   self.clr = {
      active = false,
      timeout = 5,
      timer = 0.25,
      initial_timer = 0.25
   }
end

function game:update(dt)
   love.graphics.clear(0, 0, 0)

   self.sniper:update(dt)
   self.spy:update(dt)
   self.npcs:update(dt)
   self.target:update(dt)
   self.goals:update(dt)
   self.timer = self.timer - dt

   -----
   if self.sniper.ammo <= 0
      or self.target.is_dead and self.goals:expired_all()
   then
      return self.gamestate_handle.switch(game_end, 'spy wins', the_start)
   end

   if self.timer <= 0 then
      return self.gamestate_handle.switch(game_end, 'time out. sniper wins', the_start)
   end

   self.target:handle_spy_pos(self.spy.x, self.spy.y)
   self.goals:handle_spy_pos(self.spy.x, self.spy.y)

   const.window_width = love.graphics.getWidth()
   const.window_height = love.graphics.getHeight()

   if self.fb.active then
      self.fb.timer = self.fb.timer - dt
      if self.fb.timer <= 0 then
         self.fb.fade = self.fb.fade - dt
      end
      if self.fb.fade <= 0 then
         self.fb.active = false
      end
   end

   if self.smk.active then
      for _, p in ipairs(self.smk.particles) do
         p.sprite:rotate(dt*p.rotation)
      end

      self.smk.in_fade = self.smk.in_fade + dt
      self.smk.c[4] = self.smk.in_fade
      if self.smk.in_fade >= 1 then
         self.smk.c[4] = self.smk.out_fade
         self.smk.timer = self.smk.timer - dt
         if self.smk.timer <= 0 then
            self.smk.out_fade = self.smk.out_fade - dt
         end
      end
      if self.smk.out_fade <= 0 then
         self.smk.active = false
      end
   end

   if self.clr.active then
      if self.clr.timeout <= 0 then
         self.clr.active = false
      end

      if self.clr.timer <= 0 then
         self.clr.timer = self.clr.initial_timer
         self.npcs:colormix()
         self.spy:colormix()
      end

      self.clr.timer = self.clr.timer - dt
      self.clr.timeout = self.clr.timeout - dt
   end
end

local g = love.graphics
function game:draw()
   g.clear(bg_color)

   g.setColor(1, 1, 1, 1)
   g.push()
   g.scale(4)
   g.draw(self.bg, 0, 0)
   g.pop()

   self.goals:draw()
   self.spy:draw()
   self.npcs:draw()
   self.target:draw()
   self.sniper:draw()

   util.print_centered(string.format('%d:%.f', self.timer/60, self.timer%60),
                       const.window_width/2,
                       50,
                       0,
                       0.5)

   if self.fb.active then
      g.setColor(1, 1, 1, self.fb.fade)
      g.rectangle('fill', 0, 0, const.window_width, const.window_height)
   end

   if self.smk.active then
      g.setColor(self.smk.c)
      for _, p in ipairs(self.smk.particles) do
         p.sprite:drawFrameCentered(p.x, p.y)
      end
   end
end

function game:mousepressed(x, y, button)
   if button == 1 then
      self.sniper:handle_shot()

      if util.test_collision_dot_circle(x, y,
                                        self.spy.x, self.spy.y,
                                        character.radius)
      then
         return self.gamestate_handle.switch(game_end, 'sniper wins', the_start)
      end

      self.npcs:handle_shot(x, y)
   end
end

function game:wheelmoved (_, y)
   self.sniper:handle_wheelmove(nil, y)
end

return game
