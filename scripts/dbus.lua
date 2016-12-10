local naugty = require("naughty")

if dbus.request_name("session", "com.example.service") then
   naughty.notify({ preset = naughty.config.presets.critical,
		    title = "Ok.",
		    text = "True." })
end


dbus.add_match("session", "interface = 'com.example.service' member = 'HelloSignal' ")
dbus.connect_signal("com.example.service.Signal", function()
		       naughty.notify({ preset = naughty.config.presets.critical,
					title = "Hello.",
					text = "Signal." })
		       
)
