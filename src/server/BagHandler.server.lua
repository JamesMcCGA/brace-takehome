-- JamesCelestial 2026 | Brace Take home
-- BagSpawner.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local assetsFolder: Folder = ReplicatedStorage:WaitForChild("Assets")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes")
local modelFolder: Folder = assetsFolder:WaitForChild("Models")
local bagFolder: Folder = modelFolder:WaitForChild("Bags")
local conveyorModel: Model = workspace:WaitForChild("Conveyor")
local bagSpawnPoint = conveyorModel:WaitForChild("BagSpawn") 

local spawnInterval = conveyorModel:SetAttribute("SpawnInterval", 1) -- default, is updated via remote event and picked up on the main loop

-- Config
local BELT_SPEED = 10

-- Creates bag model, assigns an ID using the GenerateGUID method from HttpService; set as attribute
-- Attributes are fine in this instance, could also use object properties if going object oriented
-- @return The spawned bag model.
local function spawnBag(): Model
	local bag = bagFolder:WaitForChild("Suitcase"):Clone()
    for _, part in ipairs(bag:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end

    -- give the bag an ID and set it to the workplace
	local bagId = HttpService:GenerateGUID(false)
	bag:SetAttribute("BagId", bagId)
	bag:PivotTo(bagSpawnPoint.WorldCFrame)
	bag.Parent = workspace.SpawnedBags

    -- register click detector
    bag.ClickDetector.MouseClick:Connect(function(player)
        local id = bag:GetAttribute("BagId")
        print("[Server] Bag clicked - ID:", id)
        remotesFolder.BagClicked:FireClient(player, id)
    end)

    -- set the bag to a random material & colour
	local primary = bag.PrimaryPart
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

    primary.Material = materials[math.random(#materials)]
    primary.Color = colours[math.random(#colours)]

    -- simple spawn animation
    local originalSize = primary.Size
	primary.Size = originalSize * 0.01
	local tween = TweenService:Create(
		primary,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = originalSize }
	)tween:Play()

	return bag
end

-- Moves bag model across the conveyor using linear interpolation. Decided on this over tween service because its easier for models.
-- @param The bag model to control.
-- @return The spawned bag model.
local function moveAndDeleteBag(bag: Model)
    local conveyorEnd: BasePart = conveyorModel:WaitForChild("ConveyorEnd")

    local startCF = bag:GetPivot()
    local endCF = conveyorEnd.CFrame
    local distance = (endCF.Position - startCF.Position).Magnitude
    local duration = distance / BELT_SPEED
    local startTime = os.clock()
    local conn

    conn = RunService.Heartbeat:Connect(function()
        if not bag.Parent then
            conn:Disconnect()
            return
        end

        local t = (os.clock() - startTime) / duration
        if t >= 1 then
            bag:PivotTo(endCF)
            conn:Disconnect()

            -- simple deletion animation
            for _, part in ipairs(bag:GetDescendants()) do
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
            return
        end

        local newCF = startCF:Lerp(endCF, t)
        bag:PivotTo(newCF)
    end)
end


-- Primary spawn loop
-- Reads from the interval every iteration incase it has changed
local function startSpawner()
    task.spawn(function()
        while true do
            local interval = conveyorModel:GetAttribute("SpawnInterval") or 1
            task.wait(interval)
            print("[BagHandler] Interval is: " .. interval)
            local bag = spawnBag()
            moveAndDeleteBag(bag)
        end
    end)
end


startSpawner()