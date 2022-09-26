local msg = require "mp.msg"
length=0
function fSeek()
	--length = mp.get_property_osd(${duration})
	--length=mp.get_property('percent-pos') 
	--length = tonumber(mp.get_property("length"))
	--length= mp.get_property_number('length', 0)
	pos= tonumber(mp.get_property("time-pos"))
	remaining= tonumber(mp.get_property("time-remaining"))
	--length = mp.get_property_number("duration")
	--length= mp.get_property("duration")
	msg.info("length " .. pos)
	msg.info("remain " .. remaining)
end

mp.add_key_binding("shift+d", "seek",fSeek)