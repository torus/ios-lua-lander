function bootstrap()
   -- TODO: load some scripts
   print "hello bootstrap"
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

      local bodydef = b2.b2BodyDef()
      bodydef.type = b2.b2_dynamicBody
      bodydef.position:Set(3, 0)
      bodydef.angle = 0
      bodydef.allowSleep = true
      bodydef.awake = true
      bodydef.fixedRotation = false

      local body = world:CreateBody(bodydef)

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
   coroutine.resume(stat.main_coro, elapsed)
end

bootstrap()
