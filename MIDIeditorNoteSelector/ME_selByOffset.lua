package.path = package.path .. 
";C:\\Users\\pjbxm\\AppData\\Roaming\\REAPER\\Scripts\\!MySkripz\\?.lua"
require "_DEBUG"

--[[	/ME_selByOffset		]]

local r = reaper
local SMB = r.ShowMessageBox
local GAC = r.get_action_context -- ()
local MGA = r.MIDIEditor_GetActive -- () returns hWnd
local MGT = r.MIDIEditor_GetTake -- (hWnd)
local ESN = r.MIDI_EnumSelNotes -- (take,idx) idx -1 to get first
local ppqSM = r.MIDI_GetPPQPos_StartOfMeasure -- (take, PPQpos)

local MCE = r.MIDI_CountEvts
    -- bRet, iNoteCt, iCCevtCt, iTxtSysxCt = (take)
local MGN = r.MIDI_GetNote
    -- bRet, bSel, bMute, nStartPPQpos, nEndPPQpos, iChan, iPitch, iVel = (take, idx)
local MSN = r.MIDI_SetNote
    -- bRet = (take, idx, [ bSel, bMute, nStartPPQpos, nEndPPQpos, iChan, iPitch, iVel, bNoSort])

-- ipq = intervals per quarter
--	if 0 then ipq = 1/grid
--	if nil then PPQ is echoed, otherwise this generates
-- 		a function(ppq) that returns a snap value
local SnapFunc = function(ipq)
	if ipq then
		local snap = ipq == 0 and tix*MGG(take) or tix//ipq
		local slop = snap//2
		return function(PPQ) return snap * ((PPQ + slop)//snap) end
	else
		return function(PPQ) return PPQ end
	end
end


---------------------- MAIN --------------------------------------------------
local _,_,_,_,_,_,_,conStr = GAC()
--local spanStr, pitchStr = string.match(conStr,".+:s=([^,]+),*(.*)")
local slopStr, spanStr, pitchStr = string.match(conStr,".+:s=([0-9]*),([0-9%.]+)(P*)")
scmx2(slopStr, spanStr, pitchStr)
local hWnd = MGA()
if hWnd then
	local take = MGT(hWnd)
	if take then

		local mtix = tonumber(spanStr) * 4 * r.SNM_GetIntConfigVar("miditicksperbeat",0)
		local pitch = (pitchStr == "P")
		local slop = tonumber(SlopStr)	-- nil if ""
		local Snap = SnapFunc(slop)
		
		-- get take's measure offset
		local ppqOfs = ppqSM(take,0)
		-- Get the selected note PPQs
		local idx = ESN(take,-1)		-- get 1st selected
		local SPPQs = {}
		if pitch then
			while idx ~= -1 do
				local _, _, _, ppqN, _, _, numN = MGN(take,idx)
				SPPQs[#SPPQs+1] = { Snap((ppqN - ppqOfs) % mtix), numN } -- calc the Npos
				idx = ESN(take,idx)
			end
		else
			while idx ~= -1 do
				local _, _, _, ppqN = MGN(take,idx)
				SPPQs[#SPPQs+1] = Snap((ppqN - ppqOfs) % mtix) -- calc the Npos
				idx = ESN(take,idx)
			end
		end
		-- Check & select the take notes
		local _, nCount, _, _ = MCE(take)
		if pitch then
			for k = 0, nCount-1 do
				local _, _, _, ppqN, _, _, numN = MGN(take,k)
				local Npos = Snap((ppqN - ppqOfs) % mtix) -- calc the Npos
				for _,sppq in ipairs(SPPQs) do
					if (sppq[1] == Npos) and (sppq[2] == numN) then
						MSN(take,k,true,nil,nil,nil,nil,nil,nil,true)
						break
					end
				end
			end
		else
			for k = 0, nCount-1 do
				local _, _, _, ppqN = MGN(take,k)
				local Npos = Snap((ppqN - ppqOfs) % mtix) -- calc the Npos
				for _,sppq in ipairs(SPPQs) do
					if sppq == Npos then
						MSN(take,k,true,nil,nil,nil,nil,nil,nil,true)
						break
					end
				end
			end
		end

	else
		SMB("MIDIEditor_GetTake() failed...\nTake object is bad or unavailable !",
		"ME_selSpan Script Error",0x30)
	end
else
	SMB("MIDIEditor_GetActive() failed...\nhWnd is bad or no MIDI editor open !",
	"ME_selSpan Script Error",0x30)
end