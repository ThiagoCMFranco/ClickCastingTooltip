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



local name, mct = ...
local L = mct.L 

local C_LanguageContributors = {}

local AceGUI = LibStub("AceGUI-3.0")

-- Create a container frame
local settingsFrame = AceGUI:Create("Frame")
settingsFrame:SetCallback("OnClose",function(widget)  end)
settingsFrame:SetTitle(L["AddonName_Interface"] .. " - " .. L["Settings"])
settingsFrame:SetStatusText(L["DevelopmentTeamCredit"])
settingsFrame:SetWidth(880)
settingsFrame:SetHeight(540)
settingsFrame:SetLayout("Flow")

-- Add the frame as a global variable under the name `CCTSettingsFrameName`
_G["CCTSettingsFrameName"] = settingsFrame.frame
-- Register the global variable `CCTSettingsFrameName` as a "special frame"
-- so that it is closed when the escape key is pressed.
tinsert(UISpecialFrames, "CCTSettingsFrameName")

local treeW = AceGUI:Create("TreeGroup")

function CCT_LoadCredits()

    treeW:ReleaseChildren()

    scrollContainerCredits = AceGUI:Create("SimpleGroup")
    scrollContainerCredits:SetFullWidth(true)
    scrollContainerCredits:SetFullHeight(true)
    scrollContainerCredits:SetLayout("Fill")
    
    treeW:AddChild(scrollContainerCredits)
    
    scrollFrameCredits = AceGUI:Create("ScrollFrame")
    scrollFrameCredits:SetLayout("Flow")
    scrollContainerCredits:AddChild(scrollFrameCredits)

    local LabelCredits = AceGUI:Create("Label")
    LabelCredits:SetText(L["lblCreditColabList"])
    SetACE3WidgetFontSize(LabelCredits, 13)
    LabelCredits:SetWidth(580)
    scrollFrameCredits:AddChild(LabelCredits)

end

function CCT_LoadAbout()
    treeW:ReleaseChildren()

    scrollContainerAbout = AceGUI:Create("SimpleGroup")
    scrollContainerAbout:SetFullWidth(true)
    scrollContainerAbout:SetFullHeight(true)
    scrollContainerAbout:SetLayout("Fill")
    
    treeW:AddChild(scrollContainerAbout)
    
    scrollFrameAbout = AceGUI:Create("ScrollFrame")
    scrollFrameAbout:SetLayout("Flow")
    scrollContainerAbout:AddChild(scrollFrameAbout)

    local LabelAbout_Title = AceGUI:Create("Label")
    LabelAbout_Title:SetText("|cFFFFC90E" .. L["AddonName_Interface"] .. "|r")
    SetACE3WidgetFontSize(LabelAbout_Title, 20)
    LabelAbout_Title:SetWidth(640)
    scrollFrameAbout:AddChild(LabelAbout_Title)

    local LabelAbout = AceGUI:Create("Label")
    LabelAbout:SetText("|cFFFFC90E" .. L["About_Version"] .. "|r\n\n" .. L["About_Title"] .. "\n\n" .. L["About_Line1"] .. "\n\n" .. L["About_Line2"] .. "\n\n" .. L["About_Line3"] .. "\n\n")
    SetACE3WidgetFontSize(LabelAbout, 13)
    LabelAbout:SetWidth(620)
    scrollFrameAbout:AddChild(LabelAbout)

    local btnOpenSpellSettings = AceGUI:Create("Button")

    btnOpenSpellSettings:SetText(L["buttonOpenSpellSettings"])
    btnOpenSpellSettings:SetWidth(260)
    btnOpenSpellSettings:SetCallback("OnClick", function() 
        ToggleClickBindingFrame()
    end)
    scrollFrameAbout:AddChild(btnOpenSpellSettings)
    
    local headingAbout1 = AceGUI:Create("Heading")
    headingAbout1:SetRelativeWidth(1)
    scrollFrameAbout:AddChild(headingAbout1)

    local LabelAboutLocalizationDisclaimer = AceGUI:Create("Label")
    LabelAboutLocalizationDisclaimer:SetText(L["About_Line4"])
    SetACE3WidgetFontSize(LabelAboutLocalizationDisclaimer, 13)
    LabelAboutLocalizationDisclaimer:SetWidth(620)
    scrollFrameAbout:AddChild(LabelAboutLocalizationDisclaimer)
end

function CCT_LoadSettings()
    treeW:ReleaseChildren()

    scrollContainerGeneral = AceGUI:Create("SimpleGroup")
    scrollContainerGeneral:SetFullWidth(true)
    scrollContainerGeneral:SetFullHeight(true)
    scrollContainerGeneral:SetLayout("Fill")
    
    treeW:AddChild(scrollContainerGeneral)
    
    scrollFrameGeneral = AceGUI:Create("ScrollFrame")
    scrollFrameGeneral:SetLayout("Flow")
    scrollContainerGeneral:AddChild(scrollFrameGeneral)

    local btnOpenSpellSettings = AceGUI:Create("Button")

    --btnOpenSpellSettings:SetText(L["buttonOpenSpellSettings"])
    --btnOpenSpellSettings:SetWidth(200)
    --btnOpenSpellSettings:SetCallback("OnClick", function() 
    --    ToggleClickBindingFrame()
    --end)
    --scrollFrameGeneral:AddChild(btnOpenSpellSettings)

    local chkLockDragDrop = AceGUI:Create("CheckBox")
    local chkHideMinimapIcon = AceGUI:Create("CheckBox")
    local chkHideDeveloperCreditOnTooltips = AceGUI:Create("CheckBox")
    local chkHideWhenNoActionIsBound = AceGUI:Create("CheckBox")
    local chkHidePanelTitle = AceGUI:Create("CheckBox")
    
    chkLockDragDrop:SetLabel(L["LockDragDrop"])
    chkLockDragDrop:SetCallback("OnValueChanged", function(widget, event, text) 
        ClickCastingTooltipDB.LockDragDrop = chkLockDragDrop:GetValue()
    end)
    chkLockDragDrop:SetWidth(700)
    scrollFrameGeneral:AddChild(chkLockDragDrop)
    
    chkHideMinimapIcon:SetLabel(L["chkHideMinimapIcon"])
    chkHideMinimapIcon:SetCallback("OnValueChanged", function(widget, event, text) 
        ClickCastingTooltipDB.HideMinimapIcon = chkHideMinimapIcon:GetValue()
        ClickCastingTooltipSharedDB.minimap.hide = ClickCastingTooltipDB.HideMinimapIcon
    end)
    chkHideMinimapIcon:SetWidth(575)
    scrollFrameGeneral:AddChild(chkHideMinimapIcon)
    
    chkHideDeveloperCreditOnTooltips:SetLabel(L["HideDeveloperCreditOnTooltips"])
    chkHideDeveloperCreditOnTooltips:SetCallback("OnValueChanged", function(widget, event, text) 
        ClickCastingTooltipDB.HideDeveloperCreditOnTooltips = chkHideDeveloperCreditOnTooltips:GetValue()
     end)
    chkHideDeveloperCreditOnTooltips:SetWidth(700)
    scrollFrameGeneral:AddChild(chkHideDeveloperCreditOnTooltips)

    chkHideWhenNoActionIsBound:SetLabel(L["HideWhenNoActionIsBound"])
    chkHideWhenNoActionIsBound:SetCallback("OnValueChanged", function(widget, event, text) 
        ClickCastingTooltipDB.HideWhenNoActionIsBound = chkHideWhenNoActionIsBound:GetValue()
     end)
    chkHideWhenNoActionIsBound:SetWidth(700)
    scrollFrameGeneral:AddChild(chkHideWhenNoActionIsBound)

    chkHidePanelTitle:SetLabel(L["HidePanelTitle"])
    chkHidePanelTitle:SetCallback("OnValueChanged", function(widget, event, text) 
        ClickCastingTooltipDB.HidePanelTitle = chkHidePanelTitle:GetValue()
        ClickCastingTooltip.UpdateDisplay()
     end)
    chkHidePanelTitle:SetWidth(700)
    scrollFrameGeneral:AddChild(chkHidePanelTitle)
 
    chkLockDragDrop:SetValue(ClickCastingTooltipDB.LockDragDrop)
    chkHideMinimapIcon:SetValue(ClickCastingTooltipDB.HideMinimapIcon)
    chkHideDeveloperCreditOnTooltips:SetValue(ClickCastingTooltipDB.HideDeveloperCreditOnTooltips)
    chkHideWhenNoActionIsBound:SetValue(ClickCastingTooltipDB.HideWhenNoActionIsBound)
    chkHidePanelTitle:SetValue(ClickCastingTooltipDB.HidePanelTitle)
    

end


local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function CCT_LoadAddActions()
    -- Limpa o conteúdo anterior do TreeGroup
    treeW:ReleaseChildren()

    -- 1. Criamos um SimpleGroup para servir de casca (Wrapper)
    -- Usamos o layout "Fill" para que ele ocupe todo o espaço do TreeGroup
    local aceContainer = AceGUI:Create("ScrollFrame")
    aceContainer:SetLayout("Fill")
    aceContainer:SetFullWidth(true)
    aceContainer:SetFullHeight(true)

    treeW:AddChild(aceContainer)

    local label = AceGUI:Create("Label")

    label:SetText(
    "|cffffd100Addon spell and macro window:|r\n" ..
    "this shoudn't be here but is the only way to make this work properly. " ..
    "This is a dummy text to keep enough space to keep fields fitting the right size of the panel.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    )

    label:SetFullWidth(true)
    
    label:SetFontObject(GameFontHighlightSmall) -- Ou use label:SetFont("Fonts\\FRIZQT__.TTF", 12)
    
    aceContainer:AddChild(label)

    AceConfigDialog:Open("ClickCastingTooltip", aceContainer)        
end

tree = { 
    { 
        value = "S",
        text = L["Settings_Menu_About"],
        icon = "Interface\\Icons\\inv_misc_book_09",
    },
    { 
        value = "G",
        text = L["Settings_Menu_General"],
        icon = "Interface\\Icons\\inv_misc_gear_01",
    },
    { 
        value = "A",
        text = L["Settings_Menu_AddActions"],
        icon = "Interface\\Icons\\inv_misc_gear_01",
    },
    { 
        value = "C", 
        text = L["Settings_Menu_Credit"],
        icon = "Interface\\Icons\\inv_misc_coin_02",
    },
  }

  
  treeW:SetFullHeight(true)
  treeW:SetLayout("Flow")
  treeW:SetTree(tree)
  settingsFrame:AddChild(treeW)

  treeW:SetCallback("OnGroupSelected", function(container, _, group, ...)
    
    --elseif string.find(group, "Ctx") then

    if group == "G" then
        CCT_LoadSettings()
    elseif group == "A" then
        CCT_LoadAddActions()
    elseif group == "C" then
        CCT_LoadCredits()
    elseif group == "S" then
        CCT_LoadAbout()
    else
        print(group)
    end
end)

settingsFrame:Hide()

treeW:SelectByValue("S")

CCT_LoadAbout()

function ClickCastingTooltip:ToggleSettingsFrame()
    if not settingsFrame:IsShown() then
        settingsFrame:Show()
    else
        settingsFrame:Hide()
    end
end

--Cria atalho para as configurações na janela nativa de opções de addons.
local ClickCastingTooltipMainPanel = CreateFrame("Frame", "ClickCastingTooltipNativeMainSettings", UIParent)
ClickCastingTooltipMainPanel.name = L["AddonName_Interface"]

local MainCategory, layout = Settings.RegisterCanvasLayoutCategory(ClickCastingTooltipMainPanel, ClickCastingTooltipMainPanel.name)
Settings.RegisterAddOnCategory(MainCategory)

local title = ClickCastingTooltipMainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["AddonName_Interface"])

local btnAbrirConfiguracoes = CreateFrame("Button", "OpenAce3Window", ClickCastingTooltipMainPanel, "GameMenuButtonTemplate")
btnAbrirConfiguracoes:SetPoint("TOPLEFT", 16, -40)
btnAbrirConfiguracoes:SetSize(280, 30)
btnAbrirConfiguracoes:SetText(L["buttonOpenSettings"])
btnAbrirConfiguracoes:SetScript("OnClick", function()
    ClickCastingTooltip:ToggleSettingsFrame()
end)
