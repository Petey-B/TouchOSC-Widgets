--[[	The DEFER-minator

	This takes an OSC string argument
	TouchOSC sends it to tell the defer loop that it should exit
	The last arg (persist) should be false, we don't want to save it
	It's really that simple, with very little overhead
	The receiving loop MUST delete the ExtState section or it
		will never run again
]]
local r = reaper
local _,_,_,_,_,_,_,conStr = r.get_action_context()
r.SetExtState("OSC", string.match(conStr,".+:s=(.+)"), "1", false)