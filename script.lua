-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Gọn Đẹp + Nhịp Sóng Nhạc Dải Neon Dính Khớp 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER DÍNH KHỚP
local FakeBoomboxModel = nil
local VisualizerBars = {}
local function CreateFakeBoombox()
    if FakeBoomboxModel then FakeBoomboxModel:Destroy() end
    for _, bar in pairs(VisualizerBars) do if bar then bar:Destroy() end end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("UpperTorso") and not character:FindFirstChild("Torso") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Tạo một Model để nhóm Boombox và Sóng nhạc
    FakeBoomboxModel = Instance.new("Model")
    FakeBoomboxModel.Name = "ThanhPhucBoomboxSystem"
    FakeBoomboxModel.Parent = character

    -- 1. Thân Boombox Cầu Vồng
    local part = Instance.new("Part")
    part.Name = "BoomboxBody"
    part.Size = Vector3.new(1.8, 1.2, 0.4)
    part.CanCollide = false
    part.Massless = true
    part.Parent = FakeBoomboxModel
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://212641536"
    mesh.TextureId = "rbxassetid://212641550"
    mesh.Parent = part
    
    -- Gắn Boombox vào Lưng (như quai chéo)
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- 2. Dải Sóng Nhạc Neon (Visualizer Bars) - CHỈNH VỊ TRÍ DÍNH KHỚP
    local barCount = 10 -- Số lượng thanh sóng nhạc (nhiều hơn cho giống ảnh)
    local barWidth = 1.6 / barCount
    local barDepth = part.Size.Z - 0.05 -- Chiều sâu gần bằng thân loa

    -- Vị trí trục Z (phía trước dải sóng nhạc) dính khớp với bề mặt trước của Boombox
    local zOffset = -0.19 

    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Chiều cao ban đầu thấp nhất, dính chặt
        bar.Size = Vector3.new(barWidth - 0.02, 0.05, barDepth) 
        bar.CanCollide = false
        bar.Massless = true
        bar.Transparency = 0.2 -- Hơi trong suốt một chút cho giống hiệu ứng dải neon
        bar.Parent = FakeBoomboxModel
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        -- Căn chỉnh dải sóng nhạc nằm trên đỉnh và sát bề mặt trước của thân Boombox
        barWeld.C0 = CFrame.new(-0.8 + (i - 0.5) * barWidth, 0.6, zOffset)
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + Nhảy sóng theo nhịp âm thanh (dính khớp)
    coroutine.wrap(function()
        local hue = 0
        while part and part.Parent do
            local loudness = LocalSound.PlaybackLoudness
            local normLoudness = math.clamp(loudness / 400, 0, 1.2) -- Chuẩn hóa tỷ lệ nhạc
            
            -- Màu sắc Cầu vồng (Chroma)
            hue = (hue + 1.2) % 360 
            local mainColor = Color3.fromHSV(hue / 360, 1, 1)
            part.Color = mainColor
            mesh.VertexColor = Vector3.new(mainColor.R, mainColor.G, mainColor.B)
            
            -- Cập nhật dải sóng nhạc dính khớp theo beat
            for _, item in pairs(VisualizerBars) do
                if item.Part and item.Part.Parent then
                    -- Tạo độ nhấp nhô sống động
                    local waveFactor = math.sin(tick() * 15 + item.Index * 0.8) * 0.15
                    local targetHeight = math.clamp((normLoudness * 0.9) + waveFactor + 0.1, 0.1, 0.7) -- Chiều cao vừa phải, không quá lố
                    
                    -- Thay đổi chiều cao thanh nhạc (chỉ dài lên trên)
                    item.Part.Size = Vector3.new(item.Part.Size.X, targetHeight, barDepth)
                    -- Điều chỉnh vị trí tâm để dính chặt bề mặt
                    item.Weld.C0 = CFrame.new(-0.8 + (item.Index - 0.5) * barWidth, 0.6 + (targetHeight / 2), zOffset)
                    
                    -- Đổi màu neon dải sóng nhạc cùng tông màu dải
                    local barHue = (hue + (item.Index * 5)) % 360
                    item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
                end
            end
            
            RunService.RenderStepped:Wait()
        end
    end)()
end

-- Tự động đeo lại khi nhân vật hồi sinh
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if LocalSound.IsPlaying then
        CreateFakeBoombox()
    end
end)

-- GIAO DIỆN GUI (Giữ nguyên toàn bộ cấu trúc cũ)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Nút ẨN MENU
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false 
end)

-- Nút MỞ MENU
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true 
end)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Ô nhập ID Nhạc
local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

-- Nút PHÁT NHẠC
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

-- Kích hoạt phát nhạc và gọi Loa Đeo Chéo xuất hiện
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        CreateFakeBoombox() -- Tạo mẫu loa quai chéo cầu vồng tích hợp sóng nhạc dính khớp!
        print("Thanh Phuc đã bật nhạc + Đeo xéo Boombox tích hợp sóng nhạc khớp!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
