-- JamesCelestial 2026 | Brace Take home
-- UIController.lua
-- Purely used for mounting the react ui

-- Services & Packages
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local App = require(script.Parent.ui.App)

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- create root and mount
local root = ReactRoblox.createRoot(Instance.new("Folder"))
root:render(ReactRoblox.createPortal(
	React.createElement(App),
	playerGui
))