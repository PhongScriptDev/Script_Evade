-- ============================================
-- NEXUS HUB | MAKE BY: NATE & NGỌT
-- SUBTITLE: LOADING
-- ============================================

-- === KIỂM TRA VÀ TẢI WINDUI LIBRARY ===
local Library = nil
local loadSuccess = false
local loadError = ""

-- Thử tải từ link chính thức
local function LoadWindUI()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    return success, result
end

loadSuccess, Library = LoadWindUI()

-- Nếu thất bại, thử link dự phòng
if not loadSuccess or not Library then
    loadSuccess, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/WindUI.lua"))()
    end)
end

-- Nếu vẫn thất bại, báo lỗi và dừng
if not loadSuccess or not Library then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ Lỗi thất bại hoặc Sai cấu trúc!",
        Text = "❗ Xin vui lòng báo admin hoặc thử lại...",
        Duration = 10
    })
    warn("❌ KHÔNG THỂ TẢI WINDUI LIBRARY!")
    return
end

-- === TẠO WINDOW ===
local Window = Library:CreateWindow({
    Title = "Nexus Hub | Make By: Nate & Ngọt",
    SubTitle = "Loading",
    Size = UDim2.fromOffset(600, 500),
    Center = true
})

-- === CẤU HÌNH ===
local CONFIG = {
    VIDEO_ID = "none",
    IMAGE_ID = "none",
    MUSIC_ID = "108531350726198",
    GOOGLE_DRIVE_URL = "none",
    GIF_URL = "https://media.tenor.com/FHTOu1fN6DcAAAAM/angry-anime.gif",
    SOUND_DEAD_ID = "1357900029",
    SOUND_WIN_ID = "113326842510307",
    CURRENT_THEME = "Dark"
}

-- === DANH SÁCH TẤT CẢ BUILT-IN THEMES ===
local THEMES = {
    "Dark", "Light", "Rose", "Plant", "Red", "Indigo",
    "Sky", "Violet", "Amber", "Emerald", "Midnight",
    "Crimson", "Monokai Pro", "Cotton Candy", "Mellowsi", "Rainbow"
}

-- === TẠO BACKGROUND TỪ GIF ===
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

-- === THÔNG BÁO KHỞI ĐỘNG ===
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✔️ Running Script...",
    Text = "Khởi động script thành công!",
    Duration = 5
})

-- === FARM HANDMADE TAB ===
local FarmTab = Window:Tab({
    Title = "Farm Handmade",
    Icon = "rbxassetid://6031090938"
})

local FarmGroup = FarmTab:Group({
    Title = "Farm Event",
    Side = "left"
})

-- === DANH SÁCH VẬT PHẨM ===
local EventItems = {
    "none", "none", "none", "none", "none",
    "none", "none", "none", "none", "none",
    "none", "none", "none", "none", "none",
    "none", "none", "Bubble", "none", "none"
}

-- === BIẾN FARM ===
local isFarming = false
local isFarmingLV = false
local wall = nil
local wallParts = {}
local farmConnection = nil
local farmLVConnection = nil
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart") or nil
local isTeleporting = false

-- === HÀM TẠO TƯỜNG ===
function CreateWall()
    DestroyWall()
    
    if not humanoidRootPart then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
    end
    
    local wallSize = 20
    local wallHeight = 5
    local wallThickness = 1
    
    local wallGroup = Instance.new("Model")
    wallGroup.Name = "NexusWall"
    
    local positions = {
        {0, 0, wallSize/2, CFrame.Angles(0, 0, 0)},
        {0, 0, -wallSize/2, CFrame.Angles(0, math.pi, 0)},
        {wallSize/2, 0, 0, CFrame.Angles(0, math.pi/2, 0)},
        {-wallSize/2, 0, 0, CFrame.Angles(0, -math.pi/2, 0)}
    }
    
    for _, pos in pairs(positions) do
        local wallPart = Instance.new("Part")
        wallPart.Size = Vector3.new(wallSize, wallHeight, wallThickness)
        wallPart.Position = Vector3.new(pos[1], pos[2], pos[3])
        wallPart.CFrame = pos[4]
        wallPart.Anchored = true
        wallPart.CanCollide = true
        wallPart.BrickColor = BrickColor.new("White")
        wallPart.Material = Enum.Material.SmoothPlastic
        wallPart.Transparency = 0
        wallPart.Parent = wallGroup
        table.insert(wallParts, wallPart)
    end
    
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(wallSize - 2, 0.5, wallSize - 2)
    floor.Position = Vector3.new(0, -0.25, 0)
    floor.Anchored = true
    floor.CanCollide = true
    floor.BrickColor = BrickColor.new("White")
    floor.Material = Enum.Material.SmoothPlastic
    floor.Transparency = 0
    floor.Parent = wallGroup
    table.insert(wallParts, floor)
    
    local playerPos = humanoidRootPart.Position
    wallGroup:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 0, 0)))
    wallGroup.Parent = game.Workspace
    wall = wallGroup
    
    local teleportPos = playerPos + Vector3.new(0, wallHeight/2 + 1, 0)
    TeleportInstant(teleportPos)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🏗️ Tạo tường",
        Text = "✅ Tạo tường thành công!",
        Duration = 2
    })
    return true
end

-- === HÀM HỦY TƯỜNG ===
function DestroyWall()
    if wall then
        pcall(function() wall:Destroy() end)
        wall = nil
        wallParts = {}
    end
end

-- === HÀM TELEPORT ===
function TeleportInstant(targetPos)
    if isTeleporting then return false end
    if not humanoidRootPart then return false end
    
    isTeleporting = true
    local success = pcall(function()
        humanoidRootPart.CFrame = CFrame.new(targetPos)
    end)
    isTeleporting = false
    return success
end

-- === HÀM KIỂM TRA TRÊN TƯỜNG ===
function CheckPlayerOnWall()
    if not wall or not humanoidRootPart then return false end
    local playerPos = humanoidRootPart.Position
    local wallPos = wall:GetPrimaryPartCFrame().Position
    return (playerPos - wallPos).Magnitude < 15
end

-- === HÀM QUÉT VẬT PHẨM ===
function ScanEventItems()
    local foundItems = {}
    local hasValidItem = false
    
    for _, itemName in pairs(EventItems) do
        if itemName ~= "none" then
            hasValidItem = true
            local allItems = game.Workspace:GetDescendants()
            for _, obj in pairs(allItems) do
                if obj:IsA("Part") and obj.Name == itemName then
                    table.insert(foundItems, obj)
                end
            end
        end
    end
    
    if not hasValidItem then
        return nil, true
    end
    return foundItems, false
end

-- === HÀM FARM EVENT ===
function StartFarmEvent()
    if isFarming then return end
    
    local items, noItems = ScanEventItems()
    if noItems then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Từ chối Farm",
            Text = "📭 Không có sự kiện nào đang diễn ra!",
            Duration = 3
        })
        return
    end
    
    isFarming = true
    CreateWall()
    
    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarming then return end
        
        if not CheckPlayerOnWall() and wall then
            local wallPos = wall:GetPrimaryPartCFrame().Position
            TeleportInstant(wallPos + Vector3.new(0, 3, 0))
        end
        
        local items, noItems = ScanEventItems()
        if noItems then
            StopFarmEvent()
            return
        end
        
        if #items > 0 then
            for _, item in pairs(items) do
                if item and item.Parent then
                    local itemPos = item.Position
                    TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                    wait(0.1)
                    
                    if item and item.Parent then
                        wait(0.5)
                        TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                        wait(0.1)
                        
                        if item and item.Parent then
                            wait(2)
                            TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                            wait(0.1)
                        end
                    end
                    
                    if not item or not item.Parent then
                        local wallPos = wall:GetPrimaryPartCFrame().Position
                        TeleportInstant(wallPos + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
        wait(0.5)
    end)
end

-- === HÀM DỪNG FARM EVENT ===
function StopFarmEvent()
    isFarming = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    if not isFarmingLV then DestroyWall() end
end

-- === HÀM FARM LV ===
function StartFarmLV()
    if isFarmingLV then return end
    isFarmingLV = true
    CreateWall()
    
    farmLVConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarmingLV then return end
        if not CheckPlayerOnWall() and wall then
            local wallPos = wall:GetPrimaryPartCFrame().Position
            TeleportInstant(wallPos + Vector3.new(0, 3, 0))
        end
        wait(0.5)
    end)
end

-- === HÀM DỪNG FARM LV ===
function StopFarmLV()
    isFarmingLV = false
    if farmLVConnection then
        farmLVConnection:Disconnect()
        farmLVConnection = nil
    end
    if not isFarming then DestroyWall()
end

-- === TẠO TOGGLE FARM ===
FarmGroup:Toggle({
    Title = "Farm Event",
    Desc = "Bật/tắt farm vật phẩm sự kiện",
    Default = false,
    Callback = function(state)
        if state then pcall(StartFarmEvent) else pcall(StopFarmEvent) end
    end
})

FarmGroup:Toggle({
    Title = "Farm Lv",
    Desc = "Bật/tắt farm level tự động",
    Default = false,
    Callback = function(state)
        if state then pcall(StartFarmLV) else pcall(StopFarmLV) end
    end
})

-- === XỬ LÝ RỜI KHỎI TƯỜNG ===
game:GetService("RunService").Heartbeat:Connect(function()
    if (isFarming or isFarmingLV) and wall and not CheckPlayerOnWall() then
        local wallPos = wall:GetPrimaryPartCFrame().Position
        TeleportInstant(wallPos + Vector3.new(0, 3, 0))
    end
end)

-- === XỬ LÝ CHARACTER ===
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if (isFarming or isFarmingLV) and wall then
        local wallPos = wall:GetPrimaryPartCFrame().Position
        TeleportInstant(wallPos + Vector3.new(0, 3, 0))
    end
end)

-- === TAB ANTI ===
local AntiTab = Window:Tab({
    Title = "Anti-comprehensive & Sound",
    Icon = "rbxassetid://6031090994"
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

-- === HÀM PHÁT ÂM THANH ===
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

-- === HÀM CHỐNG AFK ===
function StartAntiAFK()
    if isAntiAFK then return end
    isAntiAFK = true
    
    antiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiAFK then return end
        local timeSinceLastMove = tick() - lastMoveTime
        if timeSinceLastMove > 600 and character and humanoidRootPart then
            local currentPos = humanoidRootPart.Position
            humanoidRootPart.CFrame = CFrame.new(currentPos + Vector3.new(0, 0.1, 0))
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

-- === HÀM AUTO REJOINED ===
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

-- === HÀM ANTI-BANNED ===
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

-- === HÀM ANTI-ERROR ===
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

-- === HÀM SOUND DEAD ===
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

-- === HÀM SOUND WIN ===
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

-- === TẠO TOGGLE ANTI ===
AntiGroup:Toggle({
    Title = "Anti-AFK",
    Desc = "Chống mã lỗi 20 phút",
    Default = false,
    Callback = function(state)
        if state then pcall(StartAntiAFK) else pcall(StopAntiAFK) end
    end
})

AntiGroup:Toggle({
    Title = "Auto Rejoined",
    Desc = "Tự động tham gia lại nếu gặp mã lỗi",
    Default = false,
    Callback = function(state)
        if state then pcall(StartAutoRejoined) else pcall(StopAutoRejoined) end
    end
})

AntiGroup:Toggle({
    Title = "Anti-Banned",
    Desc = "Chống banned từ server",
    Default = false,
    Callback = function(state)
        if state then pcall(StartAntiBanned) else pcall(StopAntiBanned) end
    end
})

AntiGroup:Toggle({
    Title = "Anti-Error code",
    Desc = "Chống tất cả mã lỗi từ Roblox, Server và Admin",
    Default = false,
    Callback = function(state)
        if state then pcall(StartAntiError) else pcall(StopAntiError) end
    end
})

AntiGroup:Toggle({
    Title = "Sound Dead/Defeated",
    Desc = "Tự động phát nhạc khi chết hoặc bị hạ gục bởi Next Bot",
    Default = false,
    Callback = function(state)
        if state then pcall(StartSoundDead) else pcall(StopSoundDead) end
    end
})

AntiGroup:Toggle({
    Title = "Sound Survive/Win",
    Desc = "Tự động phát nhạc khi thắng hoặc được hồi sinh",
    Default = false,
    Callback = function(state)
        if state then pcall(StartSoundWin) else pcall(StopSoundWin) end
    end
})

AntiGroup:Toggle({
    Title = "Auto Start the script",
    Desc = "Tự động khởi động lại script nếu bị kick hoặc mã lỗi",
    Default = false,
    Callback = function(state)
        isAutoStart = state
    end
})

-- === TAB SETTINGS ===
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "rbxassetid://6031090994"
})

local SettingsGroup = SettingsTab:Group({
    Title = "Theme Settings",
    Side = "left"
})

-- === DROPDOWN CHỌN THEME ===
local selectedTheme = "Dark"
SettingsGroup:Dropdown({
    Title = "Chọn Theme",
    Desc = "Chọn theme cho WindUI Library (16 themes có sẵn)",
    Default = "Dark",
    Options = THEMES,
    Callback = function(option)
        selectedTheme = option
    end
})

-- === BUTTON ĐẶT THEME ===
SettingsGroup:Button({
    Title = "Đặt Theme",
    Desc = "Áp dụng theme đã chọn và khởi động lại script",
    Callback = function()
        if not selectedTheme or selectedTheme == "" then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Lỗi",
                Text = "❗ Vui lòng chọn theme trước khi đặt!",
                Duration = 3
            })
            return
        end
        
        CONFIG.CURRENT_THEME = selectedTheme
        
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
        
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PhongScriptDev/Script_Evade/refs/heads/main/NexusHub.lua"))()
    end
})

-- === BUTTON RESTART SCRIPT ===
SettingsGroup:Button({
    Title = "Restart the script",
    Desc = "Khởi động lại toàn bộ script",
    Callback = function()
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PhongScriptDev/Script_Evade/refs/heads/main/NexusHub.lua"))()
    end
})

-- === BUTTON DESTROY UI ===
SettingsGroup:Button({
    Title = "Destroy the UI",
    Desc = "Xóa UI mà không khởi động lại",
    Callback = function()
        if Window and Window.MainFrame then
            Window.MainFrame:Destroy()
        end
    end
})

print("✅ Nexus Hub đã tải thành công!")
