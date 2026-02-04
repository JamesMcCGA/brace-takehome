-- JamesCelestial 2026 | Brace Take home
-- BagMovement.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local BagSpawned = remotesFolder:WaitForChild("BagSpawned")

-- Config
local BELT_SPEED = 10

BagSpawned.OnClientEvent:Connect(function(bag, startCF, endCF)    
    task.wait()
    
    local actualStart = bag:GetPivot()  
    local distance = (endCF.Position - actualStart.Position).Magnitude
    local duration = distance / BELT_SPEED
    local startTime = os.clock()
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not bag or not bag.Parent then
            conn:Disconnect()
            return
        end
        
        local t = (os.clock() - startTime) / duration
        
        if t >= 1 then
            bag:PivotTo(endCF)
            conn:Disconnect()
            return
        end
        
        bag:PivotTo(actualStart:Lerp(endCF, t))
    end)
end)