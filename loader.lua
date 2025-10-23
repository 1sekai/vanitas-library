-- =================================================================
-- VLib 3.0
-- Dibuat oleh AI (Gemini) untuk Vanitas
-- Fitur: Kategori kiri, Minimize, Smooth Tweens, UICorner
-- =================================================================

local VLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Preset Animasi
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- Fungsi untuk membuat GUI utama
function VLib:CreateWindow(options)
    local title = options.Name or "VLib Window"
    local hotkey = options.Hotkey or Enum.KeyCode.RightShift
    local defaultTabName = nil
    
    -- Status Jendela
    local isVisible = true
    local isMinimized = false
    
    -- Objek Window yang akan kita kembalikan
    local Window = {}
    Window.Tabs = {} -- Menyimpan referensi ke tab dan halamannya
    Window.CurrentTab = nil

    -- 1. SCREEN GUI (Kontainer Utama)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "VLib_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    Window.ScreenGui = ScreenGui 

    -- 2. MAIN FRAME (Jendela Utama)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    local fullSize = UDim2.new(0, 500, 0, 350)
    local minimizedSize = UDim2.new(0, 200, 0, 30) -- Ukuran saat minimize
    MainFrame.Size = fullSize
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 55)
    MainFrame.BorderSizePixel = 1
    MainFrame.ClipsDescendants = true -- Penting untuk animasi minimize
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- 3. TOP BAR (Judul, Minimize, Close)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TopBar.BorderSizePixel = 0
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.Size = UDim2.new(1, -60, 1, 0) -- Sisakan ruang untuk 2 tombol
    TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)

    -- Tombol Close (Toggle)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Parent = TopBar
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    
    -- Tombol Minimize
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Parent = TopBar
    MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Text = "–" -- Karakter minus
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 20 -- Sedikit lebih besar agar terlihat

    -- 4. CONTAINER UTAMA (Untuk Tab Kiri dan Konten Kanan)
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = MainFrame
    MainContainer.Size = UDim2.new(1, 0, 1, -30) -- Penuhi sisa ruang
    MainContainer.Position = UDim2.new(0, 0, 0, 30)
    MainContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true

    -- 5. TAB BAR (Sidebar Kiri)
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Parent = MainContainer
    TabBar.Size = UDim2.new(0, 120, 1, 0)
    TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 3
    Instance.new("UIPadding", TabBar).PaddingTop = UDim.new(0, 5)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    -- 6. CONTENT FRAME (Konten Kanan)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainContainer
    ContentFrame.Size = UDim2.new(1, -120, 1, 0)
    ContentFrame.Position = UDim2.new(0, 120, 0, 0)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true

    -- 7. PAGE LAYOUT (Untuk switching halaman)
    local PageLayout = Instance.new("UIPageLayout")
    PageLayout.Parent = ContentFrame
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Animated = true
    PageLayout.EasingStyle = Enum.EasingStyle.Quint
    PageLayout.EasingDirection = Enum.EasingDirection.Out
    PageLayout.TweenTime = 0.3
    
    -- Penyesuaian untuk Mobile
    local function CheckDevice()
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
            -- Ini adalah Mobile
            fullSize = UDim2.new(0.9, 0, 0.7, 0)
            minimizedSize = UDim2.new(0.6, 0, 0, 30)
            MainFrame.Size = fullSize
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TabBar.Size = UDim2.new(0, 100, 1, 0) -- Tab lebih kecil
            ContentFrame.Size = UDim2.new(1, -100, 1, 0)
            ContentFrame.Position = UDim2.new(0, 100, 0, 0)
        end
    end
    CheckDevice() 

    -- Fungsi Toggle (Sembunyikan/Tampilkan) - Tombol 'X'
    local function ToggleUI()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
        -- Jika Anda ingin animasi fade, ini akan jauh lebih rumit
        -- Untuk mobile, Visible = true/false adalah yang paling ringan
    end
    
    CloseButton.MouseButton1Click:Connect(ToggleUI)
    
    -- Fungsi Minimize - Tombol '–'
    local function ToggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            -- Kecilkan
            MainContainer.Visible = false
            TitleLabel.Text = title -- Tampilkan judul penuh
            TweenService:Create(MainFrame, TWEEN_INFO, {Size = minimizedSize, Position = UDim2.new(0.5, 0, 0.1, 0)}):Play()
        else
            -- Besarkan
            MainContainer.Visible = true
            TitleLabel.Text = title
            TweenService:Create(MainFrame, TWEEN_INFO, {Size = fullSize, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
    
    -- Hotkey
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == hotkey then
            ToggleUI()
        end
    end)
    
    
    --- FUNGSI: MEMBUAT TAB BARU ---
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Warna
        local color_Active = Color3.fromRGB(50, 50, 55)
        local color_Inactive = Color3.fromRGB(40, 40, 45)
        local color_TextActive = Color3.fromRGB(255, 255, 255)
        local color_TextInactive = Color3.fromRGB(200, 200, 200)

        -- Buat Tombol Tab di Sidebar Kiri
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Parent = TabBar
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, 0)
        TabButton.BackgroundColor3 = color_Inactive
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = tabName
        TabButton.TextColor3 = color_TextInactive
        TabButton.TextSize = 16
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
        
        -- Buat Halaman Konten di Kanan
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName .. "_Page"
        TabPage.Parent = ContentFrame
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        TabPage.BorderSizePixel = 0
        TabPage.ScrollBarThickness = 3
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UIPadding", TabPage).PaddingLeft = UDim.new(0, 10)
        Instance.new("UIPadding", TabPage).PaddingRight = UDim.new(0, 10)
        Instance.new("UIPadding", TabPage).PaddingTop = UDim.new(0, 10)
        
        local PageListLayout = Instance.new("UIListLayout")
        PageListLayout.Parent = TabPage
        PageListLayout.FillDirection = Enum.FillDirection.Vertical
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, 8)
        
        -- Simpan referensi
        Tab.Button = TabButton
        Tab.Page = TabPage
        Window.Tabs[tabName] = Tab

        -- Atur Tab Pertama sebagai Default
        if not defaultTabName then
            defaultTabName = tabName
            Window.CurrentTab = Tab
            TabButton.BackgroundColor3 = color_Active
            TabButton.TextColor3 = color_TextActive
            PageLayout:JumpTo(TabPage)
        end
        
        -- Fungsi Klik Tab
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            
            -- Reset tab lama (dengan tween)
            TweenService:Create(Window.CurrentTab.Button, TWEEN_INFO, {BackgroundColor3 = color_Inactive, TextColor3 = color_TextInactive}):Play()
            
            -- Atur tab baru (dengan tween)
            TweenService:Create(TabButton, TWEEN_INFO, {BackgroundColor3 = color_Active, TextColor3 = color_TextActive}):Play()
            
            -- Ganti Halaman
            PageLayout:JumpTo(TabPage)
            Window.CurrentTab = Tab
        end)
        
        --- FUNGSI ELEMEN (di dalam Tab) ---
        
        function Tab:CreateButton(btnOptions)
            local btnName = btnOptions.Name or "Button"
            local btnCallback = btnOptions.Callback or function() print(btnName .. " Ditekan") end
            
            local color_Base = Color3.fromRGB(50, 50, 55)
            local color_Hover = Color3.fromRGB(70, 70, 75)
            
            local Button = Instance.new("TextButton")
            Button.Name = btnName
            Button.Parent = TabPage
            Button.Size = UDim2.new(1, 0, 0, 35)
            Button.BackgroundColor3 = color_Base
            Button.Font = Enum.Font.SourceSans
            Button.Text = btnName
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 16
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            
            Button.MouseButton1Click:Connect(btnCallback)
            
            -- Hover Effects
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = color_Hover}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = color_Base}):Play()
            end)
            
            return Button
        end

        function Tab:CreateToggle(tglOptions)
            local tglName = tglOptions.Name or "Toggle"
            local tglCallback = tglOptions.Callback or function(val) print(tglName, "diatur ke", val) end
            local tglDefault = tglOptions.CurrentValue or false
            
            local isEnabled = tglDefault
            
            local color_On = Color3.fromRGB(70, 150, 70)
            local color_Off = Color3.fromRGB(150, 70, 70)
            
            local ToggleFrame = Instance.new("TextButton") -- Ganti ke TextButton agar bisa diklik
            ToggleFrame.Name = tglName .. "_Frame"
            ToggleFrame.Parent = TabPage
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            ToggleFrame.Text = "" -- Hapus teks, hanya untuk klik
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.BackgroundTransparency = 1
            Label.BorderSizePixel = 0
            Label.Font = Enum.Font.SourceSans
            Label.Text = tglName
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            
            local Switch = Instance.new("TextButton")
            Switch.Parent = ToggleFrame
            Switch.Size = UDim2.new(0, 40, 0, 25)
            Switch.Position = UDim2.new(1, -45, 0.5, -12.5)
            Switch.Font = Enum.Font.SourceSansBold
            Switch.TextSize = 14
            Switch.TextColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 4)
            
            local function updateVisuals()
                if isEnabled then
                    Switch.Text = "ON"
                    TweenService:Create(Switch, TWEEN_INFO, {BackgroundColor3 = color_On}):Play()
                else
                    Switch.Text = "OFF"
                    TweenService:Create(Switch, TWEEN_INFO, {BackgroundColor3 = color_Off}):Play()
                end
            end
            
            updateVisuals()
            
            local function onToggle()
                isEnabled = not isEnabled
                updateVisuals()
                pcall(tglCallback, isEnabled)
            end
            
            ToggleFrame.MouseButton1Click:Connect(onToggle)
            Switch.MouseButton1Click:Connect(onToggle)
            
            return ToggleFrame
        end

        function Tab:CreateLabel(labelText)
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = TabPage
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            Label.Font = Enum.Font.SourceSansItalic
            Label.Text = "  " .. labelText -- Tambah spasi
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 6)
            return Label
        end
        
        return Tab
    end
    
    --- FUNGSI: HANCURKAN GUI ---
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return VLib
