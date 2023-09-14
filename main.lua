local Gamestate = require 'lib.hump.gamestate'
require 'start'
require 'game'
require 'end'
local audio = require 'audio'
local mus

function love.load ()
   math.randomseed(os.time())
   Gamestate.registerEvents()
   Gamestate.switch(start, Gamestate)

   mus = love.audio.newSource('res/01.wav', 'stream')
   mus:setLooping(true)
   mus:play()
   mus:setVolume(0.1)
   love.mouse.setVisible(false)
   love.graphics.setDefaultFilter('nearest', 'nearest', 0)
end
