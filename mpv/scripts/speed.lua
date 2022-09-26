local msg = require "mp.msg"

function speed_mod()
	msg.info("gaura")
	msg.info(mp.get_property("speed"))
	if mp.get_property("speed") == "1.000000" then
		mp.osd_message("speed 0.1", 2)
		mp.set_property("speed", "0.1")
		msg.info("nrsimha")
	elseif mp.get_property("speed") == "0.100000" then
		mp.osd_message("speed 0.3", 2)
		mp.set_property("speed", "0.3")
		--mp.command("seek -1")
		msg.info("nrsimha")
	elseif mp.get_property("speed") == "0.300000" then
		mp.osd_message("speed 0.5", 2)
		mp.set_property("speed", "0.5")
		--mp.command("seek -1")
		msg.info("nrsimha")
	elseif mp.get_property("speed") == "0.500000" then
		mp.osd_message("speed 0.7 ------- Be reaaaaaaaaaaady", 1)
		mp.set_property("speed", "0.7")
		--mp.command("seek -1")
		msg.info("nrsimha")
	elseif mp.get_property("speed") == "0.700000" then
		mp.osd_message("speed 15", 2)
		mp.set_property("speed", "7")
		--mp.command("seek -1")
		msg.info("nrsimha")
	else
		mp.osd_message("speed 1.0", 2)
		mp.set_property("speed", "1.0")
		mp.command("seek -2")
		msg.info("nitya")
	end
end

function speed_modduo()
	msg.info("gaura")
	msg.info(mp.get_property("speed"))
	if mp.get_property("speed") == "3.000000" then
		mp.osd_message("speed 1", 2)
		mp.set_property("speed", "1.0")
		mp.command("seek -10.0 exact")
		msg.info("nrsimha")
	else
		mp.osd_message("speed 3", 2)
		mp.set_property("speed", "3.0")
		mp.command("seek -2.0 exact")
		--mp.command("seek -0.2")
		msg.info("nitya")
	end
end

function speed_mod2()
	msg.info("gaura")
	msg.info(mp.get_property("speed"))
	if mp.get_property("speed") == "1.000000" then
		mp.set_property("speed", "0.3")
		mp.command("seek -2")
		msg.info("nrsimha")
	else
		mp.set_property("speed", "1")
		msg.info("nitya")
	end
end

function speed_mod3()
	msg.info("gaura")
	msg.info(mp.get_property("speed"))
	if mp.get_property("speed") == "1.000000" then
		mp.set_property("speed", "0.3")
		mp.set_property_bool('pause', true)
		mp.command("seek -2")
		msg.info("nrsimha")
	else
		mp.set_property("speed", "7")
		mp.set_property_bool('pause', false)
		msg.info("nitya")
	end
end


function seek_back()
	mp.command("seek -1 keyframes")
	mp.command("seek -0.5 exact")
end

function seek_front()
	mp.command("seek +1 keyframes")
	mp.command("seek -0.5 exact")
end


mp.add_key_binding("}", "speed", speed_mod)
mp.add_key_binding("\\", "speed2", speed_mod2)
mp.add_key_binding("/", "speed3", speed_modduo)
--mp.add_key_binding("RIGHT", "right", seek_front)
--mp.add_key_binding("LEFT", "left", seek_back)