local msg = require("mp.msg")
local utils = require("mp.utils") -- utils.to_string()
local assdraw = require('mp.assdraw')

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

function toggle_fps(filters)
	for k, v in pairs(filters) do
		local name = v["name"]
		msg.info(name)
		if name == "fps" then
			local f = v["params"]
			msg.info(f["@0"])

			if f["@0"] == "0.5" then
				msg.info("fps==0.5")
				mp.command('vf set ""')
				mp.command('vf toggle fps=0.65')
			elseif f["@0"] == "0.65" then
				msg.info("fps==0.65")
				mp.command('vf set ""')
				mp.command('vf toggle fps=0.75')
			elseif f["@0"] == "0.75" then
				msg.info("fps==0.75")
				mp.command('vf set ""')
				mp.command('vf toggle fps=0.85')
			elseif f["@0"] == "0.85" then
				msg.info("fps==0.85")
				mp.command('vf set ""')
				mp.command('vf toggle fps=1')
			elseif f["@0"] == "1" then
				msg.info("fps==1")
				mp.command('vf set ""')
				mp.command('vf toggle fps=2')
			else
				msg.info("fps!=1")
				mp.command('vf set ""')
				mp.command('vf toggle fps=0.5')
			end
		end
		msg.info("hare Krishna")
		msg.info(name)
	end
	print(filters['name'])
	print(filters['params'])
end	

function change_fps()
    msg.info("Inside Function")
    clip_fps = mp.get_property_number("fps")
    msg.info(clip_fps)
    print("Setting speed to", clip_fps)
    msg.info(tprint(mp.get_property_native("vf")))
    if next(mp.get_property_native("vf")) ~= nil then
		msg.info("Table Not nill")
		toggle_fps(mp.get_property_native("vf"))
	else
		msg.info("Table nill")
		mp.command('vf set ""')
		mp.command('vf toggle fps=1')
	end
    disp_fps = mp.get_property_number("display-fps")
    msg.info(disp_fps)
    msg.info("*************************************************")
end	

mp.register_script_message("change_fps", change_fps)