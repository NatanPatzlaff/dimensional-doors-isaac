local mod = RegisterMod("DimensionalDoors", 1)
local game = Game()

local function log(msg)
    print("[DD] " .. msg)
end

-- ============================================================
-- Configuração do Rick
-- ============================================================
local RICK_VARIANT = 6660
local TOUCH_DISTANCE = 40

local function getRickSprite(ent)
    local data = ent:GetData()
    if not data.rickSprite then
        data.rickSprite = Sprite()
        data.rickSprite:Load("gfx/rick_beggar.anm2", true)
        data.rickSprite:Play("Idle", true)
        data.rickState = "idle"
    end
    return data.rickSprite, data
end

local function getPortalSprite(ent)
    local data = ent:GetData()
    if not data.portalSprite then
        data.portalSprite = Sprite()
        data.portalSprite:Load("gfx/grid/portal_door.anm2", true)
        data.portalSprite:Play("Idle", true)
    end
    return data.portalSprite
end

-- ============================================================
-- StageAPI: Definicao do Novo Andar
-- ============================================================
local RickDimension = nil
local PORTAL_VARIANT = 6661

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isSave)
    log("Dimensional Doors inicializado.")
    if StageAPI and StageAPI.Loaded then
        log("StageAPI carregado com sucesso!")
        if not RickDimension then
            -- Cria o andar customizado
            RickDimension = StageAPI.CustomStage("RickDimension")
            RickDimension:SetDisplayName("Rick's Dimension")
            
            -- Cria os layouts minimos para o andar nao crashar
            local roomLayout = StageAPI.Room({
                Width = 13, Height = 7,
                SpawnEntities = {}
            })
            local roomList = StageAPI.RoomList()
            roomList:AddRoom(roomLayout)
            RickDimension:SetRooms(roomList)
            
            log("Andar RickDimension registrado.")
        end
    else
        log("AVISO: StageAPI não encontrado. O andar novo não vai funcionar!")
    end
end)

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
            local players = Isaac.FindInRadius(ent.Position, TOUCH_DISTANCE, EntityPartition.PLAYER)
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

    -- Logica de entrar no Portal (para o novo andar)
    if StageAPI and StageAPI.Loaded and RickDimension then
        local portals = Isaac.FindByType(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, -1)
        for _, portal in ipairs(portals) do
            local players = Isaac.FindInRadius(portal.Position, 25, EntityPartition.PLAYER)
            if #players > 0 then
                -- Jogador tocou no portal: vai para a Rick Dimension
                StageAPI.GotoCustomStage(RickDimension, false)
                portal:Remove()
                log("Teleportando para a Rick Dimension...")
            end
        end
    end
end)

-- ============================================================
-- SPAWN DAS PORTAS APOS O BOSS
-- ============================================================
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
    local room = game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        -- Verifica se tem a portal gun
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
            -- Spawna 2 portais no meio da sala
            local center = room:GetCenterPos()
            local portal1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, 0, center + Vector(-40, 40), Vector.Zero, nil)
            local portal2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, PORTAL_VARIANT, 0, center + Vector(40, 40), Vector.Zero, nil)
            
            -- Adiciona os sprites pros portais
            portal1:GetSprite():Load("gfx/grid/portal_door.anm2", true)
            portal1:GetSprite():Play("Idle", true)
            portal1.SortingLayer = SortingLayer.SORTING_BACKGROUND -- Fica atras dos personagens
            
            portal2:GetSprite():Load("gfx/grid/portal_door.anm2", true)
            portal2:GetSprite():Play("Idle", true)
            portal2.SortingLayer = SortingLayer.SORTING_BACKGROUND
            
            log("Portais spawnados!")
        end
    end
end)

-- ============================================================
-- RENDER
-- ============================================================
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
    -- Render Rick
    local ricks = Isaac.FindByType(EntityType.ENTITY_EFFECT, RICK_VARIANT, -1)
    for _, ent in ipairs(ricks) do
        local sprite, _ = getRickSprite(ent)
        local screenPos = Isaac.WorldToScreen(ent.Position)
        sprite:Render(screenPos, Vector.Zero, Vector.Zero)
        sprite:Update()
    end
end)