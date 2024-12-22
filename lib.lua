local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = 'lua.cc',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Legit = Window:AddTab('Legit'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Aimbot Setup
local AimbotMain = Tabs.Legit:AddLeftGroupbox('Aimbot')
local AimbotExtra = Tabs.Legit:AddRightGroupbox('Extra')

-- ESP Setup
local VisualsMain = Tabs.Visuals:AddLeftGroupbox('ESP')
local VisualsExtra = Tabs.Visuals:AddRightGroupbox('Colors')

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.ZIndex = 999

-- ESP Implementation
local ESP = {
    Drawings = {},
    Players = {},
}

-- Aimbot Controls
AimbotMain:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
}):AddKeyPicker('AimbotKey', {
    Default = 'MB2',
    SyncToggleState = false,
    Mode = 'Hold',
    Text = 'Aimbot',
    NoUI = false
})

AimbotMain:AddSlider('AimbotSmooth', {
    Text = 'Smoothness',
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
})

AimbotMain:AddSlider('AimbotFOV', {
    Text = 'FOV Size',
    Default = 400,
    Min = 10,
    Max = 800,
    Rounding = 0,
})

AimbotExtra:AddToggle('WallCheck', {
    Text = 'Wall Check',
    Default = true,
})

AimbotExtra:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = false,
})

AimbotExtra:AddToggle('ShowFOV', {
    Text = 'Show FOV Circle',
    Default = true,
})

AimbotExtra:AddDropdown('TargetPart', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
})

AimbotExtra:AddLabel('FOV Color'):AddColorPicker('FovColor', {
    Default = Color3.fromRGB(255, 255, 255),
})

-- ESP Controls
VisualsMain:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
})

VisualsMain:AddToggle('BoxESP', {
    Text = 'Boxes',
    Default = true,
})

VisualsMain:AddToggle('HealthESP', {
    Text = 'Health Bar',
    Default = true,
})

VisualsMain:AddToggle('NameESP', {
    Text = 'Names',
    Default = true,
})

VisualsMain:AddToggle('ESPTeamCheck', {
    Text = 'Team Check',
    Default = false,
})

VisualsMain:AddToggle('ShowDistance', {
    Text = 'Distance',
    Default = true,
})

VisualsMain:AddSlider('MaxDistance', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
})

-- ESP Colors
VisualsExtra:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Default = Color3.fromRGB(255, 255, 255),
})

VisualsExtra:AddLabel('Box Outline'):AddColorPicker('BoxOutlineColor', {
    Default = Color3.fromRGB(0, 0, 0),
})

VisualsExtra:AddLabel('Health Bar Color'):AddColorPicker('HealthColor', {
    Default = Color3.fromRGB(0, 255, 0),
})

VisualsExtra:AddLabel('Name Color'):AddColorPicker('NameColor', {
    Default = Color3.fromRGB(255, 255, 255),
})

VisualsExtra:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {
    Default = Color3.fromRGB(255, 255, 255),
})

local function CreateDrawings(player)
    local drawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    drawings.BoxOutline.Thickness = 1
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Color = Options.BoxOutlineColor.Value
    drawings.BoxOutline.Transparency = 1
    drawings.BoxOutline.Visible = false
    drawings.BoxOutline.ZIndex = 1
    
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Color = Options.BoxColor.Value
    drawings.Box.Transparency = 1
    drawings.Box.Visible = false
    drawings.Box.ZIndex = 2
    
    drawings.HealthBarOutline.Thickness = 1
    drawings.HealthBarOutline.Filled = true
    drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBarOutline.Transparency = 1
    drawings.HealthBarOutline.Visible = false
    drawings.HealthBarOutline.ZIndex = 1
    
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Color = Options.HealthColor.Value
    drawings.HealthBar.Transparency = 1
    drawings.HealthBar.Visible = false
    drawings.HealthBar.ZIndex = 2
    
    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Options.NameColor.Value
    drawings.Name.Visible = false
    drawings.Name.ZIndex = 2
    
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color = Options.DistanceColor.Value
    drawings.Distance.Visible = false
    drawings.Distance.ZIndex = 2
    
    ESP.Drawings[player] = drawings
end

-- Color Picker Callbacks (Now after ESP table is created)
Options.BoxColor:OnChanged(function()
    if ESP.Drawings then
        for _, drawings in pairs(ESP.Drawings) do
            drawings.Box.Color = Options.BoxColor.Value
        end
    end
end)

Options.BoxOutlineColor:OnChanged(function()
    if ESP.Drawings then
        for _, drawings in pairs(ESP.Drawings) do
            drawings.BoxOutline.Color = Options.BoxOutlineColor.Value
        end
    end
end)

Options.HealthColor:OnChanged(function()
    if ESP.Drawings then
        for _, drawings in pairs(ESP.Drawings) do
            drawings.HealthBar.Color = Options.HealthColor.Value
        end
    end
end)

Options.NameColor:OnChanged(function()
    if ESP.Drawings then
        for _, drawings in pairs(ESP.Drawings) do
            drawings.Name.Color = Options.NameColor.Value
        end
    end
end)

Options.DistanceColor:OnChanged(function()
    if ESP.Drawings then
        for _, drawings in pairs(ESP.Drawings) do
            drawings.Distance.Color = Options.DistanceColor.Value
        end
    end
end)

local function RemoveDrawings(player)
    if ESP.Drawings[player] then
        for _, drawing in pairs(ESP.Drawings[player]) do
            drawing:Remove()
        end
        ESP.Drawings[player] = nil
    end
end

-- Aimbot Functions
local function GetClosest()
    local MaxDist = Options.AimbotFOV.Value
    local Target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v == Players.LocalPlayer then continue end
        if Toggles.TeamCheck.Value and v.Team == Players.LocalPlayer.Team then continue end
        
        local targetPart = Options.TargetPart.Value
        if not v.Character or not v.Character:FindFirstChild(targetPart) then continue end
        
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character[targetPart].Position)
        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
        
        if Distance < MaxDist and OnScreen then
            if Toggles.WallCheck.Value then
                local ray = Ray.new(Camera.CFrame.Position, 
                    v.Character[targetPart].Position - Camera.CFrame.Position)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, Players.LocalPlayer.Character})
                if hit and hit:IsDescendantOf(v.Character) then
                    MaxDist = Distance
                    Target = v
                end
            else
                MaxDist = Distance
                Target = v
            end
        end
    end
    return Target
end

-- Update Functions
local function UpdateESP()
    for player, drawings in pairs(ESP.Drawings) do
        if not player or not player.Parent then
            RemoveDrawings(player)
            continue
        end

        if not Toggles.ESPEnabled.Value then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end

        if Toggles.ESPTeamCheck.Value and player.Team == Players.LocalPlayer.Team then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not humanoid or not rootPart then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end

        local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        
        if not onScreen or distance > Options.MaxDistance.Value then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end

        local size = Vector2.new(2000 / vector.Z, 2500 / vector.Z)
        local position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)

        if Toggles.BoxESP.Value then
            drawings.BoxOutline.Size = size
            drawings.BoxOutline.Position = position
            drawings.BoxOutline.Color = Options.BoxOutlineColor.Value
            drawings.BoxOutline.Visible = true
            
            drawings.Box.Size = size
            drawings.Box.Position = position
            drawings.Box.Color = Options.BoxColor.Value
            drawings.Box.Visible = true
        else
            drawings.BoxOutline.Visible = false
            drawings.Box.Visible = false
        end

        if Toggles.HealthESP.Value then
            local healthBarHeight = size.Y * (humanoid.Health / humanoid.MaxHealth)
            
            drawings.HealthBarOutline.Size = Vector2.new(4, size.Y)
            drawings.HealthBarOutline.Position = Vector2.new(position.X - 6, position.Y)
            drawings.HealthBarOutline.Visible = true
            
            drawings.HealthBar.Size = Vector2.new(2, healthBarHeight)
            drawings.HealthBar.Position = Vector2.new(position.X - 5, position.Y + size.Y - healthBarHeight)
            drawings.HealthBar.Color = Options.HealthColor.Value
            drawings.HealthBar.Visible = true
        else
            drawings.HealthBarOutline.Visible = false
            drawings.HealthBar.Visible = false
        end

        if Toggles.NameESP.Value then
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(vector.X, position.Y - 16)
            drawings.Name.Color = Options.NameColor.Value
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        if Toggles.ShowDistance.Value then
            drawings.Distance.Text = math.floor(distance) .. "s"
            drawings.Distance.Position = Vector2.new(vector.X, position.Y + size.Y)
            drawings.Distance.Color = Options.DistanceColor.Value
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end
    end
end

-- Main Loops
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if Toggles.ShowFOV.Value then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.AimbotFOV.Value
        FOVCircle.Color = Options.FovColor.Value
    else
        FOVCircle.Visible = false
    end
    
    -- Update Aimbot
    if Toggles.AimbotEnabled.Value and Options.AimbotKey:GetState() then
        local Target = GetClosest()
        if Target then
            local targetPart = Options.TargetPart.Value
            local TargetPos = Camera:WorldToViewportPoint(Target.Character[targetPart].Position)
            local MousePos = UserInputService:GetMouseLocation()
            
            mousemoverel(
                (TargetPos.X - MousePos.X) * Options.AimbotSmooth.Value,
                (TargetPos.Y - MousePos.Y) * Options.AimbotSmooth.Value
            )
        end
    end
    
    -- Update ESP
    UpdateESP()
end)

-- Player Handling
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateDrawings(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    CreateDrawings(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveDrawings(player)
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder('lua')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:Notify('Loaded!', 3)
