-- ZOOM
function zoom_in()
	zoom = mp.get_property("video-zoom")
	zoom_to = zoom + 0.1
    mp.set_property("video-zoom", zoom_to)  
end
function zoom_in2()
	zoom = mp.get_property("video-zoom")
	zoom_to = zoom + 1
    mp.set_property("video-zoom", zoom_to)  
end
function zoom_out()
	zoom = mp.get_property("video-zoom")
	zoom_to = zoom - 0.1
    mp.set_property("video-zoom", zoom_to)  
end
function zoom_out2()
	zoom = mp.get_property("video-zoom")
	zoom_to = zoom - 1
    mp.set_property("video-zoom", zoom_to)  
end
function zoom_reset()
	mp.set_property("video-zoom", 0)  
end

-- ROTATE
function cw()
	prop = mp.get_property_native("video-rotate")
	rota = prop + 90
	if rota == 360 then
		mp.set_property_native("video-rotate", 0)
	else
		mp.set_property_native("video-rotate", rota)
	end
	--if prop !== 0 then
	--mp.osd_message(prop)
end
function ccw()
	prop = mp.get_property_native("video-rotate")
	rota = prop - 90
	mp.set_property_native("video-rotate", rota)
end

-- PAN
function pan_right()
	pan = mp.get_property("video-pan-x")
	pan_to = pan + 0.05
    mp.set_property("video-pan-x", pan_to)  
end
function pan_left()
	pan = mp.get_property("video-pan-x")
	pan_to = pan - 0.05
    mp.set_property("video-pan-x", pan_to)  
end
function pan_up()
	pan = mp.get_property("video-pan-y")
	pan_to = pan + 0.05
    mp.set_property("video-pan-y", pan_to)  
end
function pan_down()
	pan = mp.get_property("video-pan-y")
	pan_to = pan - 0.05
    mp.set_property("video-pan-y", pan_to)  
end
function pan_reset()
    mp.set_property("video-pan-y", 0.0)  
    mp.set_property("video-pan-x", 0.0)
    mp.set_property("video-zoom", 0.0)    
end

--mp.add_key_binding("a", "zoom_in2", zoom_in2)
mp.add_key_binding("Shift+a", "zoom_out2", zoom_out2)
--mp.add_key_binding("z", "zoom_in", zoom_in)
--mp.add_key_binding("Shift+z", "zoom_out", zoom_out)
--mp.add_key_binding("Alt+z", "zoom_reset", zoom_reset)

--mp.add_key_binding("r", "cw", cw)
--mp.add_key_binding("Shift+r", "ccw", ccw)

-- mp.add_key_binding("LEFT", "pan_right", pan_right)
-- mp.add_key_binding("RIGHT", "pan_left", pan_left)
-- mp.add_key_binding("UP", "pan_up", pan_up)
-- mp.add_key_binding("DOWN", "pan_down", pan_down)
mp.add_key_binding("ctrl+p", "reset_pan", pan_reset)
 
