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


-- Instanciação da função principal do Addon
ClickCastingTooltip = ClickCastingTooltip or {}

if not ClickCastingTooltipSharedDB then
    ClickCastingTooltipSharedDB = {minimap = {hide = false}}
end
if not ClickCastingTooltipDB then
    ClickCastingTooltipDB = {}
end

local name, CCT = ...
local L = CCT.L 

-- Adição do ícone de minimapa.
ClickCastingTooltipMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("ClickCastingTooltip", {
	type = "data source",
	text = L["AddonName"],
	icon = "Interface\\AddOns\\ClickCastingTooltip\\CCTIcon.png",
	OnClick = function(self, btn)
        if btn == "LeftButton" then
            ToggleClickBindingFrame()
        elseif btn == "RightButton" then
            PlaySound(808)
            ClickCastingTooltip:ToggleSettingsFrame()
        end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end
		if (ClickCastingTooltipDB.HideDeveloperCreditOnTooltips) then
        	tooltip:AddLine(L["AddonName_Interface"] .. "\n\n" .. L["LClickAction"] .. "\n" .. L["RClickAction"] .."", nil, nil, nil, nil)
    	else
			tooltip:AddLine(L["AddonName_Interface"] .. "\n\n" .. L["LClickAction"] .. "\n" .. L["RClickAction"] .. "\n\n" .. L["DevelopmentTeamCredit"], nil, nil, nil, nil)
	    end
        
	end,
})

ClickCastingTooltipMinimapButton:Show(L["AddonName"])

local eventListenerFrame = CreateFrame("Frame", "ClickCastingTooltipEventListenerFrame", UIParent)

eventListenerFrame:RegisterEvent("ADDON_LOADED")

eventListenerFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        local addonName = L["AddonName"]
        if name == addonName then
            ClickCastingTooltipMinimapButton:Register(L["AddonName"], miniButton, ClickCastingTooltipSharedDB.minimap)
        end
	end
end)

function CCT_ToggleMinimapButton(_param)
    if _param then
        ClickCastingTooltipMinimapButton:Hide("ClickCastingTooltip")
    else
        ClickCastingTooltipMinimapButton:Show("ClickCastingTooltip")
    end
end

local function AreKeysPressed(activationString)
    if activationString == "N" then
        return not (IsControlKeyDown() or IsAltKeyDown() or IsShiftKeyDown())
    end
    local reqCtrl = string.find(activationString, "C") ~= nil
    local reqAlt = string.find(activationString, "A") ~= nil
    local reqShift = string.find(activationString, "S") ~= nil
    return IsControlKeyDown() == reqCtrl and IsAltKeyDown() == reqAlt and IsShiftKeyDown() == reqShift
end

---------------------------------------------------------
-- CONFIGURAÇÃO DO FRAME MÓVEL (HUD)
---------------------------------------------------------

local CastClickFrame = CreateFrame("Frame", "CastClickBindingHUD", UIParent, "BackdropTemplate")
CastClickFrame:SetSize(220, 100)
CastClickFrame:SetPoint("CENTER", 0, 0)
CastClickFrame:SetMovable(true)
CastClickFrame:EnableMouse(true)
CastClickFrame:RegisterForDrag("RightButton")
CastClickFrame:SetClampedToScreen(true)

-- Estilo Visual
CastClickFrame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
CastClickFrame:SetBackdropColor(0, 0, 0, 0.8)

-- Texto do Título
local title = CastClickFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
title:SetPoint("TOPLEFT", 10, -10)
title:SetText(L["Cast_Click_Bindings"])
title:SetTextColor(0, 1, 0) -- Verde

-- Tabela para armazenar as linhas de texto do frame
CastClickFrame.Lines = {}

local function UpdateHUD()
    local hasMouseover = UnitExists("mouseover")
    for _, line in ipairs(CastClickFrame.Lines) do line:Hide() end
    if not hasMouseover then return end

    local _, playerClass = UnitClass("player")
    local classData = CastClickApp.db.profile.classes[playerClass]
    if not classData then return end

    -- Agrupa habilidades por combinação de teclas e tipo de clique
    local grouped = {}
    for _, info in ipairs(classData) do
        if AreKeysPressed(info.ActivationKeys) then
            grouped[info.ActivationKeys] = grouped[info.ActivationKeys] or {}
            table.insert(grouped[info.ActivationKeys], info)
        end
    end

    -- Ordem fixa dos tipos de clique
    local clickOrder = {"Lclick", "Mclick", "Rclick", "clickButton4", "clickButton5"}

    local lineIndex = 1
    local lineWidth = 200
    for activationKeys, infos in pairs(grouped) do
        -- Cabeçalho das teclas
        if not CastClickFrame.Lines[lineIndex] then
            CastClickFrame.Lines[lineIndex] = CastClickFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
        end
        local header = CastClickFrame.Lines[lineIndex]
        header:SetPoint("TOPLEFT", 10, -20 - (lineIndex * 15))
        local prefix = activationKeys
            :gsub("C", "|cff00ccffCtrl|r ")
            :gsub("S", "|cffff7d0aShift|r ")
            :gsub("A", "|cffffff00Alt|r ")
            :gsub("N", "")
        header:SetText(prefix)
        header:SetTextColor(0.8, 1, 0.8)
        header:Show()
        if lineWidth < header:GetWidth() then lineWidth = header:GetWidth() end
        lineIndex = lineIndex + 1

        -- Exibe habilidades na ordem fixa de clique
        for _, clickType in ipairs(clickOrder) do
            for _, info in ipairs(infos) do
                if info.Click == clickType then
                    if not CastClickFrame.Lines[lineIndex] then
                        CastClickFrame.Lines[lineIndex] = CastClickFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
                    end
                    local fs = CastClickFrame.Lines[lineIndex]
                    fs:SetPoint("TOPLEFT", 25, -20 - (lineIndex * 15))

                    local r, g, b = 1, 1, 1
                    local status = ""
                    local displayName = info.SpellName

                    if info.Type == "macro" then
                        r, g, b = 0.5, 0.8, 1
                        displayName = displayName .. " [M]"
                    end

                    local click = info.Click
                        :gsub("Lclick", "|cffD3AF37" .. L["Lclick"] .. "|r")
                        :gsub("Rclick", "|cffD3AF37" .. L["Rclick"] .. "|r")
                        :gsub("Mclick", "|cffD3AF37" .. L["Mclick"] .. "|r")
                        :gsub("clickButton4", "|cffD3AF37" .. L["clickButton4"] .. "|r")
                        :gsub("clickButton5", "|cffD3AF37" .. L["clickButton5"] .. "|r")

                    fs:SetText(string.format("%s: %s%s", click, displayName, status))
                    fs:SetTextColor(r, g, b)
                    fs:Show()
                    if lineWidth < fs:GetWidth() then lineWidth = fs:GetWidth() end
                    lineIndex = lineIndex + 1
                end
            end
        end
    end

    if lineIndex == 1 then
        CastClickFrame:SetHeight(50)
        CastClickFrame:SetWidth(220)
    else
        title:Show()
        CastClickFrame:SetBackdropColor(0, 0, 0, 0.8)
        CastClickFrame:SetBackdropBorderColor(1, 1, 1, 1)
        CastClickFrame:SetHeight(35 + (lineIndex * 15))
        CastClickFrame:SetWidth(lineWidth + 40)
    end
end

-- Eventos de Arrastar
CastClickFrame:SetScript("OnDragStart", function(self)
   if not ClickCastingTooltipDB.LockDragDrop then
    self:StartMoving()
    end 
end)
CastClickFrame:SetScript("OnDragStop", function(self)
   if not ClickCastingTooltipDB.LockDragDrop then
    CastClickFrame:StopMovingOrSizing()
    end 
end)

-- Atualização constante (OnUpdate) para checar teclas
CastClickFrame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 0.1 then -- Atualiza a cada 0.1s para performance
        UpdateHUD()
        self.timer = 0
    end
end)

local function SetupSlashCommands()

    SLASH_ClickCastingTooltip1 = "/ClickCastingTooltip"
    SLASH_ClickCastingTooltip2 = "/CCT"
    SlashCmdList["ClickCastingTooltip"] = function(arg)
        if (arg == "config") then
            ClickCastingTooltip:ToggleSettingsFrame()
        elseif (arg == "bindings") then
            ToggleClickBindingFrame()
        else
			print(L["SlashCommands"])
        end
    end
end

SetupSlashCommands()