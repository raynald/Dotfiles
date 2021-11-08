--      ██╗   ██╗ ██████╗ ██╗     ██╗   ██╗███╗   ███╗███████╗
--      ██║   ██║██╔═══██╗██║     ██║   ██║████╗ ████║██╔════╝
--      ██║   ██║██║   ██║██║     ██║   ██║██╔████╔██║█████╗
--      ╚██╗ ██╔╝██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══╝
--       ╚████╔╝ ╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║███████╗
--        ╚═══╝   ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝


-- ===================================================================
-- Initialization
-- ===================================================================


local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local offsetx = dpi(56)
local offsety = dpi(300)
local screen = awful.screen.focused()
local icon_dir = gears.filesystem.get_configuration_dir() .. "/icons/brightness/" 


-- ===================================================================
-- Appearance & Functionality
-- ===================================================================


local brightness_icon = wibox.widget {
   widget = wibox.widget.imagebox
}

-- create the brightness_adjust component
local brightness_adjust = wibox({
   screen = awful.screen.focused(),
   x = screen.geometry.width - offsetx,
   y = (screen.geometry.height / 2) - (offsety / 2),
   width = dpi(48),
   height = offsety,
   shape = gears.shape.rounded_rect,
   visible = false,
   ontop = true
})

local brightness_bar = wibox.widget{
   widget = wibox.widget.progressbar,
   shape = gears.shape.rounded_bar,
   color = "#efefef",
   background_color = beautiful.bg_focus,
   max_value = 100,
   value = 0
}

brightness_adjust:setup {
   layout = wibox.layout.align.vertical,
   {
      wibox.container.margin(
         brightness_bar, dpi(14), dpi(20), dpi(20), dpi(20)
      ),
      forced_height = offsety * 0.75,
      direction = "east",
      layout = wibox.container.rotate
   },
   wibox.container.margin(
      brightness_icon
   )
}

-- create a 4 second timer to hide the brightness adjust
-- component whenever the timer is started
local hide_brightness_adjust = gears.timer {
   timeout = 4,
   autostart = true,
   callback = function()
      brightness_adjust.visible = false
   end
}

-- show brightness-adjust when "brightness_change" signal is emitted
awesome.connect_signal("brightness_change",
   function()
      -- set new brightness value
      awful.spawn.easy_async_with_shell(
         "light",
         function(stdout)
            local brightness_level = tonumber(stdout)
            brightness_bar.value = brightness_level
            if (brightness_level > 40) then
               brightness_icon:set_image(icon_dir .. "brightness-high.png")
            else
               brightness_icon:set_image(icon_dir .. "brightness-low.png")
            end
         end,
         false
      )

      -- make brightness_adjust component visible
      if brightness_adjust.visible then
         hide_brightness_adjust:again()
      else
         brightness_adjust.visible = true
         hide_brightness_adjust:start()
      end
   end
)
