setmetatable(_G, {__index = function(tbl, key)
                     error ("undefined global variable: " .. key, 2)
end})

local Collision = {}
local State = {}
local Hud = {Message = {}}

local LOG_VERSION = "1.0"
local DEBUG_MODE = true

function Collision:type()
   return self.type
end

function Collision:create(collision_type)
   local col = {
      type = collision_type
   }
   setmetatable(col, {__index = State})
   return col
end

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

local function make_terrain_from_height_map(ctx, view, world, height)
   local scr_rect = view("bounds")
   local terview = (ctx:wrap(objc.class.LLTerrainView)("alloc")
                    ("initWithFrame:", -scr_rect))
   view("insertSubview:atIndex:", -terview, 0)

   objc.push(ctx.stack, -scr_rect)
   local x, y, sw, sh = objc.extract(ctx.stack, "CGRect")
   print(x, y, sw, sh)

   for i = 1, 16 do
      -- print("i", i)
      local h1 = (height[i - 1] * 32 - sh) / 10
      local h2 = (height[i] * 32 - sh) / 10
      local x1 = (i - 1) * 64 / 10
      local x2 = i * 64 / 10

      local vtx
      if h1 > h2 then
         vtx = {b2.b2Vec2(x1, h2), b2.b2Vec2(x2, h2), b2.b2Vec2(x1, h1)}
      elseif h1 == h2 then
         vtx = {b2.b2Vec2(x1, h1), b2.b2Vec2(x2, h1 - 1), b2.b2Vec2(x2, h1)}
      else
         vtx = {b2.b2Vec2(x1, h1), b2.b2Vec2(x2, h1), b2.b2Vec2(x2, h2)}
      end

      local poly = b2.b2PolygonShape()
      poly:Set(vtx)

      local bodydef = b2.b2BodyDef()
      local body = world:CreateBody(bodydef)
      body:CreateFixture(poly, 0)
      if h1 == h2 then
         local col = Collision:create("platform")
         body:SetUserData(col)
      end
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
   return terview
end

local function load_height_map(ctx, mission)
   local base_path = ctx:wrap(objc.class.NSBundle)("mainBundle")("resourcePath")
   local dirs = {"Documents", "levels"}
   local path
   for i, dir in ipairs(dirs) do
      path = string.format("%s/%s/%03d.lua", base_path, dir, mission)
      local fp = io.open(path)
      if fp then
         fp:close()
         break
      end
   end

   print("loading hight map file", path)
   local func = loadfile(
      path, "bt", {
         ipairs = ipairs,
         make_terrain_from_height_map = make_terrain_from_height_map,
         height_map = function(map)
            local dest = {}
            for i, v in ipairs(map) do
               -- print("height_map", i, v)
               dest[i - 1] = v
            end
            return function(ctx, view, world)
               return make_terrain_from_height_map(ctx, view, world, dest)
            end
         end
   })
   -- print(func)
   local height_map = func()
   -- print("height_map[0]", height_map[0])
   return height_map
end

function State:make_terrain(mission)
   local ctx, view, world = self.ctx, self.view, self.world
   local height = load_height_map(ctx, mission)

   return height(ctx, view, world)
end

local function get_bounds(ctx, view)
      local bounds = view("bounds")
      objc.push(ctx.stack, -bounds)
      -- returns 4 values: x, y, width, height
      return objc.extract(ctx.stack, "CGRect")
end

local function make_ground(world, screen_size)
   print("screen_size", table.unpack(screen_size))

   local half_width = screen_size[1] / 10 / 2
   local half_height = screen_size[2] / 10 / 2

   local bodydef = b2.b2BodyDef()
   bodydef.position:Set(half_width, 1)
   local groundbody = world:CreateBody(bodydef)
   local box = b2.b2PolygonShape()
   box:SetAsBox(half_width, 1)
   groundbody:CreateFixture(box, 0)

   local left_bodydef = b2.b2BodyDef()
   left_bodydef.position:Set(-1, -half_height)
   local left_groundbody = world:CreateBody(left_bodydef)
   local left_box = b2.b2PolygonShape()
   left_box:SetAsBox(1, half_height)
   left_groundbody:CreateFixture(left_box, 0)

   local right_bodydef = b2.b2BodyDef()
   right_bodydef.position:Set(half_width * 2 + 1, -half_height)
   local right_groundbody = world:CreateBody(right_bodydef)
   local right_box = b2.b2PolygonShape()
   right_box:SetAsBox(1, half_height)
   right_groundbody:CreateFixture(right_box, 0)

   return {groundbody, left_groundbody, right_groundbody}
end

local function make_spaceship(ctx, world)
   local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
   local ship = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)

   local x, y, width, height = get_bounds(ctx, ship)
   print(x, y, width, height)

   local shipview = (ctx:wrap(objc.class.UIView)("alloc")
                     ("initWithFrame:", -(ship("bounds"))))
   shipview("addSubview:", -ship)

   local shipbody = make_spaceship_body(world)
   set_fixture(shipbody, width, height)
   local col = Collision:create("ship")
   shipbody:SetUserData(col)

   local jetimg = ctx:wrap(objc.class.UIImage)("imageNamed:", "fire.png")
   local jetview = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -jetimg)
   jetview("setHidden:", true)
   shipview("addSubview:", -jetview)

   local jx, jy, jet_w, jet_h = get_bounds(ctx, jetview)

   local function set_power(x)
      if x == 0 then
         jetview("setHidden:", true)
      else
         local t = cg.CGAffineTransformConcat(
            cg.CGAffineTransformMakeScale(x, x),
            cg.CGAffineTransformMakeTranslation((width - jet_w) / 2,
                                                (height - jet_h * (1 - x) / 2)))
         local twraped = cg.CGAffineTransformWrap(t)

         objc.push(ctx.stack, twraped)
         -- print("trans", objc.extract(ctx.stack, "CGAffineTransform"))

         jetview("setHidden:", false)
         jetview("setTransform:", twraped)
      end
   end

   return shipview, shipbody, set_power
end

function State:set_contact_listner(world)
   local listbl = {}
   local listener = b2.create_contact_listener(listbl)
   world:SetContactListener(listener)
   self.collision_detected = false
   self.listener = listener
   self.listbl = listbl
   local stat = self

   function listbl:got_impulses(imp, contact)
      if not stat.collision_detected then
         print("imp", imp.count, contact)

         local fixa = contact:GetFixtureA()
         local fixb = contact:GetFixtureB()

         print(fixa, fixb)

         local bodya = fixa:GetBody()
         local bodyb = fixb:GetBody()

         print(bodya, bodyb)

         local cola = bodya:GetUserData()
         local colb = bodyb:GetUserData()

         print(cola, colb)
         print(cola and cola.type, colb and colb.type)

         for i = 1, imp.count do
            local vals = b2.get_impulse(imp, i - 1)

            print("imp normal", vals.normalImpulse)
            print("imp tangent", vals.tangentImpulse)

            if vals.normalImpulse > 30 then
               stat.collision_detected = true
               break
            end
         end

         if (cola and cola.type == "ship" and colb and colb.type == "platform"
             or cola and cola.type == "platform" and colb and colb.type == "ship") then
               local v = stat.shipbody:GetLinearVelocity()
               local vv = b2.b2Dot(v, v)
               if vv < 1 then
                  print("v^2:", vv)
                  stat.successfully_landed = true
               end
         else
            stat.collision_detected = true
         end
      end
   end
end

local function make_world()
   local gravity = b2.b2Vec2(0, -1)
   return b2.b2World(gravity)
end

function State:initialize()
   local stat = self

   local ctx = objc.context:create()

   local view = ctx:wrap(stat.view_controller)("view")
   local screen_bounds = {get_bounds(ctx, view)}

   view("setBackgroundColor:", -(ctx:wrap(objc.class.UIColor)("grayColor")))

   local width, height = 1024, 768
   local innerview = (ctx:wrap(objc.class.UIView)("alloc")
                      ("initWithFrame:",
                       cg.CGRectWrap(cg.CGRectMake(0, 0, width, height))))
   innerview("setBackgroundColor:", -(ctx:wrap(objc.class.UIColor)("whiteColor")))

   local ratio_x = screen_bounds[3] / width
   local ratio_y = screen_bounds[4] / height
   local ratio = math.min(ratio_x, ratio_y)
   print("screen", screen_bounds[3], screen_bounds[4])
   print("ratio", ratio, ratio_x, ratio_y)
   innerview("setTransform:",
             cg.CGAffineTransformWrap(
                cg.CGAffineTransformConcat(
                   cg.CGAffineTransformMakeScale(ratio, ratio),
                   cg.CGAffineTransformMakeTranslation(- (width - screen_bounds[3]) / 2,
                                                       - (height - screen_bounds[4]) / 2)
   )))
   view("addSubview:", -innerview)

   stat.ctx = ctx
   stat.view = innerview
   stat.screen_bounds = {0, 0, width, height}
end

function State:game_start(mission)
   local stat = self

   stat:analytics_log("start_" .. mission, {})

   if stat.world then
      stat.world = nil
      if stat.ship then
         stat.ship("removeFromSuperview")
         stat.ship = nil
      end

      collectgarbage()
   end

   local ctx = stat.ctx
   local view = stat.view
   local world = make_world()
   stat.world = world
   local ship, shipbody, set_power = make_spaceship(ctx, world)
   view("addSubview:", -ship)

   if self.terrain_view then
      self.terrain_view("removeFromSuperview")
   end
   self.terrain_view = self:make_terrain(mission)

   local screen_bounds = stat.screen_bounds
   local groundbodies = make_ground(world, {screen_bounds[3], screen_bounds[4]})

   stat.ship = ship
   stat.shipbody = shipbody
   stat.set_power = set_power
   stat.ground_bodies = groundbodies

   self.shipbody:SetTransform(b2.b2Vec2(7, -10), 0)
   self.shipbody:SetLinearVelocity(b2.b2Vec2(500, 0))

   self.collision_detected = false
   self.successfully_landed = false

   stat:set_contact_listner(world)
end

function State:on_collision_detected(pos)
   local pos = self.shipbody:GetPosition()
   local ctx, world, view, ship, shipbody
      = self.ctx, self.world, self.view, self.ship, self.shipbody

   print("collision_detected")
   ship("setHidden:", true)
   shipbody:SetActive(false)

   local parts = {}
   for i = 1, 50 do
      local bdef = b2.b2BodyDef()
      local ang = math.random() * math.pi * 2
      bdef.position:Set(pos.x + math.random() * math.cos(ang),
                        pos.y + math.random() * math.sin(ang))
      bdef.type = b2.b2_dynamicBody
      local body = world:CreateBody(bdef)
      local box = b2.b2PolygonShape()
      box:SetAsBox(0.5, 0.5)
      body:CreateFixture(box, 1)
      body:ApplyLinearImpulse(b2.b2Vec2(0.2 * math.cos(ang),
                                        0.2 * math.sin(ang)),
                              b2.b2Vec2(math.random() - 0.5, math.random() - 0.5))

      local rect = cg.CGRectWrap(cg.CGRectMake(0, 0, 10, 10))
      local partview = ctx:wrap(objc.class.LLTerrainView)("alloc")("initWithFrame:", rect)
      partview("setClipsToBounds:", true)
      local function drawRect(rect)
         local cgctx = cg.UIGraphicsGetCurrentContext()
         cg.CGContextSetRGBFillColor(cgctx, 1, 0, 0, 1)
         cg.CGContextFillRect(cgctx, cg.CGRectMake(0, 0, 10, 10))
      end

      partview("setDrawRect:", drawRect)

      view("addSubview:", -partview)

      table.insert(parts, {body = body, view = partview})
   end

   return parts
end

local function update_explosion_coro(world, prev_time, parts)
   local elapsed, accx, accy, accz = coroutine.yield()
   world:Step(elapsed - prev_time, 10, 8)

   for i, p in pairs(parts) do
      local pos = p.body:GetPosition()
      local rot = p.body:GetAngle()

      p.view("setTransform:",
             cg.CGAffineTransformWrap(
                cg.CGAffineTransformConcat(
                   cg.CGAffineTransformMakeRotation(-rot),
                   cg.CGAffineTransformMakeTranslation(pos.x * 10,
                                                          - pos.y * 10))))
   end

   return elapsed
end

function State:update_force(accx, accy, accz, fuel)
   local shipbody, set_power = self.shipbody, self.set_power

   local rot = shipbody:GetAngle()

   if accx ~= 0 and accy ~= 0 then
      local target_angle = - (math.atan(- accy / accx))
      -- print(target_angle)

      local tor = target_angle - rot
      shipbody:ApplyTorque(tor * 10000)
   end

   if accz ~= 0 and fuel > 0 then
      local a = accx * accx + accy * accy
      if a > 0 then
         local tan = accz / math.sqrt(a)
         if tan < 0 then
            local ang = - math.atan(tan)
            local sin = math.sin(rot + math.pi / 2)
            local cos = math.cos(rot + math.pi / 2)
            local pow = math.min(1, ang / (math.pi / 4))

            if pow > fuel then pow = fuel end
            shipbody:ApplyForceToCenter(b2.b2Vec2(pow * cos * 200,
                                                  pow * sin * 200))
            set_power(pow)
            fuel = fuel - (pow * 0.1)
         end
      else
         set_power(0)
      end
   end

   local av = shipbody:GetAngularVelocity()
   shipbody:ApplyTorque(-av * 10000)
   return fuel
end

function State:make_adview()
   local adview = (self.ctx:wrap(objc.class.GADInterstitial)("alloc")
                   ("initWithAdUnitID:", "ca-app-pub-1755065155356425/3106242002"))
   local adreq = self.ctx:wrap(objc.class.GADRequest)("request")
   local arr = self.ctx:wrap(objc.class.NSMutableArray)("arrayWithCapacity:", 2)
   arr("addObject:", self.simulator)
   arr("addObject:", "61f69d5e71cd7e65a18a12ece59bb00c")
   adreq("setTestDevices:", -arr)
   adview("loadRequest:", -adreq)

   return adview
end

function State:show_gameover(back_clicked, parts)
   local adview = self:make_adview()

   local function func(url, webview)
      print("clicked", url)

      local function goback()
         self.ctx:wrap(webview)("removeFromSuperview")
         for i, part in pairs(parts) do
            self.world:DestroyBody(part.body)
            part.view("removeFromSuperview")
         end
         back_clicked[1] = true
      end

      if url:match("^lualander:back") then
         goback()
         return false
      elseif url:match("^lualander:watchad") then
         self:analytics_log("ad_fail", {})
         adview("presentFromRootViewController:", self.view_controller)
         goback()
         return false
      else
         return true
      end
   end

   self:show_webview_hud("gameover", func)
end

function Hud:create(mission, webview)
   local hud = {
      mission = mission,
      webview = webview
   }
   setmetatable(hud, {__index = Hud})
   return hud
end

function Hud:dispatch(stat, url)
   local mission = self.mission
   local webview = self.webview

   local mesg = url:match("^lualander:(.*)$")
   if mesg then
      print("dispatch", url, mesg)
      Hud.Message[mesg](self, stat)
   end
end

function Hud.Message.ready(hud, stat)
   hud.webview("stringByEvaluatingJavaScriptFromString:",
               string.format("set_display({mission:%d})", hud.mission))
   if DEBUG_MODE then
      hud.webview("stringByEvaluatingJavaScriptFromString:", "show_debug()")
   end
end

function Hud.Message.debug_stay(hud, stat)
   local body = stat.shipbody
   if body then
      local center = body:GetWorldCenter()
      local imp = body:GetLinearVelocity()
      imp.x = imp.x * -body:GetMass()
      imp.y = imp.y * -body:GetMass()
      print("debug_stay:", imp.x, imp.y)
      body:ApplyLinearImpulse(imp, center)
   end
end

function Hud.Message.debug_up(hud, stat)
   local body = stat.shipbody
   if body then
      local center = body:GetWorldCenter()
      body:ApplyLinearImpulse(b2.b2Vec2(0, 100), center)
   end
end

function Hud.Message.debug_down(hud, stat)
   local body = stat.shipbody
   if body then
      local center = body:GetWorldCenter()
      body:ApplyLinearImpulse(b2.b2Vec2(0, -100), center)
   end
end

function Hud.Message.debug_left(hud, stat)
   local body = stat.shipbody
   if body then
      local center = body:GetWorldCenter()
      body:ApplyLinearImpulse(b2.b2Vec2(-100, 0), center)
   end
end

function Hud.Message.debug_right(hud, stat)
   local body = stat.shipbody
   if body then
      local center = body:GetWorldCenter()
      body:ApplyLinearImpulse(b2.b2Vec2(100, 0), center)
   end
end

function Hud.Message.debug_done(hud, stat)
   stat.successfully_landed = true
end

function State:show_hud(mission)
   print("show_hud")
   local hud
   local webview

   webview = self:show_webview_hud(
      "hud",
      function (url, wb)
         hud:dispatch(self, url)
         return true
      end
   )
   hud = Hud:create(mission, webview)

   return webview
end

function State:show_webview_hud(name, click_handler)
   print("show_webview_hud", name)
   local ctx = self.ctx
   local view = self.view
   local rect = view("bounds")
   local webview = ctx:wrap(objc.class.UIWebView)("alloc")("initWithFrame:", -rect)
   local path = (ctx:wrap(objc.class.NSBundle)("mainBundle")
                 ("pathForResource:ofType:", name, "html"))
   if not path then
      error("HUD '" .. tostring(name) .. "' not found")
   end
   local url = ctx:wrap(objc.class.NSURL)("fileURLWithPath:", path)
   local req = ctx:wrap(objc.class.NSURLRequest)("requestWithURL:", -url)
   webview("loadRequest:", -req)
   webview("setOpaque:", false)
   local clear = ctx:wrap(objc.class.UIColor)("clearColor")
   webview("setBackgroundColor:", -clear)

   view("addSubview:", -webview)

   local delegate = (ctx:wrap(objc.class.LLWebViewDelegate)("alloc")
                     ("initWithFunc:", click_handler))
   webview("setDelegate:", -delegate)

   return webview
end

function State:show_welldone(back_clicked)
   print("State:show_welldone")
   local function func(url, webview)
      print("clicked", url)
      if url:match("^lualander:back") then
         self.ctx:wrap(webview)("removeFromSuperview")
         back_clicked[1] = true
         return false
      else
         return true
      end
   end
   self:show_webview_hud("welldone", func)
end

function State:show_complete(back_clicked)
   print("State:show_complete")
   local adview = self:make_adview()

   local function func(url, webview)
      print("clicked", url)
      local function goback()
         self.ctx:wrap(webview)("removeFromSuperview")
         back_clicked[1] = true
      end

      if url:match("^lualander:back") then
         goback()
         return false
      elseif url:match("^lualander:watchad") then
         self:analytics_log("ad_complete", {})
         adview("presentFromRootViewController:", self.view_controller)
         goback()
         return false
      else
         return true
      end
   end
   self:show_webview_hud("complete", func)
end

function State:game_main_loop_coro(mission)
   local stat = self
   local ctx, world, view, ship, shipbody
      = self.ctx, self.world, self.view, self.ship, self.shipbody

   local x, y, width, height = get_bounds(ctx, ship)

   local collision = self.shipbody:GetUserData()
   print("State:game_main_loop_coro()", collision.type)

   local fuel = 99.9

   while true do
      local elapsed, accx, accy, accz = coroutine.yield()
      -- print(accx, accy, accz)

      world:Step(elapsed - stat.prev_time, 10, 8)

      if stat.collision_detected then
         stat:analytics_log("fail_" .. mission, {fuel = fuel})
         return false
      elseif stat.successfully_landed then
         stat:analytics_log("done_" .. mission, {fuel = fuel})
         return true
      end

      fuel = self:update_force(accx, accy, accz, fuel)

      local pos = shipbody:GetPosition()
      local rot = shipbody:GetAngle()

      ship("setTransform:",
           cg.CGAffineTransformWrap(
              cg.CGAffineTransformConcat(
                 cg.CGAffineTransformMakeRotation(-rot),
                 cg.CGAffineTransformMakeTranslation(pos.x * 10 - width / 2,
                                                        - pos.y * 10 - height / 2))))

      local vel = shipbody:GetLinearVelocity()
      local vel_abs = vel:Length()
      self.hud_view("stringByEvaluatingJavaScriptFromString:",
                    string.format("set_display({velocity:%.3f, fuel:%.1f})", vel_abs, fuel))

      stat.prev_time = elapsed
   end
end

function State:analytics_log(event, params)
   print("analytics_log event:", event)
   local dict = self.ctx:wrap(objc.class.NSMutableDictionary)("dictionary")
   params.log_version = LOG_VERSION
   for k, v in pairs(params) do
      dict("setObject:forKey:", v, k)
      print("analytics_log param:", k, v)
   end
   self.ctx:wrap(objc.class.FIRAnalytics)("logEventWithName:parameters:", event, -dict)
end

function State:title_screen_coro()
   local ctx = self.ctx
   local view = self.view
   local rect = view("bounds")
   local webview = ctx:wrap(objc.class.UIWebView)("alloc")("initWithFrame:", -rect)
   local path = (ctx:wrap(objc.class.NSBundle)("mainBundle")
                 ("pathForResource:ofType:", "title", "html"))
   local url = ctx:wrap(objc.class.NSURL)("fileURLWithPath:", path)
   print("url", -url)
   local req = ctx:wrap(objc.class.NSURLRequest)("requestWithURL:", -url)
   print("req", -req)
   webview("loadRequest:", -req)
   webview("setOpaque:", false)
   local clear = ctx:wrap(objc.class.UIColor)("clearColor")
   webview("setBackgroundColor:", -clear)

   local started = false
   local function func(url)
      print("clicked", url)
      if url:match("^lualander:start") then
         webview("setHidden:", true)
         started = true
         print("start")
         return false
      else
         return true
      end
   end
   local delegate = (ctx:wrap(objc.class.LLWebViewDelegate)("alloc")
                     ("initWithFunc:", func))
   webview("setDelegate:", -delegate)

   view("addSubview:", -webview)

   while true do
      if started then
         break
      else
         coroutine.yield()
      end
   end
end

local function make_main_coro(stat)
   return function()
      stat:initialize()

      while true do
         local mission_cleared = 0
         stat:title_screen_coro()
         while true do
            stat:game_start(mission_cleared + 1)
            local hud_view = stat:show_hud(mission_cleared + 1)
            stat.hud_view = hud_view
            local cleared = stat:game_main_loop_coro(mission_cleared + 1)
            local back_clicked = {false}
            if cleared then
               mission_cleared = mission_cleared + 1
               if mission_cleared < (DEBUG_MODE and 3 or 10) then -- total number of missions
                  print("welldone!")
                  stat:show_welldone(back_clicked)
                  while true do
                     if back_clicked[1] then
                        break
                     else
                        coroutine.yield()
                     end
                  end
               else
                  print("complete!")
                  stat:show_complete(back_clicked)
                  while true do
                     if back_clicked[1] then
                        break
                     else
                        coroutine.yield()
                     end
                  end
                  break
               end
            else
               mission_cleared = 0
               local parts = stat:on_collision_detected()
               stat:show_gameover(back_clicked, parts)

               while true do
                  if back_clicked[1] then
                     break
                  else
                     stat.prev_time = update_explosion_coro(stat.world, stat.prev_time, parts)
                  end
               end
            end
            hud_view("removeFromSuperview")
            if not cleared then break end
         end
      end
   end
end

function create(view_controller, simulator)
   local stat = {
      view_controller = view_controller,
      simulator = simulator,
      prev_time = 0
   }
   setmetatable(stat, {__index = State})
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
