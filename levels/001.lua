local map = {
8, 7, 5, 2, 1, 1, 2, 3, 4, 6, 7, 7, 7, 8, 8, 8, 7
}
return function(ctx, view, world)
   local dest = {}
   for i, v in ipairs(map) do
      -- print("height_map", i, v)
      dest[i - 1] = v
   end
   return make_terrain_from_height_map(ctx, view, world, dest)
end

