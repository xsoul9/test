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
titleLabel.Text = "xSoul Pet Spawner(nigga)"
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
-- Start button
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.6, 0, 0, 25)
startButton.Position = UDim2.new(0.2, 0, 0.815, 0)
startButton.Text = "Start Spawning"
startButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
startButton.BackgroundTransparency = 0.1
startButton.Font = Enum.Font.FredokaOne
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextSize = 16
startButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = startButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
buttonStroke.Color = Color3.fromRGB(255, 255, 255)
buttonStroke.Thickness = 1.5
buttonStroke.Transparency = 0.1
buttonStroke.Parent = startButton

local textStroke = Instance.new("UIStroke")
textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
textStroke.Color = Color3.new(0, 0, 0)
textStroke.Thickness = 1.5
textStroke.Transparency = 0
textStroke.Parent = startButton

local originalProperties = {
	BackgroundColor3 = startButton.BackgroundColor3,
	BackgroundTransparency = startButton.BackgroundTransparency,
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeThickness = 1.5,
	StrokeTransparency = 0.1
}

local activeAnimation = {
	endTime = 0,
	tween = nil,
	resetTween = nil
}

startButton.MouseEnter:Connect(function()
	if activeAnimation.endTime < os.clock() then
		startButton.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
		TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
			Thickness = 2,
			Transparency = 0.05
		}):Play()
	end
end)

startButton.MouseLeave:Connect(function()
	if activeAnimation.endTime < os.clock() then
		startButton.BackgroundColor3 = originalProperties.BackgroundColor3
		TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
			Thickness = originalProperties.StrokeThickness,
			Transparency = originalProperties.StrokeTransparency
		}):Play()
	end
end)

_G.spawn_pet = nil

local buttonAnimation = {
	endTime = 0,
	strokeTween = nil,
	resetThread = nil,
	intensity = 1.0,
	lastSuccess = false
}

startButton.MouseButton1Click:Connect(function()
	local pet_name = petNameBox.Text
	local currentTime = os.clock()
	local extendDuration = 1.5
	local isExtension = currentTime < buttonAnimation.endTime

	if isExtension then
		buttonAnimation.intensity = math.min(buttonAnimation.intensity + 0.3, 1.5)
	else
		buttonAnimation.intensity = 1.0
	end

	if buttonAnimation.strokeTween then
		buttonAnimation.strokeTween:Cancel()
	end

	if buttonAnimation.resetThread then
		coroutine.close(buttonAnimation.resetThread)
	end

	local feedbackColor = Color3.fromRGB(255, 50, 50)
	local spawnSuccess = false

	if pet_name ~= "" then
		spawnSuccess = _G.spawn_pet(pet_name, activeFlags)

		if spawnSuccess then
			feedbackColor = Color3.fromRGB(0, 255 * buttonAnimation.intensity, 0)
			game.StarterGui:SetCore("SendNotification", {
				Title = "Pet Spawned!",
				Text = pet_name .. " has been spawned!",
				Duration = 5
			})
		else
			game.StarterGui:SetCore("SendNotification", {
				Title = "Error",
				Text = "Pet not found: " .. pet_name,
				Duration = 3
			})
		end
	else
		game.StarterGui:SetCore("SendNotification", {
			Title = "Error",
			Text = "Please enter a pet name!",
			Duration = 3
		})
	end

	buttonAnimation.lastSuccess = spawnSuccess

	if isExtension and buttonAnimation.lastSuccess then
		feedbackColor = Color3.fromRGB(0, 255 * buttonAnimation.intensity, 0)
	end

	buttonStroke.Color = feedbackColor
	buttonStroke.Thickness = 2 * buttonAnimation.intensity
	buttonStroke.Transparency = 0.1 / buttonAnimation.intensity

	if isExtension then
		buttonAnimation.strokeTween = TweenService:Create(
			buttonStroke,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{
				Thickness = 2.5 * buttonAnimation.intensity,
				Transparency = 0.05 / buttonAnimation.intensity
			}
		)
		buttonAnimation.strokeTween:Play()
	end

	buttonAnimation.endTime = currentTime + extendDuration
	buttonAnimation.resetThread = task.delay(extendDuration, function()
		if os.clock() >= buttonAnimation.endTime then
			TweenService:Create(buttonStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Color = originalProperties.StrokeColor,
				Thickness = originalProperties.StrokeThickness,
				Transparency = originalProperties.StrokeTransparency
			}):Play()
		end
	end)
end)

_G.spawn_pet = function(pet_name, activeFlags)
	local flags = {
		F = activeFlags.F,
		R = activeFlags.R,
		N = activeFlags.N,
		M = activeFlags.M
	}

	local player = game.Players.LocalPlayer
	local loads = require(game.ReplicatedStorage.Fsys).load
	local router_client = loads("RouterClient")
	local client_data = loads("ClientData")
	local inventory_db = loads("InventoryDB")
	local inventory = client_data.get("inventory")

	for category_name, category_table in pairs(inventory_db) do
		for id, item in pairs(category_table) do
			if category_name == "pets" and item.name == pet_name then
				local fake_uuid = game.HttpService:GenerateGUID()
				local new_item = table.clone(item)

				new_item["unique"] = fake_uuid
				new_item["category"] = "pets"

				local random_age = math.random(1, 900000)
				new_item["properties"] = generate_prop(random_age, flags)
				new_item["newness_order"] = math.random(1, 900000)

				inventory[category_name][fake_uuid] = new_item

				print("Pet spawned: " .. pet_name .. " with age: " .. random_age)
				return true
			end
		end
	end

	warn("Pet not found: " .. pet_name)
	return false
end

-- Info Box setup
local infoBox = Instance.new("Frame")
infoBox.Name = "InfoBox"
infoBox.Size = UDim2.new(0.85, 0, 0, 30)
infoBox.Position = UDim2.new(0.075, 0, 0.6, 0)
infoBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoBox.BackgroundTransparency = 0.5
infoBox.BorderSizePixel = 0
infoBox.Parent = mainFrame

local infoBoxCorner = Instance.new("UICorner")
infoBoxCorner.CornerRadius = UDim.new(0, 8)
infoBoxCorner.Parent = infoBox

local infoBoxStroke = Instance.new("UIStroke")
infoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
infoBoxStroke.Thickness = 1.2
infoBoxStroke.Transparency = 0.7
infoBoxStroke.Parent = infoBox

local infoTextContainer = Instance.new("Frame")
infoTextContainer.Name = "TextContainer"
infoTextContainer.Size = UDim2.new(1, 0, 1, 0)
infoTextContainer.BackgroundTransparency = 1
infoTextContainer.Parent = infoBox

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = infoTextContainer

-- Info labels (F, R, N, M)
local labelData = {
	{ Name = "F", Text = "F", Color = Color3.fromRGB(170, 0, 255), HoverColor = Color3.fromRGB(200, 50, 255) },
	{ Name = "R", Text = "R", Color = Color3.fromRGB(0, 255, 100), HoverColor = Color3.fromRGB(0, 255, 150) },
	{ Name = "N", Text = "N", Color = Color3.fromRGB(0, 200, 255), HoverColor = Color3.fromRGB(0, 255, 255) },
	{ Name = "M", Text = "M", Color = Color3.fromRGB(255, 50, 150), HoverColor = Color3.fromRGB(255, 100, 200) }
}

for _, data in ipairs(labelData) do
	local label = Instance.new("TextLabel")
	label.Name = data.Name
	label.Size = UDim2.new(0, 40, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = data.Text
	label.TextColor3 = data.Color
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 18
	label.Parent = infoTextContainer

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.Thickness = 1.2
	uiStroke.Transparency = 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = label

	label.MouseEnter:Connect(function()
		TweenService:Create(
			label,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextColor3 = data.HoverColor }
		):Play()
	end)

	label.MouseLeave:Connect(function()
		TweenService:Create(
			label,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextColor3 = data.Color }
		):Play()
	end)

	label.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeFlags[data.Name] = not activeFlags[data.Name]

			local targetColor = activeFlags[data.Name]
				and data.HoverColor
				or data.Color

			TweenService:Create(
				label,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextColor3 = targetColor }
			):Play()
		end
	end)
end

-- Spawn All High Tiers button
local allButton = Instance.new("TextButton")
allButton.Size = UDim2.new(0.6, 0, 0, 25)
allButton.Position = UDim2.new(0.2, 0, 0.9, 0)
allButton.Text = "Spawn All High Tiers"
allButton.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
allButton.BackgroundTransparency = 0.1
allButton.Font = Enum.Font.FredokaOne
allButton.TextColor3 = Color3.fromRGB(255, 255, 255)
allButton.TextSize = 15
allButton.Parent = mainFrame

local allCorner = Instance.new("UICorner")
allCorner.CornerRadius = UDim.new(0, 8)
allCorner.Parent = allButton

local allStroke = Instance.new("UIStroke")
allStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
allStroke.Color = Color3.fromRGB(255, 255, 255)
allStroke.Thickness = 1.5
allStroke.Transparency = 0.1
allStroke.Parent = allButton

local allTextStroke = Instance.new("UIStroke")
allTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
allTextStroke.Color = Color3.new(0, 0, 0)
allTextStroke.Thickness = 1.5
allTextStroke.Transparency = 0
allTextStroke.Parent = allButton

local function animateButton(button, stroke, color)
	local tweenIn = TweenService:Create(
		stroke,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Color = color, Thickness = 2.2 }
	)
	local tweenOut = TweenService:Create(
		stroke,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5 }
	)
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		tweenOut:Play()
	end)
end

allButton.MouseButton1Click:Connect(function()
	local flags = { F = true, R = true, N = true, M = true }

	local loads = require(game.ReplicatedStorage.Fsys).load
	local client_data = loads("ClientData")
	local inventory_db = loads("InventoryDB")
	local inventory = client_data.get("inventory")

	for category_name, category_table in pairs(inventory_db) do
		for _, item in pairs(category_table) do
			if category_name == "pets" then
				local fake_uuid = game.HttpService:GenerateGUID()
				local new_item = table.clone(item)

				new_item["unique"] = fake_uuid
				new_item["category"] = "pets"

				local random_age = math.random(1, 900000)
				new_item["properties"] = generate_prop(random_age, flags)
				new_item["newness_order"] = math.random(1, 900000)

				inventory[category_name][fake_uuid] = new_item
			end
		end
	end

	game.StarterGui:SetCore("SendNotification", {
		Title = "Spawned!",
		Text = "All high-tier pets have been spawned.",
		Duration = 6
	})

	animateButton(allButton, allStroke, Color3.fromRGB(0, 255, 100))
end)
-- Make mainFrame draggable
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		updateDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Smooth return animation when released (optional)
UserInputService.InputChanged:Connect(function(input)
	if not dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		TweenService:Create(
			mainFrame,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = mainFrame.Position }
		):Play()
	end
end)

-- Final startup print
print("[✅] Skai Pet Spawner loaded successfully!")

