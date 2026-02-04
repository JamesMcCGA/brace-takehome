-- JamesCelestial 2026 | Brace Take home
-- ControllerManager.lua

-- Services 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local conveyorModel: Model = workspace:WaitForChild("Conveyor")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DesignateController = Remotes:WaitForChild("DesignateController")
local SetSpawnRate = Remotes:WaitForChild("SetSpawnRate")

local currentController: Player? = nil

local function assignController(player: Player)
    if currentController then
        DesignateController:FireClient(currentController, false)
    end
    
    currentController = player
    print("[ControllerManager] Firing to:", player.Name, "UserId:", player.UserId, "Parent:", player.Parent)
    DesignateController:FireClient(player, true)
    print("[ControllerManager] Assigned controller:", player.Name)
end

local function pickNewController()
	local players = Players:GetPlayers()
	
    -- guard against no players (idk if this is necessary)
	if #players == 0 then
		currentController = nil
		return
	end
	
	local randomPlayer = players[math.random(1, #players)]
	assignController(randomPlayer)
end

-- by default, first player to join becomes controller
Players.PlayerAdded:Connect(function(player)
	if currentController == nil then
		assignController(player)
	end
end)

-- if controller leaves, pick a new one
Players.PlayerRemoving:Connect(function(player)
	if player == currentController then
		currentController = nil
		task.defer(pickNewController)
	end
end)

-- handle players already in game
if #Players:GetPlayers() > 0 and currentController == nil then
	assignController(Players:GetPlayers()[1])
end

-- handle changes requested by the controller
SetSpawnRate.OnServerEvent:Connect(function(player, rate)
    -- some security to only allow current controller to edit
    if player ~= currentController then
        return
    end

    conveyorModel:SetAttribute("SpawnInterval", rate)
end)