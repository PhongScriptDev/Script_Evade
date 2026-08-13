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
    name = "Event Farm",
    icon = "rbxassetid://93364949241311"
})

-- ===== BIẾN =====
local isFarming = false
local isFarmingLv = false
local isAutoDetect = false
local wallModel = nil
local wallModelLv = nil
local isTeleporting = false
local isTeleportingLv = false
local farmEventToggle = nil
local farmLvToggle = nil
local autoDetectToggle = nil
local itemCount = 0
local noItemTimer = 0
local collectedItems = 0
local currentEventItem = "Bubble"
local detectedItemName = nil
local detectedItemShape = nil
local isDetecting = false

-- Biến Anti AFK & Gameplay Pause
local antiAFKActive = false
local antiGameplayPauseActive = false
local afkTimer = 0
local gameplayPauseDetected = false
local isMovingRandomly = false

-- Vị trí tường
local WALL_POSITION = Vector3.new(10000, -500, 10000)

-- ===== DANH SÁCH 20 VẬT PHẨM SỰ KIỆN =====
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

-- ===== TỰ ĐỘNG DI CHUYỂN NHẸ =====
local function RandomMovement()
    if isMovingRandomly then return end
    isMovingRandomly = true
    
    pcall(function()
        local player = game.Players.LocalPlayer
        if not player or not player.Character then
            isMovingRandomly = false
            return
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        if not hrp or not humanoid then
            isMovingRandomly = false
            return
        end
        
        -- Kiểm tra nếu đang ở trên tường
        local model = isFarming and wallModel or wallModelLv
        if model then
            local wallPos = model:GetPivot().Position
            local dist = (hrp.Position - wallPos).Magnitude
            if dist > 50 then
                isMovingRandomly = false
                return
            end
        end
        
        -- Lưu vị trí hiện tại
        local currentPos = hrp.Position
        
        -- Di chuyển ngẫu nhiên trong bán kính 2 units
        local angle = math.random() * 2 * math.pi
        local radius = math.random(10, 20) / 10 -- 1.0 đến 2.0 units
        local offset = Vector3.new(
            math.cos(angle) * radius,
            0,
            math.sin(angle) * radius
        )
        
        local targetPos = currentPos + offset
        
        -- Di chuyển từ từ đến vị trí mới
        local steps = 10
        for i = 1, steps do
            local t = i / steps
            local newPos = currentPos:Lerp(targetPos, t)
            hrp.CFrame = CFrame.new(newPos)
            task.wait(0.02)
        end
        
        -- Đứng yên 1 chút
        task.wait(math.random(10, 30) / 10) -- 1-3 giây
        
        -- Quay lại vị trí cũ
        for i = 1, steps do
            local t = i / steps
            local newPos = targetPos:Lerp(currentPos, t)
            hrp.CFrame = CFrame.new(newPos)
            task.wait(0.02)
        end
        
        isMovingRandomly = false
    end)
end

-- ===== ANTI AFK - KHÔNG LỖI 20 PHÚT =====
local function StartAntiAFK()
    if antiAFKActive then return end
    antiAFKActive = true
    afkTimer = 0
    
    Notify("🛡️ Anti AFK", "Đã kích hoạt chống AFK!", 3)
    Toast("🛡️ Anti AFK", "Đang hoạt động", 2)
    
    task.spawn(function()
        while antiAFKActive and (isFarming or isFarmingLv) do
            task.wait(20) -- Kiểm tra mỗi 20 giây
            
            if not (isFarming or isFarmingLv) then
                antiAFKActive = false
                break
            end
            
            afkTimer = afkTimer + 0.333
            
            -- Mỗi 2 phút thực hiện chống AFK
            if afkTimer >= 2 then
                afkTimer = 0
                
                pcall(function()
                    local player = game.Players.LocalPlayer
                    if player then
                        -- Cách 1: VirtualUser Click
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                        
                        -- Cách 2: Gửi tín hiệu phím giả
                        local UserInputService = game:GetService("UserInputService")
                        if UserInputService then
                            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
                            for _, key in ipairs(keys) do
                                UserInputService:SetKeyDown(key)
                                task.wait(0.03)
                                UserInputService:SetKeyUp(key)
                                task.wait(0.03)
                            end
                        end
                        
                        -- Cách 3: Tự động di chuyển nhẹ
                        if math.random(1, 3) == 1 then
                            RandomMovement()
                        end
                        
                        -- Cách 4: Gửi tín hiệu chuột giả
                        local mouse = player:GetMouse()
                        if mouse then
                            local currentPos = Vector2.new(mouse.X, mouse.Y)
                            local offset = Vector2.new(math.random(-10, 10), math.random(-10, 10))
                            mouse.X = currentPos.X + offset.X
                            mouse.Y = currentPos.Y + offset.Y
                            task.wait(0.05)
                            mouse.X = currentPos.X
                            mouse.Y = currentPos.Y
                        end
                        
                        -- Cách 5: Bắt sự kiện Idled
                        if player.Idled then
                            player.Idled:Connect(function()
                                VirtualUser:ClickButton2(Vector2.new(0, 0))
                            end)
                        end
                        
                        Toast("🛡️ Anti AFK", "Đã gửi tín hiệu", 1)
                    end
                end)
            end
        end
    end)
end

local function StopAntiAFK()
    antiAFKActive = false
    afkTimer = 0
    isMovingRandomly = false
    Notify("🛡️ Anti AFK", "Đã tắt!", 2)
    Toast("🛡️ Anti AFK", "Đã tắt", 2)
end

-- ===== ANTI GAMEPLAY PAUSE - KHÔNG BỊ TELEPORT 1 CHỖ =====
local function StartAntiGameplayPause()
    if antiGameplayPauseActive then return end
    antiGameplayPauseActive = true
    gameplayPauseDetected = false
    
    Notify("🛡️ Anti Gameplay Pause", "Đã kích hoạt!", 3)
    Toast("🛡️ Anti Pause", "Đang hoạt động", 2)
    
    -- Luồng 1: Phát hiện và chống Gameplay Pause
    task.spawn(function()
        while antiGameplayPauseActive and (isFarming or isFarmingLv) do
            task.wait(1)
            
            if not (isFarming or isFarmingLv) then
                antiGameplayPauseActive = false
                break
            end
            
            pcall(function()
                local player = game.Players.LocalPlayer
                if player then
                    -- Kiểm tra Gameplay Pause GUI
                    local gui = player.PlayerGui:FindFirstChild("GameplayPause")
                    if gui and gui.Enabled then
                        gameplayPauseDetected = true
                        
                        -- Chống Gameplay Pause bằng nhiều cách
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                        task.wait(0.1)
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                        
                        -- Tắt GUI nếu vẫn còn
                        if gui and gui.Enabled then
                            gui.Enabled = false
                        end
                        
                        -- Gửi tín hiệu phím giả
                        local UserInputService = game:GetService("UserInputService")
                        if UserInputService then
                            UserInputService:SetKeyDown(Enum.KeyCode.W)
                            task.wait(0.05)
                            UserInputService:SetKeyUp(Enum.KeyCode.W)
                            UserInputService:SetKeyDown(Enum.KeyCode.Space)
                            task.wait(0.05)
                            UserInputService:SetKeyUp(Enum.KeyCode.Space)
                        end
                        
                        -- Di chuyển nhẹ để thoát pause
                        RandomMovement()
                        
                        Toast("🛡️ Anti Pause", "Đã chống!", 1)
                        gameplayPauseDetected = false
                    end
                    
                    -- Kiểm tra các GUI khác
                    for _, guiItem in ipairs(player.PlayerGui:GetChildren()) do
                        if guiItem.Name == "Pause" or guiItem.Name == "GameplayPaused" or guiItem.Name == "AFK" then
                            if guiItem.Enabled then
                                guiItem.Enabled = false
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    -- Luồng 2: Gửi tín hiệu liên tục và di chuyển nhẹ
    task.spawn(function()
        while antiGameplayPauseActive and (isFarming or isFarmingLv) do
            task.wait(3) -- Gửi tín hiệu mỗi 3 giây
            
            if not (isFarming or isFarmingLv) then
                break
            end
            
            pcall(function()
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    
                    if hrp and humanoid then
                        -- Lưu vị trí hiện tại
                        local currentPos = hrp.Position
                        
                        -- Gửi tín hiệu VirtualUser
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                        
                        -- Mô phỏng di chuyển nhẹ (không teleport)
                        if math.random(1, 2) == 1 then
                            local offset = Vector3.new(
                                math.random(-15, 15) / 10,
                                0,
                                math.random(-15, 15) / 10
                            )
                            
                            if offset.Magnitude > 0.1 then
                                -- Di chuyển từ từ
                                local targetPos = currentPos + offset
                                local steps = 5
                                for i = 1, steps do
                                    local t = i / steps
                                    local newPos = currentPos:Lerp(targetPos, t)
                                    hrp.CFrame = CFrame.new(newPos)
                                    task.wait(0.02)
                                end
                                
                                -- Quay lại vị trí cũ
                                for i = 1, steps do
                                    local t = i / steps
                                    local newPos = targetPos:Lerp(currentPos, t)
                                    hrp.CFrame = CFrame.new(newPos)
                                    task.wait(0.02)
                                end
                            end
                        end
                        
                        -- Mô phỏng nhấn phím di chuyển
                        local UserInputService = game:GetService("UserInputService")
                        if UserInputService and math.random(1, 3) == 1 then
                            local randomKey = math.random(1, 4)
                            local key = {
                                Enum.KeyCode.W,
                                Enum.KeyCode.A,
                                Enum.KeyCode.S,
                                Enum.KeyCode.D
                            }[randomKey]
                            
                            UserInputService:SetKeyDown(key)
                            task.wait(0.05)
                            UserInputService:SetKeyUp(key)
                        end
                    end
                end
            end)
        end
    end)
end

local function StopAntiGameplayPause()
    antiGameplayPauseActive = false
    gameplayPauseDetected = false
    isMovingRandomly = false
    Notify("🛡️ Anti Gameplay Pause", "Đã tắt!", 2)
    Toast("🛡️ Anti Pause", "Đã tắt", 2)
end

-- ===== KIỂM TRA DANH SÁCH VẬT PHẨM =====
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
        return false, "⚠️ Không có sự kiện", "❗ Không còn sự kiện để farm", {}
    end
    
    if #validItems >= 1 then
        currentEventItem = validItems[1]
        return true, "✅ Có sự kiện", "🔄 Đang tìm " .. currentEventItem .. "...", validItems
    end
    
    return true, "Đang tìm vật phẩm sự kiện...", validItems
end

-- ===== GHI NHỚ HÌNH DẠNG VẬT PHẨM =====
local function MemorizeItemShape(item)
    if not item then return end
    
    local shapeData = {
        Name = item.Name,
        Size = item.Size,
        Color = item.BrickColor,
        Material = item.Material,
        Position = item.Position
    }
    
    detectedItemShape = shapeData
    detectedItemName = item.Name
    
    Notify("🧠 Ghi nhớ", "Đã ghi nhớ hình dạng: " .. item.Name, 3)
    Toast("🧠 Ghi nhớ", item.Name, 2)
    
    for i, v in ipairs(EventItems) do
        if v ~= "none" then
            EventItems[i] = item.Name
            break
        end
    end
end

-- ===== TỰ ĐỘNG PHÁT HIỆN VẬT PHẨM =====
local function SmartDetectEvent()
    if not isAutoDetect or not isFarming then return nil end
    if isDetecting then return nil end
    
    isDetecting = true
    local foundItem = nil
    
    local allParts = game.Workspace:GetDescendants()
    local player = game.Players.LocalPlayer
    
    for _, obj in ipairs(allParts) do
        if obj:IsA("BasePart") and obj.Parent then
            local isCharacter = false
            local currentParent = obj.Parent
            while currentParent do
                if currentParent:IsA("Model") and currentParent:FindFirstChild("Humanoid") then
                    isCharacter = true
                    break
                end
                currentParent = currentParent.Parent
            end
            
            if not isCharacter then
                local isEventItem = false
                for _, eventName in ipairs(EventItems) do
                    if eventName ~= "none" and string.find(string.lower(obj.Name), string.lower(eventName)) then
                        isEventItem = true
                        break
                    end
                end
                
                if isEventItem then
                    foundItem = obj
                    break
                end
            end
        end
    end
    
    isDetecting = false
    
    if foundItem then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            TeleportWithEmote(foundItem.Position, foundItem.CFrame, false, false)
            task.wait(2)
            
            if not foundItem.Parent then
                MemorizeItemShape(foundItem)
                Notify("🔍 Phát hiện", "Vật phẩm mới: " .. foundItem.Name, 3)
                Toast("🔍 Phát hiện", foundItem.Name, 2)
                
                if wallModel then
                    local wallPos = wallModel:GetPivot().Position
                    TeleportWithEmote(Vector3.new(wallPos.X, wallPos.Y + 1, wallPos.Z), nil, true, false)
                end
                
                return foundItem.Name
            end
        end
    end
    
    return nil
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
    local valid, _, _, validItems = CheckEventItemsList()
    
    if not valid then
        return items
    end
    
    local foundAny = false
    
    for _, v in pairs(workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("Model")) then
            local nameLower = string.lower(v.Name)
            
            for _, eventName in ipairs(validItems) do
                if string.find(nameLower, string.lower(eventName)) or string.find(eventName, nameLower) then
                    local isVisualEffect = v:FindFirstChildWhichIsA("ParticleEmitter") 
                                        or v:FindFirstChildWhichIsA("Trail") 
                                        or v:FindFirstChildWhichIsA("Beam")
                                        or v.ClassName == "Accessory"
                    local hasAnimation = v:FindFirstChildWhichIsA("Animation") or v:FindFirstChildWhichIsA("Animator")

                    if not isVisualEffect and not hasAnimation and not isPlayerAsset(v) then
                        local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                        if part then
                            table.insert(items, {
                                Object = part,
                                Name = v.Name,
                                Type = eventName
                            })
                            foundAny = true
                        end
                    end
                    break
                end
            end
        end
    end
    
    if not foundAny and isAutoDetect and isFarming then
        local detected = SmartDetectEvent()
        if detected then
            for i, item in ipairs(EventItems) do
                if item ~= "none" then
                    EventItems[i] = detected
                    currentEventItem = detected
                    break
                end
            end
            return getAllItems()
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
    for _, item in ipairs(items) do
        local part = item.Object
        local dst = (hrp.Position - part.Position).Magnitude
        if dst < minDst and not isNextbotNear(part.Position) then
            closest = item
            minDst = dst
        end
    end
    return closest
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
            Notify("Farm Event", "⚠️ Không có vật phẩm, đang chờ...", 3)
            Toast("⏳ Chờ", "Không có vật phẩm", 2)
            noItemTimer = 0
        end
        task.wait(1)
        if isFarming then FarmEventLoop() end
        return
    end
    
    noItemTimer = 0
    
    local target = getClosestSafeItem(hrp, items)
    
    if target then
        local itemName = target.Name
        Toast("🔄 Tìm thấy", itemName, 2)
        
        local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target.Object.Position)})
        tween:Play()
        tween.Completed:Wait()
        
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local collectId = target.Object.Parent:GetAttribute("Id") or target.Object:GetAttribute("Id") or "a19ac91bff904b7385e826fd6a23dc01"
            ReplicatedStorage.Events.Collectibles.Invoke:InvokeServer(player, collectId, "Collect")
            
            collectedItems = collectedItems + 1
            
            Notify("🔔 Tổng nhận event items", 
                string.format("🔎 Event items: %d", collectedItems), 2)
            Toast("✅ Nhận", string.format("%s #%d", itemName, collectedItems), 2)
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
    
    -- Kích hoạt Anti AFK & Gameplay Pause
    StartAntiAFK()
    StartAntiGameplayPause()
    
    CreateWall()
    task.wait(1)
    TeleportToWall()
    task.wait(0.5)
    
    task.spawn(FarmEventLoop)
end

local function StopFarmEvent()
    isFarming = false
    noItemTimer = 0
    
    -- Tắt Anti AFK & Gameplay Pause
    StopAntiAFK()
    StopAntiGameplayPause()
    
    pcall(function()
        if wallModel then
            wallModel:Destroy()
            wallModel = nil
        end
    end)
    
    Notify("🔔 Tổng nhận event items", 
        string.format("🔎 Event items: %d", collectedItems), 3)
    Toast("🛑 Dừng", string.format("Đã nhận %d vật phẩm", collectedItems), 3)
end

-- ===== FARM LV =====
local function FarmLvLoop()
    if not isFarmingLv then return end
    
    if not wallModelLv then
        CreateWallLv()
        task.wait(1)
    end
    
    TeleportToWallLv()
    Toast("📍 Đứng chờ", "Chờ phần thưởng...", 3)
    
    while isFarmingLv do
        task.wait(3)
        CheckFallOffWallLv()
        
        pcall(function()
            local notifications = game:GetService("StarterGui"):GetChildren()
            for _, notif in ipairs(notifications) do
                if notif:IsA("ScreenGui") and notif:FindFirstChild("Timer") then
                    local timer = notif.Timer
                    if timer and timer.Text and string.find(timer.Text, "Hết thời gian") then
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
                                
                                Notify("🔔 Phần thưởng nhận được:", string.format("%s | %s | %s", coinText, expText, eventText), 5)
                                Toast("🎁 Phần thưởng", "Đang nhận...", 3)
                                
                                task.wait(1)
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
    
    -- Kích hoạt Anti AFK & Gameplay Pause
    StartAntiAFK()
    StartAntiGameplayPause()
    
    CreateWallLv()
    task.wait(1)
    TeleportToWallLv()
    task.spawn(FarmLvLoop)
end

local function StopFarmLv()
    isFarmingLv = false
    
    -- Tắt Anti AFK & Gameplay Pause
    StopAntiAFK()
    StopAntiGameplayPause()
    
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

autoDetectToggle = farmTab:CreateToggle({
    name = "Auto-Detect Event",
    flag = "AutoDetectToggle",
    callback = function(value)
        if value then
            if not isFarming then
                Notify("⚠️ Cảnh báo", "Phải bật Farm Event trước!", 3)
                Toast("⚠️ Lỗi", "Cần Farm Event", 2)
                autoDetectToggle:SetValue(false)
                return
            end
            if isFarmingLv then
                Notify("⚠️ Cảnh báo", "Không thể dùng với Farm Lv!", 3)
                Toast("⚠️ Lỗi", "Đang chạy Farm Lv", 2)
                autoDetectToggle:SetValue(false)
                return
            end
            isAutoDetect = true
            Notify("🔍 Auto-Detect", "Đã bật phát hiện thông minh!", 3)
            Toast("🔍 Auto-Detect", "Đang quét...", 2)
        else
            isAutoDetect = false
            Notify("🔍 Auto-Detect", "Đã tắt phát hiện thông minh!", 3)
            Toast("🔍 Auto-Detect", "Đã tắt", 2)
        end
    end,
})

-- ===== KIỂM TRA XUỐNG TƯỜNG =====
game:GetService("RunService").Heartbeat:Connect(function()
    if isFarming then
        CheckFallOffWall()
    end
    if isFarmingLv then
        CheckFallOffWallLv()
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

print("Evade Event Farm đã được tải thành công!")
print("Sử dụng Rayfield Gen2 - Nhấn RightControl để mở UI")
print("🛡️ Anti AFK (tự động di chuyển nhẹ) & Anti Gameplay Pause đã sẵn sàng!")
