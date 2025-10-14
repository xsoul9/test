local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetSpawnerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Parent = screenGui

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 420, 0, 60)
textBox.Position = UDim2.new(0.5, -210, 0.5, -30)
textBox.PlaceholderText = "Scrivi il nome del pet qui"
textBox.TextSize = 24
textBox.Font = Enum.Font.SourceSansBold
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
textBox.Parent = mainFrame

-- Keywords per inventario pet
local INVENTORY_KEYWORDS = {
	"PetInventory", "Pets", "PetFolder", "OwnedPets", "PlayerPets",
	"Backpack", "Inventory", "PlayerInventory", "UserPets", "UserInventory",
	"CollectedPets", "PetCollection", "MyPets", "PetStorage", "Stash",
	"Storage", "AdoptedPets", "PetBag", "PlayerBag", "Owned", "PetsOwned"
}

-- Funzione per capire se una cartella può essere inventario pet
local function seemsLikePetInventory(folder)
	if not folder:IsA("Folder") then return false end
	local children = folder:GetChildren()
	if #children < 1 then return false end

	-- Controlla se almeno un figlio ha proprietà tipiche pet
	for _, child in ipairs(children) do
		if child:FindFirstChild("PetName") or child:FindFirstChild("Rarity") or child:IsA("Model") then
			return true
		end
	end
	return false
end

-- Cerca inventario pet nel gioco
local function findPetInventory()
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Folder") then
			local nameLower = obj.Name:lower()
			for _, keyword in ipairs(INVENTORY_KEYWORDS) do
				if nameLower:find(keyword:lower()) then
					if seemsLikePetInventory(obj) then
						return obj
					end
				end
			end
		end
	end
	return nil
end

-- Cerca un pet ovunque nel gioco per nome
local function findPetByName(name)
	for _, obj in ipairs(game:GetDescendants()) do
		if obj.Name:lower() == name:lower() then
			-- Presupponiamo che il pet sia un Model o Folder
			if obj:IsA("Model") or obj:IsA("Folder") then
				return obj
			end
		end
	end
	return nil
end

-- Aggiungi pet all'inventario (solo client-side)
local function addPetToInventory(inventory, petModel)
	if not inventory or not petModel then return false end
	
	-- Clona il pet e lo mette dentro inventario
	local petClone = petModel:Clone()
	petClone.Parent = inventory
	
	-- Se serve puoi aggiungere altre proprietà qui
	return true
end

-- Quando l'utente preme Invio o cambia testo nella TextBox
textBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end -- se non ha premuto invio esci
	
	local petName = textBox.Text
	if petName == "" then
		textBox.Text = "Scrivi un nome valido!"
		return
	end
	
	local inventory = findPetInventory()
	if not inventory then
		textBox.Text = "no lol"
		return
	end
	
	local pet = findPetByName(petName)
	if not pet then
		textBox.Text = "no lol"
		return
	end
	
	local success = addPetToInventory(inventory, pet)
	if success then
		textBox.Text = "Pet aggiunto a: " .. inventory.Name
	else
		textBox.Text = "no lol"
	end
end)
