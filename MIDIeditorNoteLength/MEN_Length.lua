---- API
local r = reaper
local SMB = r.ShowMessageBox
local GAC = r.get_action_context
local MGA = r.MIDIEditor_GetActive
local MGT = r.MIDIEditor_GetTake
local MGG = r.MIDI_GetGrid
local ESN = r.MIDI_EnumSelNotes
local MGN, MSN = r.MIDI_GetNote, r.MIDI_SetNote

local tix = r.SNM_GetIntConfigVar("miditicksperbeat",0)
local take


local AFs = {
["D"] = function(nLen) return nLen << 1 end,
["H"] = function(nLen) return nLen >> 1 end,
["."] = function(nLen) return nLen + (nLen >> 1) end
}

local adjSelected = function(func)
	local sppq,eppq
	local idx = ESN(take,-1)
	while idx >= 0 do
		_,_,_,sppq,eppq = MGN(take,idx)
		MSN (take,idx,nil,nil,nil,sppq+func(eppq-sppq),nil,nil,nil,true)
		idx = ESN(take,idx)
	end
end

local setSelected = function(nLen)
	local sppq,eppq
	local idx = ESN(take,-1)
	while idx >= 0 do
		_,_,_,sppq,eppq = MGN(take,idx)
		MSN (take,idx,nil,nil,nil,sppq+nLen,nil,nil,nil,true)
		idx = ESN(take,idx)
	end
end

local addSelected = function(nLen)
	local sppq,eppq
	local idx = ESN(take,-1)
	local minLen = tix//64 -- 256th note
	while idx >= 0 do
		_,_,_,sppq,eppq = MGN(take,idx)
		-- check for negative length
		if eppq-sppq+nLen < minLen then
			nLen=sppq+minLen-eppq
		end
		MSN (take,idx,nil,nil,nil,eppq+nLen,nil,nil,nil,true)
		idx = ESN(take,idx)
	end
end

---------------------- MAIN --------------------------------------------------
-- /MEN_Length - osc msg ( H | D | . | + | - | = ) ([##])
local _,_,_,_,_,_,_,conStr = GAC()
local sOp,sLen = string.match(conStr,".+:s=([DH%+%-%.=])([0-9]*)")

local hWnd = MGA()
if hWnd then
	take = MGT(hWnd)
	if take then
		if sLen == "" then
			-- might want to check for nil func
			adjSelected(AFs[sOp])
		else
			local nLen = tix*(sLen=="9" and MGG(take) or 2^(3-tonumber(sLen)))
			if sOp == "="  then
				setSelected(nLen)
			elseif sOp=="+" then
				addSelected(nLen)
			elseif sOp=="-" then
				addSelected(-nLen)
			else
				SMB("Unknown op: '"..sOp.."'\nPassed in OSC message !",
				"MEN_Length OSC Error",0x30)
			end
		
		end
	else
		SMB("MIDIEditor_GetTake() failed...\nTake object is bad or unavailable !",
		"MEN_Length Script Error",0x30)
	end
else
	SMB("MIDIEditor_GetActive() failed...\nhWnd is bad or no MIDI editor open !",
	"MEN_Length Script Error",0x30)
end