-- LocalScript (StarterPlayerScripts)
-- This script creates a small UI, validates input locally, searches the workspace for a pet model
-- (by name or PetName value), and sends a secure request to the server using ReplicatedStorage.RequestAddPet.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RequestAddPet")

-- ---------- UI BUILD (so it's "one script" on client) ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetSpawnerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 120)
frame.Position = UDim2.new(0.5, -160, 0.1, 0)
frame.BackgroundTransparency = 0.15
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Pet Spawner (Dev Only)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 28)
input.Position = UDim2.new(0, 10, 0, 38)
input.PlaceholderText = "Enter exact pet name (e.g., Dog)"
input.ClearTextOnFocus = false
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.TextColor3 = Color3.fromRGB(0,0,0)
input.BackgroundColor3 = Color3.fromRGB(240,240,240)
input.Parent = frame

local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(0.5, -15, 0, 28)
spawnButton.Position = UDim2.new(0, 10, 0, 72)
spawnButton.Text = "Request Spawn"
spawnButton.Font = Enum.Font.SourceSansBold
spawnButton.TextSize = 16
spawnButton.BackgroundColor3 = Color3.fromRGB(50,170,50)
spawnButton.TextColor3 = Color3.fromRGB(255,255,255)
spawnButton.Parent = frame

local feedback = Instance.new("TextLabel")
feedback.Size = UDim2.new(0.5, -15, 0, 28)
feedback.Position = UDim2.new(0.5, 5, 0, 72)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.Font = Enum.Font.SourceSansItalic
feedback.TextSize = 14
feedback.TextColor3 = Color3.fromRGB(255,255,255)
feedback.TextXAlignment = Enum.TextXAlignment.Left
feedback.Parent = frame

-- ---------- HELPER: Search world for a pet model by exact name or by PetName value ----------
local function findPetInWorkspace(petName)
	if not petName or petName == "" then return nil end
	petName = tostring(petName)

	-- Search all descendants under workspace for Models whose Name matches OR have a child StringValue named "PetName".
	for _, obj in ipairs(workspace:GetDescendants()) do
		-- quick filters to reduce scanning overhead
		if obj:IsA("Model") then
			-- Exact model name match
			if obj.Name == petName then
				return obj
			end
			-- Check for a child StringValue named PetName (common pattern)
			local petNameValue = obj:FindFirstChild("PetName")
			if petNameValue and petNameValue:IsA("StringValue") and petNameValue.Value == petName then
				return obj
			end
			-- Sometimes the pet is a part with Attribute or Value
			local attrName = obj:GetAttribute("PetName")
			if attrName == petName then
				return obj
			end
		-- Optionally allow searching Parts with a PetName attribute or StringValue, if your game uses them
		elseif obj:IsA("BasePart") then
			local attr = obj:GetAttribute("PetName")
			if attr == petName then
				return obj
			end
			local sv = obj:FindFirstChild("PetName")
			if sv and sv:IsA("StringValue") and sv.Value == petName then
				return obj
			end
		end
	end

	return nil
end

-- ---------- SECURE client-side validation before sending request ----------
local function isValidInput(petName)
	if type(petName) ~= "string" then return false end
	petName = petName:match("^%s*(.-)%s*$") -- trim
	if petName == "" then return false end
	-- Ban suspicious characters or extremely long inputs
	if #petName > 50 then return false end
	-- Disallow null bytes, newline, control characters
	if petName:find("[%z\n\r]") then return false end
	return true
end

-- ---------- CONNECT BUTTON ----------
spawnButton.MouseButton1Click:Connect(function()
	local petName = tostring(input.Text or ""):match("^%s*(.-)%s*$")
	if not isValidInput(petName) then
		feedback.Text = "❌ Invalid input"
		return
	end

	feedback.Text = "🔎 Searching world..."
	-- Try to find the pet instance in the world for extra client-side validation (server will revalidate)
	local petInstance = findPetInWorkspace(petName)

	if not petInstance then
		feedback.Text = "❌ Pet not found in world"
		return
	end

	-- Prepare a light payload: petName and petInstance's Instance path-ish identifier.
	-- WARNING: The client should NOT be allowed to claim arbitrary metadata. Only send what helps server re-lookup/identify.
	-- We'll send:
	--   1) petName (string)
	--   2) petInstance:GetDebugId() or petInstance:GetFullName() (server will still re-find by name & id)
	local petFullName = petInstance:GetFullName() -- for server re-check; not trusted
	local payload = {
		petName = petName,
		petFullName = petFullName,
		clientTime = os.time()
	}

	feedback.Text = "📤 Requesting server to add pet..."
	-- FireServer: server will validate and respond via RemoteEvent reply (or another remote). We'll use a callback pattern via RemoteEvent and Listen for RemoteEvent result
	remote:FireServer(payload)
end)

-- ---------- Optional: receive server feedback via a RemoteFunction/RemoteEvent result pattern ----------
-- For simplicity we assume server will fire back to the client via the same RemoteEvent with a "Result" event.
-- You can implement a dedicated RemoteEvent for replies if you prefer.
ReplicatedStorage:WaitForChild("RequestAddPet"):OnClientEvent(function(result)
	if type(result) == "table" and result.player == player then
		if result.status == "OK" then
			feedback.Text = "✅ Pet added to inventory: "..tostring(result.petName)
		else
			feedback.Text = "❌ "..tostring(result.message or "Failed to add pet")
		end
	end
end)

-- Cleanup if needed on leaving
player.AncestryChanged:Connect(function()
	if not player:IsDescendantOf(game) then
		screenGui:Destroy()
	end
end)
