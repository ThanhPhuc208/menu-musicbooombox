-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo + Nháy Theo Nhạc (Visualizer) 💟
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

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER
local FakeBoombox = nil
local VisualizerBars = {}

local function CreateFakeBoombox()
    if FakeBoombox then FakeBoombox:Destroy() end
    for _, bar in pairs(VisualizerBars) do if bar then bar:Destroy() end end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("UpperTorso") and not character:FindFirstChild("Torso") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Khởi tạo Mesh chuẩn Chroma Boombox (Dáng dẹp, gọn)
    FakeBoombox = Instance.new("SpecialMesh")
    FakeBoombox.MeshId = "rbxassetid://212641536" -- ID Mesh dáng boombox dẹp gọn
    FakeBoombox.TextureId = "rbxassetid://212641550" -- Texture gốc để phủ màu Neon
    
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Size = Vector3.new(1.8, 1.2, 0.4) -- Thu hẹp bề ngang cực kỳ gọn
    part.CanCollide = false
    part.Massless = true
    FakeBoombox.Parent = part
    part.Parent = character
    
    -- Gắn và Xoay Xéo như đeo Balo Quai Chéo
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- TẠO CÁC THANH SÓNG NHẠC (VISUALIZER BARS) THEO ẢNH 1000056606.jpg
    local barCount = 5 -- Số lượng thanh sóng nhạc trên đỉnh loa
    local barWidth = 1.6 / barCount
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        varSize = Vector3.new(barWidth - 0.05, 0.1, 0.2)
        bar.Size = varSize
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        -- Xếp hàng ngang trên đỉnh của Boombox
        local xOffset = -0.8 + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, 0.6, 0) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + Nhảy sóng theo nhịp âm thanh (PlaybackLoudness)
    coroutine.wrap(function()
        local hue = 0
        while part and part.Parent do
            -- Lấy độ lớn âm thanh hiện tại (Thường từ 0 đến khoảng 300-400)
            local loudness = LocalSound.PlaybackLoudness
            local normLoudness = math.clamp(loudness / 300, 0, 1.5) -- Chuẩn hóa tỷ lệ nhạc
            
            -- 1. Tốc độ chuyển màu Cầu vồng sẽ chạy NHANH HƠN khi nhạc đập Bass mạnh
            local speedMultiplier = 1 + (normLoudness * 4)
            hue = (hue + (0.8 * speedMultiplier)) % 360 
            
            local mainColor = Color3.fromHSV(hue / 360, 1, 1)
            part.Color = mainColor
            FakeBoombox.VertexColor = Vector3.new(mainColor.R, mainColor.G, mainColor.B)
            
            -- 2. Cập nhật các thanh sóng nhạc (Visualizer) nhấp nhô cao thấp theo ảnh 1000056606.jpg
            for _, item in pairs(VisualizerBars) do
                if item.Part and item.Part.Parent then
                    -- Tạo độ nhấp nhô khác nhau một chút giữa các cột cho đẹp mắt
                    local waveFactor = math.sin(tick() * 10 + item.Index) * 0.2
                    local targetHeight = math.clamp((normLoudness * 1.2) + waveFactor, 0.1, 1.5)
                    
                    -- Thay đổi chiều cao thanh nhạc sống động
                    item.Part.Size = Vector3.new(item.Part.Size.X, targetHeight, item.Part.Size.Z)
                    -- Điều chỉnh tâm Weld để thanh chỉ dài lên phía trên chứ không bị lún xuống dưới
                    item.Weld.C0 = CFrame.new(-0.8 + (item.Index - 0.5) * barWidth, 0.6 + (targetHeight / 2), 0)
                    
                    -- Đổi màu thanh sóng nhạc theo dải màu cầu vồng lệch nhịp cực đẹp
                    local barHue = (hue + (item.Index * 15)) % 360
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
        
        CreateFakeBoombox() -- Tạo mẫu loa quai chéo cầu vồng tích hợp sóng nhạc nhảy theo beat
        print("Thanh Phuc đã bật nhạc + Đeo xéo Chroma Boombox cảm ứng sóng nhạc!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
