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

StatusConfig = {
    ["A"] = { label = L["Alied"], color = "ff00ff00" },
    ["E"] = { label = L["Enemy"], color = "ffff0000" },
    ["H"] = { label = L["Hostile"], color = "ffff0000" },
    ["N"] = { label = L["Neutral"], color = "ffffff00" },
    ["F"] = { label = L["Friendly"], color = "ff00ff00" },
    ["S"] = { label = "-", color = "ffffffff" },
}

ClassHexColors = {
    ["DEATHKNIGHT"] = "ffC41E3A",
    ["DEMONHUNTER"] = "ffA330C9",
    ["DRUID"]       = "ffFF7C0A",
    ["EVOKER"]      = "ff33937F",
    ["HUNTER"]      = "ffAAD372",
    ["MAGE"]        = "ff3FC7EB",
    ["MONK"]        = "ff00FF98",
    ["PALADIN"]     = "ffF48CBA",
    ["PRIEST"]      = "ffFFFFFF",
    ["ROGUE"]       = "ffFFF468",
    ["SHAMAN"]      = "ff0070DD",
    ["WARLOCK"]     = "ff8788EE",
    ["WARRIOR"]     = "ffC69B6D",
    ["X"]           = "ffffffff",
}

KeysColors = {
    ["Ctrl"] = "ff00ccff",
    ["Alt"] = "ffffff00",
    ["Shift"] = "ffff7d0a",
    ["LClick"] = "ffD3AF37",
    ["MClick"] = "ffD3AF37",
    ["RClick"] = "ffD3AF37",
    ["clickButton4"] = "ffD3AF37",
    ["clickButton5"] = "ffD3AF37",
    ["No_Modifier"] = "ffffffff",
}

AllowedFrames = {"TargetFrame", "PlayerFrame", "FocusFrame", "PartyFrame", "RaidFrame", "ArenaFrame"}