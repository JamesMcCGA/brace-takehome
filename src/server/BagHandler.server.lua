-- JamesCelestial 2026 | Brace Take home
-- BagSpawner.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


-- Variables
local assetsFolder: Folder = ReplicatedStorage:WaitForChild("Assets")
local modelFolder: Folder = assetsFolder:WaitForChild("Models")
local bagFolder: Folder = modelFolder:WaitForChild("Bags")
local conveyorModel: Model = workspace:WaitForChild("Conveyor")
local bagSpawnPoint = conveyorModel:WaitForChild("BagSpawn") 
local bagTemplates: {Model} = {}

local spawnInterval = conveyorModel:SetAttribute("SpawnInterval", 1) -- hard-coding this for now. will be read from the UI. 

-- Config
local BELT_SPEED = 10

-- Verifies the necessary existence of bag models and adds to bagTemplates table for easy access
local function verifyAndStoreBagModels()
    for _, child in ipairs(bagFolder:GetChildren()) do
        if child:IsA("Model") then
            table.insert(bagTemplates, child)
        end
    end
    
    if #bagTemplates < 1 then
        error("No bag models found")
    end
end

-- Creates bag model, assigns an ID using the GenerateGUID method from HttpService; set as attribute
-- Attributes are fine in this instance, could also use object properties if going object oriented
-- @return The spawned bag model.
local function spawnBag(): Model
	local chosenBag = bagTemplates[math.random(#bagTemplates)]
	local bag = chosenBag:Clone()
    for _, part in ipairs(bag:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end

	local bagId = HttpService:GenerateGUID(false)
	bag:SetAttribute("BagId", bagId)
	bag:PivotTo(bagSpawnPoint.WorldCFrame)
	bag.Parent = workspace.SpawnedBags
	local primary = bag.PrimaryPart
	local originalSize = primary.Size
	primary.Size = originalSize * 0.01

    -- simple spawn animation
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
            local bag = spawnBag()
            moveAndDeleteBag(bag)
        end
    end)
end


verifyAndStoreBagModels()
startSpawner()
