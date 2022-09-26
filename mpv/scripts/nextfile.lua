local msg = require "mp.msg"
local utils = require "mp.utils"
local options = require "mp.options"

local settings = {

    --filetypes,{'*mp4','*mkv'} for specific or {'*'} for all filetypes
    filetypes = {'*mkv','*mp4','*jpg','*gif','*png','*flv','*avi','*ts','*3gp','*aac','*webm','*mov','*MOV','*VOB','*mpg'}, 

    --linux(true)/windows(false)
    linux_over_windows = true,

    --at end of directory jump to start and vice versa
    allow_looping = true

}

function osd(str)
    return mp.osd_message(str, 3)
end

function on_loaded()
    path = string.sub(mp.get_property("path"), 1, string.len(mp.get_property("path"))-string.len(mp.get_property("filename")))
    print("on_loaded: "..mp.get_property("path"))
    file = mp.get_property("filename")
    print("on_loaded: "..file)
end

function nexthandler()
  movetofile(true)
end

function prevhandler()
  movetofile(false)
end

function saveto()
    osd("saving file to nature")
    local outpath = '/home/administrator/saved_vids'
    --local outpath = "/home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/temple_live_dont_delete/gaur_poornima_march_12_2017_mumbai_WITH_RNS/rns_jagannath_gaur/donw/lat"
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)
    utils.subprocess({args = {'cp','--backup=numbered',inpath,outpath}, cancellable = false})
end

function refresh()
    osd("refreshing")
    local outpath = '/home/simha_personal_data/multimedia_audio_video_image/Videos/nature'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)

    -- seconds = 0
    -- timer = mp.add_periodic_timer(1, function()
    -- print("called every second")
    -- osd(seconds)
    -- # stop it after 10 seconds
    -- seconds = seconds + 1
    -- if seconds >= 10 then
        -- timer:kill()
    -- end
    mp.commandv("loadfile", inpath, "replace")
    mp.command("play")
end

function saveto2()
    osd("saving file to nature")
    local outpath = '/home/administrator/saved_vids'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)
    utils.subprocess({args = {'cp','--backup=numbered',inpath,outpath}, cancellable = false})
end

function refresh()
    osd("refreshing")
    local outpath = '/home/simha_personal_data/multimedia_audio_video_image/Videos/nature'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)

    -- seconds = 0
    -- timer = mp.add_periodic_timer(1, function()
    -- print("called every second")
    -- osd(seconds)
    -- # stop it after 10 seconds
    -- seconds = seconds + 1
    -- if seconds >= 10 then
        -- timer:kill()
    -- end
    mp.commandv("loadfile", inpath, "replace")
    mp.command("play")
end

function escape(str)
    return str:gsub("\\", "\\\\"):gsub("'", "'\\''")
end


function movetofile(forward)
    print('forward: '..tostring(forward))
    local search = ' '
    for w in pairs(settings.filetypes) do
        if settings.linux_over_windows then
      search = search..string.gsub(path, "%s+", "\\ ")..settings.filetypes[w]..' '
        else
            search = search..'"'..path..settings.filetypes[w]..'" '
        end
    end

    print('search: '..search)
    print('find: find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')


-- custom added to see the files order
    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        testcount=1
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
        for dirx in popen:lines() do
            print("["..tostring(testcount).."]: "..'dirx: '..dirx)
            testcount=testcount+1
        end
    else
        popen = io.popen('dir /b '..search) 
    end
-- custom added to see the files order


    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen = io.popen('dir /b '..search) 
    end

    local popen2=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen2 = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen2 = io.popen('dir /b '..search) 
    end

    print("popen: "..tostring(popen))
    if popen then
        local found = false
        local memory = nil
        local lastfile = true
        local firstfile = nil

        total_count = 0
        for dirx in popen2:lines() do
            total_count = total_count + 1
        end
        popen2:close()
        local count = 0
        for dirx in popen:lines() do
            print('file[dirx in popen:lines()]: '..file)
            print('count[dirx in popen:lines()]: '..tostring(count))
            print('dirx[dirx in popen:lines()]: '..dirx)
            print('found[dirx in popen:lines()]: '..tostring(found))
            if found == true then
                print('dirx:[found == true]'..dirx)
                count = count + 1
                print(tostring(count).."/"..tostring(total_count))
                mp.osd_message(tostring(count).."/"..tostring(total_count),10000)
                mp.commandv("loadfile", path..dirx, "replace")
                mp.set_property("pause", "no")

                --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

                --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
                --mp.commandv("quit")
                

                lastfile=false
                break
            end
            if dirx == file then
                found = true
                print('dirx:[dirx == file]'..dirx)
                if not forward then
                  lastfile=false 
                  if settings.allow_looping and firstfile==nil then 
                    found=false
                  else
                    if firstfile==nil then break end
                    print(tostring(count).."/"..tostring(total_count))
                    mp.osd_message(tostring(count).."/"..tostring(total_count),10000)
                    mp.commandv("loadfile", path..memory, "replace")
                    mp.set_property("pause", "no")
                    --mp.commandv("quit")
                    --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

                    --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
                    break
                  end
                end
            end
            memory = dirx
            if firstfile==nil then
                firstfile=dirx
            end
            print('firstfile: '..firstfile)
            count = count + 1
        end
        if lastfile and settings.allow_looping then
            print('firstfile [lastfile and settings.allow_looping]: '..firstfile)
            print("1/"..tostring(total_count),10000)
            mp.osd_message("1/"..tostring(total_count),10000)
            mp.commandv("loadfile", path..firstfile, "replace")
            mp.set_property("pause", "no")
            --mp.commandv("quit")
            --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

            --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
        end
        if not found then
            print('memory [if not found then]: '..memory)
            print(tostring(total_count).."/"..tostring(total_count))
            mp.osd_message(tostring(total_count).."/"..tostring(total_count),10000)
            mp.commandv("loadfile", path..memory, "replace")
            mp.set_property("pause", "no")
            --mp.commandv("quit")
            --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

            --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
        end

        popen:close()
    else
        print("error: could not scan for files")
    end
end



function show_location()
    path2 = string.sub(mp.get_property("path"), 1, string.len(mp.get_property("path"))-string.len(mp.get_property("filename")))
    print("show_location: "..mp.get_property("path"))
    file2 = mp.get_property("filename")
    print("show_location: "..file2)
    mp.osd_message(file2)

    local search = ' '
    for w in pairs(settings.filetypes) do
        if settings.linux_over_windows then
      search = search..string.gsub(path, "%s+", "\\ ")..settings.filetypes[w]..' '
        else
            search = search..'"'..path..settings.filetypes[w]..'" '
        end
    end

    print('search: '..search)
    print('find: find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')


-- custom added to see the files order
    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        testcount=1
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
        for dirx in popen:lines() do
            print("["..tostring(testcount).."]: "..'dirx: '..dirx)
            testcount=testcount+1
        end
    else
        popen = io.popen('dir /b '..search) 
    end
-- custom added to see the files order


    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen = io.popen('dir /b '..search) 
    end

    local popen2=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen2 = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen2 = io.popen('dir /b '..search) 
    end

    print("popen: "..tostring(popen))
    if popen then

        local total_count = 0
        for dirx in popen2:lines() do
            total_count = total_count + 1
        end
        popen2:close()

        local count = 0
        found = false
        for dirx in popen:lines() do
            print('count: '..tostring(count))
            print('dirx: '..dirx)
            print('file: '..file2)
            print('found: '..tostring(found))
            if dirx == file2 then
                found = true
            end
            print('found: '..tostring(found))
            if found == true then
                print('dirx:[found == true]'..dirx)
                count = count + 1
                mp.osd_message(tostring(count).."/"..tostring(total_count),10000)
                break
            end
            count = count + 1
        end
        popen:close()
    end
end

function deletefile(forward)
    path = string.sub(mp.get_property("path"), 1, string.len(mp.get_property("path"))-string.len(mp.get_property("filename")))
    print("deletefile: "..mp.get_property("path"))
    file = mp.get_property("filename")
    print("deletefile: "..file)
    print("on_loaded: "..file)
    print('forward: '..tostring(forward))
    forward=true
    local search = ' '
    for w in pairs(settings.filetypes) do
        if settings.linux_over_windows then
      search = search..string.gsub(path, "%s+", "\\ ")..settings.filetypes[w]..' '
        else
            search = search..'"'..path..settings.filetypes[w]..'" '
        end
    end

    print('search: '..search)
    print('find: find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')


-- custom added to see the files order
    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        testcount=1
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
        for dirx in popen:lines() do
            print("["..tostring(testcount).."]: "..'dirx: '..dirx)
            testcount=testcount+1
        end
    else
        popen = io.popen('dir /b '..search) 
    end
-- custom added to see the files order


    local popen=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen = io.popen('dir /b '..search) 
    end

    local popen2=nil
    if settings.linux_over_windows then
        print('search: '..search)
        popen2 = io.popen('find '..search..' -type f -size +10k -printf "%f\\n" 2>/dev/null')
    else
        popen2 = io.popen('dir /b '..search) 
    end

    print("popen: "..tostring(popen))
    if popen then
        local found = false
        local memory = nil
        local lastfile = true
        local firstfile = nil

        total_count = 0
        for dirx in popen2:lines() do
            total_count = total_count + 1
        end
        popen2:close()
        local count = 0
        for dirx in popen:lines() do
            print('file[dirx in popen:lines()]: '..file)
            print('count[dirx in popen:lines()]: '..tostring(count))
            print('dirx[dirx in popen:lines()]: '..dirx)
            print('found[dirx in popen:lines()]: '..tostring(found))
            if found == true then
                print('dirx:[found == true]'..dirx)
                count = count + 1
                print(tostring(count).."/"..tostring(total_count))
                mp.osd_message(tostring(count).."/"..tostring(total_count),10000)
                mp.commandv("loadfile", path..dirx, "replace")
                mp.set_property("pause", "no")

                --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

                --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
                --mp.commandv("quit")
                

                lastfile=false
                break
            end
            if dirx == file then
                found = true
                print('dirx:[dirx == file]'..dirx)
                if not forward then
                  lastfile=false 
                  if settings.allow_looping and firstfile==nil then 
                    found=false
                  else
                    if firstfile==nil then break end
                    print(tostring(count).."/"..tostring(total_count))
                    mp.osd_message(tostring(count).."/"..tostring(total_count),10000)
                    mp.commandv("loadfile", path..memory, "replace")
                    mp.set_property("pause", "no")
                    --mp.commandv("quit")
                    --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

                    --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
                    break
                  end
                end
            end
            memory = dirx
            if firstfile==nil then
                firstfile=dirx
            end
            print('firstfile: '..firstfile)
            count = count + 1
        end
        if lastfile and settings.allow_looping then
            print('firstfile [lastfile and settings.allow_looping]: '..firstfile)
            print("1/"..tostring(total_count),10000)
            mp.osd_message("1/"..tostring(total_count),10000)
            mp.commandv("loadfile", path..firstfile, "replace")
            mp.set_property("pause", "no")
            --mp.commandv("quit")
            --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

            --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
        end
        if not found then
            print('memory [if not found then]: '..memory)
            print(tostring(total_count).."/"..tostring(total_count))
            mp.osd_message(tostring(total_count).."/"..tostring(total_count),10000)
            mp.commandv("loadfile", path..memory, "replace")
            mp.set_property("pause", "no")
            --mp.commandv("quit")
            --local outfield = "mpv --keep-open --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --mute=yes --loop=inf --geometry=20:20 " ..path..dirx

            --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
        end

        popen:close()
    else
        print("error: could not scan for files")
    end
    print("filename:ending: "..path..file)
    mp.commandv("run", "/usr/bin/rm", path..file)

end


function moveto1()
    osd("saving file to nature")
    local outpath = '/home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/temple_live_dont_delete/gaur_poornima_march_12_2017_mumbai_WITH_RNS/rns_jagannath_gaur/donw/other_oher/mov/vd/001'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)
    utils.subprocess({args = {'mv',inpath,outpath}, cancellable = false})
end

function moveto2()
    osd("saving file to nature")
    local outpath = '/home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/temple_live_dont_delete/gaur_poornima_march_12_2017_mumbai_WITH_RNS/rns_jagannath_gaur/donw/other_oher/mov/vd/002'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)
    utils.subprocess({args = {'mv',inpath,outpath}, cancellable = false})
end

function moveto3()
    osd("saving file to nature")
    local outpath = '/home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/temple_live_dont_delete/gaur_poornima_march_12_2017_mumbai_WITH_RNS/rns_jagannath_gaur/donw/other_oher/mov/vd/003'
    local inpath = escape(utils.join_path(
                    utils.getcwd(),
                    mp.get_property("stream-path")))
    local file1 = mp.get_property("stream-path")
    mp.msg.info(file1)
    mp.msg.info(inpath)
    utils.subprocess({args = {'mv',inpath,outpath}, cancellable = false})
end

mp.add_key_binding('SHIFT+UP', 'nextfile', nexthandler)
mp.add_key_binding('SHIFT+DOWN', 'previousfile', prevhandler)
mp.add_key_binding("a", 'deletfile', deletefile)
mp.add_key_binding('SHIFT+S', 'saveto', saveto)
mp.add_key_binding('SHIFT+ALT+S', 'saveto2', saveto2)
mp.add_key_binding('ctrl+1', 'moveto1', moveto1)
mp.add_key_binding('ctrl+2', 'moveto2', moveto2)
mp.add_key_binding('ctrl+3', 'moveto3', moveto3)
mp.register_event('file-loaded', on_loaded)
mp.register_script_message("show_location", show_location)
mp.add_key_binding('y', 'refresh', refresh)