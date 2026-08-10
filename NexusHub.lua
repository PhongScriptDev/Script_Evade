-- ============================================
-- NEXUS HUB | MAKE BY: NATE & NGỌT
-- SUBTITLE: LOADING
-- ============================================

-- === TẢI WINDUI LIBRARY (LINK CHÍNH XÁC TỪ TRANG CHỦ) ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- === THÔNG BÁO KHỞI ĐỘNG ===
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✔️ Running Script...",
    Text = "Khởi động script thành công!",
    Duration = 5,
    Icon = "rbxassetid://6031090938"
})

-- === TẠO WINDOW ===
local Window = Library:CreateWindow({
    Title = "Nexus Hub | Make By: Nate & Ngọt",
    SubTitle = "Loading",
    Size = UDim2.fromOffset(600, 500),
    Center = true
})

-- === CẤU HÌNH THEME ===
local CONFIG = {
    VIDEO_ID = "none",
    IMAGE_ID = "none",
    MUSIC_ID = "108531350726198",
    GOOGLE_DRIVE_URL = "none",
    GIF_URL = "https://media.tenor.com/FHTOu1fN6DcAAAAM/angry-anime.gif",
    SOUND_DEAD_ID = "1357900029",
    SOUND_WIN_ID = "113326842510307"
}

-- === LẤY DỮ LIỆU TỪ VIDEO ===
local function GetVideoData(videoId)
    if videoId == "none" then return nil end
    
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:HttpGet("https://www.roblox.com/video-thumbnails?videoIds=" .. videoId)
        )
    end)
    
    if success and data and data.data and #data.data > 0 then
        local videoInfo = data.data[1]
        return {
            Title = videoInfo.title or "Video Title",
            Creator = videoInfo.creatorName or "Unknown Creator",
            Thumbnail = videoInfo.thumbnailUrl or "",
            Duration = videoInfo.duration or 0,
            Views = videoInfo.viewCount or 0
        }
    end
    return nil
end

local videoData = GetVideoData(CONFIG.VIDEO_ID)

-- === THEME ===
local Theme = Window:Theme({
    Background = Color3.fromRGB(15, 15, 20),
    Glow = Color3.fromRGB(0, 200, 255),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 170)
})

-- === TẠO BACKGROUND TỪ HÌNH ẢNH ===
if CONFIG.IMAGE_ID ~= "none" then
    pcall(function()
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.fromScale(1, 1)
        imageLabel.Image = "rbxassetid://" .. CONFIG.IMAGE_ID
        imageLabel.BackgroundTransparency = 1
        imageLabel.ImageTransparency = 0.3
        imageLabel.ScaleType = Enum.ScaleType.Crop
        imageLabel.Parent = Window.MainFrame
    end)
end

-- === TẠO BACKGROUND TỪ GIF ===
if CONFIG.GIF_URL ~= "none" then
    pcall(function()
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.fromScale(1, 1)
        imageLabel.Image = CONFIG.GIF_URL
        imageLabel.BackgroundTransparency = 1
        imageLabel.ImageTransparency = 0.3
        imageLabel.ScaleType = Enum.ScaleType.Crop
        imageLabel.Parent = Window.MainFrame
    end)
end

-- === PHÁT NHẠC ===
if CONFIG.MUSIC_ID ~= "none" then
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. CONFIG.MUSIC_ID
        sound.Volume = 0.3
        sound.Looped = true
        sound.Parent = game:GetService("Players").LocalPlayer
        sound:Play()
    end)
end

-- === HIỆU ỨNG CHUYỂN ĐỘNG TỪ VIDEO ===
local motionElements = {}
local isMotionRunning = false
local motionSpeed = 1
local motionStyle = "Wave"

function CreateMotionFromVideo()
    for _, obj in pairs(motionElements) do
        pcall(function() obj:Destroy() end)
    end
    motionElements = {}
    
    if not videoData then return end
    
    local numElements = 8 + math.floor(videoData.Duration / 10)
    
    for i = 1, math.min(numElements, 20) do
        pcall(function()
            local angle = (i - 1) * (math.pi * 2 / numElements)
            local radius = 120 + math.sin(i * 1.5) * 30
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromOffset(25, 25)
            frame.BackgroundColor3 = Theme.Accent
            frame.BackgroundTransparency = 0.5
            frame.BorderSizePixel = 0
            frame.Position = UDim2.fromOffset(
                300 + math.cos(angle) * radius,
                250 + math.sin(angle) * radius
            )
            frame.Parent = Window.MainFrame
            
            local glow = Instance.new("Frame")
            glow.Size = UDim2.fromOffset(50, 50)
            glow.BackgroundColor3 = Theme.Glow
            glow.BackgroundTransparency = 0.8
            glow.BorderSizePixel = 0
            glow.Position = UDim2.fromOffset(-12, -12)
            glow.Parent = frame
            
            if videoData.Thumbnail and videoData.Thumbnail ~= "" then
                local image = Instance.new("ImageLabel")
                image.Size = UDim2.fromOffset(20, 20)
                image.Image = videoData.Thumbnail
                image.BackgroundTransparency = 1
                image.Position = UDim2.fromOffset(2, 2)
                image.Parent = frame
            end
            
            table.insert(motionElements, {
                Frame = frame,
                Glow = glow,
                Angle = angle,
                Radius = radius,
                Phase = i / numElements * math.pi * 2,
                Speed = 0.5 + math.random() * 0.5
            })
        end)
    end
end

function UpdateMotion(deltaTime)
    if not isMotionRunning then return end
    
    local time = tick() * 0.4 * motionSpeed
    
    for _, obj in pairs(motionElements) do
        pcall(function()
            local angleOffset = 0
            local radiusOffset = 0
            local sizeMultiplier = 1
            local transparencyOffset = 0
            
            if motionStyle == "Wave" then
                angleOffset = math.sin(time + obj.Phase) * 0.3
                radiusOffset = math.sin(time * 0.8 + obj.Phase) * 15
            elseif motionStyle == "Pulse" then
                angleOffset = 0
                radiusOffset = math.sin(time * 1.5 + obj.Phase) * 25
                sizeMultiplier = 1 + math.sin(time * 2 + obj.Phase) * 0.3
            elseif motionStyle == "Glow" then
                angleOffset = math.sin(time * 0.7 + obj.Phase) * 0.2
                radiusOffset = math.cos(time * 0.6 + obj.Phase) * 10
                transparencyOffset = math.sin(time + obj.Phase) * 0.15
                obj.Glow.Size = UDim2.fromOffset(
                    50 + math.sin(time + obj.Phase) * 20,
                    50 + math.sin(time + obj.Phase) * 20
                )
            elseif motionStyle == "Spin" then
                angleOffset = time * 0.2
                radiusOffset = math.sin(time * 0.5 + obj.Phase) * 20
            elseif motionStyle == "Bounce" then
                angleOffset = 0
                radiusOffset = math.abs(math.sin(time * 1.2 + obj.Phase)) * 30
            end
            
            local currentAngle = obj.Angle + time * 0.2 * obj.Speed + angleOffset
            local currentRadius = obj.Radius + radiusOffset
            
            obj.Frame.Position = UDim2.fromOffset(
                300 + math.cos(currentAngle) * currentRadius,
                250 + math.sin(currentAngle) * currentRadius
            )
            
            if sizeMultiplier ~= 1 then
                local baseSize = 25
                obj.Frame.Size = UDim2.fromOffset(baseSize * sizeMultiplier, baseSize * sizeMultiplier)
            end
            
            if transparencyOffset ~= 0 then
                obj.Frame.BackgroundTransparency = 0.5 + transparencyOffset
                obj.Glow.BackgroundTransparency = 0.8 + transparencyOffset * 0.5
            end
            
            obj.Frame.Rotation = (obj.Frame.Rotation or 0) + deltaTime * 30 * motionSpeed
        end)
    end
end

function StartMotion()
    isMotionRunning = true
    CreateMotionFromVideo()
    
    game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        UpdateMotion(deltaTime)
    end)
end

if CONFIG.VIDEO_ID ~= "none" then
    StartMotion()
end

-- === THÔNG TIN VIDEO ===
if videoData then
    pcall(function()
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.fromOffset(200, 60)
        infoFrame.Position = UDim2.fromOffset(200, 420)
        infoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        infoFrame.BackgroundTransparency = 0.5
        infoFrame.BorderSizePixel = 0
        infoFrame.Parent = Window.MainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.fromOffset(190, 25)
        titleLabel.Position = UDim2.fromOffset(5, 5)
        titleLabel.Text = videoData.Title:sub(1, 30) .. (videoData.Title:len() > 30 and "..." or "")
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = "Left"
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = infoFrame
        
        local creatorLabel = Instance.new("TextLabel")
        creatorLabel.Size = UDim2.fromOffset(190, 20)
        creatorLabel.Position = UDim2.fromOffset(5, 30)
        creatorLabel.Text = "🎨 " .. videoData.Creator
        creatorLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
        creatorLabel.TextSize = 12
        creatorLabel.TextXAlignment = "Left"
        creatorLabel.BackgroundTransparency = 1
        creatorLabel.Parent = infoFrame
    end)
end

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
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "none",
    "Bubble",
    "none",
    "none"
}

-- === BIẾN TOÀN CỤ ===
local isFarming = false
local isFarmingLV = false
local wall = nil
local wallParts = {}
local farmConnection = nil
local farmLVConnection = nil
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart") or nil
local lastTeleportPosition = nil
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
    lastTeleportPosition = teleportPos
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
        lastTeleportPosition = targetPos
    end)
    
    isTeleporting = false
    return success
end

-- === HÀM KIỂM TRA TRÊN TƯỜNG ===
function CheckPlayerOnWall()
    if not wall or not humanoidRootPart then return false end
    local playerPos = humanoidRootPart.Position
    local wallPos = wall:GetPrimaryPartCFrame().Position
    local distance = (playerPos - wallPos).Magnitude
    return distance < 15
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎯 Farm Event",
        Text = "⚡ Đang khởi động Farm Event...",
        Duration = 2
    })
    
    CreateWall()
    
    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarming then return end
        
        if not CheckPlayerOnWall() and wall then
            local wallPos = wall:GetPrimaryPartCFrame().Position
            TeleportInstant(wallPos + Vector3.new(0, 3, 0))
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🔄 Teleporting",
                Text = "✅ Teleporting lại tường thành công!",
                Duration = 1
            })
        end
        
        local items, noItems = ScanEventItems()
        
        if noItems then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⏹️ Dừng Farm",
                Text = "📭 Không còn sự kiện để farm!",
                Duration = 3
            })
            StopFarmEvent()
            return
        end
        
        if #items > 0 then
            for _, item in pairs(items) do
                if item and item.Parent then
                    local itemPos = item.Position
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "🎯 Teleporting",
                        Text = "🎯 Teleporting đến vật phẩm sự kiện...",
                        Duration = 1
                    })
                    
                    TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                    wait(0.1)
                    
                    if item and item.Parent then
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "⚠️ Thất bại",
                            Text = "❌ Nhặt vật phẩm thất bại! Teleporting thử lại...",
                            Duration = 2
                        })
                        wait(0.5)
                        
                        TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                        wait(0.1)
                        
                        if item and item.Parent then
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "⏳ Đang chờ",
                                Text = "⏳ Chờ và thử lại...",
                                Duration = 2
                            })
                            wait(2)
                            
                            TeleportInstant(itemPos + Vector3.new(0, 2, 0))
                            wait(0.1)
                        end
                    end
                    
                    if not item or not item.Parent then
                        local remainingItems = ScanEventItems()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "✅ Thành công",
                            Text = "✅ Nhặt vật phẩm thành công! Số lượng còn lại: " .. #remainingItems,
                            Duration = 2
                        })
                        
                        local wallPos = wall:GetPrimaryPartCFrame().Position
                        TeleportInstant(wallPos + Vector3.new(0, 3, 0))
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "🔄 Teleporting",
                            Text = "✅ Teleporting lại tường thành công!",
                            Duration = 1
                        })
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
    if not isFarmingLV then
        DestroyWall()
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⏹️ Dừng Farm",
        Text = "🛑 Đã dừng Farm Event!",
        Duration = 2
    })
end

-- === HÀM FARM LV ===
function StartFarmLV()
    if isFarmingLV then return end
    
    isFarmingLV = true
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎯 Farm LV",
        Text = "⚡ Đang khởi động Farm LV...",
        Duration = 2
    })
    
    CreateWall()
    
    farmLVConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isFarmingLV then return end
        
        if not CheckPlayerOnWall() and wall then
            local wallPos = wall:GetPrimaryPartCFrame().Position
            TeleportInstant(wallPos + Vector3.new(0, 3, 0))
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🔄 Teleporting",
                Text = "✅ Teleporting lại tường thành công!",
                Duration = 1
            })
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
    
    if not isFarming then
        DestroyWall()
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⏹️ Dừng Farm LV",
        Text = "🛑 Đã dừng Farm LV!",
        Duration = 2
    })
end

-- === TẠO TOGGLE FARM EVENT ===
FarmGroup:Toggle({
    Title = "Farm Event",
    Desc = "Bật/tắt farm vật phẩm sự kiện",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                StartFarmEvent()
            end)
        else
            pcall(function()
                StopFarmEvent()
            end)
        end
    end
})

-- === TẠO TOGGLE FARM LV ===
FarmGroup:Toggle({
    Title = "Farm Lv",
    Desc = "Bật/tắt farm level tự động",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                StartFarmLV()
            end)
        else
            pcall(function()
                StopFarmLV()
            end)
        end
    end
})

-- === XỬ LÝ RỜI KHỎI TƯỜNG ===
game:GetService("RunService").Heartbeat:Connect(function()
    if (isFarming or isFarmingLV) and wall then
        if not CheckPlayerOnWall() then
            local wallPos = wall:GetPrimaryPartCFrame().Position
            TeleportInstant(wallPos + Vector3.new(0, 3, 0))
        end
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
        sound.Volume = volume or 0.5
        sound.Parent = game:GetService("Players").LocalPlayer
        sound:Play()
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔊 Sound",
            Text = "🎵 Đang phát âm thanh!",
            Duration = 2
        })
        
        game:GetService("Debris"):AddItem(sound, 10)
    end)
end

-- === HÀM CHỐNG AFK ===
function StartAntiAFK()
    if isAntiAFK then return end
    isAntiAFK = true
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🛡️ Anti-AFK",
        Text = "✅ Đã bật chống AFK (20 phút)!",
        Duration = 2
    })
    
    antiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiAFK then return end
        
        local timeSinceLastMove = tick() - lastMoveTime
        if timeSinceLastMove > 600 then
            if character and humanoidRootPart then
                local currentPos = humanoidRootPart.Position
                humanoidRootPart.CFrame = CFrame.new(currentPos + Vector3.new(0, 0.1, 0))
                lastMoveTime = tick()
            end
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔄 Auto Rejoined",
        Text = "✅ Đã bật tự động tham gia lại!",
        Duration = 2
    })
    
    game:GetService("RunService").Heartbeat:Connect(function()
        if not isAutoRejoined then return end
        
        if not game:IsLoaded() or game:GetService("Players").LocalPlayer == nil then
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🛡️ Anti-Banned",
        Text = "✅ Đã bật chống banned từ server!",
        Duration = 2
    })
    
    local bannedDetected = false
    
    game:GetService("RunService").Heartbeat:Connect(function()
        if not isAntiBanned then return end
        
        local success = pcall(function()
            local player = game:GetService("Players").LocalPlayer
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🛡️ Anti-Error Code",
        Text = "✅ Đã bật chống tất cả mã lỗi!",
        Duration = 2
    })
    
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔊 Sound Dead/Defeated",
        Text = "✅ Đã bật phát hiện chết/hạ gục!",
        Duration = 2
    })
    
    soundDeadConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isSoundDead then return end
        
        pcall(function()
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local currentHealth = humanoid.Health
                
                if currentHealth <= 0 and not isDead then
                    isDead = true
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "💀 Đã chết/Hạ gục",
                        Text = "🔊 Đang phát âm thanh Dead/Defeated!",
                        Duration = 3
                    })
                    
                    if CONFIG.SOUND_DEAD_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_DEAD_ID, 0.5)
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
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔊 Sound Survive/Win",
        Text = "✅ Đã bật phát hiện thắng/sống sót!",
        Duration = 2
    })
    
    soundWinConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isSoundWin then return end
        
        pcall(function()
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local currentHealth = humanoid.Health
                
                if isDead and currentHealth > 0 then
                    isDead = false
                    isWin = true
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "🎉 Thắng/Sống sót",
                        Text = "🔊 Đang phát âm thanh Survive/Win!",
                        Duration = 3
                    })
                    
                    if CONFIG.SOUND_WIN_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_WIN_ID, 0.5)
                    end
                    
                    wait(5)
                    isWin = false
                end
                
                local gameState = game:GetService("Workspace"):FindFirstChild("GameState")
                if gameState and gameState.Value == "Win" and not isWin then
                    isWin = true
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "🎉 Thắng vòng",
                        Text = "🔊 Đang phát âm thanh Win!",
                        Duration = 3
                    })
                    
                    if CONFIG.SOUND_WIN_ID ~= "none" then
                        PlaySound(CONFIG.SOUND_WIN_ID, 0.5)
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

-- === TẠO TOGGLE ANTI-AFK ===
AntiGroup:Toggle({
    Title = "Anti-AFK",
    Desc = "Chống mã lỗi 20 phút",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartAntiAFK() end)
        else
            pcall(function() StopAntiAFK() end)
        end
    end
})

-- === TẠO TOGGLE AUTO REJOINED ===
AntiGroup:Toggle({
    Title = "Auto Rejoined",
    Desc = "Tự động tham gia lại nếu gặp mã lỗi",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartAutoRejoined() end)
        else
            pcall(function() StopAutoRejoined() end)
        end
    end
})

-- === TẠO TOGGLE ANTI-BANNED ===
AntiGroup:Toggle({
    Title = "Anti-Banned",
    Desc = "Chống banned từ server",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartAntiBanned() end)
        else
            pcall(function() StopAntiBanned() end)
        end
    end
})

-- === TẠO TOGGLE ANTI-ERROR ===
AntiGroup:Toggle({
    Title = "Anti-Error code",
    Desc = "Chống tất cả mã lỗi từ Roblox, Server và Admin",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartAntiError() end)
        else
            pcall(function() StopAntiError() end)
        end
    end
})

-- === TẠO TOGGLE SOUND DEAD ===
AntiGroup:Toggle({
    Title = "Sound Dead/Defeated",
    Desc = "Tự động phát nhạc khi chết hoặc bị hạ gục bởi Next Bot",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartSoundDead() end)
        else
            pcall(function() StopSoundDead() end)
        end
    end
})

-- === TẠO TOGGLE SOUND WIN ===
AntiGroup:Toggle({
    Title = "Sound Survive/Win",
    Desc = "Tự động phát nhạc khi thắng hoặc được hồi sinh",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function() StartSoundWin() end)
        else
            pcall(function() StopSoundWin() end)
        end
    end
})

-- === ĐIỀU KHIỂN TỐC ĐỘ ===
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        motionSpeed = 2
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        motionSpeed = 1
    end
end)

print("✅ Nexus Hub đã tải thành công!")
