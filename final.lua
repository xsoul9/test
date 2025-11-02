local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
local UIManager = Fsys.load("UIManager")
local data

local _overwrite_local_trade_state = UIManager.apps.TradeApp._overwrite_local_trade_state
UIManager.apps.TradeApp._overwrite_local_trade_state = function(self, trade, ...)
	if trade then
		local offer = trade.sender == Players.LocalPlayer and trade.sender_offer or trade.recipient == Players.LocalPlayer and trade.recipient_offer
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
		local team = trade.sender == Players.LocalPlayer and "sender_offer" or trade.recipient == Players.LocalPlayer and "recipient_offer"
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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local activeFlags = {F = false, R = false, N = false, M = false}
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
	TweenService:Create(uiStroke, TweenInfo.new(
		TRANSITION_TIME,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
		), {
			Color = colorPalette[nextIndex]
		}):Play()
	currentIndex = nextIndex
	wait(TRANSITION_TIME)
	animateToNextColor()
end
coroutine.wrap(animateToNextColor)()

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Skai Pet Spawner"
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
titleLabel.Parent = mainFrame
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

local validPetNames = {}
local validPetNamesClean = {}

local function loadPetNames()
	local inventory_db = require(game.ReplicatedStorage.Fsys).load("InventoryDB")
	for category_name, category_table in pairs(inventory_db) do
		if category_name == "pets" then
			for id, item in pairs(category_table) do
				validPetNames[#validPetNames + 1] = item.name
				validPetNamesClean[#validPetNamesClean + 1] = item.name:lower():gsub("%s+", "")
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
				i = i + 1
			end
			local word = str:sub(wordStart, i-1)
			if #word > 0 then
				word = word:sub(1,1):upper()..word:sub(2):lower()
			end
			result = result..word
		else
			result = result..str:sub(i, i)
			i = i + 1
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
		{Color = targetColor}
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
	elseif isExactMatch then
		targetColor = COLORS.VALID
	elseif isCleanMatch then
		targetColor = COLORS.VALID
	else
		targetColor = COLORS.INVALID
	end
	setGlowColor(targetColor)
end)
setGlowColor(COLORS.NEUTRAL)
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
		extendDuration = 1.5
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
				Text = "Pet not found: "..pet_name,
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
		buttonAnimation.strokeTween = TweenService:Create(buttonStroke,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Thickness = 2.5 * buttonAnimation.intensity,
				Transparency = 0.05 / buttonAnimation.intensity
			})
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
	local flags = {F = activeFlags.F, R = activeFlags.R, N = activeFlags.N, M = activeFlags.M}
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

local flagColors = {
	M = Color3.fromRGB(170, 0, 255),
	N = Color3.fromRGB(0, 255, 100),
	F = Color3.fromRGB(0, 200, 255),
	R = Color3.fromRGB(255, 50, 150)
}

local animationSystem = {
	pulsePhase = 0,
	pulseSpeed = 2,
	baseThickness = 1.2,
	maxThickness = 3,
	activeColors = nil,
	active = false
}

local function updateAnimation(dt)
	if not animationSystem.active then return end
	animationSystem.pulsePhase = animationSystem.pulsePhase + dt * animationSystem.pulseSpeed
	local pulse = (math.sin(animationSystem.pulsePhase) + 1) * 0.5
	local thickness = animationSystem.baseThickness + (animationSystem.maxThickness - animationSystem.baseThickness) * pulse
	infoBoxStroke.Thickness = thickness
	infoBoxStroke.Transparency = 0.7 - (0.5 * pulse)
	if animationSystem.activeColors then
		local brightness = 0.8 + (0.4 * pulse)
		local r, g, b = 0, 0, 0
		for _, color in ipairs(animationSystem.activeColors) do
			r = r + (color.R * brightness)
			g = g + (color.G * brightness)
			b = b + (color.B * brightness)
		end
		local mixedColor = Color3.new(
			math.min(r / #animationSystem.activeColors, 1),
			math.min(g / #animationSystem.activeColors, 1),
			math.min(b / #animationSystem.activeColors, 1)
		)
		infoBoxStroke.Color = mixedColor
	end
end

local function createTextLabel(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 16
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	if text == "Mega Neon" then
		label.Text = "Mega Neon"
	elseif text ~= "Ride" and text ~= "Neon" and text ~= "Fly" then
		label.Text = label.Text .. " "
	end
	return label
end

local function updateInfoBox(activeFlags)
	for _, child in ipairs(infoTextContainer:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	local activeColors = {}
	local hasFlags = false
	local labels = {}
	if activeFlags["M"] then
		table.insert(labels, {"Mega Neon", flagColors.M})
		table.insert(activeColors, flagColors.M)
		hasFlags = true
	end
	if activeFlags["N"] then
		table.insert(labels, {"Neon", flagColors.N})
		table.insert(activeColors, flagColors.N)
		hasFlags = true
	end
	if activeFlags["F"] then
		table.insert(labels, {"Fly", flagColors.F})
		table.insert(activeColors, flagColors.F)
		hasFlags = true
	end
	if activeFlags["R"] then
		table.insert(labels, {"Ride", flagColors.R})
		table.insert(activeColors, flagColors.R)
		hasFlags = true
	end
	for i, labelData in ipairs(labels) do
		local label = createTextLabel(labelData[1], labelData[2])
		label.Parent = infoTextContainer
	end
	if hasFlags then
		animationSystem.active = true
		animationSystem.activeColors = activeColors
	else
		animationSystem.active = false
		createTextLabel("Normal", Color3.fromRGB(255, 255, 255)).Parent = infoTextContainer
		infoBoxStroke.Color = Color3.fromRGB(255, 255, 255)
		infoBoxStroke.Thickness = animationSystem.baseThickness
		infoBoxStroke.Transparency = 0.7
	end
end

RunService.Heartbeat:Connect(updateAnimation)
updateInfoBox({F = false, R = false, N = false, M = false})

local prefixes = {"F", "R", "N", "M"}
local totalButtons = #prefixes
local buttonWidth = 0.18
local spaceBetweenButtons = 0.07
local totalWidth = totalButtons * buttonWidth + (totalButtons - 1) * spaceBetweenButtons
local startingX = (1 - totalWidth) / 2

for i, prefix in ipairs(prefixes) do
	local prefixButton = Instance.new("TextButton")
	prefixButton.Size = UDim2.new(buttonWidth, 0, 0, 25)
	prefixButton.Position = UDim2.new(startingX + (buttonWidth + spaceBetweenButtons) * (i - 1), 0, 0.4, 0)
	prefixButton.Text = prefix
	prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	prefixButton.BackgroundTransparency = 0.2
	prefixButton.Font = Enum.Font.FredokaOne
	prefixButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	prefixButton.TextSize = 16
	prefixButton.Parent = mainFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = prefixButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	buttonStroke.Color = flagColors[prefix]
	buttonStroke.Thickness = 2
	buttonStroke.Transparency = 0.5
	buttonStroke.Parent = prefixButton

	local textStroke = Instance.new("UIStroke")
	textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	textStroke.Color = Color3.new(0, 0, 0)
	textStroke.Thickness = 1.5
	textStroke.Transparency = 0
	textStroke.Parent = prefixButton

	local originalStroke = {
		Color = flagColors[prefix],
		Thickness = 2,
		Transparency = 0.5
	}

	prefixButton.MouseButton1Click:Connect(function()
		if prefix == "M" and activeFlags["N"] then return end
		if prefix == "N" and activeFlags["M"] then return end
		activeFlags[prefix] = not activeFlags[prefix]
		if activeFlags[prefix] then
			prefixButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Color = Color3.fromRGB(0, 255, 0),
				Thickness = 3,
				Transparency = 0.2
			}):Play()
		else
			prefixButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Color = originalStroke.Color,
				Thickness = originalStroke.Thickness,
				Transparency = originalStroke.Transparency
			}):Play()
		end
		updateInfoBox(activeFlags)
	end)
end

local spawnAllButton = Instance.new("TextButton")
spawnAllButton.Size = UDim2.new(0.6, 0, 0, 25)
spawnAllButton.Position = UDim2.new(0.2, 0, 0.9, 0)
spawnAllButton.Text = "Spawn All High Tiers"
spawnAllButton.BackgroundColor3 = Color3.fromRGB(200, 0, 100)
spawnAllButton.BackgroundTransparency = 0.1
spawnAllButton.Font = Enum.Font.FredokaOne
spawnAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnAllButton.TextSize = 14
spawnAllButton.Parent = mainFrame

local allButtonCorner = Instance.new("UICorner")
allButtonCorner.CornerRadius = UDim.new(0, 8)
allButtonCorner.Parent = spawnAllButton

local allButtonStroke = Instance.new("UIStroke")
allButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
allButtonStroke.Color = Color3.fromRGB(255, 255, 255)
allButtonStroke.Thickness = 1.5
allButtonStroke.Transparency = 0.1
allButtonStroke.Parent = spawnAllButton

local allTextStroke = Instance.new("UIStroke")
allTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
allTextStroke.Color = Color3.new(0, 0, 0)
allTextStroke.Thickness = 1.5
allTextStroke.Transparency = 0
allTextStroke.Parent = spawnAllButton

local allOriginalProperties = {
	BackgroundColor3 = spawnAllButton.BackgroundColor3,
	BackgroundTransparency = spawnAllButton.BackgroundTransparency,
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeThickness = 1.5,
	StrokeTransparency = 0.1
}

local allActiveAnimation = {
	endTime = 0,
	strokeTween = nil,
	resetThread = nil,
	intensity = 1.0
}

spawnAllButton.MouseEnter:Connect(function()
	if allActiveAnimation.endTime < os.clock() then
		spawnAllButton.BackgroundColor3 = Color3.fromRGB(230, 0, 130)
		TweenService:Create(allButtonStroke, TweenInfo.new(0.2), {
			Thickness = 2,
			Transparency = 0.05
		}):Play()
	end
end)

spawnAllButton.MouseLeave:Connect(function()
	if allActiveAnimation.endTime < os.clock() then
		spawnAllButton.BackgroundColor3 = allOriginalProperties.BackgroundColor3
		TweenService:Create(allButtonStroke, TweenInfo.new(0.2), {
			Thickness = allOriginalProperties.StrokeThickness,
			Transparency = allOriginalProperties.StrokeTransparency
		}):Play()
	end
end)

local highTierPets = {
	"Shadow Dragon", "Bat Dragon", "Frost Dragon", "Giraffe", "Owl",
	"Parrot", "Crow", "Evil Unicorn", "Arctic Reindeer", "Hedgehog",
	"Dalmatian", "Turtle", "Kangaroo", "Lion", "Elephant", "Rhino",
	"Chocolate Chip Bat Dragon", "Cow", "Blazing Lion", "African Wild Dog",
	"Flamingo", "Diamond Butterfly", "Mini Pig", "Caterpillar",
	"Albino Monkey", "Candyfloss Chick", "Pelican", "Blue Dog",
	"Pink Cat", "Haetae", "Peppermint Penguin", "Winged Tiger",
	"Sugar Glider", "Shark Puppy", "Goat", "Sheeeeep", "Lion Cub",
	"Nessie", "Flamingo", "Frostbite Bear", "Balloon Unicorn",
	"Honey Badger", "Hot Doggo", "Crocodile", "Hare", "Ram", "Yeti",
	"Meetkat", "Jellyfish", "Happy Clown", "Orchid Butterfly",
	"Many Mackerel", "Strawberry Shortcake Bat Dragon", "Zombie Buffalo",
	"Fairy Bat Dragon"
}

spawnAllButton.MouseButton1Click:Connect(function()
	local currentTime = os.clock()
	local extendDuration = 3.0
	local isExtension = currentTime < allActiveAnimation.endTime
	if isExtension then
		allActiveAnimation.intensity = math.min(allActiveAnimation.intensity + 0.3, 1.5)
		extendDuration = 3.0
	else
		allActiveAnimation.intensity = 1.0
	end
	if allActiveAnimation.strokeTween then
		allActiveAnimation.strokeTween:Cancel()
	end
	if allActiveAnimation.resetThread then
		coroutine.close(allActiveAnimation.resetThread)
	end
	local successCount = 0
	for _, petName in ipairs(highTierPets) do
		if _G.spawn_pet(petName, activeFlags) then
			successCount = successCount + 1
			wait(0.1)
		end
	end
	local feedbackColor
	if successCount > 0 then
		feedbackColor = Color3.fromRGB(0, 255 * allActiveAnimation.intensity, 0)
		game.StarterGui:SetCore("SendNotification", {
			Title = "Spawn Complete!",
			Text = "Spawned " .. successCount .. " high tier pets!",
			Duration = 5
		})
	else
		feedbackColor = Color3.fromRGB(255, 50, 50)
		game.StarterGui:SetCore("SendNotification", {
			Title = "Error",
			Text = "No pets were spawned!",
			Duration = 3
		})
	end
	allButtonStroke.Color = feedbackColor
	allButtonStroke.Thickness = 2 * allActiveAnimation.intensity
	allButtonStroke.Transparency = 0.1 / allActiveAnimation.intensity
	if isExtension then
		allActiveAnimation.strokeTween = TweenService:Create(allButtonStroke,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Thickness = 2.5 * allActiveAnimation.intensity,
				Transparency = 0.05 / allActiveAnimation.intensity
			})
		allActiveAnimation.strokeTween:Play()
	end
	allActiveAnimation.endTime = currentTime + extendDuration
	allActiveAnimation.resetThread = task.delay(extendDuration, function()
		if os.clock() >= allActiveAnimation.endTime then
			TweenService:Create(allButtonStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Color = allOriginalProperties.StrokeColor,
				Thickness = allOriginalProperties.StrokeThickness,
				Transparency = allOriginalProperties.StrokeTransparency
			}):Play()
		end
	end)
end)
local function loadInMainFrame()
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local sizeGoal = {Size = UDim2.new(0, 300, 0, 210)}
	local transparencyGoal = {BackgroundTransparency = 0}
	local sizeTween = TweenService:Create(mainFrame, tweenInfo, sizeGoal)
	local transparencyTween = TweenService:Create(mainFrame, tweenInfo, transparencyGoal)
	sizeTween:Play()
	transparencyTween:Play()
end

loadInMainFrame()

local dragging, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
