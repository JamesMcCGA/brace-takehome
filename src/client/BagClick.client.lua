-- JamesCelestial 2026 | Brace Take home
-- BagClick.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local assetsFolder: Folder = ReplicatedStorage:WaitForChild("Assets")
local remotesFolder: Folder = ReplicatedStorage:WaitForChild("Remotes")

-- Handle click and print info
remotesFolder.BagClicked.OnClientEvent:Connect(function(bagId)
    print("[Client] Bag clicked - ID:", bagId)
end)