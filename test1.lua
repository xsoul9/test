-- LocalScript: Global-search client-only pet adder (for testing)
-- Cerca "dappertutto" nel gioco (tutti i discendenti visibili al client)
-- NON comunica col server; tutto resta sul client.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ------------------------
-- Config
-- ------------------------
local SEARCH_COOLDOWN = 1.0 -- secondi minimi fra ricerche per evitare lag
local MAX_NAME_LENGTH = 120

-- ------------------------
-- UI
-- ------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GlobalPetSearcherGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 130)
frame.Position = UDim2.new(0.5, -210, 0.08, 0)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.08
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Global Pet Searcher (client-only)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 34)
input.Position = UDim2.new(0, 10, 0, 42)
input.PlaceholderText = "Enter pet name (exact or partial)"
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(245,245,245)
input.TextColor3 = Color3.fromRGB(0,0,0)
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.Parent = frame

local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(0.46, -10, 0, 30)
spawnButton.Position = UDim2.new(0, 10, 0, 86)
spawnButton.Text = "Search & Add Locally"
spawnButton.Font = Enum.Font.SourceSansBold
spawnButton.TextSize = 14
spawnButton.BackgroundColor3 = Color3.fromRGB(45,140,45)
spawnButton.TextColor3 = Color3.fromRGB(255,255,255)
spawnButton.Parent = frame

local feedback = Instance.new("TextLabel")
feedback.Size = UDim2.new(0.54, -10, 0, 30)
feedback.Position = UDim2.new(0.46, 5, 0, 86)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.Font = Enum.Font.SourceSansItalic
feedback.TextSize = 14
feedback.TextColor3 = Color3.fromRGB(255,255,255)
feedback.TextXAlignment = Enum.TextXAlignment.Left
feedback.Parent = frame

-- ------------------------
-- Local inventory helper (client-only)
-- ------------------------
local function getOrCreateLocalInventory()
    local inv = player:FindFirstChild("LocalInventory")
    if inv and inv:IsA("Folder") then return inv end
    inv = Instance.new("Folder")
    inv.Name = "LocalInventory"
    inv.Parent = player
    return inv
end

-- ------------------------
-- Sanitizzazione input
-- ------------------------
local function isValidName(s)
    if type(s) ~= "string" then return false end
    s = s:match("^%s*(.-)%s*$") -- trim
    if s == "" then return false end
    if #s > MAX_NAME_LENGTH then return false end
    if s:find("[%z\n\r]") then return false end
    return true
end

-- ------------------------
-- Funzione di ricerca "globale"
-- Cerca in tutti i discendenti di `game` accessibili al client.
-- Restituisce la prima istanza candidata trovata (Model/BasePart), o nil.
-- Note: Non troverà cose in ServerStorage o server-only containers.
-- ------------------------
local function findPetEverywhere(petName, allowPartial)
    if not petName then return nil end
    petName = tostring(petName)
    local lowerQuery = petName:lower()

    -- iteriamo su tutti i discendenti della root 'game'. Questo è equivalente a cercare "dappertutto"
    local descendants = game:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        -- Filtri rapidi: tipi utili
        local isaModel = obj:IsA("Model")
        local isaBasePart = obj:IsA("BasePart")
        local isaGui = obj:IsA("GuiObject")
        local isaInstanceWithValue = obj:IsA("ValueBase") -- StringValue, ObjectValue, etc.

        -- Otteniamo possibili nomi da confrontare:
        local candNames = {}

        -- 1) Nome dell'istanza stessa
        if obj.Name then
            table.insert(candNames, obj.Name)
        end

        -- 2) Child StringValue chiamati "PetName" o "Name"
        local sv = obj:FindFirstChild("PetName")
        if sv and sv:IsA("StringValue") then table.insert(candNames, sv.Value) end
        local sv2 = obj:FindFirstChild("Name")
        if sv2 and sv2:IsA("StringValue") then table.insert(candNames, sv2.Value) end

        -- 3) Attributo "PetName" o "DisplayName"
        local attrPet = obj:GetAttribute("PetName")
        if attrPet then table.insert(candNames, tostring(attrPet)) end
        local attrDisp = obj:GetAttribute("DisplayName")
        if attrDisp then table.insert(candNames, tostring(attrDisp)) end

        -- 4) Se è una GUI, considera Text/Title properties (utile se pets sono rappresentati in GUI)
        if isaGui then
            local ok, text = pcall(function() return obj.Text end)
            if ok and type(text) == "string" then table.insert(candNames, text) end
            local ok2, text2 = pcall(function() return obj.TitleText end)
            if ok2 and type(text2) == "string" then table.insert(candNames, text2) end
        end

        -- 5) Se è un ValueBase (StringValue...), usa .Value
        if isaInstanceWithValue and obj.Value and type(obj.Value) == "string" then
            table.insert(candNames, obj.Value)
        end

        -- Controlla tutti i nomi candidati
        for _, cand in ipairs(candNames) do
            if type(cand) == "string" then
                local candLower = cand:lower()
                if allowPartial then
                    if candLower:find(lowerQuery, 1, true) then
                        return obj
                    end
                else
                    if candLower == lowerQuery then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end

-- ------------------------
-- Aggiungi entry all'inventario locale
-- ------------------------
local function addPetToLocalInventory(petName, petInstance)
    local inv = getOrCreateLocalInventory()

    -- evita duplicati
    if inv:FindFirstChild(petName) then
        return false, "Hai già questo pet in inventario locale."
    end

    -- crea struttura di esempio
    local petEntry = Instance.new("Folder")
    petEntry.Name = petName

    local rarity = Instance.new("StringValue")
    rarity.Name = "Rarity"
    rarity.Value = "Unknown"
    rarity.Parent = petEntry

    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = 1
    level.Parent = petEntry

    local pid = Instance.new("StringValue")
    pid.Name = "PetId"
    pid.Value = "LOCAL_" .. tostring(player.UserId) .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000,9999))
    pid.Parent = petEntry

    local foundAt = Instance.new("StringValue")
    foundAt.Name = "FoundIn"
    foundAt.Value = petInstance and petInstance:GetFullName() or "N/A"
    foundAt.Parent = petEntry

    petEntry.Parent = inv
    return true, "Pet aggiunto localmente."
end

-- ------------------------
-- Throttle & stato
-- ------------------------
local lastSearchTime = 0

-- ------------------------
-- Connect bottone
-- ------------------------
spawnButton.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastSearchTime < SEARCH_COOLDOWN then
        feedback.Text = "⌛ Attendi un momento..."
        return
    end
    lastSearchTime = now

    local rawName = tostring(input.Text or ""):match("^%s*(.-)%s*$")
    if not isValidName(rawName) then
        feedback.Text = "❌ Nome non valido."
        return
    end

    feedback.Text = "🔎 Cercando dappertutto..."
    -- puoi impostare allowPartial = true per trovare anche parziali
    local allowPartial = true
    local found = findPetEverywhere(rawName, allowPartial)

    if not found then
        feedback.Text = "❌ Pet non trovato nelle aree visibili."
        return
    end

    -- aggiungi localmente (solo client)
    local ok, msg = addPetToLocalInventory(rawName, found)
    if ok then
        feedback.Text = "✅ " .. msg
    else
        feedback.Text = "❌ " .. msg
    end
end)

-- ------------------------
-- Note e debug (opzionale)
-- ------------------------
-- Premi R per stampare l'inventario locale nella output (comodo per debug)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(inputObj, gameProcessed)
    if gameProcessed then return end
    if inputObj.KeyCode == Enum.KeyCode.R then
        local inv = player:FindFirstChild("LocalInventory")
        if not inv then
            print("LocalInventory vuoto")
            return
        end
        print("---- LocalInventory ----")
        for _, pet in ipairs(inv:GetChildren()) do
            local rid = pet:FindFirstChild("Rarity") and pet.Rarity.Value or "?"
            local lvl = pet:FindFirstChild("Level") and pet.Level.Value or "?"
            local fid = pet:FindFirstChild("FoundIn") and pet.FoundIn.Value or "?"
            print(pet.Name, "| Rarity:", rid, "| Level:", lvl, "| FoundIn:", fid)
        end
        print("------------------------")
    end
end)

