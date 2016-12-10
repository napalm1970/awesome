local naughty = require("naughty")
local wibox = require("wibox")
local awful = require("awful")

text = ""
titpe  = ""


pacwidget = wibox.widget.textbox()

function Mesg(text, title)
   pacwidget.notify = naughty.notify({
         text ,
         title ,
         timeout = 10
   })
end



pacwidget.list = ""
pacwidget.timer = timer({ timeout = 3600 })
pacwidget.timer:connect_signal("timeout" ,
                               function()

                                  local io = { popen = io.popen }

                                  if os.execute("yaourt -Sy")   then

                                     local s = io.popen("yaourt -Qu")
                                     local count = 0
                                     local str = ''

                                     for line in s:lines() do
                                        count = count + 1
                                        str = str .. line .. "\n"
                                     end


                                     if count > 0 then

                                        pacwidget:set_text("U: " .. tostring(count) .. ' ')
                                        pacwidget.list = str
                                        naughty.notify({
                                              text = "Имеется ".. tostring(count) .. " обновлений."  ,
                                              title = " " ,
                                              timeout = 20
                                        })

                                        s:close()
                                     else
                                        pacwidget:set_text("")
                                        pacwidget.list = str
                                        s:close()
                                     end

                                  else
                                     naughty.notify({
                                           text = "False",
                                           title = " " ,
                                           timeout = 10
                                     })
                                  end

end)


pacwidget.timer:start()
pacwidget.notify = nil

pacwidget:connect_signal("mouse::enter",
                         function()
                            pacwidget.notify = naughty.notify({
                                  text = pacwidget.list,
                                  title = "Updates: ",
                                  timeout = 0
                            })
end)

pacwidget:connect_signal("mouse::leave",
                         function()
                            if naughty.notify then
                               naughty.destroy(pacwidget.notify)
                               pacwidget.notify = nil
                            end
end)
