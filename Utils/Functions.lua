--------------------------------------------------------------------------------
--[[ Click Casting Tooltip ]]--
--
-- by ThiagoCMFranco <https://github.com/ThiagoCMFranco>
--
--Copyright (C) 2026  Thiago de C. M. Franco
--
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
--------------------------------------------------------------------------------

local name, CCT = ...
local L = CCT.L 

function GetTargetedFrameData()

    local mouseFoci = GetMouseFoci()
    
    if not mouseFoci then return nil end

    for _, frame in ipairs(mouseFoci) do

        local name = tostring(debugName or "")
        
        if frame.unit then

            local u = frame.unit
            if u == "player" or u == "target" or u == "focus" or u == "targettarget" or 
               string.find(u, "^boss%d+$") or string.find(u, "^party%d+$") or string.find(u, "^raid%d+$") then
                return true
            end
        end
    
        if name then
            for _, allowedName in ipairs(AllowedFrames) do
                if string.find(name, allowedName, 1, true) then
                    return true
                end
            end
        end
    end
    
    return nil
end

function SincronizarHabilidades()

    local infoVec = C_ClickBindings.GetProfileInfo()
    
    if not infoVec or #infoVec == 0 then
        print(L["BindingsSyncError"])
        return
    else
        print(L["BindingsSyncSuccess"])
    end
    
    local typeLabels = {
        [0] = "Nenhum",
        [1] = "Spell",
        [2] = "Macro",
        [3] = "Interação",
        [4] = "PetAction"
    }

    local modifiersLabels = {
        [0] = "N",
        [12] = "C",
        [48] = "A",
        [3] = "S",
        [60] = "CA",
        [15] = "CS",
        [51] = "SA",
        [63] = "CSA",
    }
    
    local clickLabels = {
        ["LeftButton"] = "Lclick",
        ["MiddleButton"] = "Mclick",
        ["RightButton"] = "Rclick",
        ["Button4"] = "clickButton4",
        ["Button5"] = "clickButton5",
    }

    local _, playerClass = UnitClass("player")
    local currentSpec = GetSpecialization() or 1
    CastClickApp.db.profile.classes[playerClass][currentSpec] = {}

    for index, bindingInfo in ipairs(infoVec) do
        local bType = bindingInfo.type or 0
        local actionID = bindingInfo.actionID or 0
        local button = bindingInfo.button or "Sem Botão"
        local modifiers = bindingInfo.modifiers or 0
        
        local typeLabel = typeLabels[bType] or "Desconhecido"
        
        local modLabel = (modifiers > 0) and ("(Mod:" .. modifiersLabels[modifiers] .. " - " .. modifiers .. ") ") or ""
        
        local spellName = ""
        if(typeLabel == "Spell") then
        spellName = C_Spell.GetSpellInfo(actionID).name
        end

        if(typeLabel == "Macro") then
        spellName = C_Macro.GetMacroName(actionID)
        end

        if (typeLabel == "Spell") then
            table.insert(CastClickApp.db.profile.classes[playerClass][currentSpec], {
                                ActivationKeys = modifiersLabels[modifiers] or "N",
                                Type = typeLabel,
                                ID = actionID,
                                SpellName = spellName,
                                Click = clickLabels[button]
                            })
        end
        if (typeLabel == "Macro") then
        table.insert(CastClickApp.db.profile.classes[playerClass][currentSpec], {
                                ActivationKeys = modifiersLabels[modifiers] or "N",
                                Type = typeLabel,
                                ID = actionID,
                                SpellName = "|cff80ccff" .. spellName .. " " .. L["Macro"] .. "|r",
                                Click = clickLabels[button]
                            })
        end
    end

    ClickCastingTooltip:UpdateSettings()
    
end

function CreateInlineIcon(atlasNameOrTexID, sizeX, sizeY, xOffset, yOffset)
	sizeX = sizeX or 16;
	sizeY = sizeY or sizeX;
	xOffset = xOffset or 0;
	yOffset = yOffset or 0;

	if (type(atlasNameOrTexID) == "number") then
		-- REF.: CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)
		return CreateTextureMarkup(atlasNameOrTexID, 0, 0, sizeX, sizeY, 0, 0, 0, 0, xOffset, yOffset);  --> keep original color
		-- return string.format("|T%d:%d:%d:%d:%d|t", atlasNameOrTexID, size, size, xOffset, yOffset);
	end
	-- if ( type(atlasNameOrTexID) == "string" or tonumber(atlasNameOrTexID) ~= nil ) then
	if (type(atlasNameOrTexID) == "string") then
		-- REF.: CreateAtlasMarkup(atlasName, width, height, offsetX, offsetY, rVertexColor, gVertexColor, bVertexColor)
		return CreateAtlasMarkup(atlasNameOrTexID, sizeX, sizeY, xOffset, yOffset);  --> keep original color
	end

	return ''
end