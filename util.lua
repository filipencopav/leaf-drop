local M = {}

M.print_centered = function (text, x, y, r, sx, sy, kx, ky)
   local font = love.graphics.getFont()
   local fw = font:getWidth(text)
   local fh = font:getHeight()
   love.graphics.print(text, x, y, r, sx, sy, fw/2, fh/2, kx, ky)
end

M.print_centered_with_rect_bg = function (text, x, y, r, sx, sy, kx, ky, text_color)
   local font = love.graphics.getFont()
   local fw = font:getWidth(text)
   local fh = font:getHeight()
   love.graphics.rectangle('fill', x - (fw*sx)/2, y - (fh*sy)/2, fw*sx, fh*sy)
   if text_color then love.graphics.setColor(text_color) end
   love.graphics.print(text, x, y, r, sx, sy, fw/2, fh/2, kx, ky)
end

M.clamp = function (num, lower, upper)
   if num < lower then return lower end
   if num > upper then return upper end
   return num
end

M.test_collision_dot_rect = function (dot_x, dot_y, rect_x, rect_y, rect_w, rect_h)
   local val = dot_x > rect_x
      and dot_x < (rect_x + rect_w)
      and dot_y > rect_y
      and dot_y < (rect_y + rect_h)
   return val
end

M.test_collision_dot_circle = function (dot_x, dot_y, circle_x, circle_y, radius)
   local x = dot_x - circle_x
   local y = dot_y - circle_y
   local dist = math.sqrt(x*x + y*y)
   return dist <= radius
end

M.test_circles_collide = function (x1, y1, r1, x2, y2, r2)
   local x = x1 - x2
   local y = y1 - y2
   return math.sqrt(x*x + y*y) <= r1 + r2
end

return M
