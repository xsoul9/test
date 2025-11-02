local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
local UIManager = Fsys.load("UIManager")

local data
local _overwrite_local_trade_state = UIManager.apps.TradeApp._overwrite_local_trade_state

UIManager.apps.TradeApp._overwrite_local_trade_state = function(self, trade, ...)
	if trade then
		local offer = trade.sender == Players.LocalPlayer and trade.sender_offer
			or trade.recipient == Players.LocalPlayer and trade.recipient_offer

		if offer then
			if data then
				offer.items = data
			end
		end
	else
		data = nil
	end

	return _overwrite_local_trade_state(self, trade, ...)
end

local _change_local_trade_state = UIManager.apps.TradeApp._change_local_trade_state

UIManager.apps.TradeApp._change_local_trade_state = function(self, change, ...)
	local trade = UIManager.apps.TradeApp.local_trade_state

	if trade then
		local team = trade.sender == Players.LocalPlayer and "sender_offer"
			or trade.recipient == Players.LocalPlayer and "recipient_offer"

		if team then
			local offer = change[team]
			if offer and offer.items then
				data = offer.items
			end
		end
	end

	return _change_local_trade_state(self, change, ...)
end

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local activeFlags = { F = false, R = false, N = false, M = false }

local baseColors = {
	Color3.fromRGB(170, 0, 255),
	Color3.fromRGB(0, 255, 100),
	Color3.fromRGB(0, 200, 255),
	Color3.fromRGB(255, 50, 150)
}

local function generate_prop(i, flags)
	return {
		["flyable"] = flags.F,
		["rideable"] = flags.R,
		["neon"] = flags.N,
		["mega_neon"] = flags.M,
		["age"] = i
	}
end

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkaiAdmSpawner"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 210)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(170, 0, 255)
uiStroke.Thickness = 3
uiStroke.Transparency = 0
uiStroke.Parent = mainFrame

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(0, 310, 0, 220)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BackgroundTransparency = 0
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 0
blackFrame.Parent = screenGui

local blackCorner = Instance.new("UICorner")
blackCorner.CornerRadius = UDim.new(0, 15.5)
blackCorner.Parent = blackFrame

mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
	blackFrame.Position = UDim2.new(
		mainFrame.Position.X.Scale,
		mainFrame.Position.X.Offset - 5,
		mainFrame.Position.Y.Scale,
		mainFrame.Position.Y.Offset - 5
	)
end)

blackFrame.Position = UDim2.new(
	mainFrame.Position.X.Scale,
	mainFrame.Position.X.Offset - 5,
	mainFrame.Position.Y.Scale,
	mainFrame.Position.Y.Offset - 5
)
local colorPalette = {
	Color3.fromRGB(170, 0, 255),
	Color3.fromRGB(120, 0, 255),
	Color3.fromRGB(0, 100, 255),
	Color3.fromRGB(0, 200, 255),
	Color3.fromRGB(0, 255, 150),
	Color3.fromRGB(0, 255, 100),
	Color3.fromRGB(255, 100, 0),
	Color3.fromRGB(255, 50, 150)
}

local TRANSITION_TIME = 4
local currentIndex = 1

local function animateToNextColor()
	local nextIndex = currentIndex % #colorPalette + 1

	TweenService:Create(
		uiStroke,
		TweenInfo.new(TRANSITION_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ Color = colorPalette[nextIndex] }
	):Play()

	currentIndex = nextIndex
	wait(TRANSITION_TIME)
	animateToNextColor()
end

coroutine.wrap(animateToNextColor)()

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Skai Pet Spawner"
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
titleLabel.Parent = mainFrame

-- Textbox for pet name input
local petNameBox = Instance.new("TextBox")
petNameBox.Size = UDim2.new(0.85, 0, 0, 28)
petNameBox.Position = UDim2.new(0.075, 0, 0.18, 0)
petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
petNameBox.BackgroundTransparency = 0.2
petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.TextSize = 14
petNameBox.Font = Enum.Font.FredokaOne
petNameBox.PlaceholderText = "Enter Pet Name to Spawn"
petNameBox.Text = ""
petNameBox.ClearTextOnFocus = false
petNameBox.Parent = mainFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = petNameBox

local textStroke = Instance.new("UIStroke")
textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
textStroke.Color = Color3.new(0, 0, 0)
textStroke.Thickness = 1.2
textStroke.Transparency = 0
textStroke.Parent = petNameBox

local boxGlow = Instance.new("UIStroke")
boxGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
boxGlow.Color = Color3.fromRGB(255, 255, 255)
boxGlow.Thickness = 2.2
boxGlow.Transparency = 0.25
boxGlow.Parent = petNameBox

-- Load valid pet names from InventoryDB
local validPetNames = {}
local validPetNamesClean = {}

local function loadPetNames()
	local inventory_db = require(game.ReplicatedStorage.Fsys).load("InventoryDB")

	for category_name, category_table in pairs(inventory_db) do
		if category_name == "pets" then
			for _, item in pairs(category_table) do
				table.insert(validPetNames, item.name)
				table.insert(validPetNamesClean, item.name:lower():gsub("%s+", ""))
			end
			break
		end
	end
end

loadPetNames()

local COLORS = {
	NEUTRAL = Color3.fromRGB(220, 220, 255),
	VALID = Color3.fromRGB(120, 255, 150),
	INVALID = Color3.fromRGB(255, 120, 120)
}

local currentColorTween = nil

local function capitalizeWords(str)
	local result = ""
	local i = 1
	local n = #str

	while i <= n do
		if str:sub(i, i):match("%S") then
			local wordStart = i
			while i <= n and str:sub(i, i):match("%S") do
				i += 1
			end

			local word = str:sub(wordStart, i - 1)
			if #word > 0 then
				word = word:sub(1, 1):upper() .. word:sub(2):lower()
			end

			result ..= word
		else
			result ..= str:sub(i, i)
			i += 1
		end
	end

	return result
end

local lastCursorPosition = 1

local function setGlowColor(targetColor)
	if currentColorTween then
		currentColorTween:Cancel()
	end

	currentColorTween = TweenService:Create(
		boxGlow,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Color = targetColor }
	)

	currentColorTween:Play()
end

petNameBox:GetPropertyChangedSignal("Text"):Connect(function()
	lastCursorPosition = petNameBox.CursorPosition
	local inputText = petNameBox.Text
	local newText = capitalizeWords(inputText)

	if newText ~= inputText then
		petNameBox.Text = newText
		local addedChars = #newText - #inputText
		petNameBox.CursorPosition = math.max(1, math.min(lastCursorPosition + addedChars, #newText + 1))
		return
	end

	local displayedText = petNameBox.Text
	local cleanName = displayedText:lower():gsub("%s+", "")
	local isExactMatch = false
	local isCleanMatch = false

	for _, name in ipairs(validPetNames) do
		if name:lower() == displayedText:lower() then
			isExactMatch = true
			break
		end
	end

	isCleanMatch = table.find(validPetNamesClean, cleanName) ~= nil

	local targetColor

	if displayedText == "" then
		targetColor = COLORS.NEUTRAL
	elseif isExactMatch or isCleanMatch then
		targetColor = COLORS.VALID
	else
		targetColor = COLORS.INVALID
	end

	setGlowColor(targetColor)
end)

setGlowColor(COLORS.NEUTRAL)
