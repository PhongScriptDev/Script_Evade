local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ===== PHÁT NHẠC KHI KHỞI ĐỘNG =====
local function PlayStartupMusic()
    local soundId = "rbxassetid://9120263686" -- Thay ID nhạc của bạn vào đây
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5
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

-- ===== BIẾN TOÀN CỤC =====
local isFarming = false
local isFarmingLv = false
local wallModel = nil
local wallModelLv = nil
local isTeleporting = false
local isTeleportingLv = false
local retryCount = 0
local maxRetry = 2
local isWaitingForItem = false
local currentTarget = nil
local farmEventToggle = nil
local farmLvToggle = nil
local isScanning = false

-- Danh sách 20 vật phẩm (1 Bubble, 19 none)
local EventItems = {
    "Bubble",
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
    "none",
    "none"
}

-- ===== HÀM THÔNG BÁO =====
local function Notify(title, message, duration)
    duration = duration or 3
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Text = message,
            Duration = duration,
        })
    end)
end

-- ===== FARM EVENT - TẠO TƯỜNG HÌNH VUÔNG MÀU XANH NƯỚC =====
local function CreateWall()
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    
    Notify("Farm Event", "Đang tạo tường hình vuông...", 2)
    
    wallModel = Instance.new("Model")
    wallModel.Name = "FarmWall"
    
    -- Vị trí tường (xa nhưng không gây lag)
    local wallPosition = Vector3.new(0, -800, 0)
    
    -- Tạo tường hình vuông lớn màu xanh nước biển
    local wallSize = 150 -- Kích thước hình vuông
    
    -- Tạo mặt phẳng chính (hình vuông)
    local mainWall = Instance.new("Part")
    mainWall.Size = Vector3.new(wallSize, 5, wallSize) -- Hình vuông rộng
    mainWall.Position = wallPosition
    mainWall.Anchored = true
    mainWall.CanCollide = true
    mainWall.Transparency = 0
    mainWall.BrickColor = BrickColor.new("Bright blue") -- Màu xanh nước biển
    mainWall.Material = Enum.Material.SmoothPlastic
    mainWall.Parent = wallModel
    
    -- Tạo các cạnh viền xung quanh để tường chắc chắn hơn
    local edgeSize = 5
    local positions = {
        Vector3.new(0, 2.5, wallSize/2),
        Vector3.new(0, 2.5, -wallSize/2),
        Vector3.new(wallSize/2, 2.5, 0),
        Vector3.new(-wallSize/2, 2.5, 0),
    }
    
    for _, pos in ipairs(positions) do
        local edge = Instance.new("Part")
        edge.Size = Vector3.new(wallSize, edgeSize, edgeSize)
        edge.Position = wallPosition + pos
        edge.Anchored = true
        edge.CanCollide = true
        edge.Transparency = 0
        edge.BrickColor = BrickColor.new("Bright blue")
        edge.Material = Enum.Material.SmoothPlastic
        edge.Parent = wallModel
    end
    
    -- Thêm các trụ đỡ ở góc
    local cornerPositions = {
        Vector3.new(wallSize/2, -2.5, wallSize/2),
        Vector3.new(wallSize/2, -2.5, -wallSize/2),
        Vector3.new(-wallSize/2, -2.5, wallSize/2),
        Vector3.new(-wallSize/2, -2.5, -wallSize/2),
    }
    
    for _, pos in ipairs(cornerPositions) do
        local corner = Instance.new("Part")
        corner.Size = Vector3.new(10, 10, 10)
        corner.Position = wallPosition + pos
        corner.Anchored = true
        corner.CanCollide = true
        corner.Transparency = 0
        corner.BrickColor = BrickColor.new("Bright blue")
        corner.Material = Enum.Material.SmoothPlastic
        corner.Parent = wallModel
    end
    
    wallModel.Parent = game.Workspace
    
    Notify("Farm Event", "Tường hình vuông đã được tạo!", 2)
    
    -- Teleport người chơi lên tường
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(wallPosition + Vector3.new(0, 5, 0))
            Notify("Farm Event", "Đã teleport lên tường!", 2)
        end
    end
    
    return wallModel
end

-- ===== FARM EVENT - KIỂM TRA DANH SÁCH =====
local function CheckEventItemsList()
    local validItems = {}
    local noneCount = 0
    
    for _, item in ipairs(EventItems) do
        if item == "none" then
            noneCount = noneCount + 1
        else
            table.insert(validItems, item)
        end
    end
    
    if noneCount == #EventItems then
        return false, "Từ chối farm event vì hết sự kiện!", {}
    end
    
    return true, "Đang tìm Bubble...", validItems
end

-- ===== FARM EVENT - TÌM VẬT PHẨM (QUÉT TOÀN BỘ SERVER) =====
local function FindEventItems()
    if isScanning then return {} end
    isScanning = true
    
    local foundItems = {}
    local valid, _, validItems = CheckEventItemsList()
    
    if not valid then
        isScanning = false
        return foundItems
    end
    
    Notify("Farm Event", "Đang quét toàn bộ server để tìm Bubble...", 2)
    
    -- Quét toàn bộ workspace
    local allParts = game.Workspace:GetDescendants()
    local player = game.Players.LocalPlayer
    
    for _, obj in ipairs(allParts) do
        if obj:IsA("BasePart") and obj.Parent then
            for _, itemName in ipairs(validItems) do
                if obj.Name == itemName then
                    local position = obj.Position
                    local cframe = obj.CFrame
                    
                    if position and position.Magnitude > 0 then
                        -- Kiểm tra không phải là nhân vật
                        local isCharacter = false
                        local currentParent = obj.Parent
                        while currentParent do
                            if currentParent:IsA("Model") and currentParent:FindFirstChild("Humanoid") then
                                isCharacter = true
                                break
                            end
                            currentParent = currentParent.Parent
                        end
                        
                        -- Kiểm tra không phải là tường của chính mình
                        local isWall = false
                        if wallModel and obj.Parent == wallModel then
                            isWall = true
                        end
                        
                        if not isCharacter and not isWall then
                            table.insert(foundItems, {
                                Name = itemName,
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
    end
    
    -- Sắp xếp theo khoảng cách gần nhất
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
    
    Notify("Farm Event", string.format("Đã tìm thấy %d Bubble trong server!", #foundItems), 2)
    
    isScanning = false
    return foundItems
end

-- ===== FARM EVENT - TELEPORT CÓ EMOTE =====
local function TeleportToPosition(position, cframe, isWall)
    if isTeleporting then return end
    isTeleporting = true
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        isTeleporting = false
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then
        isTeleporting = false
        return
    end
    
    if isWall then
        Notify("Farm Event", "Đang teleport đến tường...", 1)
    else
        Notify("Farm Event", "Đang teleport đến Bubble...", 1)
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
            if cframe then
                humanoidRootPart.CFrame = cframe
            else
                humanoidRootPart.CFrame = CFrame.new(position)
            end
        end
    end)
    
    task.wait(0.05)
    isTeleporting = false
end

-- ===== FARM EVENT - KIỂM TRA VỊ TRÍ (TỰ ĐỘNG TELEPORT LÊN TƯỜNG) =====
local function CheckPlayerPosition()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Kiểm tra nếu người chơi rời khỏi tường (xuống dưới -500)
    if wallModel and humanoidRootPart.Position.Y < -500 then
        local wallPosition = wallModel:GetPivot().Position
        Notify("Farm Event", "Phát hiện rời khỏi tường, đang teleport lại...", 2)
        TeleportToPosition(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
    end
    
    -- Kiểm tra nếu người chơi ở quá xa tường
    if wallModel then
        local wallPosition = wallModel:GetPivot().Position
        local distance = (humanoidRootPart.Position - wallPosition).Magnitude
        if distance > 500 then
            Notify("Farm Event", "Phát hiện ở xa tường, đang teleport lại...", 2)
            TeleportToPosition(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
        end
    end
end

-- ===== FARM EVENT - MAIN LOOP =====
local function FarmEventLoop()
    if not isFarming then return end
    
    local valid, message = CheckEventItemsList()
    if not valid then
        Notify("Farm Event", message, 5)
        isFarming = false
        if farmEventToggle then
            pcall(function()
                farmEventToggle:SetValue(false)
            end)
        end
        return
    end
    
    -- Tạo tường nếu chưa có
    if not wallModel then
        CreateWall()
        task.wait(1)
    end
    
    -- Luôn kiểm tra vị trí người chơi
    CheckPlayerPosition()
    
    -- Tìm vật phẩm sự kiện (Quét toàn bộ server)
    local foundItems = FindEventItems()
    
    if #foundItems == 0 then
        Notify("Farm Event", "Không tìm thấy Bubble nào trong server, đang chờ...", 2)
        task.wait(2)
        if isFarming then
            FarmEventLoop()
        end
        return
    end
    
    local target = foundItems[1]
    currentTarget = target
    
    if target then
        if isWaitingForItem then
            if not target.Object or not target.Object.Parent then
                isWaitingForItem = false
                retryCount = 0
                Notify("Farm Event", "Đã nhận được Bubble thành công!", 3)
            else
                task.wait(0.5)
                if isFarming then
                    FarmEventLoop()
                end
                return
            end
        end
        
        TeleportToPosition(target.Position, target.CFrame, false)
        task.wait(0.3)
        
        if not target.Object or not target.Object.Parent then
            Notify("Farm Event", "Đã nhận Bubble thành công!", 2)
            retryCount = 0
        else
            if retryCount < maxRetry then
                retryCount = retryCount + 1
                Notify("Farm Event", string.format("Nhận thất bại lần %d, thử lại...", retryCount), 2)
                task.wait(0.3)
                TeleportToPosition(target.Position, target.CFrame, false)
                task.wait(0.3)
                
                if not target.Object or not target.Object.Parent then
                    Notify("Farm Event", "Đã nhận Bubble thành công!", 2)
                    retryCount = 0
                else
                    isWaitingForItem = true
                    Notify("Farm Event", "Đang chờ Bubble biến mất...", 2)
                    task.wait(0.5)
                    if isFarming then
                        FarmEventLoop()
                    end
                    return
                end
            else
                isWaitingForItem = true
                Notify("Farm Event", "Đang chờ Bubble biến mất...", 2)
                task.wait(0.5)
                if isFarming then
                    FarmEventLoop()
                end
                return
            end
        end
        
        -- Teleport về tường
        if wallModel then
            local wallPosition = wallModel:GetPivot().Position
            TeleportToPosition(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
        end
    end
    
    CheckPlayerPosition()
    task.wait(0.3)
    
    if isFarming then
        FarmEventLoop()
    end
end

local function StartFarmEvent()
    if isFarming then return end
    isFarming = true
    isWaitingForItem = false
    retryCount = 0
    isScanning = false
    CreateWall()
    task.wait(1)
    task.spawn(FarmEventLoop)
end

local function StopFarmEvent()
    isFarming = false
    currentTarget = nil
    isWaitingForItem = false
    retryCount = 0
    isScanning = false
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    Notify("Farm Event", "Đã dừng Farm Event!", 2)
end

-- ===== FARM LV =====
local function CreateWallLv()
    pcall(function()
        if wallModelLv then
            wallModelLv:Destroy()
            wallModelLv = nil
        end
    end)
    
    Notify("Farm Lv", "Đang tạo tường hình vuông...", 2)
    
    wallModelLv = Instance.new("Model")
    wallModelLv.Name = "FarmWallLv"
    
    local wallPosition = Vector3.new(0, -800, 0)
    local wallSize = 150
    
    local mainWall = Instance.new("Part")
    mainWall.Size = Vector3.new(wallSize, 5, wallSize)
    mainWall.Position = wallPosition
    mainWall.Anchored = true
    mainWall.CanCollide = true
    mainWall.Transparency = 0
    mainWall.BrickColor = BrickColor.new("Bright blue")
    mainWall.Material = Enum.Material.SmoothPlastic
    mainWall.Parent = wallModelLv
    
    wallModelLv.Parent = game.Workspace
    
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(wallPosition + Vector3.new(0, 5, 0))
        end
    end
    
    Notify("Farm Lv", "Tường hình vuông đã được tạo!", 2)
    
    return wallModelLv
end

local function TeleportToPositionLv(position, cframe, isWall)
    if isTeleportingLv then return end
    isTeleportingLv = true
    
    local player = game.Players.LocalPlayer
    if not player or not player.Character then
        isTeleportingLv = false
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then
        isTeleportingLv = false
        return
    end
    
    if isWall then
        Notify("Farm Lv", "Đang teleport đến tường...", 1)
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
            if cframe then
                humanoidRootPart.CFrame = cframe
            else
                humanoidRootPart.CFrame = CFrame.new(position)
            end
        end
    end)
    
    task.wait(0.05)
    isTeleportingLv = false
end

local function CheckPlayerPositionLv()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if wallModelLv and humanoidRootPart.Position.Y < -500 then
        local wallPosition = wallModelLv:GetPivot().Position
        Notify("Farm Lv", "Phát hiện rời khỏi tường, đang teleport lại...", 2)
        TeleportToPositionLv(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
    end
end

local function FarmLvLoop()
    if not isFarmingLv then return end
    
    if not wallModelLv then
        CreateWallLv()
        task.wait(1)
    end
    
    if wallModelLv then
        local wallPosition = wallModelLv:GetPivot().Position
        TeleportToPositionLv(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
        Notify("Farm Lv", "Đang đứng tại tường chờ phần thưởng...", 3)
    end
    
    while isFarmingLv do
        task.wait(5)
        CheckPlayerPositionLv()
        
        pcall(function()
            local notifications = game:GetService("StarterGui"):GetChildren()
            for _, notif in ipairs(notifications) do
                if notif:IsA("ScreenGui") and notif:FindFirstChild("Timer") then
                    local timer = notif.Timer
                    if timer and timer.Text and string.find(timer.Text, "Hết thời gian") then
                        Notify("Farm Lv", "Đã hết thời gian!", 3)
                        
                        local rewards = game:GetService("ReplicatedStorage"):FindFirstChild("Rewards")
                        if rewards then
                            local playerReward = rewards:FindFirstChild(game.Players.LocalPlayer.Name)
                            if playerReward then
                                Notify("Farm Lv", string.format("Phần thưởng của bạn: %s", playerReward.Value), 5)
                            end
                        end
                        break
                    end
                end
            end
        end)
    end
end

local function StartFarmLv()
    if isFarmingLv then return end
    if isFarming then
        StopFarmEvent()
    end
    isFarmingLv = true
    CreateWallLv()
    task.wait(1)
    task.spawn(FarmLvLoop)
end

local function StopFarmLv()
    isFarmingLv = false
    pcall(function()
        if wallModelLv then
            wallModelLv:Destroy()
            wallModelLv = nil
        end
    end)
    Notify("Farm Lv", "Đã dừng Farm Lv!", 2)
end

-- ===== TẠO TOGGLE =====
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

-- ===== XỬ LÝ LOAD MAP =====
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("LoadCharacter"):Connect(function()
    if isFarming then
        task.wait(2)
        CreateWall()
        task.wait(1)
        if wallModel then
            local wallPosition = wallModel:GetPivot().Position
            TeleportToPosition(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
        end
    end
    
    if isFarmingLv then
        task.wait(2)
        CreateWallLv()
        task.wait(1)
        if wallModelLv then
            local wallPosition = wallModelLv:GetPivot().Position
            TeleportToPositionLv(Vector3.new(wallPosition.X, wallPosition.Y + 5, wallPosition.Z), nil, true)
        end
    end
end)

-- ===== KIỂM TRA VỊ TRÍ LIÊN TỤC =====
game:GetService("RunService").Heartbeat:Connect(function()
    if isFarming then
        CheckPlayerPosition()
    end
    
    if isFarmingLv then
        CheckPlayerPositionLv()
    end
end)

print("Farm Handmade Pro đã được tải thành công!")
print("Sử dụng Rayfield Gen2 - Nhấn RightControl để mở UI")
