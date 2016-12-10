local wibox   = require("wibox")
local awful   = require("awful")
local naughty = require("naughty")


kbd_img_path = "/home/napalm/.config/awesome/scripts/kbd/"
kbdwidget = wibox.widget.imagebox(kbd_img_path .. "us.png")

t = {["0"] = "US", ["1"] = "RU"}
kbd_state = 0
text = ""
title = ""



function setUs_layout()

   awful.util.spawn_with_shell("setxkbmap us")
   kbdwidget:set_image ( kbd_img_path .. "us.png") 
   kbd_state = 0

end


function setRu_layout()

   awful.util.spawn_with_shell("setxkbmap ru")
   kbdwidget:set_image ( kbd_img_path .. "ru.png") 
   kbd_state = 1

end

kbdwidget:buttons(awful.util.table.join(awful.button( { }, 1, 
						     function() 
							if kbd_state <= 0 then 

							   setRu_layout()
							elseif kbd_state >= 1 then
                               setUs_layout()
							end
						     end
						    )))



kbdwidget:connect_signal("mouse::enter", 
			 function()

			    kbdwidget.notify = naughty.notify({
								 text =  t[tostring(kbd_state)],
								 title,
								 timeout = 0			
							      })
			 end)

kbdwidget:connect_signal("mouse::leave", 
			 function()
			    if naughty.notify then 
			       naughty.destroy(kbdwidget.notify)
			       kbdwidget.notify = nil
			    end
			 end)
