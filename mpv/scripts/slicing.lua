local msg = require "mp.msg"
local utils = require "mp.utils"
local options = require "mp.options"

local cut_pos = nil
local cut_pos_frame = nil
local cut_pos_approx = nil
local copy_audio = true
local o = {
    -- target_dir = "/var/cache/other/kimja",
    target_dir = '/home/simha_personal_data/programming_arch_firefox/extra/Unsorted/vid/varun',
    vcodec = "rawvideo",
    acodec = "pcm_s16le",
    prevf = "",
    vf = "format=yuv444p16$hqvf,scale=in_color_matrix=$matrix,format=bgr24",
    hqvf = "",
    postvf = "",
    opts = "",
    ext = "avi",
    command_template = [[
        ffmpeg -y
         -i '$in'  -ss $shift   -t $duration
        -c:v copy -an '$out.mp4'
    ]],
    command_template_approxlong = [[
        set -x;ffmpeg   -y -ss $shift
         -i '$in' -to $duration
        -c:v mjpeg -qscale:v 4 -preset slow -c:a aac -strict -2 -b:a 128k '$out.$ext'
    ]],
    command_template_audio = [[
        set -x;ffmpeg   -y -ss $shift
         -i '$in' -ss 0 -to $duration
          -c:a aac -strict experimental -ac 2 -ar 32000 -ab 48k '$out.aac'
    ]],
    command_template_audio_old = [[
        set -x;ffmpeg   -y -ss $shift
         -i '$in' -ss 0 -to $duration -vn -acodec copy '$out.aac'
    ]],
    command_template_approxsmall = [[
        set -x;ffmpeg   -y -ss $shift
         -i '$in' -ss 0 -to $duration
        -c:v mjpeg -qscale:v 4 -preset slow -c:a aac -strict -2 -b:a 128k '$out.$ext'
    ]],
    command_template_frame = [[
        avidemux2_cli --video-codec MJPEG --audio-codec AAC --output-format AVI --load '$in' --begin $shift --end $duration --save '$out.$ext'
    ]],
    command_template_simha_mkv = [[
        set -x;mkvmerge -o '$out' --split parts:$start-$end $in 
    ]],
    command_template_simha = [[
        set -x;ffmpeg  -ss $shift -y 
         -i '$in'  -to $duration
        -c copy '$out'
    ]],
    command_template_phase1 = [[
        ffmpeg -y -i $in -c:v libx264 -profile:v high -preset:v ultrafast -b:v 500k -vf scale=-2:400 -movflags +faststart -c:a aac -strict experimental -ac 2 -ar 32000 -ab 50k -pass 1 -f mp4 /dev/null && \
    ]],
    command_template_phase2 = [[
        ffmpeg -y -i $in -c:v libx264 -profile:v high -preset:v faster -b:v 500k  -vf scale=-2:400 -movflags +faststart -c:a aac -strict experimental -ac 2 -ar 32000 -ab 50k -pass 2 $out.mp4
    ]],
}
options.read_options(o)

function timestamp(duration)
    local hours = duration / 3600
    local minutes = duration % 3600 / 60
    local seconds = duration % 60
    return string.format("%02d_%02d_%06.3f", hours, minutes, seconds)
end

function osd(str)
    return mp.osd_message(str, 3)
end

function log(str)
    local logpath = string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        "mpv_slicing.log")
    f = io.open(logpath, "a")
    f:write(string.format("# %s\n%s\n",
        os.date("%Y-%m-%d %H:%M:%S"),
        str))
    f:close()
end

function escape(str)
    return str:gsub("\\", "\\\\"):gsub("'", "'\\''")
end

function trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

function get_csp()
    local csp = mp.get_property("colormatrix")
    if csp == "bt.601" then return "bt601"
        elseif csp == "bt.709" then return "bt709"
        elseif csp == "smpte-240m" then return "smpte240m"
        else
            local err = "Unknown colorspace: " .. csp
            osd(err)
            error(err)
    end
end

function get_outname(shift, endpos)
    local name = mp.get_property("filename")
    local dotidx = name:reverse():find(".", 1, true)
    if dotidx then name = name:sub(1, -dotidx-1) end
    name = name:gsub(" ", "_")
    name = name:gsub(":", "_")
    name = name .. "-whatsapp"
    return name
end

function get_outname_approx(shift, endpos)
    local name = mp.get_property("filename")
    msg.info("n0" .. name)
    local extsimha = name:match "[^.]+$"
    msg.info("ext" .. extsimha)
    local dotidx = name:reverse():find(".", 1, true)
    msg.info(dotidx)
    if dotidx then name = name:sub(1, -dotidx-1) end
    msg.info("n1" .. name)
    name = name:gsub(" ", "_")
    msg.info("n2" .. name)
    name = name .. string.format("_::%s::s%s::%s::to%s::-copy.%s",timestamp(shift), shift,  timestamp(endpos), endpos - shift,extsimha)
     name = name:gsub(":", "_")
    return name
end

function get_outname_simha(shift, endpos)
    local name = mp.get_property("filename")
    local extsimha = name:match "[^.]+$"
    local dotidx = name:reverse():find(".", 1, true)
    if dotidx then name = name:sub(1, -dotidx-1) end
    name = name:gsub(" ", "_")
    name = name .. string.format("_::%s::s%s::%s::to%s::-copy.%s",timestamp(shift), shift,  timestamp(endpos), endpos - shift,extsimha)
    name = name:gsub(":", "_")
    return name
end

function cut(shift, endpos)
    local cmd = trim(o.command_template:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname(shift, endpos)))

    cmd = cmd:gsub("$shift", shift)
    cmd = cmd:gsub("$duration", endpos)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
    
    local outfield = "mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes \"" .. outpath .. "." .. o.ext.."\""


    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result = utils.subprocess({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})

    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
	--		mp.osd_message('Finished')
	--	end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function cut_approx(shift, endpos)
    print(utils.getcwd())
    local cmd = trim(o.command_template_approxlong:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname_approx(shift, endpos)))

    cmd = cmd:gsub("$shift", shift)
    cmd = cmd:gsub("$duration", endpos - shift)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes \"" .. outpath .. "." .. o.ext.."\""



    msg.info(cmd)
    log(cmd)
    msg.info(outfield)
    log(outfield)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    -- local result = utils.subprocess_detached({args = {'xterm','-e',cmd}, cancellable = false})
    local hare = utils.subprocess({args = {'xterm','-e',cmd}, cancellable = false})
    local jimka = utils.subprocess_detached({args = {'xterm','-e',outfield}})
    --msg.info(string.format("jimka %s",jimka))
    --log(jimka)

    --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
    utils.subprocess_detached({args = {'touch','/home/simha/njdfhdkjf'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function quit_new()
    hare = utils.getpid()
    utils.subprocess_detached({args = {'xterm','-T',"PQXYMNL",'-e',"sh /home/simha/.public_html/mpv_top.sh "..utils.getpid()}, cancellable = false})
end

function cut_audio(shift, endpos)
    local cmd = trim(o.command_template_audio:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname_approx(shift, endpos)))

    cmd = cmd:gsub("$shift", shift - 0.5)
    cmd = cmd:gsub("$duration", endpos - shift + 0.5)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "mpv --keep-open  --osd-fractions --force-window=yes --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes " .. outpath .. ".aac"



    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    -- local result = utils.subprocess_detached({args = {'xterm','-e',cmd}, cancellable = false})
    local hare = utils.subprocess({args = {'xterm','-e',cmd}, cancellable = false})
    local jimka = utils.subprocess_detached({args = {'xterm','-e',outfield}})

    --local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function cut_approxsmall(shift, endpos)
    local cmd = trim(o.command_template_approxsmall:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname_approx(shift, endpos)))

    cmd = cmd:gsub("$shift", shift - 0.05)
    cmd = cmd:gsub("$duration", endpos - shift + 0.05)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes \"" .. outpath .. "." .. o.ext.."\""



    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result = utils.subprocess({args = {'xterm','-e',cmd}, cancellable = false})
    local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})
    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function cut_copysimha(shift, endpos)
    print("cut_copysimha :: utils.getcwd() :: "..utils.getcwd())
    print("cut_copysimha :: mp.get_property(\"stream-path\") :: "..mp.get_property("stream-path"))
    local cmd = trim(o.command_template_simha:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst Return the
    -- concatenation of the 2 paths. Tries to be clever. For example, if p2 is
    -- an absolute path, p2 is returned without change.
    print("cut_copysimha :: inpath :: "..inpath)

    -- TODO: Windows?
--[[    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname_simha(shift, endpos)))--]]
    local outpath = escape(string.format("%s/%s",
        utils.split_path(mp.get_property("stream-path")),
        get_outname_simha(shift, endpos)))
    print("cut_copysimha :: utils.split_path(mp.get_property(\"stream-path\") :: "..utils.split_path(mp.get_property("stream-path")))
    print("cut_copysimha :: utils.getcwd() :: "..utils.getcwd())
    print("cut_copysimha :: get_outname_simha(shift, endpos) :: "..get_outname_simha(shift, endpos))
    print("cut_copysimha :: outpath :: "..outpath)

    cmd = cmd:gsub("$start", shift.."s")
    cmd = cmd:gsub("$end", endpos.."s")
    cmd = cmd:gsub("$shift", shift)
    cmd = cmd:gsub("$duration", endpos - shift)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause " .. outpath


    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result = utils.subprocess({args = {'xterm','-e',cmd}, cancellable = false})
    local result2 = utils.subprocess_detached({args = {'xterm','-hold','-e',outfield}})
    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function cut_copysimha_ffmpeg(shift, endpos)
    local cmd = trim(o.command_template_simha_ffmpeg:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname_simha(shift, endpos)))

    cmd = cmd:gsub("$start", shift.."s")
    cmd = cmd:gsub("$end", endpos.."s")
    cmd = cmd:gsub("$shift", shift)
    cmd = cmd:gsub("$duration", endpos - shift)
    cmd = cmd:gsub("$vcodec", o.vcodec)
    cmd = cmd:gsub("$acodec", o.acodec)
    cmd = cmd:gsub("$audio", copy_audio and "" or "-an")
    -- cmd = cmd:gsub("$prevf", o.prevf)
    -- cmd = cmd:gsub("$vf", o.vf)
    -- cmd = cmd:gsub("$hqvf", o.hqvf)
    -- cmd = cmd:gsub("$postvf", o.postvf)
    -- cmd = cmd:gsub("$matrix", get_csp())
    -- cmd = cmd:gsub("$opts", o.opts)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes " .. outpath


    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result = utils.subprocess({args = {'xterm','-hold', '-e',cmd}, cancellable = false})
    local result2 = utils.subprocess_detached({args = {'xterm','-hold','-e',outfield}})
    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end




function cut_frame(shift, endpos)
    local cmd = trim(o.command_template_frame:gsub("%s+", " "))
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))
    -- TODO: Windows?
    local outpath = escape(string.format("%s/%s",
        o.target_dir:gsub("~", os.getenv("HOME")),
        get_outname(shift, endpos)))

    cmd = cmd:gsub("$shift", shift)
    cmd = cmd:gsub("$duration", endpos)
    -- Beware that input/out filename may contain replacing patterns.
    cmd = cmd:gsub("$ext", o.ext)
    cmd = cmd:gsub("$out", outpath)
    cmd = cmd:gsub("$in", inpath, 1)
    cmdnew = '"' .. cmd .. '"'
   local outfield = "nohup mpv --keep-open  --osd-fractions --volume=90 --autofit-larger=100 --script-opts=osc-layout=topbar --no-osd-bar --pause --mute=yes \"" .. outpath .. "." .. o.ext.."\""

    msg.info(cmd)
    log(cmd)
    --local result = utils.subprocess_detached({args = {'ffmpeg','-v','warning','-y','-stats','-i',inpath,'-ss',shift,'-to',endpos,'-c:v','mjpeg','-qscale:v','4','-preset','ultrafast','-c:a','aac','-strict','-2','-b:a','64k',outfield}})
    -- local result = utils.subprocess_detached({args = {'xterm','-hold','-e',cmd}, cancellable = false})
    local result = utils.subprocess({args = {'xterm','-e',cmd}, cancellable = false})
    local result2 = utils.subprocess_detached({args = {'xterm','-e',outfield}})

    --utils.subprocess_detached({args = {'touch','/home/guest/sample'}})
    --if result.status == 0 then 
    --      mp.osd_message('Finished')
    --  end
     -- utils.subprocess_detach({args = {"hare krishna"}})
end

function cut_whatsapp400()
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))

    osd("formating video to whatsapp")
    cmdnew = "sh /home/simha/.public_html/inputconvert.sh " .. "'" .. inpath .. "'"
    msg.info(cmdnew);
    local result3 = utils.subprocess_detached({args = {'xterm','-hold','-e',cmdnew}})

end

function convert_to_images()
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))

    osd("converting to images")
    cmdnew = "sh /home/simha/.public_html/convertoimages.sh " .. "'" .. inpath .. "'"
    msg.info(cmdnew);
    local result3 = utils.subprocess_detached({args = {'xterm','-hold','-e',cmdnew}})

end


function cut_cutvideo()
	local pos_approx = mp.get_property_number("time-pos")
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))

    osd("formating video to whatsapp")
    cmdnew = "sh /home/simha/.public_html/cutvideo.sh " .. "'" .. inpath .. "' " .. pos_approx 
    msg.info(cmdnew);
    local result3 = utils.subprocess_detached({args = {'xterm','-hold','-e',cmdnew}})

end


function crf_testing()
    local pos_approx = mp.get_property_number("time-pos")          
    osd(string.format("Approx Marked %s as start position %s", timestamp(pos_approx), pos_approx))
    local inpath = escape(utils.join_path(
                utils.getcwd(),
                mp.get_property("stream-path")))

        -- osd("formating video to crf")
        cmdnew = "sh /home/simha/.public_html/crftesting.sh " .. "'" .. inpath .. "'" .. " '" .. pos_approx .. "'"
        msg.info(cmdnew);
        local result3 = utils.subprocess_detached({args = {'xterm','-e',cmdnew}})

end



function toggle_mark()
    local pos = mp.get_property_number("time-pos")
    if cut_pos then
        local shift, endpos = cut_pos, pos
        if shift > endpos then
            shift, endpos = endpos, shift
        end
        if shift == endpos then
            osd("Cut fragment is empty")
        else
            cut_pos = nil
            osd(string.format("Cut fragment: %s - %s",
                timestamp(shift),
                timestamp(endpos)))
            cut(shift, endpos)
        end
    else
        cut_pos = pos
        osd(string.format("Marked %s as start position", timestamp(pos)))
    end
end

function toggle_audio()
    copy_audio = not copy_audio
    osd("Audio capturing is " .. (copy_audio and "enabled" or "disabled"))
end


function toggle_cancel()
	cut_pos = nil
    cut_pos_frame = nil
    cut_pos_approx = nil
	osd(string.format("Cancelled position"))
end

function toggle_frame()
    local pos_frame = mp.get_property_number("estimated-frame-number")
    if cut_pos_frame then
        local shift_frame, endpos_frame = cut_pos_frame, pos_frame
        if shift_frame > endpos_frame then
            shift_frame, endpos_frame = endpos_frame, shift_frame
        end
        if shift_frame == endpos_frame then
            osd("Cut fragment is empty")
        else
            cut_pos_frame = nil
            osd(string.format("Cut fragment: %s - %s",
                shift_frame,
                endpos_frame))
            cut_frame(shift_frame, endpos_frame)
        end
    else
        cut_pos_frame = pos_frame
        osd(string.format("Marked %s as start position", cut_pos_frame))
    end
end

function toggle_mark_approx()
    local pos_approx = mp.get_property_number("time-pos")
    if cut_pos_approx then
        local shift_approx, endpos_approx = cut_pos_approx, pos_approx
        if shift_approx > endpos_approx then
            shift_approx, endpos_approx = endpos_approx, shift_approx
        end
        if shift_approx == endpos_approx then
            osd("Approx Cut fragment is empty")
        else
            cut_pos_approx = nil
            osd(string.format("Approx Cut fragment: %s - %s",
                timestamp(shift_approx),
                timestamp(endpos_approx)))
            cut_approx(shift_approx, endpos_approx)
        end
    else
        cut_pos_approx = pos_approx
        osd(string.format("Approx Marked %s as start position %s", timestamp(pos_approx), pos_approx))
    end
end

function toggle_mark_audio()
    local pos_approx = mp.get_property_number("time-pos")
    if cut_pos_approx then
        local shift_approx, endpos_approx = cut_pos_approx, pos_approx
        if shift_approx > endpos_approx then
            shift_approx, endpos_approx = endpos_approx, shift_approx
        end
        if shift_approx == endpos_approx then
            osd("Approx Cut fragment is empty")
        else
            cut_pos_approx = nil
            osd(string.format("Approx Cut fragment: %s - %s",
                timestamp(shift_approx),
                timestamp(endpos_approx)))
            cut_audio(shift_approx, endpos_approx)
        end
    else
        cut_pos_approx = pos_approx
        osd(string.format("Approx Marked %s as start position %s", timestamp(pos_approx), pos_approx))
    end
end


function toggle_copysimha()
    local pos_copysimha = mp.get_property_number("time-pos")
    if cut_pos_copysimha then
        local shift_copysimha, endpos_copysimha = cut_pos_copysimha, pos_copysimha
        if shift_copysimha > endpos_copysimha then
            shift_copysimha, endpos_copysimha = endpos_copysimha, shift_copysimha
        end
        if shift_copysimha == endpos_copysimha then
            osd("Copy Cut fragment is empty")
        else
            cut_pos_copysimha = nil
            osd(string.format("Copy Cut fragment: %s - %s",
                timestamp(shift_copysimha),
                timestamp(endpos_copysimha)))
            cut_copysimha(shift_copysimha, endpos_copysimha)
        end
    else
        cut_pos_copysimha = pos_copysimha
        osd(string.format("Copy Marked %s as start position", timestamp(pos_copysimha)))
    end
end

function toggle_copysimha_ffmpeg()
    local pos_copysimha = mp.get_property_number("time-pos")
    if cut_pos_copysimha then
        local shift_copysimha, endpos_copysimha = cut_pos_copysimha, pos_copysimha
        if shift_copysimha > endpos_copysimha then
            shift_copysimha, endpos_copysimha = endpos_copysimha, shift_copysimha
        end
        if shift_copysimha == endpos_copysimha then
            osd("Copy Cut fragment is empty")
        else
            cut_pos_copysimha = nil
            osd(string.format("Copy Cut fragment: %s - %s",
                timestamp(shift_copysimha),
                timestamp(endpos_copysimha)))
            cut_copysimha_ffmpeg(shift_copysimha, endpos_copysimha)
        end
    else
        cut_pos_copysimha = pos_copysimha
        osd(string.format("Copy Marked %s as start position", timestamp(pos_copysimha)))
    end
end


function toggle_approxsmall()
    local pos_approxsmall = mp.get_property_number("time-pos")
    if cut_pos_approxsmall then
        local shift_approxsmall, endpos_approxsmall = cut_pos_approxsmall, pos_approxsmall
        if shift_approxsmall > endpos_approxsmall then
            shift_approxsmall, endpos_approxsmall = endpos_approxsmall, shift_approxsmall
        end
        if shift_approxsmall == endpos_approxsmall then
            osd("Copy Cut fragment is empty")
        else
            cut_pos_approxsmall = nil
            osd(string.format("Copy Cut fragment: %s - %s",
                timestamp(shift_approxsmall),
                timestamp(endpos_approxsmall)))
            cut_approxsmall(shift_approxsmall, endpos_approxsmall)
        end
    else
        cut_pos_approxsmall = pos_approxsmall
        osd(string.format("Copy Marked %s as start position", timestamp(pos_approxsmall)))
    end
end

function cut_info()
    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))

    osd("information of the video")
    cmdnew = "ffmpeg -i \"" .. inpath.."\""
    msg.info(cmdnew);
    local result3 = utils.subprocess_detached({args = {'xterm','-hold','-e',cmdnew}})

end

function play_new()
    msg.info("play_new Hare Krishna");
    mp.set_property("pause", "no")
end



-- mp.add_key_binding("c", "slicing_mark", toggle_mark)
--mp.add_key_binding("a", "slicing_markapprox_mjpeg", toggle_mark_approx)  -- cut_approx  command_template_approxlong get_outname_approx
mp.add_key_binding("p", "slicing_copy", toggle_copysimha) -- cut_copysimha command_template_simha get_outname_simha
mp.add_key_binding("'", "slicing_copy_ffmpeg", toggle_copysimha_ffmpeg) -- cut_copysimha_ffmpeg command_template_simha_ffmpeg get_outname_simha_ffmpeg
mp.add_key_binding("shift+p", "slicing_whatsapp",cut_whatsapp400)
mp.add_key_binding("ctrl+shift+i", "convert_to_images",convert_to_images)
-- mp.add_key_binding("s", "slicing_approxsmall", toggle_approxsmall)
-- -- mp.add_key_binding("a", "slicing_audio", toggle_audio)
-- mp.add_key_binding("n", "slicing_cancel", toggle_cancel)
-- mp.add_key_binding("j", "slicing_frame", toggle_frame)
-- mp.add_key_binding("shift+j", "crf_testing", crf_testing)
-- mp.add_key_binding("i", "slicing_info", cut_info)
mp.add_key_binding("b", "slicing_audio", toggle_mark_audio) -- cut_audio, toggle_mark_audio, command_template_audio, get_outname_approx 
-- mp.add_key_binding("z", "slicing_cut", cut_cutvideo)

-- mp.add_key_binding("q","quit_new",quit_new)

mp.add_key_binding("shift+z","play_new",play_new)
