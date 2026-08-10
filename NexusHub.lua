-- ============================================
-- NEXUS HUB | MAKE BY: NATE & NGỌT
-- SUBTITLE: LOADING
-- ============================================

-- === TẢI WINDUI (LINK CHÍNH THỨC) ===
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- === TẠO WINDOW ===
local Window = WindUI:CreateWindow({
    Title = "Nexus Hub | Make By: Nate & Ngọt",
    SubTitle = "Loading",
    Size = UDim2.fromOffset(600, 500),
    Center = true
})

-- === THÔNG BÁO KHỞI ĐỘNG ===
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✔️ Running Script...",
    Text = "Khởi động script thành công!",
    Duration = 5
})

-- === CẤU HÌNH ===
local CONFIG = {
    IMAGE_ID = "6031090938",
    MUSIC_ID = "108531350726198",
    GIF_URL = "https://media.tenor.com/FHTOu1fN6DcAAAAM/angry-anime.gif",
    SOUND_DEAD_ID = "1357900029",
    SOUND_WIN_ID = "113326842510307"
}

-- === BACKGROUND ===
if CONFIG.IMAGE_ID ~= "none" then
    pcall(function()
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.fromScale(1, 1)
        imageLabel.Image = "rbxassetid://" .. CONFIG.IMAGE_ID
        imageLabel.BackgroundTransparency = 1
        imageLabel.ImageTransparency = 0.3
        imageLabel.ScaleType = Enum.ScaleType.Crop
        imageLabel.ZIndex = 0
        imageLabel.Parent = Window.MainFrame
    end)
end

if CONFIG.GIF_URL ~= "none" then
    pcall(function()
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.fromScale(1, 1)
        imageLabel.Image = CONFIG.GIF_URL
        imageLabel.BackgroundTransparency = 1
        imageLabel.ImageTransparency = 0.3
        imageLabel.ScaleType = Enum.ScaleType.Crop
        imageLabel.ZIndex = 0
        imageLabel.Parent = Window.MainFrame
    end)
end

-- === PHÁT NHẠC ===
if CONFIG.MUSIC_ID ~= "none" then
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. CONFIG.MUSIC_ID
        sound.Volume = 0.8
        sound.Looped = true
        sound.Parent = game:GetService("Players").LocalPlayer
        sound:Play()
    end)
end

-- === TẠO TAB FARM ===
local FarmTab = Window:Tab({
    Title = "Farm Handmade"
})

local FarmGroup = FarmTab:Group({
    Title = "Farm Event",
    Side = "left"
})

-- === FARM LOGIC ===
local EventItems = {
    "none", "none", "none", "none", "none",
    "none", "none", "none", "none", "none",
    "none", "none", "none", "none", "none",
    "none", "none", "Bubble", "none", "none"
}

local isFarming = false
local isFarmingLV = false
local wall = nil
local farmConnection = nil
local farmLVConnection = nil
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart") or nil

function CreateWall()
    if wall then wall:Destroy() end
    
    if not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
    end
    
    local wallGroup = Instance.new("Model")
    wallGroup.Name = "NexusWall"
    
    local positions = {
        {0, 0, 10, CFrame.Angles(0, 0, 0)},
        {0, 0, -10, CFrame.Angles(0, math.pi, 0)},
        {10, 0, 0, CFrame.Angles(0, math.pi/2, 0)},
        {-10, 0, 0, CFrame.Angles(0, -math.pi/2, 0)}
    }
    
    for _, pos in pairs(positions) do
        local wallPart = Instance.new("Part")
        wallPart.Size = Vector3.new(20, 5, 1)
        wallPart.Position = Vector3.new(pos[1], pos[2], pos[3])
        wallPart.CFrame = pos[4]
        wallPart.Anchored = true
        wallPart.CanCollide = true
        wallPart.BrickColor = BrickColor.new("White")
        wallPart.Material = Enum.Material.SmoothPlastic
        wallPart.Parent = wallGroup
    end
    
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(18, 0.5, 18)
    floor.Position = Vector3.new(0, -0.25, 0)
    floor.Anchored = true
    floor.CanCollide = true
    floor.BrickColor = BrickColor.new("White")
    floor.Material = Enum.Material.SmoothPlastic
    floor.Parent = wallGroup
    
    local playerPos = humanoidRootPart.Position
    wallGroup:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 0, 0)))
    wallGroup.Parent = game.Workspace
    wall = wallGroup
    
    humanoidRootPart.CFrame = CFrame.new(playerPos + Vector3.new(0, 3.5, 0))
    return true
end

function DestroyWall()
    if wall then
        wall:Destroy()
        wall = nil
    end
end

function ScanEventItems()
    local foundItems = {}
    for _, itemName in pairs(EventItems) do
        if itemName ~= "none" then
            local allItems = game.Workspace:GetDescendants()
            for _, obj in pairs(allItems) do
                if obj:IsA("Part") and obj.Name == itemName then
                    table.insert(foundItems, obj)
                end
            end
        end
    end
    return foundItems
end

function StartFarmEvent()
    if isFarming then return end
    local items = ScanEventItems()
    if #items == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Từ chối Farm",
            Text = "Không có sự kiện nào!",
            Duration = 3
        })
        return
    end
    
    isFarming = true
    CreateWall()
    
    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarming then return end
        local items = ScanEventItems()
        if #items == 0 then
            StopFarmEvent()
            return
        end
        for _, item in pairs(items) do
            if item and item.Parent then
                humanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 2, 0))
                wait(0.1)
                if item and item.Parent then
                    wait(0.5)
                    humanoidRootPart.CFrame = CFrame.new(item.Position + Vector3.new(0, 2, 0))
                end
            end
        end
        wait(0.5)
    end)
end

function StopFarmEvent()
    isFarming = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    if not isFarmingLV then DestroyWall() end
end

function StartFarmLV()
    if isFarmingLV then return end
    isFarmingLV = true
    CreateWall()
    
    farmLVConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarmingLV then return end
        wait(0.5)
    end)
end

function StopFarmLV()
    isFarmingLV = false
    if farmLVConnection then
        farmLVConnection:Disconnect()
        farmLVConnection = nil
    end
    if not isFarming then DestroyWall()
end

FarmGroup:Toggle({
    Title = "Farm Event",
    Desc = "Bật/tắt farm vật phẩm sự kiện",
    Default = false,
    Callback = function(state)
        if state then StartFarmEvent() else StopFarmEvent() end
    end
})

FarmGroup:Toggle({
    Title = "Farm Lv",
    Desc = "Bật/tắt farm level tự động",
    Default = false,
    Callback = function(state)
        if state then StartFarmLV() else StopFarmLV() end
    end
})

-- === TAB ANTI ===
local AntiTab = Window:Tab({
    Title = "Anti-comprehensive & Sound"
})

local AntiGroup = AntiTab:Group({
    Title = "Anti Features",
    Side = "left"
})

-- === BIẾN ANTI ===
local isAntiAFK = false
local isAutoRejoined = false
local isAntiBanned = false
local isAntiError = false
local isSoundDead = false
local isSoundWin = false
local isAutoStart = false
local antiAFKConnection = nil
local errorCheckConnection = nil
local soundDeadConnection = nil
local soundWinConnection = nil
local lastMoveTime = tick()
local isDead = false
local isWin = false

function PlaySound(soundId, volume)
    if soundId == "none" then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = volume or 0.8
        sound.Parent = player
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 10)
    end)
end

function StartAntiAFK()
    if isAntiAFK then return end
    isAntiAFK = true
    antiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiAFK then return end
        local timeSinceLastMove = tick() - lastMoveTime
        if timeSinceLastMove > 600 and character and humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 0.1, 0))
            lastMoveTime = tick()
        end
    end)
end

function StopAntiAFK()
    isAntiAFK = false
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

function StartAutoRejoined()
    if isAutoRejoined then return end
    isAutoRejoined = true
    game:GetService("RunService").Heartbeat:Connect(function()
        if not isAutoRejoined then return end
        if not game:IsLoaded() or not player then
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end

function StopAutoRejoined()
    isAutoRejoined = false
end

function StartAntiBanned()
    if isAntiBanned then return end
    isAntiBanned = true
    local bannedDetected = false
    game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiBanned then return end
        local success = pcall(function()
            if not player then return end
            player:GetAttribute("Banned")
        end)
        if not success and not bannedDetected then
            bannedDetected = true
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end

function StopAntiBanned()
    isAntiBanned = false
end

function StartAntiError()
    if isAntiError then return end
    isAntiError = true
    errorCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiError then return end
        local success = pcall(function()
            if game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui") then
                local prompts = game:GetService("CoreGui").RobloxPromptGui
                for _, child in pairs(prompts:GetChildren()) do
                    if child:IsA("ScreenGui") and child.Enabled then
                        child.Enabled = false
                    end
                end
            end
        end)
        if not success and isAutoRejoined then
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end

function StopAntiError()
    isAntiError = false
    if errorCheckConnection then
        errorCheckConnection:Disconnect()
        errorCheckConnection = nil
    end
end

function StartSoundDead()
    if isSoundDead then return end
    isSoundDead = true
    soundDeadConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isSoundDead then return end
        pcall(function()
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local currentHealth = humanoid.Health
                if currentHealth <= 0 and not isDead then
                    isDead = true
                    if CONFIG.SOUND_DEAD_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_DEAD_ID, 0.8)
                    end
                elseif currentHealth > 0 and isDead then
                    isDead = false
                end
            end
        end)
    end)
end

function StopSoundDead()
    isSoundDead = false
    if soundDeadConnection then
        soundDeadConnection:Disconnect()
        soundDeadConnection = nil
    end
end

function StartSoundWin()
    if isSoundWin then return end
    isSoundWin = true
    soundWinConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isSoundWin then return end
        pcall(function()
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local currentHealth = humanoid.Health
                if isDead and currentHealth > 0 then
                    isDead = false
                    isWin = true
                    if CONFIG.SOUND_WIN_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_WIN_ID, 0.8)
                    end
                    wait(5)
                    isWin = false
                end
                local gameState = game:GetService("Workspace"):FindFirstChild("GameState")
                if gameState and gameState.Value == "Win" and not isWin then
                    isWin = true
                    if CONFIG.SOUND_WIN_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_WIN_ID, 0.8)
                    end
                    wait(5)
                    isWin = false
                end
            end
        end)
    end)
end

function StopSoundWin()
    isSoundWin = false
    if soundWinConnection then
        soundWinConnection:Disconnect()
        soundWinConnection = nil
    end
end

AntiGroup:Toggle({
    Title = "Anti-AFK",
    Desc = "Chống mã lỗi 20 phút",
    Default = false,
    Callback = function(state)
        if state then StartAntiAFK() else StopAntiAFK() end
    end
})

AntiGroup:Toggle({
    Title = "Auto Rejoined",
    Desc = "Tự động tham gia lại nếu gặp mã lỗi",
    Default = false,
    Callback = function(state)
        if state then StartAutoRejoined() else StopAutoRejoined() end
    end
})

AntiGroup:Toggle({
    Title = "Anti-Banned",
    Desc = "Chống banned từ server",
    Default = false,
    Callback = function(state)
        if state then StartAntiBanned() else StopAntiBanned() end
    end
})

AntiGroup:Toggle({
    Title = "Anti-Error code",
    Desc = "Chống tất cả mã lỗi",
    Default = false,
    Callback = function(state)
        if state then StartAntiError() else StopAntiError() end
    end
})

AntiGroup:Toggle({
    Title = "Sound Dead/Defeated",
    Desc = "Phát nhạc khi chết/hạ gục",
    Default = false,
    Callback = function(state)
        if state then StartSoundDead() else StopSoundDead() end
    end
})

AntiGroup:Toggle({
    Title = "Sound Survive/Win",
    Desc = "Phát nhạc khi thắng/sống sót",
    Default = false,
    Callback = function(state)
        if state then StartSoundWin() else StopSoundWin() end
    end
})

AntiGroup:Toggle({
    Title = "Auto Start the script",
    Desc = "Tự động khởi động lại script nếu bị kick",
    Default = false,
    Callback = function(state)
        isAutoStart = state
    end
})

-- === TAB SERVER ===
local ServerTab = Window:Tab({
    Title = "Server & Players"
})

local ServerGroup = ServerTab:Group({
    Title = "Server Manager",
    Side = "left"
})

local playerCountLabel = ServerGroup:Label({
    Title = "Players in the server: 0"
})

local maxPlayersLabel = ServerGroup:Label({
    Title = "Max players: 0"
})

local function UpdatePlayerCount()
    local players = game:GetService("Players"):GetPlayers()
    local maxPlayers = game:GetService("Players").MaxPlayers
    playerCountLabel:Update("Players in the server: " .. #players)
    maxPlayersLabel:Update("Max players: " .. maxPlayers)
end

UpdatePlayerCount()
game:GetService("Players").PlayerAdded:Connect(UpdatePlayerCount)
game:GetService("Players").PlayerRemoving:Connect(UpdatePlayerCount)

function ServerHop()
    local currentPlaceId = game.PlaceId
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. currentPlaceId .. "/servers/Public?limit=100")
        )
    end)
    if not success or not result or not result.data then return end
    local lowestPlayers = math.huge
    local bestServer = nil
    for _, server in pairs(result.data) do
        if server.playing < server.maxPlayers and server.playing < lowestPlayers then
            lowestPlayers = server.playing
            bestServer = server
        end
    end
    if bestServer then
        game:GetService("TeleportService"):TeleportToPlaceInstance(currentPlaceId, bestServer.id, player)
    end
end

function ServerFull()
    local currentPlaceId = game.PlaceId
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. currentPlaceId .. "/servers/Public?limit=100")
        )
    end)
    if not success or not result or not result.data then return end
    local highestPlayers = -1
    local bestServer = nil
    for _, server in pairs(result.data) do
        if server.playing < server.maxPlayers and server.playing > highestPlayers then
            highestPlayers = server.playing
            bestServer = server
        end
    end
    if bestServer then
        game:GetService("TeleportService"):TeleportToPlaceInstance(currentPlaceId, bestServer.id, player)
    end
end

function RejoinedServer()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

function RandomServer()
    local currentPlaceId = game.PlaceId
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. currentPlaceId .. "/servers/Public?limit=100")
        )
    end)
    if not success or not result or not result.data then return end
    local availableServers = {}
    for _, server in pairs(result.data) do
        if server.playing < server.maxPlayers then
            table.insert(availableServers, server)
        end
    end
    if #availableServers > 0 then
        local randomServer = availableServers[math.random(1, #availableServers)]
        game:GetService("TeleportService"):TeleportToPlaceInstance(currentPlaceId, randomServer.id, player)
    end
end

ServerGroup:Button({
    Title = "Server Hop",
    Desc = "Tìm máy chủ ít người chơi nhất",
    Callback = function()
        pcall(ServerHop)
    end
})

ServerGroup:Button({
    Title = "Server Full",
    Desc = "Tìm máy chủ gần full người chơi",
    Callback = function()
        pcall(ServerFull)
    end
})

ServerGroup:Button({
    Title = "Rejoined Server",
    Desc = "Vào lại máy chủ đã ở trước đó",
    Callback = function()
        pcall(RejoinedServer)
    end
})

ServerGroup:Button({
    Title = "Random Server",
    Desc = "Tìm server ngẫu nhiên không full",
    Callback = function()
        pcall(RandomServer)
    end
})

-- === TAB SETTINGS ===
local SettingsTab = Window:Tab({
    Title = "Settings"
})

local SettingsGroup = SettingsTab:Group({
    Title = "Settings",
    Side = "left"
})

-- === FPS ===
local isShowFPS = false
local fpsGUI = nil
local fpsLabel = nil

function CreateFPSGUI()
    if fpsGUI then
        fpsGUI:Destroy()
        fpsGUI = nil
        fpsLabel = nil
    end
    
    fpsGUI = Instance.new("ScreenGui")
    fpsGUI.Name = "FPSDisplay"
    fpsGUI.Parent = player:WaitForChild("PlayerGui")
    fpsGUI.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 50)
    frame.Position = UDim2.new(1, -110, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = fpsGUI
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 0, 0)
    uiStroke.Thickness = 2
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLabel.TextSize = 18
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Parent = frame
    
    spawn(function()
        local hue = 0
        while fpsGUI and fpsGUI.Parent do
            hue = (hue + 0.01) % 1
            uiStroke.Color = Color3.fromHSV(hue, 1, 1)
            wait(0.05)
        end
    end)
    
    spawn(function()
        local lastTime = tick()
        local frameCount = 0
        while fpsGUI and fpsGUI.Parent do
            frameCount = frameCount + 1
            local currentTime = tick()
            if currentTime - lastTime >= 1 then
                if fpsLabel then
                    fpsLabel.Text = "FPS: " .. frameCount
                end
                frameCount = 0
                lastTime = currentTime
            end
            wait()
        end
    end)
end

function DestroyFPSGUI()
    if fpsGUI then
        fpsGUI:Destroy()
        fpsGUI = nil
        fpsLabel = nil
    end
end

SettingsGroup:Toggle({
    Title = "Show Fps",
    Desc = "Hiển thị FPS thật của người dùng",
    Default = false,
    Callback = function(state)
        isShowFPS = state
        if state then
            CreateFPSGUI()
        else
            DestroyFPSGUI()
        end
    end
})

-- === THEMES ===
local THEMES = {
    "Dark", "Light", "Rose", "Plant", "Red", "Indigo",
    "Sky", "Violet", "Amber", "Emerald", "Midnight",
    "Crimson", "Monokai Pro", "Cotton Candy", "Mellowsi", "Rainbow"
}

local selectedTheme = "Dark"

SettingsGroup:Dropdown({
    Title = "Chọn Theme",
    Desc = "Chọn theme cho WindUI Library",
    Default = "Dark",
    Options = THEMES,
    Callback = function(option)
        selectedTheme = option
    end
})

SettingsGroup:Button({
    Title = "Đặt Theme",
    Desc = "Áp dụng theme và khởi động lại",
    Callback = function()
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PhongScriptDev/Script_Evade/refs/heads/main/NexusHub.lua"))()
    end
})

SettingsGroup:Button({
    Title = "Restart the script",
    Desc = "Khởi động lại script",
    Callback = function()
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PhongScriptDev/Script_Evade/refs/heads/main/NexusHub.lua"))()
    end
})

SettingsGroup:Button({
    Title = "Destroy the UI",
    Desc = "Xóa UI",
    Callback = function()
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
        DestroyFPSGUI()
    end
})

print("✅ Nexus Hub đã tải thành công!")
