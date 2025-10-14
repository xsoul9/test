-- LocalScript: Global Pet Inventory Finder + Local Copy (CLIENT ONLY)
-- Scopo:
--  1) Cerca "potenziali" contenitori inventario pet in tutte le istanze accessibili al client.
--  2) Mostra i risultati in una UI.
--  3) Permette di "importare" (copiare) la struttura trovata in una LocalInventory sul client (solo per test).
-- NOTE DI SICUREZZA: NON invia nulla al server, NON modifica oggetti server-side, NON esegue exploit.
-- È uno strumento di debug/ricerca client-side.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- CONFIG
local INVENTORY_KEYWORDS = {
    "Backpack", "Inventory", "PetInventory", "Pets", "PlayerInventory",
    "BackpackPets", "PetFolder", "OwnedPets", "PlayerPets", "PlayerData", "Data"
}
local MAX_CHECK_CHILDREN = 200 -- limiti per performance quando si ispezionano cartelle pesanti
local MAX_RESULTS = 100 -- numero massimo di candidates mostrati

-- ---------- UI CREATION ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryFinderGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 380)
frame.Position = UDim2.new(0.5, -260, 0.06, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Inventory Finder (client-only) — Cerca potenziali inventari pet"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0, 160, 0, 30)
scanButton.Position = UDim2.new(0, 10, 0, 48)
scanButton.Text = "Scansiona (dappertutto)"
scanButton.Font = Enum.Font.SourceSansBold
scanButton.TextSize = 14
scanButton.BackgroundColor3 = Color3.fromRGB(55,125,200)
scanButton.TextColor3 = Color3.fromRGB(255,255,255)
scanButton.Parent = frame

local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0, 160, 0, 30)
refreshButton.Position = UDim2.new(0, 180, 0, 48)
refreshButton.Text = "Aggiorna lista"
refreshButton.Font = Enum.Font.SourceSans
refreshButton.TextSize = 14
refreshButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
refreshButton.TextColor3 = Color3.fromRGB(255,255,255)
refreshButton.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 36)
infoLabel.Position = UDim2.new(0, 10, 0, 88)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "I risultati appariranno nella lista. Clicca 'Importa localmente' per copiarne una versione di test nella LocalInventory."
infoLabel.TextWrapped = true
infoLabel.TextColor3 = Color3.fromRGB(200,200,200)
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextSize = 14
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = frame

-- Result list area
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 20)
listLabel.Position = UDim2.new(0, 10, 0, 130)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Potenziali inventari trovati:"
listLabel.TextColor3 = Color3.fromRGB(255,255,255)
listLabel.Font = Enum.Font.SourceSansBold
listLabel.TextSize = 14
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 180)
scroll.Position = UDim2.new(0, 10, 0, 154)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 0.85
scroll.BackgroundColor3 = Color3.fromRGB(20,20,20)
scroll.BorderSizePixel = 0
scroll.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0,6)
uiListLayout.Parent = scroll

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 1, -28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Stato: Idle"
statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 14
statusLabel.Parent = frame

-- ---------- Utility functions ----------
local function seemsLikePetInventory(folder)
    -- Ritorna true se il folder contiene bambini che appaiono come pet (heuristiche)
    if not folder then return false end
    if not folder:GetChildren or #folder:GetChildren() == 0 then return false end

    local children = folder:GetChildren()
    local checkLimit = math.min(#children, MAX_CHECK_CHILDREN)
    local possibleScore = 0

    for i = 1, checkLimit do
        local child = children[i]
        -- Se il figlio ha child "Rarity", "PetName", "Level", "Age" incrementa score
        if child:FindFirstChild("Rarity") and child.Rarity:IsA("StringValue") then possibleScore = possibleScore + 2 end
        if child:FindFirstChild("PetName") and child.PetName:IsA("StringValue") then possibleScore = possibleScore + 3 end
        if child:FindFirstChild("Level") and child.Level:IsA("IntValue") then possibleScore = possibleScore + 1 end
        if child:FindFirstChild("Age") and child.Age:IsA("IntValue") then possibleScore = possibleScore + 1 end

        -- Se i nomi dei figli sembrano nomi di pet (es. tanti children con nomi non generici)
        if #tostring(child.Name) > 2 then possibleScore = possibleScore + 0.2 end
    end

    -- se ci sono molti figli o score alto, consideralo candidato
    if #children >= 3 and possibleScore >= 3 then
        return true
    end
    return false
end

local function nameContainsKeyword(name)
    if not name then return false end
    local lname = name:lower()
    for _, k in ipairs(INVENTORY_KEYWORDS) do
        if lname:find(k:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Cerca potenziali candidate in tutto il gioco visibile al client
local function findPotentialInventories()
    statusLabel.Text = "Stato: Scansione in corso..."
    local results = {}
    local desc = game:GetDescendants()
    for i = 1, #desc do
        local obj = desc[i]
        -- Ci interessano principalmente contenitori (Folder/Model/Instance)
        if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Instance") then
            -- 1) se il nome contiene keyword
            if nameContainsKeyword(obj.Name) then
                -- se sembra contenitore pet, aggiungi
                if pcall(function() return seemsLikePetInventory(obj) end) then
                    if seemsLikePetInventory(obj) then
                        table.insert(results, obj)
                        if #results >= MAX_RESULTS then break end
                    end
                end
            else
                -- 2) se non ha keyword nel nome, verifica direttamente con heuristica (potrebbe essere inventario con nome generico)
                if pcall(function() return seemsLikePetInventory(obj) end) then
                    if seemsLikePetInventory(obj) then
                        table.insert(results, obj)
                        if #results >= MAX_RESULTS then break end
                    end
                end
            end
        end
    end
    statusLabel.Text = "Stato: Scansione completata. Trovati "..tostring(#results).." potenziali."
    return results
end

-- Crea un bottone risultato nella UI per ogni candidate
local function clearResultsUI()
    for _, child in ipairs(scroll:GetChildren()) do
        if child ~= uiListLayout then child:Destroy() end
    end
end

-- Copia la struttura (solo lettura) in una LocalInventory client-side
local function importToLocalInventory(source)
    if not source then return false, "Sorgente nulla" end
    local inv = player:FindFirstChild("LocalInventory")
    if inv then inv:Destroy() end -- ricrea sempre per evitare duplicati / conflitti
    inv = Instance.new("Folder")
    inv.Name = "LocalInventory"
    inv.Parent = player

    -- Copia i primi N figli (non ricorsivamente) come esempio
    for i, child in ipairs(source:GetChildren()) do
        if i > 200 then break end -- sicurezza
        -- creiamo una copia simulata con alcuni metadati se presenti
        local entry = Instance.new("Folder")
        entry.Name = child.Name or ("Item_"..i)

        local pv = child:FindFirstChild("PetName")
        if pv and pv:IsA("StringValue") then
            local sv = Instance.new("StringValue")
            sv.Name = "PetName"
            sv.Value = pv.Value
            sv.Parent = entry
        end

        local rv = child:FindFirstChild("Rarity")
        if rv and rv:IsA("StringValue") then
            local sv2 = Instance.new("StringValue")
            sv2.Name = "Rarity"
            sv2.Value = rv.Value
            sv2.Parent = entry
        end

        local lv = child:FindFirstChild("Level")
        if lv and lv:IsA("IntValue") then
            local iv = Instance.new("IntValue")
            iv.Name = "Level"
            iv.Value = lv.Value
            iv.Parent = entry
        end

        -- aggiungiamo un ID locale per testing
        local id = Instance.new("StringValue")
        id.Name = "LocalImportedId"
        id.Value = "LOCALIMPORT_"..tostring(os.time()).."_"..tostring(math.random(1000,9999))
        id.Parent = entry

        -- registra da dove proviene per debug
        local src = Instance.new("StringValue")
        src.Name = "SourcePath"
        src.Value = source:GetFullName()
        src.Parent = entry

        entry.Parent = inv
    end

    return true, "Importazione completata in LocalInventory."
end

-- ---------- Event handlers ----------
local currentResults = {}

local function addResultToUI(obj)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = scroll

    local shortName = obj.Name
    local full = obj:GetFullName()
    btn.Text = shortName.."  —  "..full

    local importBtn = Instance.new("TextButton")
    importBtn.Size = UDim2.new(0, 140, 1, -6)
    importBtn.Position = UDim2.new(1, -150, 0, 3)
    importBtn.AnchorPoint = Vector2.new(1, 0)
    importBtn.Text = "Importa localmente"
    importBtn.Font = Enum.Font.SourceSansBold
    importBtn.TextSize = 12
    importBtn.BackgroundColor3 = Color3.fromRGB(50,140,50)
    importBtn.TextColor3 = Color3.fromRGB(255,255,255)
    importBtn.Parent = btn

    local inspectBtn = Instance.new("TextButton")
    inspectBtn.Size = UDim2.new(0, 80, 1, -6)
    inspectBtn.Position = UDim2.new(1, -300, 0, 3)
    inspectBtn.AnchorPoint = Vector2.new(1,0)
    inspectBtn.Text = "Ispeziona"
    inspectBtn.Font = Enum.Font.SourceSans
    inspectBtn.TextSize = 12
    inspectBtn.BackgroundColor3 = Color3.fromRGB(110,110,110)
    inspectBtn.TextColor3 = Color3.fromRGB(255,255,255)
    inspectBtn.Parent = btn

    -- Ispeziona: stampa dettagli nell'output (solo lettura)
    inspectBtn.MouseButton1Click:Connect(function()
        print("------ ISPEZIONE: ", obj:GetFullName(), "------")
        print("Children count:", #obj:GetChildren())
        for _, c in ipairs(obj:GetChildren()) do
            local info = "- "..c.Name
            if c:FindFirstChild("PetName") and c.PetName:IsA("StringValue") then
                info = info.." | PetName: "..tostring(c.PetName.Value)
            end
            if c:FindFirstChild("Rarity") and c.Rarity:IsA("StringValue") then
                info = info.." | Rarity: "..tostring(c.Rarity.Value)
            end
            if c:FindFirstChild("Level") and c.Level:IsA("IntValue") then
                info = info.." | Level: "..tostring(c.Level.Value)
            end
            print(info)
        end
        print("------ FINE ISPEZIONE ------")
        statusLabel.Text = "Stato: Ispezione completata (vedi Output)."
    end)

    -- Importa: copia in LocalInventory (client-only)
    importBtn.MouseButton1Click:Connect(function()
        statusLabel.Text = "Stato: Importazione in corso..."
        local ok, msg = pcall(function() return importToLocalInventory(obj) end)
        if ok then
            statusLabel.Text = "Stato: Importazione completata."
            print("Importato localmente da:", obj:GetFullName())
        else
            statusLabel.Text = "Stato: Importazione fallita."
            warn("Import fallita:", msg)
        end
    end)
end

local function populateResults(results)
    clearResultsUI()
    currentResults = results
    for _, obj in ipairs(results) do
        addResultToUI(obj)
    end
    -- aggiorna CanvasSize
    local total = uiListLayout.AbsoluteContentSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, total + 10)
end

scanButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "Stato: Avvio scansione..."
    -- scan
    local results = findPotentialInventories()
    populateResults(results)
end)

refreshButton.MouseButton1Click:Connect(function()
    if #currentResults == 0 then
        statusLabel.Text = "Stato: Nessun risultato da aggiornare."
        return
    end
    statusLabel.Text = "Stato: Aggiornamento risultati..."
    -- ricontrolla i risultati attuali per vedere se sono ancora validi
    local stillValid = {}
    for _, obj in ipairs(currentResults) do
        if obj and obj.Parent then
            if pcall(function() return seemsLikePetInventory(obj) end) and seemsLikePetInventory(obj) then
                table.insert(stillValid, obj)
            end
        end
    end
    populateResults(stillValid)
    statusLabel.Text = "Stato: Aggiornamento completato. Trovati "..tostring(#stillValid).." ancora validi."
end)

-- Shortcut per rimuovere la GUI con ESC (opzionale)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        screenGui:Destroy()
    end
end)

-- Fine script
