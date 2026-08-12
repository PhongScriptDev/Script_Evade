local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ===== PHÁT NHẠC KHI KHỞI ĐỘNG =====
local function PlayStartupMusic()
    local soundId = "rbxassetid://1357900029" -- Thay ID nhạc của bạn vào đây
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 10
    sound.Looped = false
    sound.Parent = game.Workspace
    
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    print("Đã phát nhạc chào mừng!")
end

PlayStartupMusic()


local window = Rayfield:CreateWindow({
    name = "✨ Nexus Hub",
    subtitle = "Created by: Nate & Ngọt",
    theme = "Frost",
})


window:Notify({
    title = "🔔 Notify Running...",
    content = "The UI Library Script Ran Successfully!",
    duration = 5,
})


-- ===== TẠO TAG VERSION =====
local versionTag = window:CreateTag({
    text = "⚡ Version: 2.1.7",
    color = Color3.fromRGB(100, 200, 255),
})


-- ===== TẠO TAG FPS =====
local fpsTag = window:CreateTag({
    text = "FPS: 0",
    color = Color3.fromRGB(80, 200, 120),
})

-- ===== HÀM CẬP NHẬT FPS =====
local function UpdateFpsTag()
    local lastTime = tick()
    local frameCount = 0
    
    game:GetService("RunService").Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        
        if deltaTime >= 0.5 then
            local fps = frameCount / deltaTime
            frameCount = 0
            lastTime = currentTime
            
            local roundedFps = math.floor(fps + 0.5)
            
            local color
            if roundedFps >= 55 then
                color = Color3.fromRGB(80, 200, 120)
            elseif roundedFps >= 40 and roundedFps < 55 then
                color = Color3.fromRGB(255, 175, 15)
            else
                color = Color3.fromRGB(255, 50, 50)
            end
            
            pcall(function()
                fpsTag:Set({
                    text = "FPS: " .. roundedFps,
                    color = color
                })
            end)
        end
    end)
end

UpdateFpsTag()

-- ===== TẠO TAB =====
local farmTab = window:CreateTab({
    name = "Farm Handmade",
    icon = "rbxassetid://93364949241311"
})

-- ===== BIẾN CHO FARM EVENT =====
local isFarming = false
local wallModel = nil
local isTeleporting = false
local retryCount = 0
local maxRetry = 3
local isWaitingForItem = false
local currentTarget = nil
local farmEventToggle = nil
local isScanning = false
local isOnWall = false
local isWaitingForRound = false

-- ===== BIẾN CHO FARM LV =====
local isFarmingLv = false
local wallModelLv = nil
local isTeleportingLv = false
local farmLvToggle = nil
local isOnWallLv = false

-- Vị trí tường cố định
local WALL_POSITION = Vector3.new(10000, -500, 10000)

-- ===== HÀM THÔNG BÁO RAYFIELD GEN2 =====
local function Notify(title, content, duration)
    duration = duration or 3
    pcall(function()
        window:Notify({
            title = title,
            content = content,
            duration = duration,
        })
    end)
end

-- ===== HÀM TOAST RAYFIELD GEN2 =====
local function Toast(title, subtitle, duration)
    duration = duration or 2
    pcall(function()
        window:Toast({
            title = title,
            subtitle = subtitle,
            duration = duration,
        })
    end)
end

-- ============================================
-- ===== FARM EVENT - TẠO TƯỜNG =====
-- ============================================
local function CreateWall()
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    
    Notify("Farm Event", "Đang tạo tường ở vị trí xa...", 2)
    
    wallModel = Instance.new("Model")
    wallModel.Name = "FarmWall"
    
    local wall = Instance.new("Part")
    wall.Size = Vector3.new(200, 1, 200)
    wall.Position = WALL_POSITION
    wall.Anchored = true
    wall.CanCollide = true
    wall.Transparency = 0
    wall.BrickColor = BrickColor.new("White")
    wall.Material = Enum.Material.SmoothPlastic
    wall.Parent = wallModel
    
    wallModel.Parent = game.Workspace
    
    Notify("Farm Event", "Tường đã được tạo thành công!", 2)
    Toast("✅ Tường", "Đã tạo xong", 2)
    
    return wallModel
end

-- ===== FARM LV - TẠO TƯỜNG =====
local function CreateWallLv()
    pcall(function()
        if wallModelLv then
            wallModelLv:Destroy()
            wallModelLv = nil
        end
    end)
    
    Notify("Farm Lv", "Đang tạo tường ở vị trí xa...", 2)
    
    wallModelLv = Instance.new("Model")
    wallModelLv.Name = "FarmWallLv"
    
    local wall = Instance.new("Part")
    wall.Size = Vector3.new(200, 1, 200)
    wall.Position = WALL_POSITION
    wall.Anchored = true
    wall.CanCollide = true
    wall.Transparency = 0
    wall.BrickColor = BrickColor.new("White")
    wall.Material = Enum.Material.SmoothPlastic
    wall.Parent = wallModelLv
    
    wallModelLv.Parent = game.Workspace
    
    Notify("Farm Lv", "Tường đã được tạo thành công!", 2)
    Toast("✅ Tường Lv", "Đã tạo xong", 2)
    
    return wallModelLv
end

-- ============================================
-- ===== TELEPORT CHUNG =====
-- ============================================
local function TeleportWithEmote(position, cframe, isWall, isLv)
    if isLv then
        if isTeleportingLv then return end
        isTeleportingLv = true
    else
        if isTeleporting then return end
        isTeleporting = true
    end
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        if isLv then
            isTeleportingLv = false
        else
            isTeleporting = false
        end
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then
        if isLv then
            isTeleportingLv = false
        else
            isTeleporting = false
        end
        return
    end
    
    local prefix = isLv and "Farm Lv" or "Farm Event"
    if isWall then
        Toast("🏠 " .. prefix, "Đang teleport đến tường...", 2)
    else
        Toast("🔄 " .. prefix, "Đang teleport đến Bubble...", 2)
    end
    
    pcall(function()
        if humanoid:FindFirstChild("Animator") then
            local animator = humanoid.Animator
            local emote = Instance.new("Animation")
            emote.AnimationId = "rbxassetid://5077725058"
            local emoteTrack = animator:LoadAnimation(emote)
            emoteTrack:Play()
            
            if cframe then
                humanoidRootPart.CFrame = cframe
            else
                humanoidRootPart.CFrame = CFrame.new(position)
            end
            
            task.wait(0.05)
            emoteTrack:Stop()
        else
            humanoid.Sit = true
            task.wait(0.05)
            
            if cframe then
                humanoidRootPart.CFrame = cframe
            else
                humanoidRootPart.CFrame = CFrame.new(position)
            end
            
            task.wait(0.05)
            humanoid.Sit = false
        end
    end)
    
    task.wait(0.05)
    
    if isLv then
        isTeleportingLv = false
    else
        isTeleporting = false
    end
end

-- ============================================
-- ===== FARM EVENT - TELEPORT ĐẾN TƯỜNG =====
-- ============================================
local function TeleportToWall()
    if not wallModel then return end
    
    local pos = wallModel:GetPivot().Position
    local targetPos = Vector3.new(pos.X, pos.Y + 1, pos.Z)
    
    TeleportWithEmote(targetPos, nil, true, false)
end

-- ============================================
-- ===== FARM EVENT - TELEPORT ĐẾN BUBBLE =====
-- ============================================
local function TeleportToBubble(position, cframe)
    TeleportWithEmote(position, cframe, false, false)
end

-- ============================================
-- ===== FARM LV - TELEPORT ĐẾN TƯỜNG =====
-- ============================================
local function TeleportToWallLv()
    if not wallModelLv then return end
    
    local pos = wallModelLv:GetPivot().Position
    local targetPos = Vector3.new(pos.X, pos.Y + 1, pos.Z)
    
    TeleportWithEmote(targetPos, nil, true, true)
end

-- ============================================
-- ===== FARM EVENT - PHÁT HIỆN XUỐNG TƯỜNG =====
-- ============================================
local function CheckIfFallOffWall()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not wallModel then return end
    
    local wallPos = wallModel:GetPivot().Position
    local posY = humanoidRootPart.Position.Y
    
    -- Nếu người chơi xuống dưới tường (Y thấp hơn tường)
    if posY < wallPos.Y - 1 then
        isOnWall = false
        Notify("Farm Event", "⚠️ Phát hiện đã xuống tường! Đang teleport lại...", 2)
        Toast("⚠️ Xuống tường", "Đang teleport lại...", 2)
        TeleportToWall()
        task.wait(0.5)
        isOnWall = true
        Toast("✅ Đã teleport", "Lên tường thành công", 2)
    end
end

-- ============================================
-- ===== FARM LV - PHÁT HIỆN XUỐNG TƯỜNG =====
-- ============================================
local function CheckIfFallOffWallLv()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not wallModelLv then return end
    
    local wallPos = wallModelLv:GetPivot().Position
    local posY = humanoidRootPart.Position.Y
    
    if posY < wallPos.Y - 1 then
        isOnWallLv = false
        Notify("Farm Lv", "⚠️ Phát hiện đã xuống tường! Đang teleport lại...", 2)
        Toast("⚠️ Xuống tường", "Đang teleport lại...", 2)
        TeleportToWallLv()
        task.wait(0.5)
        isOnWallLv = true
        Toast("✅ Đã teleport", "Lên tường thành công", 2)
    end
end

-- ============================================
-- ===== FARM EVENT - KIỂM TRA VÒNG CHƠI =====
-- ============================================
local function CheckRoundStatus()
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local gameState = game:GetService("ReplicatedStorage"):FindFirstChild("GameState")
    if gameState then
        local state = gameState.Value
        if state == "Waiting" or state == "Ended" then
            return false, "Đang chờ vòng mới..."
        end
    end
    
    local voteTime = game:GetService("ReplicatedStorage"):FindFirstChild("VoteTime")
    if voteTime and voteTime.Value > 0 then
        return false, "Đang trong thời gian bình chọn..."
    end
    
    return true, "Sẵn sàng farm!"
end

-- ============================================
-- ===== FARM EVENT - TÌM BUBBLE =====
-- ============================================
local function FindBubbles()
    if isScanning then return {} end
    isScanning = true
    
    local foundItems = {}
    
    Notify("Farm Event", "🔍 Đang quét toàn bộ map để tìm Bubble...", 2)
    Toast("🔍 Quét map", "Đang tìm Bubble...", 2)
    
    local allParts = game.Workspace:GetDescendants()
    local player = game.Players.LocalPlayer
    
    for _, obj in ipairs(allParts) do
        if obj:IsA("BasePart") and obj.Parent then
            if obj.Name == "Bubble" then
                local position = obj.Position
                local cframe = obj.CFrame
                
                if position and position.Magnitude > 0 then
                    local isCharacter = false
                    local currentParent = obj.Parent
                    while currentParent do
                        if currentParent:IsA("Model") and currentParent:FindFirstChild("Humanoid") then
                            isCharacter = true
                            break
                        end
                        currentParent = currentParent.Parent
                    end
                    
                    local isMyWall = false
                    if wallModel and obj.Parent == wallModel then
                        isMyWall = true
                    end
                    
                    if not isCharacter and not isMyWall then
                        table.insert(foundItems, {
                            Name = "Bubble",
                            Position = position,
                            CFrame = cframe,
                            Object = obj,
                            Parent = obj.Parent
                        })
                    end
                end
            end
        end
    end
    
    if player and player.Character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            table.sort(foundItems, function(a, b)
                local distA = (a.Position - rootPart.Position).Magnitude
                local distB = (b.Position - rootPart.Position).Magnitude
                return distA < distB
            end)
        end
    end
    
    Notify("Farm Event", string.format("✅ Đã tìm thấy %d Bubble trong map!", #foundItems), 2)
    Toast("✅ Tìm thấy", #foundItems .. " Bubble", 2)
    
    isScanning = false
    return foundItems
end

-- ============================================
-- ===== FARM EVENT - MAIN LOOP =====
-- ============================================
local function FarmEventLoop()
    if not isFarming then return end
    
    -- Tạo tường nếu chưa có
    if not wallModel then
        CreateWall()
        task.wait(1)
    end
    
    -- Teleport lên tường nếu chưa ở trên tường
    if wallModel then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local wallPos = wallModel:GetPivot().Position
                local posY = rootPart.Position.Y
                
                if posY < wallPos.Y - 1 then
                    TeleportToWall()
                    task.wait(0.5)
                    isOnWall = true
                else
                    isOnWall = true
                end
            end
        end
    end
    
    -- Kiểm tra vòng chơi
    local canFarm, status = CheckRoundStatus()
    if not canFarm then
        if not isWaitingForRound then
            isWaitingForRound = true
            Notify("Farm Event", "⏳ " .. status, 2)
            Toast("⏳ Chờ", status, 2)
        end
        task.wait(2)
        if isFarming then
            FarmEventLoop()
        end
        return
    end
    isWaitingForRound = false
    
    -- Tìm Bubble
    local foundItems = FindBubbles()
    
    if #foundItems == 0 then
        Notify("Farm Event", "⏳ Không tìm thấy Bubble nào, đang chờ...", 2)
        Toast("⏳ Chờ Bubble", "Không có Bubble", 2)
        task.wait(2)
        if isFarming then
            FarmEventLoop()
        end
        return
    end
    
    -- Lấy Bubble gần nhất
    local target = foundItems[1]
    currentTarget = target
    
    if target then
        -- Kiểm tra nếu đang chờ Bubble biến mất
        if isWaitingForItem then
            if not target.Object or not target.Object.Parent then
                isWaitingForItem = false
                retryCount = 0
                Notify("Farm Event", "✅ Đã nhận Bubble thành công!", 2)
                Toast("✅ Nhận Bubble", "Thành công!", 2)
                TeleportToWall()
                task.wait(0.3)
                isOnWall = true
            else
                task.wait(0.5)
                if isFarming then
                    FarmEventLoop()
                end
                return
            end
        end
        
        -- TELEPORT ĐẾN BUBBLE
        Notify("Farm Event", "🔄 Đang teleport đến Bubble...", 2)
        Toast("🔄 Teleport", "Đến Bubble", 2)
        TeleportToBubble(target.Position, target.CFrame)
        task.wait(0.3)
        
        -- Kiểm tra đã nhận được chưa
        if not target.Object or not target.Object.Parent then
            Notify("Farm Event", "✅ Đã nhận Bubble thành công!", 2)
            Toast("✅ Nhận Bubble", "Thành công!", 2)
            retryCount = 0
            TeleportToWall()
            task.wait(0.3)
            isOnWall = true
        else
            -- Thử lại nếu thất bại
            if retryCount < maxRetry then
                retryCount = retryCount + 1
                Notify("Farm Event", string.format("❌ Nhận thất bại lần %d, thử lại...", retryCount), 2)
                Toast("❌ Thất bại", "Lần " .. retryCount, 2)
                task.wait(0.3)
                TeleportToBubble(target.Position, target.CFrame)
                task.wait(0.3)
                
                if not target.Object or not target.Object.Parent then
                    Notify("Farm Event", "✅ Đã nhận Bubble thành công!", 2)
                    Toast("✅ Nhận Bubble", "Thành công!", 2)
                    retryCount = 0
                    TeleportToWall()
                    task.wait(0.3)
                    isOnWall = true
                else
                    isWaitingForItem = true
                    Notify("Farm Event", "⏳ Đang chờ Bubble biến mất...", 2)
                    Toast("⏳ Chờ biến mất", "Đang chờ...", 2)
                    while isWaitingForItem and target.Object and target.Object.Parent do
                        task.wait(0.5)
                    end
                    if isWaitingForItem then
                        isWaitingForItem = false
                        retryCount = 0
                        Notify("Farm Event", "✅ Bubble đã biến mất!", 2)
                        Toast("✅ Biến mất", "Bubble đã biến mất", 2)
                        TeleportToWall()
                        task.wait(0.3)
                        isOnWall = true
                    end
                end
            else
                isWaitingForItem = true
                Notify("Farm Event", "⏳ Đang chờ Bubble biến mất...", 2)
                Toast("⏳ Chờ biến mất", "Đang chờ...", 2)
                while isWaitingForItem and target.Object and target.Object.Parent do
                    task.wait(0.5)
                end
                if isWaitingForItem then
                    isWaitingForItem = false
                    retryCount = 0
                    Notify("Farm Event", "✅ Bubble đã biến mất!", 2)
                    Toast("✅ Biến mất", "Bubble đã biến mất", 2)
                    TeleportToWall()
                    task.wait(0.3)
                    isOnWall = true
                end
            end
        end
    end
    
    task.wait(0.3)
    
    if isFarming then
        FarmEventLoop()
    end
end

-- ============================================
-- ===== START/STOP FARM EVENT =====
-- ============================================
local function StartFarmEvent()
    if isFarming then return end
    
    isFarming = true
    isWaitingForItem = false
    retryCount = 0
    isScanning = false
    isOnWall = false
    isWaitingForRound = false
    
    Notify("Farm Event", "🚀 Đang khởi động Farm Event...", 2)
    Toast("🚀 Khởi động", "Farm Event", 2)
    
    CreateWall()
    task.wait(1)
    TeleportToWall()
    task.wait(0.5)
    isOnWall = true
    Toast("✅ Sẵn sàng", "Bắt đầu farm!", 2)
    
    task.spawn(FarmEventLoop)
end

local function StopFarmEvent()
    isFarming = false
    currentTarget = nil
    isWaitingForItem = false
    retryCount = 0
    isScanning = false
    isOnWall = false
    isWaitingForRound = false
    
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    
    Notify("Farm Event", "🛑 Đã dừng Farm Event!", 2)
    Toast("🛑 Dừng", "Farm Event", 2)
end

-- ============================================
-- ===== FARM LV - MAIN LOOP (CHỈ ĐỨNG) =====
-- ============================================
local function FarmLvLoop()
    if not isFarmingLv then return end
    
    -- Tạo tường nếu chưa có
    if not wallModelLv then
        CreateWallLv()
        task.wait(1)
    end
    
    -- Teleport lên tường
    if wallModelLv then
        TeleportToWallLv()
        Notify("Farm Lv", "📍 Đang đứng tại tường chờ phần thưởng...", 2)
        Toast("📍 Đứng chờ", "Chờ phần thưởng...", 2)
        isOnWallLv = true
    end
    
    -- CHỈ ĐỨNG TRÊN TƯỜNG, KHÔNG LÀM GÌ KHÁC
    while isFarmingLv do
        task.wait(3)
        
        -- Kiểm tra nếu rời khỏi tường thì teleport lại
        CheckIfFallOffWallLv()
        
        -- Kiểm tra hết thời gian và phần thưởng
        pcall(function()
            local notifications = game:GetService("StarterGui"):GetChildren()
            for _, notif in ipairs(notifications) do
                if notif:IsA("ScreenGui") and notif:FindFirstChild("Timer") then
                    local timer = notif.Timer
                    if timer and timer.Text and string.find(timer.Text, "Hết thời gian") then
                        Notify("Farm Lv", "⏰ Đã hết thời gian!", 3)
                        Toast("⏰ Hết giờ", "Kiểm tra phần thưởng", 3)
                        
                        local rewards = game:GetService("ReplicatedStorage"):FindFirstChild("Rewards")
                        if rewards then
                            local playerReward = rewards:FindFirstChild(game.Players.LocalPlayer.Name)
                            if playerReward then
                                Notify("Farm Lv", string.format("🎁 Phần thưởng của bạn: %s", playerReward.Value), 5)
                                Toast("🎁 Phần thưởng", tostring(playerReward.Value), 5)
                            end
                        end
                        break
                    end
                end
            end
        end)
    end
end

-- ============================================
-- ===== START/STOP FARM LV =====
-- ============================================
local function StartFarmLv()
    if isFarmingLv then return end
    if isFarming then
        StopFarmEvent()
    end
    isFarmingLv = true
    isOnWallLv = false
    
    Notify("Farm Lv", "🚀 Đang khởi động Farm Lv...", 2)
    Toast("🚀 Khởi động", "Farm Lv", 2)
    
    CreateWallLv()
    task.wait(1)
    TeleportToWallLv()
    task.wait(0.5)
    isOnWallLv = true
    Toast("✅ Sẵn sàng", "Đứng chờ phần thưởng", 2)
    
    task.spawn(FarmLvLoop)
end

local function StopFarmLv()
    isFarmingLv = false
    isOnWallLv = false
    pcall(function()
        if wallModelLv then
            wallModelLv:Destroy()
            wallModelLv = nil
        end
    end)
    Notify("Farm Lv", "🛑 Đã dừng Farm Lv!", 2)
    Toast("🛑 Dừng", "Farm Lv", 2)
end

-- ============================================
-- ===== TẠO TOGGLE =====
-- ============================================
farmEventToggle = farmTab:CreateToggle({
    name = "Farm Event",
    flag = "FarmEventToggle",
    callback = function(value)
        if value then
            StartFarmEvent()
        else
            StopFarmEvent()
        end
    end,
})

farmLvToggle = farmTab:CreateToggle({
    name = "Farm Lv",
    flag = "FarmLvToggle",
    callback = function(value)
        if value then
            StartFarmLv()
        else
            StopFarmLv()
        end
    end,
})

-- ============================================
-- ===== KIỂM TRA XUỐNG TƯỜNG LIÊN TỤC =====
-- ============================================
game:GetService("RunService").Heartbeat:Connect(function()
    if isFarming then
        CheckIfFallOffWall()
    end
    
    if isFarmingLv then
        CheckIfFallOffWallLv()
    end
end)

-- ============================================
-- ===== XỬ LÝ LOAD MAP =====
-- ============================================
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("LoadCharacter"):Connect(function()
    if isFarming then
        task.wait(2)
        CreateWall()
        task.wait(1)
        TeleportToWall()
    end
    
    if isFarmingLv then
        task.wait(2)
        CreateWallLv()
        task.wait(1)
        TeleportToWallLv()
    end
end)

print("Farm Handmade Pro đã được tải thành công!")
print("Sử dụng Rayfield Gen2 - Nhấn RightControl để mở UI")
