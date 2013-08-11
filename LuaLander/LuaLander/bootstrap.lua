function bootstrap()
   -- TODO: load some scripts
   print "hello bootstrap"
end

local function make_main_coro(stat)
   return function(elapsed)
      local ctx = objc.context:create()
      local view = ctx:wrap(stat.view_controller)("view")
      print ("view", -view)
      -- local imgpath = (ctx:wrap(objc.class.NSBundle)
      -- 		       ("mainBundle")
      -- 		       ("pathForResource:ofType:", "spaceship", "png"))
      -- print("imgpath", imgpath)
      local img = ctx:wrap(objc.class.UIImage)("imageNamed:", "spaceship.png")
      print("img", -img)

      local imgview = ctx:wrap(objc.class.UIImageView)("alloc")("initWithImage:", -img)
      print("imgview", -imgview)
      -- local ship = imgviewcls()
      view("addSubview:", -imgview)
      while true do
	 -- print(1 / (elapsed - stat.prev_time))
	 stat.prev_time = elapsed
	 elapsed = coroutine.yield()
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
