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

local AddonName = L["AddonName"]
local Prefix = "CCT_VER_CHECK"

C_ChatInfo.RegisterAddonMessagePrefix(Prefix)

local VersionManager = CreateFrame("Frame")
-- Eventos registrados
VersionManager:RegisterEvent("GROUP_ROSTER_UPDATE")
VersionManager:RegisterEvent("GUILD_ROSTER_UPDATE")
VersionManager:RegisterEvent("CHAT_MSG_ADDON")
VersionManager:RegisterEvent("PLAYER_LOGIN")

local hasWarned = false
local lastQuery = 0

-- Inicializar SharedDB se necessário
local function InitializeSharedDB()
    if not ClickCastingTooltipSharedDB then
        ClickCastingTooltipSharedDB = {}
    end
    if not ClickCastingTooltipSharedDB.LatestVersionUID then
        ClickCastingTooltipSharedDB.LatestVersionUID = C_CCT_VERSION_UID
    end
end

-- Função para comparar versões
local function CheckUpdate(remoteVersion, sender)
    local remote = tonumber(remoteVersion)
    if remote and remote > C_CCT_VERSION_UID then
        if not hasWarned then
            print("|cFF00FF00["..AddonName.."]|r[|cFFFF0000" .. formatarNumeroVersao(C_CCT_VERSION_UID) .. "|r]: " .. L["NewVersionMessage"] .. "|cFF00FF00".. formatarNumeroVersao(remote) .."|r.")
            hasWarned = true
        end
        -- Atualizar a referência de versão mais recente
        InitializeSharedDB()
        if (remote > ClickCastingTooltipSharedDB.LatestVersionUID) then
            ClickCastingTooltipSharedDB.LatestVersionUID = remote
        end
    end
end

local function CheckUpdateFromSharedDB()
    InitializeSharedDB()
    local latestRef = ClickCastingTooltipSharedDB.LatestVersionUID
    
    if latestRef and tonumber(latestRef) > C_CCT_VERSION_UID then
        if not hasWarned then
            print("|cFF00FF00["..AddonName.."]|r[|cFFFF0000" .. formatarNumeroVersao(C_CCT_VERSION_UID) .. "|r]: " .. L["NewVersionMessage"] .. "|cFF00FF00".. formatarNumeroVersao(latestRef) .."|r.")
            hasWarned = true
        end
    end
end


-- Função principal para enviar a pergunta de versão
local function QueryVersion(manual)
    local now = GetTime()
    
    -- Anti-spam: Se não for manual, espera 30 segundos entre envios automáticos
    if not manual and (now - lastQuery) < 30 then return end
    
    local sent = false

    if IsInGuild() then
        C_ChatInfo.SendAddonMessage(Prefix, "QUERY_VERSION", "GUILD")
        sent = true
    end

    local groupChannel
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        groupChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        groupChannel = "RAID"
    elseif IsInGroup() then
        groupChannel = "PARTY"
    end

    if groupChannel then
        C_ChatInfo.SendAddonMessage(Prefix, "QUERY_VERSION", groupChannel)
        sent = true
    end

    if sent then
        lastQuery = now
        if manual then
            print("|cFF00FF00["..AddonName.."]|r|cFFFF0000[Debug]|r Verificação de versão enviada para guilda/grupo.")
        end
    elseif manual then
        print("|cFF00FF00["..AddonName.."]|r|cFFFF0000[Debug]|r Você não está em um grupo ou guilda.")
    end

    if manual then
        CheckUpdateFromSharedDB()
    end
end

-- Comando de Chat
SLASH_ClickCastingTooltipDebug1 = "/cctdebug"
SlashCmdList["ClickCastingTooltipDebug"] = function(msg)
    if msg:lower():trim() == "-v" then
        QueryVersion(true)
    else
        print("|cFF00FF00["..AddonName.."]|r Use |cFFFFD100/cctdebug -v|r para verificar atualizações.")
    end
end

-- Gerenciador de Eventos
VersionManager:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix ~= Prefix or sender == UnitFullName("player") then return end

        if message == "QUERY_VERSION" then
            C_ChatInfo.SendAddonMessage(Prefix, tostring(C_CCT_VERSION_UID), "WHISPER", sender)
        else
            CheckUpdate(message, sender)
        end

    elseif event == "GROUP_ROSTER_UPDATE" or event == "GUILD_ROSTER_UPDATE" then
        -- Disparo automático (respeita o anti-spam de 30s)
        QueryVersion(false)
    elseif event == "PLAYER_LOGIN" then
        -- Ao conectar, tenta via chat e depois usa fallback se necessário
        C_Timer.After(0.1,function()
            QueryVersion(false)
            CheckUpdateFromSharedDB()
        end)
    end
end)

function formatarNumeroVersao(num)
    num = tonumber(num)
    if not num then return "0.0.0" end
    num = math.floor(num) % 1000000000

    -- Bloco 1 (Milhões), Bloco 2 (Milhares), Bloco 3 (Unidades)
    local b1 = math.floor(num / 1000000)
    local b2 = math.floor((num % 1000000) / 1000)
    local b3 = num % 1000

    -- A concatenação nativa de strings em Lua já descarta zeros à esquerda
    -- de números ao convertê-los para string.
    return b1 .. "." .. b2 .. "." .. b3
end