##########################   BIGBRO    ########################################

local naughty = require("naughty")


dbus.add_match("system", "type='signal', interface='org.wicd.daemon', member='StatusChanged', path='/org/wicd/daemon'")
dbus.connect_signal("org.wicd.daemon", 
		    function(data, state, info)
		       if data.member == "StatusChanged" then
			  if state == 0 then
			     naughty.notify({ 
					       title = "Oops, Alarm!",
					       text = "Signal is DOWN.",
					       timeout = 3})
			  elseif state == 3 then
			     
			     naughty.notify({ 
					       title = "Yeeessss!",
					       text = "Signal is UP.",
					       timeout = 3})

			  end
		       end
		    end
)

