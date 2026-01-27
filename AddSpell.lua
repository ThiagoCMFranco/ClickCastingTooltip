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

local name, cct = ...
local L = cct.L 

local AddonName = "ClickCastingTooltip"
CastClickApp = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0")

local defaults = {
    profile = {
        classes = {
            ["DRUID"] = {}, ["SHAMAN"] = {}, ["PALADIN"] = {}, ["PRIEST"] = {},
            ["MONK"] = {}, ["EVOKER"] = {}, ["WARRIOR"] = {}, ["HUNTER"] = {},
            ["ROGUE"] = {}, ["DEATHKNIGHT"] = {}, ["MAGE"] = {}, ["WARLOCK"] = {},
            ["DEMONHUNTER"] = {},
        }
    }
}

function CastClickApp:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ClickCastingTooltipDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, function() return self:GetOptions() end)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, "Cast Click Tooltip")
    self:RegisterChatCommand("ccc", function() 
        Settings.OpenToCategory(self.optionsFrame:GetID()) -- Versão moderna para o menu de opções
    end)
end

function CastClickApp:RefreshConfig()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(AddonName)
end

---------------------------------------------------------
-- INTERFACE DE CONFIGURAÇÃO COM BUSCA POR NOME/ID
---------------------------------------------------------
function CastClickApp:GetOptions()
    local _, playerClass = UnitClass("player")

    self.tmpType = self.tmpType or "spell"
    
    -- Lógica de busca e preview
local previewName, previewIcon = L["Waiting_Search"], "Interface\\Icons\\INV_Misc_QuestionMark"

if self.searchQuery and self.searchQuery ~= "" then
    if self.tmpType == "spell" then
        -- Lógica para Magia
        local spellInfo = C_Spell.GetSpellInfo(self.searchQuery)
        if spellInfo then
            previewName = "|cFFFFFFFF" .. spellInfo.name .. "|r"
            previewIcon = spellInfo.iconID
            self.validatedID = spellInfo.spellID
        end
    else
        -- Lógica para Macro
        -- GetMacroInfo aceita tanto o Índice quanto o Nome da macro
        local name, icon = GetMacroInfo(self.searchQuery)
        if name then
            previewName = "|cff80ccff" .. name .. " " .. L["Macro"] .. "|r"
            previewIcon = icon
            self.validatedID = name -- Usamos o nome como ID para macros
        end
    end
    
    if not self.validatedID then
        previewName = L["Not_Found"]
    end
end

    local options = {
        name = L["AddonName_Interface"],
        type = "group",
        args = {
            searchGroup = {
                order = 1,
                name = L["Search"],
                type = "group",
                inline = true,
                args = {
                    typeSelect = {
                        name = L["Binding_Type"],
                        type = "select",
                        values = { spell = L["Spell"], macro = L["Macro"] },
                        set = function(_, v) self.tmpType = v; self.searchQuery = ""; self.validatedID = nil; self:RefreshConfig() end,
                        get = function(_) return self.tmpType end,
                        order = 0,
                    },
                    spellSearch = {
                        name = self.tmpType == "spell" and L["Spell_Search_Title"] or L["Macro_Search_Title"],
                        desc = self.tmpType == "spell" and L["Spell_Search_Description"] or L["Macro_Search_Description"],
                        type = "input",
                        width = "double",
                        set = function(_, v) 
                            self.searchQuery = v
                            self.validatedID = nil -- Reseta para validar novamente
                            self:RefreshConfig() 
                        end,
                        get = function(_) return self.searchQuery or "" end,
                        order = 1,
                    },
                    preview = {
                        name = L["Result"] .. " " .. previewName,
                        type = "description",
                        image = previewIcon,
                        imageWidth = 36, imageHeight = 36,
                        order = 2,
                    },
                },
            },
            bindGroup = {
                order = 2,
                name = L["Config_Shortcut"],
                type = "group",
                inline = true,
                args = {
                    keys = {
                        name = L["ActivationKey_Label"],
                        desc = L["ActivationKey_Description"],
                        type = "select",
                        -- Rótulos legíveis para o usuário
                        values = {
                            ["N"] = L["None"],
                            ["C"] = L["Ctrl"],
                            ["S"] = L["Shift"],
                            ["A"] = L["Alt"],
                            ["CS"] = L["Ctrl_Shift"],
                            ["CA"] = L["Ctrl_Alt"],
                            ["SA"] = L["Shift_Alt"],
                            ["CSA"] = L["Ctrl_Shift_Alt"],
                        },
                        set = function(_, v) self.tmpKeys = v end,
                        get = function(_) return self.tmpKeys or "N" end,
                        order = 1,
                    },
                    click = {
                        name = L["Mouse_Button_Label"],
                        type = "select",
                        values = {Lclick=L["Lclick"], Rclick=L["Rclick"], Mclick=L["Mclick"], clickButton4=L["clickButton4"], clickButton5=L["clickButton5"]},
                        set = function(_, v) self.tmpClick = v end,
                        get = function(_) return self.tmpClick or "Lclick" end,
                        order = 2,
                    },
                    addBtn = {
                        name = L["Add_Spell_Macro"],
                        type = "execute",
                        disabled = function() return not self.validatedID end,
                        func = function()
                            local info = C_Spell.GetSpellInfo(self.validatedID)
                            table.insert(self.db.profile.classes[playerClass], {
                                ActivationKeys = self.tmpKeys or "N",
                                Type = self.tmpType, -- "spell" ou "macro"
                                ID = self.validatedID, -- SpellID ou Nome da Macro
                                SpellName = self.tmpType == "spell" and C_Spell.GetSpellInfo(self.validatedID).name or self.validatedID,
                                Click = self.tmpClick or "Lclick"
                            })
                            -- Reset pós-adição
                            self.searchQuery = ""
                            self.validatedID = nil
                            self:RefreshConfig()
                        end,
                        order = 3,
                    },
                },
            },
            list = {
                order = 3,
                name = L["Bind_Spell_Macro_List_Label"],
                type = "group",
                inline = true,
                args = {}
            },
        }
    }

    -- Gerador dinâmico da lista de habilidades
local classData = self.db.profile.classes[playerClass]
if classData then
    for k, v in ipairs(classData) do
        -- Tradução das siglas para nomes coloridos e legíveis
        local keyDisplay = v.ActivationKeys
            :gsub("C", "|cff00ccff" .. L["Ctrl"] .. "|r ")
            :gsub("S", "|cffff7d0a" .. L["Shift"] .. "|r ")
            :gsub("A", "|cffffff00" .. L["Alt"] .. "|r ")
            :gsub("N", "|cffaaaaaa" .. L["No_Modifier"] .. "|r")

        -- Tradução do botão do mouse
        local clickDisplay = v.Click
            :gsub("Lclick", "|cffD3AF37" .. L["Lclick"] .. "|r")
            :gsub("Rclick", "|cffD3AF37" .. L["Rclick"] .. "|r")
            :gsub("Mclick", "|cffD3AF37" .. L["Mclick"] .. "|r")

        options.args.list.args["item"..k] = {
            -- Exemplo de saída: [Ctrl Shift] + Esq. : Cura Encadeada
            name = string.format("|cffffee00[%s]|r + |cffffffff%s|r : |cff00ff00%s|r", 
                                 keyDisplay, clickDisplay, v.SpellName),
            type = "execute",
            desc = L["Click_To_Remove_Spell"],
            confirm = true,
            confirmText = L["Remove"] .. v.SpellName .. "?",
            func = function() 
                table.remove(classData, k)
                self:RefreshConfig()
            end,
            width = "full",
            order = k + 10,
        }
    end
end

    return options
end