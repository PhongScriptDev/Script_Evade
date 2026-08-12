local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- ===== ĐẶT POP UP VÀ PHÁT NHẠC Ở ĐÂY (CHÍNH GIỮA LOAD RAYFIELD VÀ TẠO WINDOW) =====
-- Hàm tạo Popup và phát nhạc
local function ShowMusicPopup()
    local soundId = "rbxassetid://119589720384457" -- Thay ID nhạc của bạn vào đây
    
    pcall(function()
        -- Tạo Popup trước
        local popup = Rayfield:Popup({
            title = "🎵 Phát nhạc",
            content = "Bạn có muốn bật nhạc nền không?",
            options = {
                { 
                    text = "🎶 Bật nhạc", 
                    style = "primary",
                    callback = function()
                        -- Phát nhạc khi ấn nút
                        local sound = Instance.new("Sound")
                        sound.SoundId = soundId
                        sound.Volume = 0.5
                        sound.Looped = false
                        sound.Parent = game.Workspace
                        sound:Play()
                        
                        -- Thông báo đang phát nhạc (sẽ dùng Notify sau khi có window)
                        print("🎵 Đang phát nhạc...")
                        
                        sound.Ended:Connect(function()
                            sound:Destroy()
                        end)
                    end
                },
                { 
                    text = "🔇 Tắt nhạc",
                    callback = function()
                        print("🔇 Đã tắt nhạc")
                    end
                },
            },
        })
    end)
end

-- Gọi Popup ngay tại đây (chính giữa Load Rayfield và TẠO WINDOW)
ShowMusicPopup()


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
    name = "Summer 2026",
    icon = "rbxassetid://93364949241311"
})

-- ===== BIẾN =====
local isFarming = false
local isFarmingLv = false
local wallModel = nil
local wallModelLv = nil
local isTeleporting = false
local isTeleportingLv = false
local farmEventToggle = nil
local farmLvToggle = nil
local itemCount = 0
local noItemTimer = 0
local collectedItems = 0
local rewardCoins = 0
local rewardExp = 0
local rewardEventItems = 0

-- Vị trí tường
local WALL_POSITION = Vector3.new(10000, -500, 10000)

-- ===== CHỐNG GAMEPLAY PAUSED =====
local function AntiGameplayPaused()
    pcall(function()
        local player = game.Players.LocalPlayer
        if player then
            player.Idled:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
            
            task.spawn(function()
                while true do
                    task.wait(30)
                    if isFarming or isFarmingLv then
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                    end
                end
            end)
        end
    end)
end

AntiGameplayPaused()

-- ===== HÀM THÔNG BÁO =====
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

-- ===== KIỂM TRA VẬT PHẨM =====
local function isPlayerAsset(instance)
    local Players = game:GetService("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and instance:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function getAllItems()
    local items = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("Model")) then
            local nameLower = string.lower(v.Name)
            if string.find(nameLower, "bubble") or string.find(nameLower, "coconut") then
                local isVisualEffect = v:FindFirstChildWhichIsA("ParticleEmitter") 
                                    or v:FindFirstChildWhichIsA("Trail") 
                                    or v:FindFirstChildWhichIsA("Beam")
                                    or v.ClassName == "Accessory"
                local hasAnimation = v:FindFirstChildWhichIsA("Animation") or v:FindFirstChildWhichIsA("Animator")

                if not isVisualEffect and not hasAnimation and not isPlayerAsset(v) then
                    local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        table.insert(items, part)
                    end
                end
            end
        end
    end
    return items
end

local function isNextbotNear(position)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:GetAttribute("Nextbot") == true then
            local root = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
            if root then
                local distance = (position - root.Position).Magnitude
                if distance <= 12 then 
                    return true
                end
            end
        end
    end
    return false
end

local function getClosestSafeItem(hrp, items)
    local closest, minDst = nil, math.huge
    for _, part in ipairs(items) do
        local dst = (hrp.Position - part.Position).Magnitude
        if dst < minDst and not isNextbotNear(part.Position) then
            closest = part
            minDst = dst
        end
    end
    return closest
end

local function teleportTo(hrp, pos, duration)
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- ===== TẠO TƯỜNG =====
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
    
    Notify("Farm Event", "Tường đã được tạo!", 2)
    Toast("✅ Tường", "Đã tạo xong", 2)
    
    return wallModel
end

local function CreateWallLv()
    pcall(function()
        if wallModelLv then
            wallModelLv:Destroy()
            wallModelLv = nil
        end
    end)
    
    Notify("Farm Lv", "Đang tạo tường...", 2)
    
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
    
    Notify("Farm Lv", "Tường đã được tạo!", 2)
    Toast("✅ Tường Lv", "Đã tạo xong", 2)
    
    return wallModelLv
end

-- ===== TELEPORT =====
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

local function TeleportToWall()
    if not wallModel then return end
    local pos = wallModel:GetPivot().Position
    TeleportWithEmote(Vector3.new(pos.X, pos.Y + 1, pos.Z), nil, true, false)
end

local function TeleportToWallLv()
    if not wallModelLv then return end
    local pos = wallModelLv:GetPivot().Position
    TeleportWithEmote(Vector3.new(pos.X, pos.Y + 1, pos.Z), nil, true, true)
end

-- ===== PHÁT HIỆN XUỐNG TƯỜNG =====
local function CheckFallOffWall()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if not wallModel then return end
    
    local wallPos = wallModel:GetPivot().Position
    if rootPart.Position.Y < wallPos.Y - 1 then
        Toast("⚠️ Xuống tường", "Đang teleport lại...", 2)
        TeleportToWall()
    end
end

local function CheckFallOffWallLv()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if not wallModelLv then return end
    
    local wallPos = wallModelLv:GetPivot().Position
    if rootPart.Position.Y < wallPos.Y - 1 then
        Toast("⚠️ Xuống tường", "Đang teleport lại...", 2)
        TeleportToWallLv()
    end
end

-- ===== FARM EVENT - MAIN LOOP =====
local function FarmEventLoop()
    if not isFarming then return end
    
    AntiGameplayPaused()
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not char or not hrp then
        task.wait(1)
        if isFarming then FarmEventLoop() end
        return
    end
    
    local items = getAllItems()
    itemCount = #items
    
    if itemCount == 0 then
        noItemTimer = noItemTimer + 0.5
        if noItemTimer >= 20 then
            Notify("Farm Event", "⚠️ Không có Bubble, đang chờ...", 3)
            Toast("⏳ Chờ", "Không có Bubble", 2)
            noItemTimer = 0
        end
        task.wait(1)
        if isFarming then FarmEventLoop() end
        return
    end
    
    noItemTimer = 0
    
    local target = getClosestSafeItem(hrp, items)
    
    if target then
        Toast("🔄 Tìm thấy", "Bubble gần nhất", 2)
        
        local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target.Position)})
        tween:Play()
        tween.Completed:Wait()
        
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local collectId = target.Parent:GetAttribute("Id") or target:GetAttribute("Id") or "a19ac91bff904b7385e826fd6a23dc01"
            ReplicatedStorage.Events.Collectibles.Invoke:InvokeServer(player, collectId, "Collect")
            
            collectedItems = collectedItems + 1
            Notify("🔔 Tổng nhận event items", string.format("🔎 Event items: %d", collectedItems), 2)
            Toast("✅ Nhận", string.format("Bubble #%d", collectedItems), 2)
        end)
        
        task.wait(0.5)
        
        if wallModel then
            local wallPos = wallModel:GetPivot().Position
            local tween2 = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(Vector3.new(wallPos.X, wallPos.Y + 1, wallPos.Z))})
            tween2:Play()
            tween2.Completed:Wait()
        end
    end
    
    task.wait(0.5)
    
    if isFarming then
        FarmEventLoop()
    end
end

-- ===== START/STOP FARM EVENT =====
local function StartFarmEvent()
    if isFarming then return end
    
    isFarming = true
    noItemTimer = 0
    collectedItems = 0
    
    Notify("Farm Event", "🚀 Đang khởi động Farm Event...", 2)
    Toast("🚀 Khởi động", "Farm Event", 2)
    
    CreateWall()
    task.wait(1)
    TeleportToWall()
    task.wait(0.5)
    
    task.spawn(FarmEventLoop)
end

local function StopFarmEvent()
    isFarming = false
    noItemTimer = 0
    
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    
    Notify("🔔 Tổng nhận event items", string.format("🔎 Event items: %d", collectedItems), 3)
    Toast("🛑 Dừng", string.format("Đã nhận %d Bubble", collectedItems), 3)
end

-- ===== FARM LV - CHỈ ĐỨNG TƯỜNG =====
local function FarmLvLoop()
    if not isFarmingLv then return end
    
    AntiGameplayPaused()
    
    if not wallModelLv then
        CreateWallLv()
        task.wait(1)
    end
    
    TeleportToWallLv()
    Toast("📍 Đứng chờ", "Chờ phần thưởng...", 3)
    
    while isFarmingLv do
        task.wait(3)
        CheckFallOffWallLv()
        AntiGameplayPaused()
        
        pcall(function()
            local notifications = game:GetService("StarterGui"):GetChildren()
            for _, notif in ipairs(notifications) do
                if notif:IsA("ScreenGui") and notif:FindFirstChild("Timer") then
                    local timer = notif.Timer
                    if timer and timer.Text and string.find(timer.Text, "Hết thời gian") then
                        -- THÔNG BÁO PHẦN THƯỞNG TRƯỚC KHI NHẬN
                        local rewards = game:GetService("ReplicatedStorage"):FindFirstChild("Rewards")
                        if rewards then
                            local playerReward = rewards:FindFirstChild(game.Players.LocalPlayer.Name)
                            if playerReward then
                                local coinReward = playerReward:FindFirstChild("Coins") or playerReward:FindFirstChild("Money")
                                local expReward = playerReward:FindFirstChild("Exp") or playerReward:FindFirstChild("Experience")
                                local eventReward = playerReward:FindFirstChild("EventItems") or playerReward:FindFirstChild("Bubbles")
                                
                                local coinText = coinReward and string.format("💰 Tiền %d", coinReward.Value) or "💰 Tiền 0"
                                local expText = expReward and string.format("⚡ Exp %d", expReward.Value) or "⚡ Exp 0"
                                local eventText = eventReward and string.format("🎁 Event items %d", eventReward.Value) or "🎁 Event items 0"
                                
                                -- HIỂN THỊ THÔNG BÁO TRƯỚC KHI NHẬN
                                Notify("🔔 Phần thưởng nhận được:", string.format("%s | %s | %s", coinText, expText, eventText), 5)
                                Toast("🎁 Phần thưởng", "Đang nhận...", 3)
                                
                                -- SAU ĐÓ MỚI NHẬN PHẦN THƯỞNG
                                task.wait(1)
                                -- Code nhận phần thưởng ở đây (nếu có)
                            else
                                Notify("🔔 Phần thưởng nhận được:", "❌ Không có phần thưởng", 3)
                            end
                        else
                            Notify("🔔 Phần thưởng nhận được:", "❌ Không tìm thấy phần thưởng", 3)
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
    TeleportToWallLv()
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
    Notify("Farm Lv", "🛑 Đã dừng Farm Lv!", 2)
    Toast("🛑 Dừng", "Farm Lv", 2)
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

-- ===== KIỂM TRA XUỐNG TƯỜNG =====
game:GetService("RunService").Heartbeat:Connect(function()
    if isFarming then
        CheckFallOffWall()
        AntiGameplayPaused()
    end
    if isFarmingLv then
        CheckFallOffWallLv()
        AntiGameplayPaused()
    end
end)

-- ===== RESET KHI DOWNED =====
game.Players.LocalPlayer.CharacterAdded:Connect(function()
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

print("Summer 2026 Farm đã được tải thành công!")
print("Sử dụng Rayfield Gen2 - Nhấn RightControl để mở UI")
