-- JamesCelestial 2026 | Brace Take home
-- BagHandler.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Variables
local assetsFolder = ReplicatedStorage:WaitForChild("Assets")
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local modelFolder = assetsFolder:WaitForChild("Models")
local bagFolder = modelFolder:WaitForChild("Bags")
local conveyorModel = workspace:WaitForChild("Conveyor")
local bagSpawnPoint = conveyorModel:WaitForChild("BagSpawn")
local conveyorEnd = conveyorModel:WaitForChild("ConveyorEnd")

local BagSpawned = remotesFolder:WaitForChild("BagSpawned")

conveyorModel:SetAttribute("SpawnInterval", 1)

-- Config
local BELT_SPEED = 10

local materials = {
    Enum.Material.Plastic,
    Enum.Material.SmoothPlastic,
    Enum.Material.Fabric,
    Enum.Material.Metal,
    Enum.Material.Wood,
    Enum.Material.Leather,
}

local colours = {
    Color3.fromRGB(30, 30, 30),
    Color3.fromRGB(90, 90, 90),
    Color3.fromRGB(140, 140, 140),
    Color3.fromRGB(80, 120, 200),
    Color3.fromRGB(180, 60, 60),
    Color3.fromRGB(60, 160, 100),
    Color3.fromRGB(200, 180, 80),
}

-- Creates bag model, assigns an ID using the GenerateGUID method from HttpService; set as attribute
-- Attributes are fine in this instance, could also use object properties if going object oriented
-- @return The spawned bag model.
local function spawnBag(): Model
    local bag = bagFolder:WaitForChild("Suitcase"):Clone()
    
    local bagId = HttpService:GenerateGUID(false)
    bag:SetAttribute("BagId", bagId)
    bag:PivotTo(bagSpawnPoint.WorldCFrame)
    bag.Parent = workspace.SpawnedBags

    -- click detector
    local clickDetector = bag:FindFirstChild("ClickDetector", true)
    if clickDetector then
        clickDetector.MouseClick:Connect(function(player)
            local id = bag:GetAttribute("BagId")
            print("[Server] Bag clicked - ID:", id)
            remotesFolder.BagClicked:FireClient(player, id)
        end)
    end

    -- randomise appearance
    local primary = bag.PrimaryPart
    primary.Material = materials[math.random(#materials)]
    primary.Color = colours[math.random(#colours)]

    -- simple spawn animation
    local originalSize = primary.Size
    primary.Size = originalSize * 0.01
    TweenService:Create(
        primary,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = originalSize }
    ):Play()

    return bag
end

-- Calculates the amount of time the bag would take to reach the end point, then signals the client to start the movement animation and deletes it when ready.
-- @param The bag model to control.
-- @return The spawned bag model.
local function handleBag(bag: Model)
    local startCF = bagSpawnPoint.WorldCFrame
    local endCF = conveyorEnd.CFrame
    local distance = (endCF.Position - startCF.Position).Magnitude
    local duration = distance / BELT_SPEED

    -- bag movement is handled on the client, after a calculated amount of time the server deletes the bag
    BagSpawned:FireAllClients(bag, startCF, endCF)
    task.wait(duration)

    -- simple deletion animation
    for _, part in bag:GetDescendants() do
        if part:IsA("BasePart") then
            TweenService:Create(
                part,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad),
                { Transparency = 1 }
            ):Play()
        end
    end

    task.wait(0.25)
    if bag.Parent then
        bag:Destroy()
    end
end

-- Primary spawn loop
-- Reads from the interval every iteration incase it has changed
local function startSpawner()
    task.spawn(function()
        while true do
            local interval = conveyorModel:GetAttribute("SpawnInterval") or 1
            task.wait(interval)
            
            local bag = spawnBag()
            task.spawn(handleBag, bag)
        end
    end)
end

startSpawner()