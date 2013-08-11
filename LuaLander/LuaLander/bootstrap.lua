function bootstrap()
   -- TODO: load some scripts
   print "hello bootstrap"
end

local function make_spaceship(world)
   local bodydef = b2.b2BodyDef()
   bodydef.type = b2.b2_dynamicBody
   bodydef.position:Set(3, 0)
   bodydef.angle = 0
   bodydef.allowSleep = true
   bodydef.awake = true
   bodydef.fixedRotation = false

   local body = world:CreateBody(bodydef)
   return body
end

local function make_main_coro(stat)
   return function(elapsed)
      local ctx = objc.context:create()
      local view = ctx:wrap(stat.view_controller)("view")
      print ("view", -view)
      local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
      print("img", -img)

      local ship = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)
      print("ship", -ship)
      view("addSubview:", -ship)

      local gravity = b2.b2Vec2(0, -10)
      local world = b2.b2World(gravity)

      local body = make_spaceship(world)

      local prev_incline = math.random(3) - 2
      local incline = {}
      for i = 1, 16 do
         local inc = prev_incline + math.random(3) - 2
         prev_incline = inc
         incline[i] = inc
      end
      print(table.unpack(incline))

      while true do
         elapsed = coroutine.yield()
         world:Step(elapsed - stat.prev_time, 10, 8)
         local pos = body:GetPosition()

         local trans = cg.CGAffineTransformMakeTranslation(pos.x * 100, - pos.y * 100)
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
