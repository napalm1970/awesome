-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- local pacman = require("pacman")
local keyboard = require("scripts/kbd/keyboard")
-- local dbus1 = require("dbus1")
local vicious = require("vicious")
local net_widgets = require("scripts/net_widgets")
local lain = require("lain")


os.setlocale(os.getenv("ru_RU.UTF-8"))


function run_once(prg)
   if not prg then
      return
   end
   awful.util.spawn_with_shell("x=" .. prg .. "; pgrep -u $USERNAME -x " .. prg .. " || (" .. prg .. ")")
end





-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
		    title = "Oops, there were errors during startup!",
		    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
			     -- Make sure we don't go into an endless error loop
			     if in_error then return end
			     in_error = true

			     naughty.notify({ preset = naughty.config.presets.critical,
					      title = "Oops, an error happened!",
					      text = err })
			     in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/napalm/.config/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "termite" --"xfce4-terminal"
browser = "firefox"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
   {
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      awful.layout.suit.tile.bottom,
      awful.layout.suit.tile.top,
      awful.layout.suit.floating,
      --    awful.layout.suit.fair,
      --    awful.layout.suit.fair.horizontal,
      --    awful.layout.suit.spiral,
      --    awful.layout.suit.spiral.dwindle,
      --    awful.layout.suit.max,
      --    awful.layout.suit.max.fullscreen,
      --    awful.layout.suit.magnifier
   }
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end
-- }}}x

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

internet_menu =
   {
      {"  Chrome", "google-chrome", beautiful.chrome_icon }
   }
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
			     {"Интернет", internet_menu},
			     { "open terminal", terminal }
}
		       })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox


mytextclock = awful.widget.textclock()

-- calendar

lain.widgets.calendar:attach(mytextclock)

separator = wibox.widget.textbox()
separator:set_text(" | ")


-- Alsa widget

local alsawidget =
  {
    channel = "Master",
    step = "5%",
    colors =
      {
        unmute = "#AECF96",
        mute = "#FF5656"
      },
    mixer = terminal .. " -e alsamixer", -- or whatever your preferred sound mixer is
    notifications =
      {
        icons =
          {
            -- the first item is the 'muted' icon
            "/usr/share/icons/gnome/48x48/status/audio-volume-muted.png",
            -- the rest of the items correspond to intermediate volume levels - you can have as many as you want (but must be >= 1)
            "/usr/share/icons/gnome/48x48/status/audio-volume-low.png",
            "/usr/share/icons/gnome/48x48/status/audio-volume-medium.png",
            "/usr/share/icons/gnome/48x48/status/audio-volume-high.png"
          },
        font = "Monospace 11", -- must be a monospace font for the bar to be sized consistently
        icon_size = 48,
        bar_size = 20 -- adjust to fit your font if the bar doesn't fit
      }
  }
-- widget
alsawidget.bar = awful.widget.progressbar ()
alsawidget.bar:set_width (8)
alsawidget.bar:set_vertical (true)
alsawidget.bar:set_background_color ("#494B4F")
alsawidget.bar:set_color (alsawidget.colors.unmute)
alsawidget.bar:buttons (awful.util.table.join (
                          awful.button ({}, 1, function()
                              awful.util.spawn (alsawidget.mixer)
                          end),
                          awful.button ({}, 3, function()
                              -- You may need to specify a card number if you're not using your main set of speakers.
                              -- You'll have to apply this to every call to 'amixer sset'.
                              -- awful.util.spawn ("amixer sset -c " .. yourcardnumber .. " " .. alsawidget.channel .. " toggle")
                              awful.util.spawn ("amixer sset " .. alsawidget.channel .. " toggle")
                              vicious.force ({ alsawidget.bar })
                          end),
                          awful.button ({}, 4, function()
                              awful.util.spawn ("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "+")
                              vicious.force ({ alsawidget.bar })
                          end),
                          awful.button ({}, 5, function()
                              awful.util.spawn ("amixer sset " .. alsawidget.channel .. " " .. alsawidget.step .. "-")
                              vicious.force ({ alsawidget.bar })
                          end)
))
-- tooltip
alsawidget.tooltip = awful.tooltip ({ objects = { alsawidget.bar } })
-- naughty notifications
alsawidget._current_level = 0
alsawidget._muted = false
function alsawidget:notify ()
  local preset =
    {
      height = 75,
      width = 300,
      font = alsawidget.notifications.font
    }
  local i = 1;
  while alsawidget.notifications.icons[i + 1] ~= nil
  do
    i = i + 1
  end
  if i >= 2
  then
    preset.icon_size = alsawidget.notifications.icon_size
    if alsawidget._muted or alsawidget._current_level == 0
    then
      preset.icon = alsawidget.notifications.icons[1]
    elseif alsawidget._current_level == 100
    then
      preset.icon = alsawidget.notifications.icons[i]
    else
      local int = math.modf (alsawidget._current_level / 100 * (i - 1))
      preset.icon = alsawidget.notifications.icons[int + 2]
    end
  end
  if alsawidget._muted
  then
    preset.title = alsawidget.channel .. " - Muted"
  elseif alsawidget._current_level == 0
  then
    preset.title = alsawidget.channel .. " - 0% (muted)"
    preset.text = "[" .. string.rep (" ", alsawidget.notifications.bar_size) .. "]"
  elseif alsawidget._current_level == 100
  then
    preset.title = alsawidget.channel .. " - 100% (max)"
    preset.text = "[" .. string.rep ("|", alsawidget.notifications.bar_size) .. "]"
  else
    local int = math.modf (alsawidget._current_level / 100 * alsawidget.notifications.bar_size)
    preset.title = alsawidget.channel .. " - " .. alsawidget._current_level .. "%"
    preset.text = "[" .. string.rep ("|", int) .. string.rep (" ", alsawidget.notifications.bar_size - int) .. "]"
  end
  if alsawidget._notify ~= nil
  then
    alsawidget._notify = naughty.notify (
      {
        replaces_id = alsawidget._notify.id,
        preset = preset
    })
  else
    alsawidget._notify = naughty.notify ({ preset = preset })
	end
end
-- register the widget through vicious
vicious.register (alsawidget.bar, vicious.widgets.volume, function (widget, args)
                    alsawidget._current_level = args[1]
                    if args[2] == "♩"
                    then
                      alsawidget._muted = true
                      alsawidget.tooltip:set_text (" [Muted] ")
                      widget:set_color (alsawidget.colors.mute)
                      return 100
                    end
                    alsawidget._muted = false
                    alsawidget.tooltip:set_text (" " .. alsawidget.channel .. ": " .. args[1] .. "% ")
                    widget:set_color (alsawidget.colors.unmute)
                    return args[1]
                                                          end, 5, alsawidget.channel) -- relatively high update time, use of keys/mouse will force update


-- net widgets
net_wired = net_widgets.indicator({
      interfaces = {"enp2s0"},
      timeout = 5
})


-- create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
	 if c == client.focus then
	    c.minimized = true
	 else
	    -- Without this, the following
	    -- :isvisible() makes no sense
	    c.minimized = false
	    if not c:isvisible() then
	       awful.tag.viewonly(c:tags()[1])
	    end
	    -- This will also un-minimize
	    -- the client, if needed
	    client.focus = c
	    c:raise()
	 end
   end),
   awful.button({ }, 3, function ()
	 if instance then
	    instance:hide()
	    instance = nil
	 else
	    instance = awful.menu.clients({ width=250 })
	 end
   end),
   awful.button({ }, 4, function ()
	 awful.client.focus.byidx(1)
	 if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 5, function ()
	 awful.client.focus.byidx(-1)
	 if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
			     awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			     awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			     awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			     awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   --left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   if s == 1 then right_layout:add(wibox.widget.systray()) end
   --    right_layout:add(separator)
   --    right_layout:add(pacwidget)
   -- right_layout:add(separator)
   right_layout:add(alsawidget.bar)
   right_layout:add(separator)
   right_layout:add(net_wired)
   right_layout:add(separator)
   right_layout:add(kbdwidget)
   right_layout:add(separator)
   right_layout:add(mytextclock)
   right_layout:add(separator)

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

-------------------------------------------------------------------------------
--	Скан-коды клавиш
-------------------------------------------------------------------------------
key_S = "#39"
key_J = "#44"
key_K = "#45"
key_N = "#57"
key_M = "#58"
key_F = "#41"
key_R = "#27"
key_L = "#46"
key_C = "#54"
key_W = "#25"
key_Q = "#24"
key_H = "#43"
key_Tab = "#23"
key_Tilda = "#49"
key_U = "#30"
key_I = "#31"
key_T = "#28"
key_P = "#33"
key_O = "#32"
key_Return = "#36"
key_Left = "#113"
key_Right = "#114"
key_Esc = "#9"
key_PrtScn = "#107"
key_Space = "#65"
key_X = "#53"
key_D = "#64"

-------------------------------------------------------------------------------
--	Кнопки мыши
-------------------------------------------------------------------------------
left_button = 1
right_button = 3
wheel_button = 2
plus_button = 9
minus_button = 8

-- {{{ Key bindings
globalkeys = awful.util.table.join(

   awful.key({ "Control" }, "#10",  function ()
	 awful.util.spawn_with_shell("setxkbmap us")
	 kbdwidget:set_image ( kbd_img_path .. "us.png")
   end),

   awful.key({ "Control" }, "#11",  function ()
	 awful.util.spawn_with_shell("setxkbmap ru")
	 kbdwidget:set_image ( kbd_img_path .. "ru.png")
   end),


   awful.key({ modkey,           }, key_Left,   awful.tag.viewprev       ),
   awful.key({ modkey,           }, key_Right,  awful.tag.viewnext       ),
   awful.key({ modkey,           }, key_Escape, awful.tag.history.restore),

   awful.key({ modkey,           }, key_J,
      function ()
	 awful.client.focus.byidx( 1)
	 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, key_K,
      function ()
	 awful.client.focus.byidx(-1)
	 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, key_W, function () mymainmenu:show() end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, key_J, function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, key_K, function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, key_J, function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, key_K, function () awful.screen.focus_relative(-1) end),
   awful.key({ modkey,           }, key_U, awful.client.urgent.jumpto),
   awful.key({ modkey,           }, key_Tab,
      function ()
	 awful.client.focus.history.previous()
	 if client.focus then
	    client.focus:raise()
	 end
   end),
   awful.key({ modkey,           }, key_Return, function () awful.util.spawn(terminal) end),
   awful.key({ modkey, "Control" }, key_R, awesome.restart),
   awful.key({ modkey, "Shift"   }, key_Q, awesome.quit),

   awful.key({ modkey,           }, key_L,     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, key_H,     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, key_H,     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, key_L,     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, key_H,     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, key_L,     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, key_Space, function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, key_Space, function () awful.layout.inc(layouts, -1) end),
   awful.key({ modkey, "Shift"  }, key_R, function () awful.util.spawn_with_shell("systemctl reboot") end),
   awful.key({ modkey, "Shift"  }, key_S, function () awful.util.spawn_with_shell("systemctl poweroff") end),
   awful.key({ modkey,          }, "d", function () awful.util.spawn_with_shell("/usr/bin/rofi -show run") end),

   awful.key({ modkey, "Control" }, key_N, awful.client.restore),

   -- Prompt
   awful.key({ modkey },            key_R,     function () mypromptbox[mouse.screen]:run() end),

   awful.key({ modkey }, key_X,
      function ()
	 awful.prompt.run({ prompt = "Run Lua code: " },
	    mypromptbox[mouse.screen].widget,
	    awful.util.eval, nil,
	    awful.util.getdir("cache") .. "/history_eval")
   end),
   -- Menubar
   awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, key_F,      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, key_C,      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, key_Space,  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, key_Return, function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, key_O,      awful.client.movetoscreen                        ),
   awful.key({ modkey,           }, key_T,      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, key_N,
      function (c)
	 -- The client currently has the input focus, so it cannot be
	 -- minimized, since minimized clients can't have the focus.
	 c.minimized = true
   end),
   awful.key({ modkey,           }, key_M,
      function (c)
	 c.maximized_horizontal = not c.maximized_horizontal
	 c.maximized_vertical   = not c.maximized_vertical
   end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
				      awful.key({ modkey }, "#" .. i + 9,
					 function ()
					    local screen = mouse.screen
					    if tags[screen][i] then
					       awful.tag.viewonly(tags[screen][i])
					    end
				      end),
				      awful.key({ modkey, "Control" }, "#" .. i + 9,
					 function ()
					    local screen = mouse.screen
					    if tags[screen][i] then
					       awful.tag.viewtoggle(tags[screen][i])
					    end
				      end),
				      awful.key({ modkey, "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus and tags[client.focus.screen][i] then
					       awful.client.movetotag(tags[client.focus.screen][i])
					    end
				      end),
				      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus and tags[client.focus.screen][i] then
					       awful.client.toggletag(tags[client.focus.screen][i])
					    end
   end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
		    border_color = beautiful.border_normal,
		    focus = awful.client.focus.filter,
		    keys = clientkeys,
		    maximized_vertical = false,
		    maximized_horizontal = false,
		    buttons = clientbuttons } },
   { rule = { class = "Google-chrome"}, properties = {tag = tags[1][2] } },
   { rule = { class = "Emacs"}, properties = {tag = tags[1][3] } },
   { rule = { class = "Skype"}, properties = {tag = tags[1][5] } },
   { rule = { class = "Transmission-gtk"}, properties = {tag = tags[1][5] } },
   { rule = { class = "qBittorrent"}, properties = {tag = tags[1][5] } },
   --    { rule = { class = "Kdevelop"}, properties = {tag = tags[1][3] } },
   { rule = { class = "pinentry" }, properties = { floating = true } },
   { rule = { class = "gimp" }, properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   { rule = { class = "Firefox" },properties = { tag = tags[1][2], floating = true } },
   { rule = { class = "Tor Browser" },properties = { tag = tags[1][2], floating = true } },
   { rule = { instance = "plugin-container" },
       properties = { onfocus = true, floating = true, border_width = 0, ontip = true, fullscreen = true }
   },
   { rule = { class = "Termite" }, properties = { floating = true } },
}
-- }}}




-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
			 -- Enable sloppy focus
			 -- c:connect_signal("mouse::enter", function(c)
			 --     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			 --         and awful.client.focus.filter(c) then
			 --         client.focus = c
			 --     end
			 -- end)

			 if not startup then
			    -- Set the windows at the slave,
			    -- i.e. put it at the end of others instead of setting it master.
			    -- awful.client.setslave(c)

			    -- Put windows in a smart way, only if they does not set an initial position.
			    if not c.size_hints.user_position and not c.size_hints.program_position then
			       awful.placement.no_overlap(c)
			       awful.placement.no_offscreen(c)
			    end
			 end

			 local titlebars_enabled = false
			 if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
			    -- Widgets that are aligned to the left
			    local left_layout = wibox.layout.fixed.horizontal()
			    left_layout:add(awful.titlebar.widget.iconwidget(c))

			    -- Widgets that are aligned to the right
			    local right_layout = wibox.layout.fixed.horizontal()
			    right_layout:add(awful.titlebar.widget.floatingbutton(c))
			    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
			    right_layout:add(awful.titlebar.widget.stickybutton(c))
			    right_layout:add(awful.titlebar.widget.ontopbutton(c))
			    right_layout:add(awful.titlebar.widget.closebutton(c))

			    -- The title goes in the middle
			    local title = awful.titlebar.widget.titlewidget(c)
			    title:buttons(awful.util.table.join(
					     awful.button({ }, 1, function()
						   client.focus = c
						   c:raise()
						   awful.mouse.client.move(c)
					     end),
					     awful.button({ }, 3, function()
						   client.focus = c
						   c:raise()
						   awful.mouse.client.resize(c)
					     end)
			    ))

			    -- Now bring it all together
			    local layout = wibox.layout.align.horizontal()
			    layout:set_left(left_layout)
			    layout:set_right(right_layout)
			    layout:set_middle(title)

			    awful.titlebar(c):set_widget(layout)
			 end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus
			 c.opacity = 1
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal
			 c.opacity = 0.4
end)
-- }}}

