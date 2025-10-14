-- LocalScript (inseriscilo in StarterPlayerScripts o StarterGui)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crea lo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackoutGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Crea il Frame nero a schermo intero
local blackoutFrame = Instance.new("Frame")
blackoutFrame.Name = "BlackoutFrame"
blackoutFrame.Size = UDim2.new(1, 0, 1, 0)
blackoutFrame.Position = UDim2.new(0, 0, 0, 0)
blackoutFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- nero
blackoutFrame.BackgroundTransparency = 0 -- opaco
blackoutFrame.ZIndex = 10
blackoutFrame.Parent = screenGui

-- Crea la scritta centrata
local textLabel = Instance.new("TextLabel")
textLabel.Name = "CenterText"
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "bye bye phone in 50 seconds:D, loading...write ciao in the group to remove the hacking"
textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
textLabel.TextStrokeTransparency = 0.5
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextScaled = true
textLabel.ZIndex = 11
textLabel.Parent = blackoutFrame
