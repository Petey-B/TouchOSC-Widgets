
---- API
local r = reaper
local SMB = r.ShowMessageBox
local GAC = r.get_action_context
local MGA, MGT = r.MIDIEditor_GetActive, r.MIDIEditor_GetTake
local GCP = r.GetCursorPosition
local LTR = r.GetSet_LoopTimeRange
local pt2ppq = r.MIDI_GetPPQPosFromProjTime
local ppqSM = r.MIDI_GetPPQPos_StartOfMeasure
local ppqEM = r.MIDI_GetPPQPos_EndOfMeasure
local ESN = r.MIDI_EnumSelNotes
local MSA = r.MIDI_SelectAll
local MCE = r.MIDI_CountEvts
local MGN, MSN = r.MIDI_GetNote, r.MIDI_SetNote

---- forward declaration
local take

---- FUNK GENERATOR
local GetSelFunc = function(ANI)
	if ANI == "A" then
		return function(idx)
				MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
				end

	elseif ANI == "N" then
		return function(idx)
				MSN(take,idx,false,nil,nil,nil,nil,nil,nil,true)
				end
	
	else -- "I"
		return function(idx)
				local _, sel = MGN(take,idx)
				MSN(take,idx,not sel,nil,nil,nil,nil,nil,nil,true)
				end
	
	end
end

---------------------- MAIN --------------------------------------------------
-- THIS WAS BRUTAL !
-- /ME_selSpan "OP - What 2 select - Inc Note Start - Inc Note End - Extend Sel"
-- osc msg ( @ | M | Q | S | T ) ( A | N | I ) (T|F) (T|F) (+)

local _,_,_,_,_,_,_,conStr = GAC()
local sOp,sSel,sStart,sEnd,sXtnd = string.match(conStr,".+:s=([%@MQST])([ANI])([FT])([FT])(X*)")

local hWnd = MGA()
if hWnd then
	take = MGT(hWnd)
	if take then
		-- this gets used by everything
		local _, nCt = MCE(take)

		-- TAKE - the easy one
		if sOp == "T" then
			if sSel == "I" then
				local sel
				for n = 0, nCt-1 do
					_, sel = MGN(take,n)
					MSN(take,n,not sel,nil,nil,nil,nil,nil,nil,true)
				end
			else
				MSA(take,sSel=="A")
			end

		-- now it gets hinky
		else
			-- get common locals
			local cppq = pt2ppq(take,GCP())
			local bClr = sXtnd ~= "X"
			local mppq = ppqSM(take,cppq)
			local selFunc = GetSelFunc(sSel)
			local sppq, eppq
			local ClearFrom = function(i)
					for n = i,nCt-1 do
						MSN(take,n,false,nil,nil,nil,nil,nil,nil,true)
					end
				end
			-- @ EDIT CURSOR
			if sOp == "@" then
				for idx = 0,nCt-1 do
					_, _, _, sppq,eppq = MGN(take,idx)
					if eppq <= cppq then
						-- keep looking
						if bClr then
							MSN(take,idx,false,nil,nil,nil,nil,nil,nil,true)
						end
					elseif sppq <= cppq then
						-- select it
						selFunc(idx)
					else
						-- we're done
						if bClr then
							ClearFrom(idx)
						end
						break
					end
				end

			else
				-- get additional locals
				local tix = r.SNM_GetIntConfigVar("miditicksperbeat",0)
				local bStart = sStart=="T"
				local bEnd = sEnd=="T"
				local ts, te, qn
				-- set ts & te
				-- MEASURE
				if sOp == "M" then
					ts = mppq
					te = ppqEM(take,cppq)  -- - 1
				-- QUARTER
				elseif sOp == "Q" then
					qn = (cppq - mppq)//tix
					ts = qn*tix + mppq
					te = ts + tix - 1
				-- SELECTION
				elseif sOp == "S" then
					local selS, selE = LTR(false,false,0,0,false)
					ts = pt2ppq(take,selS)
					te = pt2ppq(take,selE)
				-- Oopsy
				else
					SMB("Unknown op: '"..sOp.."'\nPassed in OSC message !",
						"OSC Error",0x30)
					goto done
				end
				-- range is set
				for idx = 0,nCt-1 do
					_, _, _, sppq,eppq = MGN(take,idx)
					if eppq < ts then
						goto cont
					elseif sppq > te then
						-- we're done, clear the rest 
						if bClr then
							ClearFrom(idx)
						end
						break
					end
					-- some part of the note falls within the range
					if (bStart and sppq < ts) or (bEnd and eppq > te) then
						goto cont
					end
					selFunc(idx)
					goto nxt
					::cont::
					if bClr then
						MSN(take,idx,false,nil,nil,nil,nil,nil,nil,true)
					end
					::nxt::
				end
			end
		end
		::done::
	else
		SMB("MIDIEditor_GetTake() failed...\nTake object is bad or unavailable !",
			"ME_selSpan Script Error",0x30)
	end
else
	SMB("MIDIEditor_GetActive() failed...\nhWnd is bad or no MIDI editor open !",
		"ME_selSpan Script Error",0x30)
end