local mod = RegisterMod("DimensionalDoors", 1)
local game = Game()

local function log(msg)
    print("[DD] " .. msg)
end

-- ============================================================
-- Configuração
-- ============================================================
local RICK_VARIANT = 6660
local PORTAL_VARIANT = 6661
local RICK_TOUCH_DISTANCE = 10
local PORTAL_TOUCH_DISTANCE = 30

-- ============================================================
-- Rick: Sprite e Lógica
-- ============================================================
local function getRickSprite(ent)
    local data = ent:GetData()
    local sprite = ent:GetSprite()
    
    if not data.rickInitialized then
        sprite:Load("gfx/rick_beggar.anm2", true)
        sprite:Play("Idle", true)
        sprite.FlipX = false
        sprite.FlipY = false
        data.rickState = "idle"
        data.rickInitialized = true
    end
    -- Sempre forçar orientação correta
    sprite.FlipX = false
    sprite.FlipY = false
    return sprite, data
end

-- ============================================================
-- StageAPI: Definicao dos Novos Andares
-- ============================================================
local AdventureDimension = nil
local DemonDimension = nil

-- Carrega os arquivos de sala criados
local landOfOooRooms = include("rooms.land_of_ooo_rooms")
local infinityCastleRooms = include("rooms.infinity_castle_rooms")

-- Registra os andares IMEDIATAMENTE quando o mod é lido (não precisa esperar o jogo começar)
if StageAPI and StageAPI.Loaded then
    log("StageAPI encontrado. Registrando Custom Stages...")
    
    -- Cria a lista de salas
    local landOfOooRoomsList = StageAPI.RoomsList("LandOfOooRooms", landOfOooRooms)
    local infinityCastleRoomsList = StageAPI.RoomsList("InfinityCastleRooms", infinityCastleRooms)
    
    -- Configuração visual: Land of Ooo
    local landOfOooBackdrop = {
        NFloors = {"gfx/backdrop/land_of_ooo/nfloor.png"},
        LFloors = {"gfx/backdrop/land_of_ooo/lfloor.png"},
        Walls = {"gfx/backdrop/land_of_ooo/wall.png"},
        Corners = {"gfx/backdrop/land_of_ooo/corner.png"}
    }
    local landOfOooGridGfx = StageAPI.GridGfx()
    local landOfOooRoomGfx = StageAPI.RoomGfx(landOfOooBackdrop, landOfOooGridGfx)
    
    -- Configuração visual: Infinity Castle
    local infinityCastleBackdrop = {
        NFloors = {"gfx/backdrop/infinity_castle/nfloor.png"},
        LFloors = {"gfx/backdrop/infinity_castle/lfloor.png"},
        Walls = {"gfx/backdrop/infinity_castle/wall.png"},
        Corners = {"gfx/backdrop/infinity_castle/corner.png"}
    }
    local infinityCastleGridGfx = StageAPI.GridGfx()
    local infinityCastleRoomGfx = StageAPI.RoomGfx(infinityCastleBackdrop, infinityCastleGridGfx)
    
    -- Cria o andar customizado 1 (Land of Ooo)
    AdventureDimension = StageAPI.CustomStage("AdventureDimension")
    AdventureDimension:SetDisplayName("Land of Ooo")
    AdventureDimension:SetRooms(landOfOooRoomsList)
    AdventureDimension:SetRoomGfx(landOfOooRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_BOSS})
    
    -- Cria o andar customizado 2 (Infinity Castle)
    DemonDimension = StageAPI.CustomStage("DemonDimension")
    DemonDimension:SetDisplayName("Infinity Castle")
    DemonDimension:SetRooms(infinityCastleRoomsList)
    DemonDimension:SetRoomGfx(infinityCastleRoomGfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_BOSS})
    
    log("Andares Land of Ooo e Infinity Castle registrados com layouts iniciais e RoomGfx.")
else
    log("AVISO: StageAPI não encontrado. Portais usarão teleporte temporário.")
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isSave)
    log("Dimensional Doors inicializado.")
end)

-- ============================================================
-- Função reutilizável: Spawnar os dois portais
-- ============================================================
local function spawnPortals(centerPos)
    -- Portal Land of Ooo (Adventure Time)
    local portal1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, 0, centerPos + Vector(-60, 0), Vector.Zero, nil)
    local spr1 = portal1:GetSprite()
    spr1:Load("gfx/grid/portal_land_of_ooo.anm2", true)
    spr1:Play("Idle", true)
    spr1.FlipX = false
    spr1.FlipY = false
    portal1.SortingLayer = SortingLayer.SORTING_BACKGROUND
    portal1:GetData().portalType = "blue"
    
    -- Portal Infinity Castle (Demon Slayer)
    local portal2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, 0, centerPos + Vector(60, 0), Vector.Zero, nil)
    local spr2 = portal2:GetSprite()
    spr2:Load("gfx/grid/portal_infinity_castle.anm2", true)
    spr2:Play("Idle", true)
    spr2.FlipX = false
    spr2.FlipY = false
    portal2.SortingLayer = SortingLayer.SORTING_BACKGROUND
    portal2:GetData().portalType = "orange"
    
    log("Portais Land of Ooo e Infinity Castle spawnados.")
    return portal1, portal2
end

-- ============================================================
-- Função: Teleportar para dimensão
-- ============================================================
local function teleportToDimension(portal)
    local data = portal:GetData()
    
    if data.portalType == "orange" then
        -- Infinity Castle (Demon Slayer)
        if StageAPI and StageAPI.Loaded and DemonDimension then
            StageAPI.GotoCustomStage(DemonDimension, false)
        else
            -- Teleporte temporário enquanto StageAPI não tá configurado
            Isaac.ExecuteCommand("stage 7")
            log("(Usando teleporte temporário - StageAPI não disponível)")
        end
        portal:Remove()
        log("Teleportando para a Infinity Castle (Demon Slayer)...")
    else
        -- Land of Ooo (Adventure Time)
        if StageAPI and StageAPI.Loaded and AdventureDimension then
            StageAPI.GotoCustomStage(AdventureDimension, false)
        else
            -- Teleporte temporário enquanto StageAPI não tá configurado
            Isaac.ExecuteCommand("stage 5")
            log("(Usando teleporte temporário - StageAPI não disponível)")
        end
        portal:Remove()
        log("Teleportando para a Land of Ooo (Adventure Time)...")
    end
end

-- ============================================================
-- Spawn do Rick no quarto inicial do 1º andar
-- ============================================================
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(_)
    local level = game:GetLevel()
    if level:GetStage() ~= LevelStage.STAGE1_1 then return end

    local room = game:GetRoom()
    local isStart = (
        room:GetType() == RoomType.ROOM_DEFAULT and
        level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()
    )
    if not isStart then return end

    local margin = 60
    local spawnPos = Vector(
        room:GetBottomRightPos().X - margin,
        room:GetTopLeftPos().Y + margin
    )

    Isaac.Spawn(EntityType.ENTITY_EFFECT, RICK_VARIANT, 0, spawnPos, Vector.Zero, nil)
end)

-- ============================================================
-- UPDATE: Logica do Rick e dos Portais
-- ============================================================
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_)
    -- Logica do Rick
    local ricks = Isaac.FindByType(EntityType.ENTITY_EFFECT, RICK_VARIANT, -1)
    for _, ent in ipairs(ricks) do
        local sprite, data = getRickSprite(ent)

        if data.rickState == "idle" then
            local players = Isaac.FindInRadius(ent.Position, RICK_TOUCH_DISTANCE, EntityPartition.PLAYER)
            if #players > 0 then
                data.rickState = "teleport"
                sprite:Play("Teleport", true)
                
                local portalGunId = Isaac.GetItemIdByName("Portal Gun")
                if portalGunId and portalGunId > 0 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, portalGunId, ent.Position, Vector(0, -2), nil)
                end
            end
        elseif data.rickState == "teleport" then
            if sprite:IsFinished("Teleport") then
                ent:Remove()
            end
        end
    end

    -- Logica de entrar no Portal
    local portals = Isaac.FindByType(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, -1)
    for _, portal in ipairs(portals) do
        local players = Isaac.FindInRadius(portal.Position, PORTAL_TOUCH_DISTANCE, EntityPartition.PLAYER)
        if #players > 0 then
            teleportToDimension(portal)
            break  -- Sai do loop após teleportar (evita processar múltiplos portais no mesmo frame)
        end
    end
end)

-- ORIENTAÇÃO DOS PORTAIS E RICK: Garantir que nunca fiquem virados
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.Variant == PORTAL_VARIANT or effect.Variant == RICK_VARIANT then
        local sprite = effect:GetSprite()
        sprite.Rotation = 0
        sprite.FlipX = false
        sprite.FlipY = false
    end
end)

-- ============================================================
-- COMANDOS PARA TESTE RÁPIDO
-- No console do Isaac, use: lua DD.portais()
-- ============================================================
DD = {}

function DD.portais()
    local room = game:GetRoom()
    local center = room:GetCenterPos()
    spawnPortals(center)
end

function DD.rick()
    local player = Isaac.GetPlayer(0)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, RICK_VARIANT, 0, player.Position, Vector.Zero, nil)
    log("Rick spawnado.")
end

function DD.gun()
    local player = Isaac.GetPlayer(0)
    local portalGunId = Isaac.GetItemIdByName("Portal Gun")
    if portalGunId and portalGunId > 0 then
        player:AddCollectible(portalGunId)
        log("Portal Gun adicionada!")
    else
        log("ERRO: Portal Gun não encontrada!")
    end
end

function DD.goto1()
    if StageAPI and StageAPI.Loaded and AdventureDimension then
        StageAPI.GotoCustomStage(AdventureDimension, false)
        log("Indo para AdventureDimension")
    else
        log("ERRO: AdventureDimension não configurada")
    end
end

function DD.goto2()
    if StageAPI and StageAPI.Loaded and DemonDimension then
        StageAPI.GotoCustomStage(DemonDimension, false)
        log("Indo para DemonDimension")
    else
        log("ERRO: DemonDimension não configurada")
    end
end

-- ============================================================
-- SPAWN DAS PORTAS APOS O BOSS
-- ============================================================
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
    local room = game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        local portalGunId = Isaac.GetItemIdByName("Portal Gun")
        local hasGun = false
        if portalGunId > 0 then
            for i = 0, game:GetNumPlayers() - 1 do
                if game:GetPlayer(i):HasCollectible(portalGunId) then
                    hasGun = true
                    break
                end
            end
        end

        if hasGun then
            local center = room:GetCenterPos()
            spawnPortals(center)
            log("Portais spawnados apos o Boss!")
        end
    end
end)
