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
local icon_dir = gears.filesystem.get_configuration_dir() .. "/icons/keyboard-brightness/" 


-- ===================================================================
-- Appearance & Functionality
-- ===================================================================


local keyboard_brightness_icon = wibox.widget {
   widget = wibox.widget.imagebox
}

-- create the keyboard_brightness_adjust component
local keyboard_brightness_adjust = wibox({
   screen = awful.screen.focused(),
   x = screen.geometry.width - offsetx,
   y = (screen.geometry.height / 2) - (offsety / 2),
   width = dpi(48),
   height = offsety,
   shape = gears.shape.rounded_rect,
   visible = false,
   ontop = true
})

local keyboard_brightness_bar = wibox.widget{
   widget = wibox.widget.progressbar,
   shape = gears.shape.rounded_bar,
   color = "#efefef",
   background_color = beautiful.bg_focus,
   max_value = 100,
   value = 0
}

keyboard_brightness_adjust:setup {
   layout = wibox.layout.align.vertical,
   {
      wibox.container.margin(
         keyboard_brightness_bar, dpi(14), dpi(20), dpi(20), dpi(20)
      ),
      forced_height = offsety * 0.75,
      direction = "east",
      layout = wibox.container.rotate
   },
   wibox.container.margin(
      keyboard_brightness_icon
   )
}

-- create a 4 second timer to hide the keyboard_brightness adjust
-- component whenever the timer is started
local hide_keyboard_brightness_adjust = gears.timer {
   timeout = 4,
   autostart = true,
   callback = function()
      keyboard_brightness_adjust.visible = false
   end
}

-- show keyboard-brightness-adjust when "keyboard-brightness_change" signal is emitted
awesome.connect_signal("keyboard_brightness_change",
   function()
      -- set new keyboard brightness value
      awful.spawn.easy_async_with_shell(
         "light -s sysfs/leds/smc::kbd_backlight",
         function(stdout)
            local keyboard_brightness_level = tonumber(stdout)
            keyboard_brightness_bar.value = keyboard_brightness_level
            if (keyboard_brightness_level > 40) then
               keyboard_brightness_icon:set_image(icon_dir .. "keyboard-high.png")
            else
               keyboard_brightness_icon:set_image(icon_dir .. "keyboard-low.png")
            end
         end,
         false
      )

      -- make keyboard_brightness_adjust component visible
      if keyboard_brightness_adjust.visible then
         hide_keyboard_brightness_adjust:again()
      else
         keyboard_brightness_adjust.visible = true
         hide_keyboard_brightness_adjust:start()
      end
   end
)
