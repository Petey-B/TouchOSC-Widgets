
---- API
local r = reaper
local SMB = r.ShowMessageBox
local GAC = r.get_action_context
local MGA = r.MIDIEditor_GetActive
local MGT = r.MIDIEditor_GetTake
local ESN = r.MIDI_EnumSelNotes
local MSA = r.MIDI_SelectAll
local MGG = r.MIDI_GetGrid
local MCE = r.MIDI_CountEvts
local MGN = r.MIDI_GetNote
local MSN = r.MIDI_SetNote

-- LOCAL GLOBALS
local tix = r.SNM_GetIntConfigVar("miditicksperbeat",0)
local take
local wrap = true
local slop			-- ipq int or nil
local snew = true	-- replace selection

-- PHUNKSHUN GENERATOR
-- ipq = intervals per quarter
--	if 0 then ipq = 1/grid
--	if nil then PPQ is echoed, otherwise this generates
-- 		a function(ppq) that returns a snap value
local SnapFunc = function(ipq)
	if ipq then
		local snap = ipq == 0 and tix*MGG(take) or tix//ipq
		local slop = snap//2
		scm(slop)
		return function(PPQ) return snap * ((PPQ + slop)//snap) end
	else
		scm("Xact")
		return function(PPQ) return PPQ end
	end
end

-- SELECT PREVIOUS PPQ - worx
-- this takes from 26-50 µs avg 35
local selectPrevPPQ = function ()
	local ppq,ppq1
	local idx = ESN(take,-1)				-- get first selected
	if idx ~= -1 then					-- something selected
		if snew then MSA(take,false) end	-- deselect
		_, _, _, ppq1 = MGN(take,idx)	-- get the ppq
		idx = idx - 1					-- point to prev note
		while idx >= 0 do				-- done if on first note
			_, _, _, ppq = MGN(take,idx)
			if ppq1 ~= ppq then
				break
			end
			idx = idx - 1
		end
	end
	-- idx is -1 if nothing selected or past the first note
	if idx == -1 then
		if wrap then
			local _,nCt = MCE(take)	-- point to the last note
			idx = nCt-1
			_, _, _, ppq = MGN(take,idx)
		else
			return nil
		end
	end
	-- get the snapper
	local Snap = SnapFunc(slop)
	ppq = Snap(ppq)
	-- idx, ppq -> last prev note, select it
	MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
	-- select every prev note at ppq
	idx = idx - 1
	while idx >= 0 do
		_, _, _, ppq1 = MGN(take,idx)
		if ppq == Snap(ppq1) then
			MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
		else
			break
		end
		idx = idx - 1
	end
end

local selectNextPPQ = function()
	local ppq,ppq1
	local idx, idx2 = -1, -1
	local _, nCt = MCE(take)
	repeat								-- get the last selected
		idx,idx2 = idx2, ESN(take,idx)
	until idx2 == -1
	if idx ~= -1 then					-- something selected
		if snew then MSA(take,false) end	-- deselect
		_, _, _, ppq1 = MGN(take,idx)	-- get the ppq
		idx = idx + 1					-- point to next note
		while idx < nCt do				-- done if on last note
			_, _, _, ppq = MGN(take,idx)
			if ppq1 ~= ppq then
				break
			end
			idx = idx + 1
		end
	end
	-- check if nothing selected or past the last note
	if idx == -1 or idx >= nCt then
		if wrap then					--> first note
			idx = 0
			_, _, _, ppq = MGN(take,idx)	
		else
			return nil
		end
	end
	-- idx, ppq -> first next note, select it
	MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
	-- get the snapper
	local Snap = SnapFunc(slop)
	ppq = Snap(ppq)
	-- select every following note at ppq
	idx = idx + 1
	while idx < nCt do
		_, _, _, ppq1 = MGN(take,idx)
		if ppq == Snap(ppq1) then
			MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
		else
			break
		end
		idx = idx + 1
	end
end


---------------------- MAIN --------------------------------------------------

-- osc msg ( < | > ) ([##]) [W] [+]

local _,_,_,_,_,_,_,conStr = GAC()
local sOp,sSlop,sWrap,sXtnd = string.match(conStr,".+:s=([<>]+)([0-9]*)(W*)(X*)")

slop = tonumber(sSlop)	-- nil if ""
wrap = sWrap == "W"		-- false if ""
snew = sXtnd ~= "X"		-- true if ""

local hWnd = MGA()
if hWnd then
	take = MGT(hWnd)
	if take then
		if sOp == ">" then
			selectNextPPQ()
		elseif sOp == "<" then
			selectPrevPPQ()
		else
			SMB("Unknown op: '"..sOp.."'\nPassed in OSC message !",
			"OSC Error",0x30)
		end
	else
		SMB("MIDIEditor_GetTake() failed...\nTake object is bad or unavailable !",
		"ME_selSpan Script Error",0x30)
	end
else
	SMB("MIDIEditor_GetActive() failed...\nhWnd is bad or no MIDI editor open !",
	"ME_selSpan Script Error",0x30)
end