
--[[	/MEmonitor "CCstr" - Another Defer Loop	]]

-- device = 16+(bridge ID = 20), chan = 0xB+(16-1)
local ID = 36
local CH = 0xBF -- 0xB0 + channel# -1
local Freq, DeferCt = 10, -6	-- check every nth call @ 30Hz, delay first loop


local r = reaper
local SMM = r.StuffMIDIMessage
local t2qn = r.TimeMap_timeToQN
local qn2m = r.TimeMap_QNToMeasures
local GMI = r.GetMediaItemTake_Item
local GMIV = r.GetMediaItemInfo_Value
local GTIS = r.GetSetMediaItemTakeInfo_String
local MGA = r.MIDIEditor_GetActive
local MGT = r.MIDIEditor_GetTake
local ESN = r.MIDI_EnumSelNotes
local MCE = r.MIDI_CountEvts
local HES = r.HasExtState
local DES = r.DeleteExtState
local DFR = r.defer

local hWnd, take, CC			-- forward declarations

local barString = function(t)
	local qns = t2qn(t)
	local ms, qnms = qn2m(0,qns)
	return string.format("%d.%.2f",ms,qns-qnms+1)
end

local SendStr = function(InfoID,Str)
	SMM( ID, CH, CC,InfoID)
	Str:gsub(".", function(c) SMM( ID, CH, CC, c:byte()) end)
	SMM( ID, CH, CC,127)
end

local lastST = 0
local lastET = 0
local lastSNS = 0
local lastNS = 0
local function QueryME()
	if DeferCt < Freq then
		DeferCt = DeferCt+1
	else
		DeferCt = 0
		if HES( "OSC", "MEmonitor" ) then
			DES( "OSC", "MEmonitor", false )
			scm("shutting down")
			return
		else
			local chkTake = MGT(hWnd)
			if chkTake then
				-- THIS BLOCK MONITORS CONTINUOUS UPDATE CHECKS
				local item =GMI(chkTake)
				local st = GMIV(item,"D_POSITION")
				local et = st + GMIV(item,"D_LENGTH")
				local _, ns = MCE(chkTake)
				local sns, idx = -1, -1
				repeat
					idx = ESN(chkTake,idx)
					sns=sns+1
				until idx == -1

				if take ~= chkTake then
					take = chkTake
					-- name
					local _,n = GTIS(take,"P_NAME","",false)
					SendStr(1,n)
					-- metrix
					SendStr(2,barString(st))
					lastST = st
					SendStr(3,barString(et))
					lastET = et
					-- notes
					SendStr(4,tostring(ns))
					lastNS = ns
					-- selected notes
					SendStr(5,tostring(sns))
					lastSNS = sns
				else
					if lastST ~= st then
						lastST = st
						SendStr(2,barString(st))
					end
					if lastET ~= et then
						lastET = et
						SendStr(3,barString(et))
					end
					if lastNS ~= ns then
						lastNS = ns
						SendStr(4,tostring(ns))
					end
					if lastSNS ~= sns then
						lastSNS = sns
						SendStr(5,tostring(sns))
					end
				end
			else
				-- MIDI Editor closed ?
				SendStr(1,"NA")
				SendStr(2,"-.-.--")
				SendStr(3,"-.-.--")
				SendStr(4,"0")
				SendStr(5,"0")
				SMM( ID, CH, CC,0)
				-- TMNBN ?
				DES( "OSC", "MEmonitor", false )
				return
			end
		end
	end
	DFR(QueryME)
end

--------- MAIN --------------------------------------------------------
local _,_,_,_,_,_,_,conStr = r.get_action_context()
local CCstr = string.match(conStr,".+:s=(%d+)")
CC = tonumber(CCstr)

if HES( "OSC", "MEmonitor" ) then
	DES( "OSC", "MEmonitor", false )
end

hWnd = MGA()
if hWnd then
	DFR(QueryME)
else
	SMM( ID, CH, CC,0)
	r.ShowConsoleMsg("MEinfoLoop failed...hWnd is bad or no MIDI editor")
end
