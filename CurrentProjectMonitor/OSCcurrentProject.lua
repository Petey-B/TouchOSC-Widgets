--[[
		OSCcurrentProject.lua	/OSCcurrentProject "CC"
		- requires OSCexit.lua to shut down
		- r.midi_init(20,-1) isn't needed unless there's focus issues
		

]]

local r = reaper
local SMM = r.StuffMIDIMessage
local GCP = r.GetCursorPosition
local EP = r.EnumProjects -- id, name = (idx)
local GPN = r.GetProjectName -- (proj)
local IPD = r.IsProjectDirty -- (proj)
local HES = r.HasExtState
local DES = r.DeleteExtState
local DFR = r.defer
local t2qn = r.TimeMap_timeToQN
local qn2m = r.TimeMap_QNToMeasures

local CC
local lastTpos, lastDirty, lastProj = 0, 0, 0
-- check every 10th call @ 30Hz, delay first loop
local Freq, DeferCt = 10, -6	

local barString = function()
	local qns = t2qn(GCP())
	local ms, qnms = qn2m(0,qns)
	return string.format("%d.%.2f",ms,qns-qnms+1)
end

local SendStr = function(ID,Str)
-- device = 16 + (bridge ID = 20), chan = 0xB0 + (16-1)
	SMM( 36, 0xBF, CC, ID)
	Str:gsub(".", function(c) SMM( 36, 0xBF, CC, c:byte()) end)
	SMM( 36, 0xBF, CC,127)
end

local function Qloop()
	if DeferCt < Freq then
		DeferCt = DeferCt+1
	else
		DeferCt = 0
		if HES( "OSC", "OSCcurrentProject" ) then
			DES( "OSC", "OSCcurrentProject", false )
			SendStr(1,"shutting down")
			SendStr(2,"-.-.--")
			return
		else
			local chkProj = EP(-1)
			if lastProj ~= chkProj then
				lastProj = chkProj
				SendStr(1,GPN(0))
			end
			local IsDirty = IPD(0)
			if lastDirty ~= IsDirty then
				lastDirty = IsDirty
				SendStr(2,lastDirty==0 and " " or "*")
			end
			local tpos = GCP()
			if lastTpos ~= tpos then
				lastTpos = tpos
				SendStr(3,barString(lastTpos))
			end
		end
	end
	DFR(Qloop)
end

--------- MAIN --------------------------------------------------------

DES( "OSC", "OSCcurrentProject", false )
local _,_,_,_,_,_,_,conStr = r.get_action_context()
local CCstr = string.match(conStr,".+:s=(%d+)")
CC = tonumber(CCstr)

DFR(Qloop)
