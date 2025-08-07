
sim_heartbeat = create_dataref("AT/system/scoop/heartbeat", "number")
sim_heartbeat = 100

dr_fog = find_dataref("sim/private/controls/fog/fog_be_gone")
dr_cloud_shadow = find_dataref("sim/private/controls/clouds/cloud_shadow_lighten_ratio")

dr_FRP = find_dataref("sim/operation/misc/frame_rate_period")

dr_payload =  find_dataref("sim/flightmodel/weight/m_fixed")
dr_watermass =  find_dataref("sim/flightmodel/weight/m_jettison")
dr_speedbrake_ratio = find_dataref("sim/cockpit2/controls/speedbrake_ratio")

dr_gear = find_dataref("sim/cockpit/switches/gear_handle_status") 
dr_onground =  find_dataref("sim/flightmodel/failures/onground_any")

dr_firebutton =  find_dataref("sim/joystick/fire_key_is_down")
dr_scoop_deploy_ratio =  find_dataref("sim/flightmodel2/misc/water_scoop_deploy_ratio")

dr_m_fuel_total = find_dataref("sim/flightmodel/weight/m_fuel_total") 
dr_fuel_flow = find_dataref("sim/flightmodel/engine/ENGN_FF_") 

debug_contact = create_dataref("AT/system/scoop/debug/contact", "number")
debug_scooping = create_dataref("AT/system/scoop/debug/scooping", "number")
debug_speed = create_dataref("AT/system/scoop/debug/speed", "number")
debug_scoo = create_dataref("AT/system/scoop/debug/sc", "number")
debug_dropready = create_dataref("AT/system/scoop/debug/dropready", "number")

at_fuel_eta = create_dataref("AT/system/fuel/eta", "number")
at_fuel_range = create_dataref("AT/system/fuel/range", "number")

dr_airspeed_kts_pilot = find_dataref("sim/flightmodel/position/indicated_airspeed") 

dr_groundspeed = find_dataref("sim/flightmodel/position/groundspeed") 
dr_water_rudder = find_dataref("sim/cockpit2/controls/water_rudder_handle_ratio")
dr_pitot = find_dataref("sim/cockpit/switches/pitot_heat_on")
dr_nav_lights_on = find_dataref("sim/cockpit/electrical/nav_lights_on")

dr_mix1 = find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")

--dr_draw_fire = find_dataref("sim/graphics/settings/draw_forestfires")

dr_custom0 = find_dataref("sim/cockpit2/switches/custom_slider_on[2]") --sim/cockpit2/controls/speedbrake_ratio

dr_easy =  find_dataref("sim/cockpit2/switches/custom_slider_on[1]")

simCMD_jettison_payload = find_command("sim/flight_controls/jettison_payload")

at_scoop_deploy = create_dataref("AT/scoop", "number")
at_dropping = create_dataref("AT/dropping", "number")
at_watercontact = create_dataref("AT/watercontact", "number")

at_easy = create_dataref("AT/system/scoop/easy", "number")
at_dropready_light = create_dataref("AT/system/scoop/dropreadylight", "number")

at_scoop_deploy = 0
at_dropping = 0

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


at_overflow = create_dataref("AT/overflow", "number")
at_overflow = 0

function toggleOverflow(phase, duration)
	sim_heartbeat = 220
	if (phase == 0) then
		if at_overflow == 0 then
			at_overflow = 1
		else
			at_overflow = 0
		end
		sim_heartbeat = 229
	end
	sim_heartbeat = 1031
end
c_overflow = create_command("AT/overflow_toggle", "Toggle overflow", toggleOverflow)

-- Lokala variabler
g_markkontakt = 1

function interpolate(x1, y1, x2, y2, value)
	y = y1 + (y2-y1)/(x2-x1)*(value-x1)
	return y
end

function myfilter(currentValue, newValue, amp)
	return ((currentValue*amp) + (newValue))/(amp+1)
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

prev_navlight = 0
prev_ballast = 0
ballast = 1000
ballastmin = 0
prev_mix = 0
readytodrop = 0
function checkIfScooping()
	debug_speed = interpolate(0, 20, 3000, 40, dr_watermass)
	at_watercontact = 0
	readytodrop = readytodrop + dr_FRP
	debug_dropready = readytodrop
	if (dr_onground > 0 and dr_gear == 0) then
		debug_contact = 1
		at_watercontact = 1
		readytodrop = 0
		if (dr_firebutton > 0 or dr_pitot > 0 or at_scoop_deploy > 0 or (dr_mix1 > 0.8)) then
			if (dr_airspeed_kts_pilot > debug_speed) then
				debug_scooping = 1
			else
				debug_scooping = 0
			end
		else
			debug_scooping = 0
		end
		prev_ballast = prev_ballast-10
		if (prev_ballast < ballastmin) then
			prev_ballast = ballastmin
		end
		dr_payload = prev_ballast
	else
		prev_ballast = ballast
		dr_payload = prev_ballast	
		debug_scooping = 0
		debug_contact = 0
	end
	at_overflow = 0
	if (debug_scooping >0) then
		-- Fill water with 200 litres per second
		-- 8.8 = 320l/s 
		-- 6.0 = 216l/s
		if dr_groundspeed > 7.0 then -- måste komma över 7m/s för att den ska orka trycka upp vatten
			add_water = dr_FRP * 6.0 * (dr_groundspeed)
		end
		dr_watermass = dr_watermass + add_water
		if (dr_watermass > 3000) then
			dr_watermass = 3000
			at_overflow = 1
		else
			
		end
		--dr_scoop_deploy_ratio = 1
		dr_speedbrake_ratio = 1
	else
		dr_speedbrake_ratio = 0
	end
	dr_custom0 = at_overflow
	if (prev_navlight ~= dr_nav_lights_on) then
		simCMD_jettison_payload:once()
		prev_navlight = dr_nav_lights_on
	end

	if (readytodrop > 10 and dr_watermass > 0) then
		at_dropready_light = 1
	else
		at_dropready_light = 0
	end
	
	if (dr_mix1 < 0.1 or (dr_pitot > 0 and at_dropready_light > 0)) then
		if (prev_mix == 0) then
			prev_mix = 1
			simCMD_jettison_payload:once()
		end
	else
		prev_mix = 0
		
	end

	if (dr_easy >0) then
		ballastmin = 0
	else
		ballastmin = 1000
	end
	
	
end

function waterRudder()
	sim_heartbeat = 3031
	if (dr_airspeed_kts_pilot < 110) then
		sim_heartbeat = 3032
		dr_water_rudder = 1
	else
		sim_heartbeat = 3033
		dr_water_rudder = 0
	end
	sim_heartbeat = 3034
end


prev_waterlevel = 0
function dropEffect()
	if dr_watermass == prev_waterlevel then
		at_dropping = 0
	else
		
		if dr_watermass < prev_waterlevel then
			at_dropping = prev_waterlevel - dr_watermass
			prev_waterlevel = dr_watermass
		else
			prev_waterlevel = dr_watermass
		end
	end
end

eta_prev = 0
function fuelCalc()
sim_heartbeat = 3050
	total = 0.0
	total = total + dr_m_fuel_total
sim_heartbeat = 3052
	if (dr_fuel_flow[0]>0) then

		eta = total / dr_fuel_flow[0]
		eta = myfilter(eta_prev,eta , 10)
		eta_prev = eta
		at_fuel_range = math.floor(dr_groundspeed * eta)
		at_fuel_eta = math.floor(eta)
	end
	sim_heartbeat = 407

end

heartbeat = 0
function before_physics() 
	sim_heartbeat = 300
	checkIfScooping()
	
	sim_heartbeat = 301
	--dr_draw_fire = 1
	sim_heartbeat = 302
	
	
	sim_heartbeat = 303
	waterRudder()
	sim_heartbeat = 304
	dropEffect()
	sim_heartbeat = 305
	fuelCalc()
	sim_heartbeat = 306
	sim_heartbeat = heartbeat
	heartbeat = heartbeat + 1
end

sim_heartbeat = 199
