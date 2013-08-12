setmetatable(_G, {__index = function(tbl, key)
                     error ("undefined global variable: " .. key, 2)
end})

function bootstrap()
   -- TODO: load some scripts
   print "hello bootstrap"
end

local function make_spaceship(world)
   local bodydef = b2.b2BodyDef()
   bodydef.type = b2.b2_dynamicBody
   bodydef.position:Set(0, 0)
   bodydef.angle = 0
   bodydef.allowSleep = true
   bodydef.awake = true
   bodydef.fixedRotation = false

   local body = world:CreateBody(bodydef)

   local box = b2.b2PolygonShape()
   box:SetAsBox(0.5, 0.5)
   body:CreateFixture(box, 1)

   return body
end

local function make_terrain()
   local prev_incline = math.random(3) - 2
   local incline = {}
   local height = {}
   local prev_height = 0
   local max_height = -100
   local min_height = 100
   for i = 1, 16 do
      local inc = prev_incline + math.random(3) - 2
      prev_incline = inc
      incline[i] = inc
      local h = prev_height + inc
      prev_height = h
      height[i] = h
      if max_height < h then
         max_height = h
      end
      if min_height > h then
         min_height = h
      end
   end
   print(table.unpack(incline))
   print(table.unpack(height))
   print(max_height, min_height)
   local height_offset = min_height - 1
end

local function get_bounds(ctx, view)
      local bounds = view("bounds")
      objc.push(ctx.stack, -bounds)
      -- returns 4 values: x, y, width, height
      return objc.extract(ctx.stack, "CGRect")
end

local function make_main_coro(stat)
   return function(elapsed)
      local ctx = objc.context:create()
      local view = ctx:wrap(stat.view_controller)("view")
      print ("view", -view)
      -- local bounds = ctx:wrap(objc.class.UIScreen)("mainScreen")("bounds")
      -- local bounds = view("bounds")
      -- print("bounds", -bounds)
      -- ---- extract
      -- objc.push(ctx.stack, -bounds)
      print(get_bounds(ctx, view))

      local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
      print("img", -img)

      local ship = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)
      print("ship", -ship)
      view("addSubview:", -ship)
      print(get_bounds(ctx, ship))

      local gravity = b2.b2Vec2(0, -10)
      local world = b2.b2World(gravity)

      local body = make_spaceship(world)
      make_terrain()

      local bodydef = b2.b2BodyDef()
      bodydef.position:Set(51.2, -70 - 1)
      -- bodydef.position:Set(51.2, -76.8 - 1)
      local groundbody = world:CreateBody(bodydef)
      local box = b2.b2PolygonShape()
      box:SetAsBox(51.2, 1)
      groundbody:CreateFixture(box, 0)

      while true do
         elapsed = coroutine.yield()
         world:Step(elapsed - stat.prev_time, 10, 8)
         local pos = body:GetPosition()

         local trans = cg.CGAffineTransformMakeTranslation(pos.x * 10, - pos.y * 10)
         ship("setTransform:", cg.CGAffineTransformWrap(trans))

         -- print(1 / (elapsed - stat.prev_time))
         stat.prev_time = elapsed
      end
   end
end

function create(view_controller)
   local stat = {
      view_controller = view_controller,
      prev_time = 0
   }
   stat.main_coro = coroutine.create(make_main_coro(stat))

   return stat
end

function update(stat, elapsed)
   if coroutine.status(stat.main_coro) == "suspended" then
      local result, err = coroutine.resume(stat.main_coro, elapsed)
      if not result then
         error(err)
      end
   end
end

bootstrap()
