-- MIDI EDITOR SCROLL - /MEV_scroll

local r = reaper
r.SN_FocusMIDIEditor()
local _,_,_,_,_,_,_,conStr = r.get_action_context()
local dir,val = string.match(conStr,".+:s=([HV])(.+)")
local CCnum = dir=="H" and 10 or 11
local CCval = 64 + tonumber(val)
r.StuffMIDIMessage( 1, 0xBF, CCnum, CCval )


