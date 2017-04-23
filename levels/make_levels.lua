local function make_height_map(mission)
   math.randomseed(mission)
   local prev_incline = (math.random(3) - 2) * math.log(mission + 1) * 0.3
   local height = {}
   local prev_height = math.random(mission) + 1
   local max_height = -100
   local min_height = 100
   for i = 1, 17 do
      local inc = (prev_incline + math.random(3) - 2) * math.log(mission + 1) * 0.3
      if prev_incline * inc < 0 then
         inc = 0
      end
      local h = prev_height + inc
      -- local h = math.max(1, math.min(prev_height + inc, 20))
      prev_incline = h - prev_height
      prev_height = h
      height[i] = h
      if max_height < h then
         max_height = h
      end
      if min_height > h then
         min_height = h
      end
   end
   local height_offset = - (min_height - 1)

   for i = 1, 17 do
      height[i] = math.floor(height[i] + height_offset)
   end

   return height
end

for i = 1, 10 do
   local height_map = make_height_map(i)
   local fp = io.open(string.format("%03d.lua", i), "w")
   fp:write("return height_map {\n")
   fp:write(table.concat(height_map, ", "))
   -- for j = 0, 16 do
   --    fp:write(string.format("[%d]=%d,", j, height_map[j]))
   -- end
   fp:write("\n}\n")
   fp:close()
end
