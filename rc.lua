local gears      = require("gears")
local awful      = require("awful")
awful.rules      = require("awful.rules")
                   require("awful.autofocus")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local vicious    = require("vicious")
local naughty    = require("naughty")
local lain       = require("lain")
local cyclefocus = require('cyclefocus')
local menubar    = require("menubar")

-- | Theme | --

local theme = "pro-dark"

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
-- Must be called after beautiful.init
--local APW        = require("apw/widget")

-- | Error handling | --

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- | Fix's | --

-- Disable cursor animation:

local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- Java GUI's fix:

awful.util.spawn_with_shell("wmname LG3D")

-- | Variable definitions | --

local home   = os.getenv("HOME")
local exec   = function (s) oldspawn(s, false) end
local shexec = awful.util.spawn_with_shell

modkey        = "Mod4"
terminal      = "konsole"
tmux          = "konsole -e tmux"
termax        = "konsole --geometry 1680x1034+0+22"
htop          = "konsole --geometry 1024x600+0+22 -e htop"
rootterm      = "sudo -i konsole"
browser       = "firefox"
filemanager   = "dolphin"
configuration = termax .. ' -e "vim -O $HOME/.config/awesome/rc.lua $HOME/.config/awesome/themes/' ..theme.. '/theme.lua"'

-- | Table of layouts | --

local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top
}

-- | Tags | --

tags = {}
for s = 1, screen.count() do
    tags[s] = awful.tag({ "  ", "  ", "  ", "  ", "  " }, s, layouts[1])
end

---- | Wallpaper | --
--
--if beautiful.wallpaper then
--    for s = 1, screen.count() do
--        -- gears.wallpaper.tiled(beautiful.wallpaper, s)
--        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--    end
--end

local wallpaper_path = home .. "/Dropbox/Wallpapers/"
local wp={
  {wallpaper_path .. "boulder-1920x1080.png"                  , wallpaper_path .. "ezhik-v-tumane-1920x1080.jpg"},
  {wallpaper_path .. "kremlyovskaya-dolina-zima-1920x1080.jpg", wallpaper_path .. "1920x1080.jpg"},
  {wallpaper_path .. "nz3d-1920x1080.jpg"                     , wallpaper_path .. "1370684459-4646adb24b1d3f15d052509afbe600c6-1920x1080.jpg"},
  {wallpaper_path .. "back_to_the_future-1920x1080.jpg"       , wallpaper_path .. "fishing_by_sandara-1920x1080.jpg"},
  {wallpaper_path .. "135847-winter-var2560sf.jpg"            , wallpaper_path .. "vim-move-shortcuts.png"}
}

--error(beautiful.wallpaper)
for s = 1, screen.count() do
    for t = 1, 5 do
        tags[s][t]:connect_signal("property::selected", function (tag)
           if not tag.selected then return end
             beautiful.wallpaper = wp[t][s]
             --gears.wallpaper.maximized(beautiful.wallpaper, s, false)
             -- gears.wallpaper.centered(beautiful.wallpaper, s)
             gears.wallpaper.fit(beautiful.wallpaper, s)
	end)
    end
end
-- }}}

-- | Menu | --
--require("debian.menu")
menu_main = {
  {"Switch user", "qdbus --system org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter"},
  { "hibernate", "systemctl hibernate" },
  { "poweroff",  "sydtemctl poweroff"     },
  { "restart",   awesome.restart     },
  { "reboot",    "sudo reboot"       },
  { "quit",      awesome.quit        }}

mainmenu = awful.menu({ items = {
--  { " Debian", debian.menu.Debian_menu.Debian },
  { " awesome",       menu_main   },
  { " file manager",  filemanager },
  { " root terminal", rootterm    },
  { " user terminal", terminal    }}})

menubar.utils.terminal = terminal
menubar.geometry = {
   height = 32,
   width = 1800,
   x = 32,
   y = 1000
}

-- | Markup | --

markup = lain.util.markup

space3 = markup.font("Terminus 3", " ")
space2 = markup.font("Terminus 2", " ")
vspace1 = '<span font="Terminus 3"> </span>'
vspace2 = '<span font="Terminus 3">  </span>'
clockgf = beautiful.clockgf

-- | Widgets | --

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- | Launchbar | --
local launchbar = require("launchbar")
local mylaunchbar = launchbar(home .. "/.config/awesome/launchbar/")
widget_lb = wibox.widget.imagebox()
--widget_lb:set_image(beautiful.widget_mail)
lbwidget = wibox.widget.background()
lbwidget:set_widget(mylaunchbar)
--lbwidget:set_bgimage(beautiful.widget_display)

-- | Redshift | --

-- Redshift widget
icons_dir = require("lain.helpers").icons_dir
local rs_on = icons_dir .. "/redshift/redshift_on.png"
local rs_off = icons_dir .. "/redshift/redshift_off.png"

local redshift = require("lain.widgets.contrib.redshift")
myredshift = wibox.widget.imagebox(rs_on)
redshift:attach(
    myredshift,
    function ()
        if redshift:is_active() then
            myredshift:set_image(rs_on)
        else
            myredshift:set_image(rs_off)
        end 
    end 
)

-- | Mail | --

--mail_widget = wibox.widget.textbox()
--vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)
--
--widget_mail = wibox.widget.imagebox()
--widget_mail:set_image(beautiful.widget_mail)
--mailwidget = wibox.widget.background()
--mailwidget:set_widget(mail_widget)
--mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(space3 .. string.format("%3d", cpu_now.usage) .. "%" .. markup.font("Tamsyn 4", " "))
    end
})

widget_cpu = wibox.widget.imagebox()
widget_cpu:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_display)

tmp_widget = wibox.widget.textbox()
vicious.register(tmp_widget, vicious.widgets.thermal, vspace1 .. "$1°C" .. vspace1, 9, "thermal_zone0")

widget_tmp = wibox.widget.imagebox()
widget_tmp:set_image(beautiful.widget_tmp)
tmpwidget = wibox.widget.background()
tmpwidget:set_widget(tmp_widget)
tmpwidget:set_bgimage(beautiful.widget_display)

-- | MEM | --

mem_widget = lain.widgets.mem({
    settings = function()
        widget:set_markup(space3 .. mem_now.used .. "MB" .. markup.font("Tamsyn 4", " "))
    end
})

widget_mem = wibox.widget.imagebox()
widget_mem:set_image(beautiful.widget_mem)
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_display)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, vspace1 .. "${/home avail_gb}GB" .. vspace1, 2)

widget_fs = wibox.widget.imagebox()
widget_fs:set_image(beautiful.widget_fs)
fswidget = wibox.widget.background()
fswidget:set_widget(fs_widget)
fswidget:set_bgimage(beautiful.widget_display)

-- | NET | --

net_widgetdl = wibox.widget.textbox()
net_widgetul = lain.widgets.net({
    iface = "enp2s0",
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", "  ") .. string.format("%6.1f",net_now.sent))
        net_widgetdl:set_markup(markup.font("Tamsyn 1", " ") .. string.format("%6.1f",net_now.received) .. markup.font("Tamsyn 1", " "))
    end
})


widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = wibox.widget.background()
netwidgetdl:set_widget(net_widgetdl)
netwidgetdl:set_bgimage(beautiful.widget_display)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = wibox.widget.background()
netwidgetul:set_widget(net_widgetul)
netwidgetul:set_bgimage(beautiful.widget_display)

-- Battery --
--bat = lain.widgets.bat({
--    battery = "BAT0",
--    settings = function()
--        if bat_now.perc == "N/A" then
--            perc = "AC"
--        elseif bat_now.status == "Charging" then           -- Makes indicator green when charging
--            perc = markup(green, bat_now.perc .. "%")      -- See markup section for color setting
--        elseif tonumber(bat_now.perc) <= 15 then
--            perc = markup(red, bat_now.perc .. "%")
--        else
--            perc = bat_now.perc .. "%"
--        end
--        widget:set_markup(markup(blue, "Bat: ") .. perc)
--        widget:set_markup(space3 .. "Bat:" .. perc .. markup.font("Tamsyn 4", " "))
--
--    end
--})
-- Battery
--baticon = wibox.widget.imagebox(beautiful.widget_batt)
--batwidget = lain.widgets.bat({
--    settings = function()
--        if bat_now.perc == "N/A" then
--            perc = "AC "
--        else
--            perc = bat_now.perc .. "% "
--        end
--        widget:set_text(perc)
--    end
--})

-- ALSA volume
--volicon = wibox.widget.imagebox(beautiful.widget_vol)
--volumewidget = lain.widgets.alsa({
--    settings = function()
--        if volume_now.status == "off" then
--            volume_now.level = volume_now.level .. "M"
--        end
--
--        widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
--    end
--})

-- Keyboard layout widget
kb_widget = wibox.widget.textbox(" En ")
kb_widget.border_width = 1
kb_widget.border_color = beautiful.fg_normal
kb_widget:set_text(" En ")

kb_strings = {[0] = " En ",
              [1] = " Ру "}

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
    local data = {...}
    local layout = data[2]
    kb_widget:set_markup(markup.font("Tamsyn 1", " ") .. kb_strings[layout] .. markup.font("Tamsyn 1", " "))
    end
)

widget_kb = wibox.widget.imagebox()
--widget_kb:set_image(beautiful.widget_kb)
kbwidget = wibox.widget.background()
kbwidget:set_widget(kb_widget)
kbwidget:set_bgimage(beautiful.widget_display)


-- | Clock / Calendar | --

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)

local index = 1
local loop_widgets = { mytextclock, mytextcalendar }
local loop_widgets_icons = { beautiful.widget_clock, beautiful.widget_cal }

clockwidget:buttons(awful.util.table.join(awful.button({}, 1,
    function ()
        index = index % #loop_widgets + 1
        clockwidget:set_widget(loop_widgets[index])
        widget_clock:set_image(loop_widgets_icons[index])
    end)))

-- | Weather | --
local read_pipe = require("lain.helpers").read_pipe

myweather = lain.widgets.weather({
    city_id=2179537,
    units="metric",
    settings = function()
        --descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup("#008050", --descr .. " @ " .. 
                                   units .. "°C "))
    end,
    notification_text_fun = function(wn)
        -- time of data forecasted
        local day = string.gsub(read_pipe(string.format("date -d @%d +'%%A %%d'", -- customize date cmd here
                                                        wn["dt"])), "\n", "")

        -- weather condition
        local desc = wn["weather"][1]["description"]

        -- temperatures, units are defined above
        local tmin = math.floor(wn["temp"]["min"])   -- min daily
        local tmax = math.floor(wn["temp"]["max"])   -- max daily
        local tmor = math.floor(wn["temp"]["morn"])  -- morning
        local tday = math.floor(wn["temp"]["day"])   -- day
        local teve = math.floor(wn["temp"]["eve"])   -- evening
        local tnig = math.floor(wn["temp"]["night"]) -- night

        -- pressure, hPa
        local pres = math.floor(wn["pressure"])

        -- humidity, %
        local humi = math.floor(wn["humidity"])

        -- wind speed, miles/hour if units are imperial, meter/sec otherwise 
        local wspe = math.floor(wn["speed"])

        -- wind degrees, meteorological degrees
        local wdeg = math.floor(wn["deg"])

        -- cloudliness, %
        local clou = math.floor(wn["clouds"])

        -- format infos as you like, HTML text markup is allowed
        return string.format("<br><b>%s</b>: %s<br>Temperature: %d - %d °C<br>Pressure: %d hPa<br>Humidity: %d%%<br>Wind: %d m/s at %d°<br>Cloudiness: %d%%<br>", day, desc, tmin, tmax, pres, humi, wspe, wdeg, clou)
    end,

})
--http://openweathermap.org/city/2179537

-- 
-- weatherwidget = wibox.widget.textbox()
-- weatherwidget:set_text(awful.util.pread(
--    "weather NZWN --metric --headers=Temperature --quiet | awk '{print $2, $3}'"
-- )) -- replace ZIP with the ID for your area. If you prefer Metric add "-m".
-- weathertimer = timer(
--    { timeout = 900 } -- Update every 15 minutes.
-- )
-- weathertimer:connect_signal(
--    "timeout", function()
--       weatherwidget:set_text(awful.util.pread(
--          "weather NZWN --headers=Temperature --quiet | awk '{print $2, $3}' &"
--       ))end)
-- 
-- weathertimer:start() -- Start the timer
-- weatherwidget:connect_signal(
--    "mouse::enter", function()
--       weather = naughty.notify(
--          {title="Weather",text=awful.util.pread("weather NZWN")})
-- end) -- this creates the hover feature.
-- 
-- weatherwidget:connect_signal(
--    "mouse::leave", function()
--       naughty.destroy(weather)
-- end)
-- 


-- | Taglist | --

mytaglist         = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )

-- | Tasklist | --

mytasklist         = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
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

-- | PANEL | --

mywibox           = {}
mypromptbox       = {}
mylayoutbox       = {}

for s = 1, screen.count() do
   
    mypromptbox[s] = awful.widget.prompt()
    
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr5px)
    left_layout:add(mytaglist[s])
    left_layout:add(spr5px)
    if s == 1 then
        left_layout:add(spr)
        left_layout:add(spr5px)
        left_layout:add(lbwidget)
        left_layout:add(spr5px)
        left_layout:add(spr)
        left_layout:add(spr5px)
        left_layout:add(mypromptbox[s])
    end

    local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(spr)
    if s == 1 then
        right_layout:add(spr5px)
        right_layout:add(wibox.widget.systray())
        right_layout:add(spr5px)
        right_layout:add(spr)
        right_layout:add(myredshift)

        right_layout:add(myweather)
        right_layout:add(myweather.icon)

        right_layout:add(spr5px)
        right_layout:add(spr)

        right_layout:add(widget_cpu)
        right_layout:add(widget_display_l)
        right_layout:add(cpuwidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)

        right_layout:add(widget_tmp)
        right_layout:add(widget_display_l)
        right_layout:add(tmpwidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)

        right_layout:add(spr)
        right_layout:add(widget_mem)
        right_layout:add(widget_display_l)
        right_layout:add(memwidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)

        right_layout:add(spr)
        right_layout:add(widget_fs)
        right_layout:add(widget_display_l)
        right_layout:add(fswidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)

        right_layout:add(spr)
        right_layout:add(widget_netdl)
        right_layout:add(widget_display_l)
        right_layout:add(netwidgetdl)
        right_layout:add(widget_display_c)
        right_layout:add(netwidgetul)
        right_layout:add(widget_display_r)
        right_layout:add(widget_netul)
        right_layout:add(spr5px)

        right_layout:add(spr)
        right_layout:add(widget_clock)
        right_layout:add(widget_display_l)
        right_layout:add(clockwidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)

        right_layout:add(spr)
        --right_layout:add(widget_kb)
        right_layout:add(widget_display_l)
        right_layout:add(kbwidget)
        right_layout:add(widget_display_r)
        right_layout:add(spr5px)
        right_layout:add(spr)
    end

    right_layout:add(mylayoutbox[s])

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_bg(beautiful.panel)

    mywibox[s]:set_widget(layout)
end

-- | Mouse bindings | --

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 5, awful.tag.viewnext),
    awful.button({ }, 4, awful.tag.viewprev)
))

-- | Key bindings | --


globalkeys = awful.util.table.join(

    awful.key({ modkey,           }, "w",      function () mainmenu:show() end),
    awful.key({ modkey            }, "r",      function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- awful.key({ modkey,           }, "Tab",
    --     function ()
    --         awful.client.focus.history.previous()
    --         if client.focus then
    --             client.focus:raise()
    --         end
    --     end),
    -- awful.key({ modkey,         }, "Tab", function(c)
    --         cyclefocus.cycle(1, {modifier="Super_L"})
    -- end),
    -- awful.key({ modkey, "Shift" }, "Tab", function(c)
    --         cyclefocus.cycle(-1, {modifier="Super_L"})
    -- end),
    cyclefocus.key({ "Mod1", }, "Tab", 1, {
        cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
        keys = {'Tab', 'ISO_Left_Tab'}
    }),
    awful.key({ modkey, "Control" }, "t", function () redshift:toggle() end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),
    -- Menubar
    awful.key({ modkey,           }, "p", function() menubar.show() end),
    awful.key({ modkey,           }, "Return", function () exec(terminal) end),
    awful.key({ modkey, "Control" }, "Return", function () exec(rootterm) end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
    -- awful.key({ modkey            }, "a",      function () shexec(configuration) end),
    awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("xscreensaver-command -lock") end),

--    awful.key({ }, "XF86AudioRaiseVolume", function ()
--       awful.util.spawn("pactl set-sink-volume 1 +5%", false) end),
--    awful.key({ }, "XF86AudioLowerVolume", function ()
--       awful.util.spawn("pactl set-sink-volume 1 -5%", false) end),
--    awful.key({ }, "XF86AudioMute", function ()
--       awful.util.spawn("pactl set-sink-mute 1 toggle", false) end),
--    awful.key({ }, "XF86AudioRaiseVolume",  APW.Up),
--    awful.key({ }, "XF86AudioLowerVolume",  APW.Down),
--    awful.key({ }, "XF86AudioMute",         APW.ToggleMute),

    awful.key({ "Mod1" }, "Shift_R", function () awful.util.spawn("dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:0") end),
    awful.key({ "Mod1" }, "Shift_L", function () awful.util.spawn("dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:1") end),
    awful.key({ }, "#197", function () awful.util.spawn("systemctl suspend") end)
)

local wa = screen[mouse.screen].workarea
ww = wa.width
wh = wa.height
ph = 22 -- (panel height)

clientkeys = awful.util.table.join(
    awful.key({ modkey            }, "Next",     function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey            }, "Prior",    function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey            }, "Down",     function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey            }, "Up",       function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey            }, "Left",     function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey            }, "Right",    function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey, "Control" }, "KP_Left",  function (c) c:geometry( { width = ww / 2, height = wh, x = 0, y = ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Right", function (c) c:geometry( { width = ww / 2, height = wh, x = ww / 2, y = ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Up",    function (c) c:geometry( { width = ww, height = wh / 2, x = 0, y = ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Down",  function (c) c:geometry( { width = ww, height = wh / 2, x = 0, y = wh / 2 + ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Prior", function (c) c:geometry( { width = ww / 2, height = wh / 2, x = ww / 2, y = ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Next",  function (c) c:geometry( { width = ww / 2, height = wh / 2, x = ww / 2, y = wh / 2 + ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Home",  function (c) c:geometry( { width = ww / 2, height = wh / 2, x = 0, y = ph } ) end),
    awful.key({ modkey, "Control" }, "KP_End",   function (c) c:geometry( { width = ww / 2, height = wh / 2, x = 0, y = wh / 2 + ph } ) end),
    awful.key({ modkey, "Control" }, "KP_Begin", function (c) c:geometry( { width = ww, height = wh, x = 0, y = ph } ) end),
    awful.key({ modkey,           }, "f",        function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",        function (c) c:kill() end),
    awful.key({ modkey,           }, "t",
        function (c)
         -- toggle titlebar
            awful.titlebar.toggle(c,"left")
        end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

awful.menu.menu_keys = {
    up    = { "k", "Up" },
    down  = { "j", "Down" },
    exec  = { "l", "Return", "Space" },
    enter = { "l", "Right" },
    back  = { "h", "Left" },
    close = { "q", "Escape" }
}

root.keys(globalkeys)

-- | Rules | --

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     -- size_hints_honor = false,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "gcolor2" },
      properties = { floating = true } },
    { rule = { class = "xmag" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
}

-- | Signals | --

autoraise_target = nil
autoraise_timer = timer { timeout = 0.5 }
autoraise_timer:connect_signal("timeout", function()
    if (autoraise_target and autoraise_target.valid) then autoraise_target:raise() end
autoraise_timer:stop()
end)

--client.connect_signal("mouse::enter", function(c)
--    autoraise_target = c
--    autoraise_timer:again()
--end)

client.connect_signal("mouse::leave", function(c)
    if autoraise_target == c then autoraise_target = nil end
end)

client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
            --c:raise()
            autoraise_target = c
            autoraise_timer:again()
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
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
                )
        -- Widgets that are aligned to the left
        local bottom_layout = wibox.layout.fixed.vertical()
        --bottom_layout:add(awful.titlebar.widget.iconwidget(c))
        --bottom_layout:buttons(buttons)
        bottom_layout:add(awful.titlebar.widget.minimizebutton(c))
        bottom_layout:add(awful.titlebar.widget.maximizedbutton(c))
        -- bottom_layout:add(awful.titlebar.widget.floatingbutton(c))
        -- Widgets that are aligned to the right
        local top_layout = wibox.layout.fixed.vertical()
        -- top_layout:add(awful.titlebar.widget.floatingbutton(c))
        -- top_layout:add(awful.titlebar.widget.maximizedbutton(c))
        -- top_layout:add(awful.titlebar.widget.stickybutton(c))
        -- top_layout:add(awful.titlebar.widget.ontopbutton(c))
        top_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.vertical()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("right")
        -- middle_layout:add(title)
        middle_layout:add(wibox.layout.rotate(title, "east"))
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.vertical()
        layout:set_bottom(bottom_layout)
        layout:set_top(top_layout)
        layout:set_middle(middle_layout)

        -- awful.titlebar(c):set_widget(layout)
        awful.titlebar(c, {position='left'}):set_widget(layout)
        awful.titlebar.hide(c,"left")
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- | run_once | --

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- | Autostart | --

--os.execute("pkill compton")
run_once("xfce4-power-manager")
run_once("nm-applet")
-- os.execute("xrandr --output DP2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate normal &")
run_once("start-pulseaudio-x11")
run_once("compton --backend glx")
-- run_once("parcellite")
run_once("xscreensaver -nosplash")
os.execute("xset r rate 200 30")
-- os.execute("setxkbmap -layout 'us,ru'")
os.execute("setxkbmap -option '' -option 'numpad:microsoft' -layout 'us,ru'")

os.execute("dropbox start &")
run_once("owncloud")
run_once("kbdd")
run_once("volumeicon")
run_once("udiskie --smart-tray")
