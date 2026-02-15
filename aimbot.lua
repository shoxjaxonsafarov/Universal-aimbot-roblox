--// BOSTON ESP + CENTER LOCK AIMBOT
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local AimKey = Enum.KeyCode.F

local AimbotOn = false
local LockedHead = nil
local MaxScreenDist = 200

-------------------------------------------------
-- BOSTON ESP
-------------------------------------------------
local function createHighlight(player)
    if player.Character and not player.Character:FindFirstChild("ESPHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
    end
end

local function createNameTag(player)
    if player.Character and player.Character:FindFirstChild("Head") and not player.Character.Head:FindFirstChild("NameTag") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Adornee = player.Character.Head
        billboard.Size = UDim2.new(0, 130, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = player.Character.Head

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TagLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.Font = Enum.Font.Cartoon
        textLabel.TextScaled = true
        textLabel.TextStrokeTransparency = 0.6
        textLabel.Parent = billboard
    end
end

local function updateNameTag(player)
    if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("NameTag") and player.Character:FindFirstChild("Humanoid") then
        if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
        if not player.Character.PrimaryPart then return end
        
        local tag = player.Character.Head.NameTag.TagLabel
        local distance = (LocalPlayer.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude
        local health = math.floor(player.Character.Humanoid.Health)
        tag.Text = player.Name .. " | " .. string.format("%.0f", distance).."m | ❤️"..health
    end
end

local function updateHighlight(player)
    if player.Character and player.Character:FindFirstChild("ESPHighlight") and player.Character:FindFirstChild("Humanoid") then
        if player.Character.Humanoid.Health <= 0 then
            player.Character.ESPHighlight.FillColor = Color3.fromRGB(120, 0, 0)
        else
            player.Character.ESPHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end

local function setupESP(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.1)
            createHighlight(player)
            createNameTag(player)
        end)
        if player.Character then
            createHighlight(player)
            createNameTag(player)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupESP(player)
end

Players.PlayerAdded:Connect(setupESP)

-------------------------------------------------
-- CENTER LOCK HEAD AIMBOT
-------------------------------------------------
local function getCenterHead()
    local bestHead = nil
    local bestDist = MaxScreenDist
    
    local center = Vector2.new(
        Camera.ViewportSize.X/2,
        Camera.ViewportSize.Y/2
    )
    
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            
            if hum and head and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestHead = head
                    end
                end
            end
        end
    end
    
    return bestHead
end

RunService.RenderStepped:Connect(function()
    if not AimbotOn then return end
    
    if not LockedHead or not LockedHead.Parent then
        LockedHead = getCenterHead()
    end
    
    if LockedHead then
        local hum = LockedHead.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            LockedHead = nil
            return
        end
        
        local camPos = Camera.CFrame.Position
        Camera.CFrame = CFrame.new(camPos, LockedHead.Position)
    end
end)

-------------------------------------------------
-- KEY
-------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == AimKey then
        AimbotOn = not AimbotOn
        if not AimbotOn then
            LockedHead = nil
        end
    end
end)

-------------------------------------------------
-- ESP UPDATE LOOP
-------------------------------------------------
while true do
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            updateNameTag(player)
            updateHighlight(player)
        end
    end
    task.wait(0.3)
end
