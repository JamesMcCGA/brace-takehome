-- JamesCelestial 2026 | Brace Take home
-- App.lua

-- Services & Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages.React)

-- Controllers
local SpawnController = require(script.Parent.components.SpawnController)

local function App()
	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		SpawnController = React.createElement(SpawnController),
	})
end

return App