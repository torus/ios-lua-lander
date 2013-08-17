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
   bodydef.position:Set(10, 0)
   bodydef.angle = 0
   bodydef.allowSleep = true
   bodydef.awake = true
   bodydef.fixedRotation = false

   local body = world:CreateBody(bodydef)

   return body
end

local function set_fixture(body, width, height)
   local box = b2.b2PolygonShape()
   box:SetAsBox(width / 2 / 10, height / 2 / 10)
   body:CreateFixture(box, 1)
end

local function make_terrain(ctx, view)
   local prev_incline = math.random(3) - 2
   local incline = {}
   local height = {}
   local prev_height = 0
   local max_height = -100
   local min_height = 100
   for i = 0, 16 do
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
   local height_offset = - (min_height - 1)

   local rect = view("bounds")
   local terview = ctx:wrap(objc.class.LLTerrainView)("alloc")("initWithFrame:", -rect)
   view("insertSubview:atIndex:", -terview, 0)

   local function drawRect(rect)
      local cgctx = cg.UIGraphicsGetCurrentContext()

      objc.push(ctx.stack, rect)
      local x, y, sw, sh = objc.extract(ctx.stack, "CGRect")
      print(x, y, sw, sh)

      cg.CGContextSetRGBFillColor(cgctx, 1, 1, 1, 1)
      cg.CGContextFillRect(cgctx, cg.CGRectMake(0, 0, sw, sh))

      cg.CGContextSetRGBStrokeColor(cgctx, 0, 0, 0, 1)
      cg.CGContextSetLineWidth(cgctx, 3)
      cg.CGContextBeginPath(cgctx)
      cg.CGContextMoveToPoint(cgctx, 0, sh)
      for i = 0, 16 do
         local h = height[i] + height_offset
         print(i, h, i * 64, 1024 - h * 64)
         cg.CGContextAddLineToPoint(cgctx, i * 64, sh - h * 32)
      end
      cg.CGContextAddLineToPoint(cgctx, sw, sh)
      cg.CGContextClosePath(cgctx)
      cg.CGContextStrokePath(cgctx)
   end

   terview("setDrawRect:", drawRect)
end

local function get_bounds(ctx, view)
      local bounds = view("bounds")
      objc.push(ctx.stack, -bounds)
      -- returns 4 values: x, y, width, height
      return objc.extract(ctx.stack, "CGRect")
end

local function make_ground(world, screen_size)
   local bodydef = b2.b2BodyDef()
   bodydef.position:Set(screen_size[1] / 10 / 2, -screen_size[2] / 10 - 1)
   local groundbody = world:CreateBody(bodydef)
   local box = b2.b2PolygonShape()
   box:SetAsBox(51.2, 1)
   groundbody:CreateFixture(box, 0)

   return groundbody
end

local function make_main_coro(stat)
   return function(elapsed)
      local ctx = objc.context:create()
      local view = ctx:wrap(stat.view_controller)("view")
      print ("view", -view)
      local screen_bounds = {get_bounds(ctx, view)}

      local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
      print("img", -img)

      local ship = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)
      print("ship", -ship)
      view("addSubview:", -ship)
      local x, y, width, height = get_bounds(ctx, ship)
      print(x, y, width, height)

      local gravity = b2.b2Vec2(0, -10)
      local world = b2.b2World(gravity)

      local shipbody = make_spaceship(world)
      set_fixture(shipbody, width, height)
      make_terrain(ctx, view)

      local groundbody = make_ground(world, {screen_bounds[3], screen_bounds[4]})

      shipbody:ApplyLinearImpulse(b2.b2Vec2(1000, 0), b2.b2Vec2(0, 1))

      while true do
         elapsed = coroutine.yield()
         world:Step(elapsed - stat.prev_time, 10, 8)
         local pos = shipbody:GetPosition()
         local rot = shipbody:GetAngle()

         -- local trans = cg.CGAffineTransformMakeTranslation(
         --    pos.x * 10 - width / 2, - pos.y * 10 - height / 2)
         -- ship("setTransform:", cg.CGAffineTransformWrap(trans))
         ship("setTransform:",
              cg.CGAffineTransformWrap(
                 cg.CGAffineTransformConcat(
                    cg.CGAffineTransformMakeRotation(rot),
                    cg.CGAffineTransformMakeTranslation(pos.x * 10 - width / 2,
                                                           - pos.y * 10 - height / 2))))

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
