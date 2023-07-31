-- MIDI EDITOR HORIZONTAL ZOOM - / /MEV_zoomH

local r = reaper
r.SN_FocusMIDIEditor()
local _,_,_,_,_,_,_,conStr = r.get_action_context()
local dir,InOut = string.match(conStr,".+:s=([HV])(.)")
local CCnum = dir=="H" and 12 or 13
local CCval = InOut=="+" and 65 or 63
r.StuffMIDIMessage( 1, 0xBF, CCnum, CCval)