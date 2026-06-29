-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Bản Menu 2 Nút Độc Lập: Sửa Triệt Để Lỗi Không Hiện Boombox 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Khởi tạo bộ phát âm thanh chuẩn ban đầu của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

local FakeBoombox = nil
local RainbowConnection = nil

-- Hàm dọn dẹp loa cũ một cách an toàn
local function RemoveBoombox()
    if RainbowConnection then RainbowConnection:Disconnect() RainbowConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy() FakeBoombox = nil end
end

-- HÀM TẠO LOA KHỐI VUÔNG GỐC (Chỉ chạy khi bạn nhấn nút Bật Loa)
local function CreateFakeBoombox()
    RemoveBoombox()
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("UpperTorso") and not character:FindFirstChild("Torso") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Tạo khối Part và Mesh gốc giống hệt bản đầu tiên hoạt động ổn định của bạn
    local part = Instance.new("Part")
    part.Name = "ThanhPhucBoombox"
    part.Size = Vector3.new(2, 2, 2)
    part.CanCollide = false
    part.Massless = true
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://114134812" -- Mesh ID gốc Boombox
    mesh.TextureId = "rbxassetid://114134769" -- Texture gốc
    mesh.Parent = part
    
    FakeBoombox = part
    part.Parent = character
    
    -- Gắn chặt vào lưng
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, 0, 0.7) * CFrame.Angles(0, math.rad(180), 0)
    weld.Parent = part
    
    -- Vòng lặp xử lý hiệu ứng cầu vồng chớp giật theo giọng nói và tiếng bass
    local hue = 0
    RainbowConnection = RunService.RenderStepped:Connect(function()
        if part and part.Parent and mesh then
            hue = (hue + 1) % 360
            local baseColor = Color3.fromHSV(hue/360, 1, 1)
            
            -- Đồng bộ chớp nháy mạnh nhẹ theo độ lớn âm thanh thực tế (Lời nói + Bass)
            local loudness = LocalSound.PlaybackLoudness
            local intensity = math.clamp(loudness / 250, 0.4, 2.5)
            
            local dynamicColor = Color3.new(
                math.clamp(baseColor.R * intensity, 0, 1),
                math.clamp(baseColor.G * intensity, 0, 1),
                math.clamp(baseColor.B * intensity, 0, 1)
            )
            
            part.Color = dynamicColor
            mesh.VertexColor = Vector3.new(dynamicColor.R, dynamicColor.G, dynamicColor.B)
            
            -- Khối vuông co giãn nhấp nhô theo đúng nhịp điệu phát ra
            local scaleMultiplier = 1 + (math.clamp(loudness / 800, 0, 0.2))
            mesh.Scale = Vector3.new(scaleMultiplier, scaleMultiplier, scaleMultiplier)
        else
            RemoveBoombox()
        end
    end)
end

-- Tự động dọn loa cũ khi nhân vật die để tránh lỗi kẹt bộ nhớ
LocalPlayer.CharacterRemoving:Connect(function()
    RemoveBoombox()
end)

-- TẠO GIAO DIỆN GUI (Thiết kế chiều cao thoáng để chứa đủ 2 phần riêng biệt)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Nút ẨN MENU (-)
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

-- Nút MỞ MENU (TP 🎵) - Di chuyển tự do
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
InputBox.Position = UDim2.new(0.05, 0, 0.23, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

-- PHẦN 1: NÚT PHÁT NHẠC (Chỉ nhận lệnh bật âm thanh)
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.46, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

-- PHẦN 2: NÚT BẬT BOOMBOX TÁCH BIỆT (Gọi khối loa cầu vồng hiện lên)
local BoomboxBtn = Instance.new("TextButton", MainFrame)
BoomboxBtn.Size = UDim2.new(0.9, 0, 0, 40)
BoomboxBtn.Position = UDim2.new(0.05, 0, 0.71, 0)
BoomboxBtn.Text = "✨ BẬT LOA BASS CẦU VỒNG"
BoomboxBtn.TextColor3 = Color3.new(1, 1, 1)
BoomboxBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 180) -- Màu tím nổi bật
Instance.new("UICorner", BoomboxBtn)

-- Xử lý bấm nút PHÁT NHẠC (Chạy cực kỳ mượt và ổn định)
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        print("Thanh Phuc phát nhạc thành công ID: " .. cleanID)
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)

-- Xử lý bấm nút BẬT LOA BASS CẦU VỒNG (Chủ động gọi ra, không sợ lỗi)
BoomboxBtn.MouseButton1Click:Connect(function()
    CreateFakeBoombox()
    print("Thanh Phuc đã kích hoạt khối loa thành công!")
end)
