setmetatable(_G, {__index = function(tbl, key)
                     error ("undefined global variable: " .. key, 2)
end})

function bootstrap()
   -- TODO: load some scripts
   print "hello bootstrap"
end

local function make_spaceship_body(world)
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

local function make_height_map()
   math.randomseed(os.time())
   local prev_incline = math.random(3) - 2
   -- local incline = {}
   local height = {}
   local prev_height = math.random(10) + 1
   local max_height = -100
   local min_height = 100
   for i = 0, 16 do
      local inc = prev_incline + math.random(3) - 2
      -- prev_incline = inc
      -- incline[i] = inc
      local h = math.max(1, math.min(prev_height + inc, 20))
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
   -- print(table.unpack(incline))
   -- print(table.unpack(height))
   -- print(max_height, min_height)
   local height_offset = - (min_height - 1)

   for i = 0, 16 do
      height[i] = height[i] + height_offset
   end

   return height
end

local function make_terrain(ctx, view, world)
   local height = make_height_map()

   local scr_rect = view("bounds")
   local terview = ctx:wrap(objc.class.LLTerrainView)("alloc")("initWithFrame:", -scr_rect)
   view("insertSubview:atIndex:", -terview, 0)

   objc.push(ctx.stack, -scr_rect)
   local x, y, sw, sh = objc.extract(ctx.stack, "CGRect")
   print(x, y, sw, sh)

   for i = 1, 16 do
      local h1 = (height[i - 1] * 32 - sh) / 10
      local h2 = (height[i] * 32 - sh) / 10
      local x1 = (i - 1) * 64 / 10
      local x2 = i * 64 / 10

      local vtx
      if h1 > h2 then
         -- print("h1 > h2", h1, h2)
         vtx = {b2.b2Vec2(x1, h2), b2.b2Vec2(x2, h2), b2.b2Vec2(x1, h1)}
      elseif h1 == h2 then
         -- print("h1 == h2", h1, h2)
         vtx = {b2.b2Vec2(x1, h1), b2.b2Vec2(x2, h1 - 1), b2.b2Vec2(x2, h1)}
      else
         -- print("h1 < h2", h1, h2)
         vtx = {b2.b2Vec2(x1, h1), b2.b2Vec2(x2, h1), b2.b2Vec2(x2, h2)}
      end

      local poly = b2.b2PolygonShape()
      poly:Set(vtx)

      local bodydef = b2.b2BodyDef()
      local body = world:CreateBody(bodydef)
      body:CreateFixture(poly, 0)
   end

   local function drawRect(rect)
      local cgctx = cg.UIGraphicsGetCurrentContext()

      cg.CGContextSetRGBFillColor(cgctx, 1, 1, 1, 1)
      cg.CGContextFillRect(cgctx, cg.CGRectMake(0, 0, sw, sh))

      cg.CGContextSetRGBStrokeColor(cgctx, 0, 0, 0, 1)
      cg.CGContextSetLineWidth(cgctx, 3)
      cg.CGContextBeginPath(cgctx)
      cg.CGContextMoveToPoint(cgctx, 0, sh)
      for i = 0, 16 do
         local h = height[i]
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

local function make_spaceship(ctx, world)
      local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
      print("img", -img)

      local ship = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)
      print("ship", -ship)

      local x, y, width, height = get_bounds(ctx, ship)
      print(x, y, width, height)

      local shipbody = make_spaceship_body(world)
      set_fixture(shipbody, width, height)

      return ship, shipbody
end

local function make_main_coro(stat)
   return function()
      local ctx = objc.context:create()
      local view = ctx:wrap(stat.view_controller)("view")
      local screen_bounds = {get_bounds(ctx, view)}

      local gravity = b2.b2Vec2(0, -1)
      local world = b2.b2World(gravity)

      local ship, shipbody = make_spaceship(ctx, world)
      view("addSubview:", -ship)
      local x, y, width, height = get_bounds(ctx, ship)

      make_terrain(ctx, view, world)

      local groundbody = make_ground(world, {screen_bounds[3], screen_bounds[4]})

      shipbody:ApplyLinearImpulse(b2.b2Vec2(300, 0), b2.b2Vec2(0, 1))

      while true do
         local elapsed, accx, accy, accz = coroutine.yield()
         -- print(accx, accy, accz)

         world:Step(elapsed - stat.prev_time, 10, 8)
         local pos = shipbody:GetPosition()
         local rot = shipbody:GetAngle()

         if accx ~= 0 and accy ~= 0 then
            local target_angle = - (math.atan(- accy / accx))
            -- print(target_angle)

            local tor = target_angle - rot
            shipbody:ApplyTorque(tor * 10000)
         end

         if accz ~= 0 then
            local a = accx * accx + accy * accy
            if a > 0 then
               local tan = accz / math.sqrt(a)
               if tan < 0 then
                  -- print("FIRE!!!!!!!!!", tan)
                  local ang = - math.atan(tan)
                  local sin = math.sin(rot + math.pi / 2)
                  local cos = math.cos(rot + math.pi / 2)
                  shipbody:ApplyForceToCenter(b2.b2Vec2(ang * cos * 1000,
                                                        ang * sin * 1000))
               end
            end
         end

         local av = shipbody:GetAngularVelocity()
         shipbody:ApplyTorque(-av * 10000)

         ship("setTransform:",
              cg.CGAffineTransformWrap(
                 cg.CGAffineTransformConcat(
                    cg.CGAffineTransformMakeRotation(-rot),
                    cg.CGAffineTransformMakeTranslation(pos.x * 10 - width / 2,
                                                           - pos.y * 10 - height / 2))))

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

function update(stat, elapsed, accx, accy, accz)
   if coroutine.status(stat.main_coro) == "suspended" then
      local result, err = coroutine.resume(stat.main_coro, elapsed, accx, accy, accz)
      if not result then
         error(err, 2)
      end
   end
end

bootstrap()
