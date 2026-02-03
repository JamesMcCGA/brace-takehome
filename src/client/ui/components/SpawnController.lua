-- JamesCelestial 2026 | Brace Take home
-- SpawnController.lua

-- Services & Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local React = require(Packages.React)

-- React states and effects
local useState = React.useState
local useEffect = React.useEffect

local function SpawnController()
	local isVisible, setIsVisible = useState(false)
	local spawnRate, setSpawnRate = useState(1)

	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local SetSpawnRate = remotes:WaitForChild("SetSpawnRate")
	local DesignateController = remotes:WaitForChild("DesignateController")

    -- listen for a controller being designated
	useEffect(function()
		local connection = DesignateController.OnClientEvent:Connect(function(isController)
			setIsVisible(isController)
		end)
		return function()
			connection:Disconnect()
		end
	end, {})

	local function updateRate(newRate: number)
		local clamped = math.clamp(newRate, 0.1, 10)
		clamped = math.round(clamped * 10) / 10
		setSpawnRate(clamped)
		SetSpawnRate:FireServer(clamped)
	end

	if not isVisible then
		return nil
	end

	return React.createElement("Frame", {
		Size = UDim2.new(0, 200, 0, 100),
		Position = UDim2.new(0, 20, 0.5, -50),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
	}, {
		Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),

		Title = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text = "Spawn Rate (seconds)",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			FontFace = Font.fromEnum(Enum.Font.GothamBold),
		}),

		Controls = React.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 40),
			Position = UDim2.new(0, 10, 0, 40),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
			}),

			Minus = React.createElement("TextButton", {
				Size = UDim2.new(0, 40, 0, 40),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Text = "-",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 24,
				FontFace = Font.fromEnum(Enum.Font.GothamBold),
				LayoutOrder = 1,
				[React.Event.Activated] = function()
					updateRate(spawnRate - 0.1)
				end,
			}, {
				Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
			}),

			Display = React.createElement("TextLabel", {
				Size = UDim2.new(0, 60, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Text = string.format("%.1f", spawnRate),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 20,
				FontFace = Font.fromEnum(Enum.Font.GothamBold),
				LayoutOrder = 2,
			}, {
				Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
			}),

			Plus = React.createElement("TextButton", {
				Size = UDim2.new(0, 40, 0, 40),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Text = "+",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 24,
				FontFace = Font.fromEnum(Enum.Font.GothamBold),
				LayoutOrder = 3,
				[React.Event.Activated] = function()
					updateRate(spawnRate + 0.1)
				end,
			}, {
				Corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 6) }),
			}),
		}),
	})
end

return SpawnController