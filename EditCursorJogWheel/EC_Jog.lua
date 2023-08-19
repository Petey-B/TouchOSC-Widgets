--[[	MEC_Jog.lua	-	/MEC_Jpg "+/-  ## "

]]
package.path = package.path .. 
";C:\\Users\\pjbxm\\AppData\\Roaming\\REAPER\\Scripts\\!MySkripz\\?.lua"
require "_DEBUG"

-- +/-	##
-- ## - 1=M, 2=H, 3=Q, 4=8th, ... 9=256th, 10=grid

local r = reaper
local _,_,_,_,_,_,_,conStr = r.get_action_context()
local sDir,sLen = string.match(conStr,".+:s=(.)([0-9CF]*)")
local nLen = tonumber(sLen) -- can be nil
local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
local d = sDir == "+" and 1 or -1

if nLen then
	local cpos = r.GetCursorPosition()
	local qn
	if nLen == 1 then
		local bpm,bpi = r.TimeMap_GetTimeSigAtTime(0,cpos)
		qn = 4 * bpm/bpi
	elseif nLen == 10 then
		if take then
			qn = r.MIDI_GetGrid(take)
		else
			local _,g = r.GetSetProjectGrid(0,false)
			qn =  4*g
		end
		
	else
		qn = 2^(3 - nLen)
	end
	r.SetEditCurPos(r.TimeMap_QNToTime(r.TimeMap_timeToQN(cpos) + (d * qn)),true,false)

else
	
	if sLen == "C" or sLen == "F" then
		--local hWnd = r.GetMainHwnd()
		--r.BR_Win32_SetFocus(hWnd)
		r.StuffMIDIMessage( 1, 0xBF, (sLen == "C" and 14 or 15), 64 + d)
	else
		if take then
			local item = r.GetMediaItemTake_Item(take)
			local st = r.GetMediaItemInfo_Value(item,"D_POSITION")
			if sDir == "B" then
				r.SetEditCurPos(st,true,false)
			else
				r.SetEditCurPos(st + r.GetMediaItemInfo_Value(item,"D_LENGTH"),true,false)
			end
		else
			r.SetEditCurPos(sDir == "B" and 0 or r.GetProjectLength(0),true,false)
		end
	end
end

