
sim_heartbeat = create_dataref("AT/system/scoop/heartbeat", "number")
sim_heartbeat = 100

dr_fog = find_dataref("sim/private/controls/fog/fog_be_gone")
dr_cloud_shadow = find_dataref("sim/private/controls/clouds/cloud_shadow_lighten_ratio")

dr_FRP = find_dataref("sim/operation/misc/frame_rate_period")

dr_payload =  find_dataref("sim/flightmodel/weight/m_fixed")
dr_watermass =  find_dataref("sim/flightmodel/weight/m_jettison")
dr_speedbrake_ratio = find_dataref("sim/cockpit2/controls/speedbrake_ratio")

dr_onground =  find_dataref("sim/flightmodel/failures/onground_any")

dr_firebutton =  find_dataref("sim/joystick/fire_key_is_down")
dr_scoop_deploy_ratio =  find_dataref("sim/flightmodel2/misc/water_scoop_deploy_ratio")

debug_contact = create_dataref("AT/system/scoop/debug/contact", "number")
debug_scooping = create_dataref("AT/system/scoop/debug/scooping", "number")
debug_speed = create_dataref("AT/system/scoop/debug/speed", "number")
debug_scoo = create_dataref("AT/system/scoop/debug/sc", "number")

dr_airspeed_kts_pilot = find_dataref("sim/flightmodel/position/indicated_airspeed") 
dr_water_rudder = find_dataref("sim/cockpit2/controls/water_rudder_handle_ratio")
dr_pitot = find_dataref("sim/cockpit/switches/pitot_heat_on")

dr_draw_fire = find_dataref("sim/graphics/settings/draw_forestfires")

at_scoop_deploy = create_dataref("AT/scoop", "number")
at_scoop_deploy = 0
function toggleScoop(phase, duration)
	sim_heartbeat = 220
	if debug_scoo == 0 then
		debug_scoo = 1
	else
		debug_scoo = 0
	end
	sim_heartbeat = 229
end
sim_heartbeat = 1030

c12 = create_command("AT/deploy_scoop", "Toggle Scoop deploy", toggleScoop)

-- Lokala variabler
g_markkontakt = 1

function interpolate(x1, y1, x2, y2, value)
	y = y1 + (y2-y1)/(x2-x1)*(value-x1)
	return y
end

function flight_start() 
	sim_heartbeat = 200
	dr_payload = 0
	dr_watermass = 0
	dr_fog = 0.1
end

function aircraft_unload()

end

function do_on_exit()

end

function checkIfScooping()
	debug_speed = interpolate(0, 50, 3000, 65, dr_watermass)
	if (dr_onground > 0) then
		debug_contact = 1
		if (dr_firebutton > 0 or dr_pitot > 0 or at_scoop_deploy > 0) then
			if (dr_airspeed_kts_pilot > debug_speed) then
				debug_scooping = 1
			else
				debug_scooping = 0
			end
		else
			debug_scooping = 0
		end
	else
		debug_scooping = 0
		debug_contact = 0
	end
	
	if (debug_scooping >0) then
		-- Fill water with 200 litres per second
		add_water = dr_FRP * 200
		dr_watermass = dr_watermass + add_water
		if (dr_watermass > 3000) then
			dr_watermass = 3000
		end
		--dr_scoop_deploy_ratio = 1
	end
end

function waterRudder()
	sim_heartbeat = 3031
	if (dr_airspeed_kts_pilot < 30) then
		sim_heartbeat = 3032
		--dr_water_rudder = 1
	else
		sim_heartbeat = 3033
		--dr_water_rudder = 0
	end
	sim_heartbeat = 3034
end
heartbeat = 0
function before_physics() 
	sim_heartbeat = 300
	checkIfScooping()
	
	sim_heartbeat = 301
	dr_draw_fire = 1
	sim_heartbeat = 302
	
	dr_payload = 0
	
	sim_heartbeat = 303
	waterRudder()
	sim_heartbeat = 304
	
	sim_heartbeat = heartbeat
	heartbeat = heartbeat + 1
end

sim_heartbeat = 199
