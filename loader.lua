-- =================================================================
-- VLib 2.0
-- Dibuat oleh AI (Gemini) untuk Vanitas
-- Fitur: Kategori di kiri, support PC + Mobile, ringan.
-- =================================================================

local VLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Fungsi untuk membuat GUI utama
function VLib:CreateWindow(options)
    local title = options.Name or "VLib Window"
    local hotkey = options.Hotkey or Enum.KeyCode.RightShift
    local defaultTabName = nil
    
    -- Objek Window yang akan kita kembalikan
    local Window = {}
    Window.Tabs = {} -- Menyimpan referensi ke tab dan halamannya
    Window.CurrentTab = nil

    -- 1. SCREEN GUI (Kontainer Utama)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "VLib_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    Window.ScreenGui = ScreenGui -- Simpan referensi

    -- 2. MAIN FRAME (Jendela Utama)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 500, 0, 350) -- Ukuran PC
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 55)
    MainFrame.BorderSizePixel = 1
    MainFrame.Visible = true

    -- 3. TOP BAR (Hanya untuk Judul dan Tombol Close)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TopBar.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.Size = UDim2.new(1, -30, 1, 0) -- Sisakan ruang untuk tombol close
    TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)

    -- Tombol Close/Toggle
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Parent = TopBar
    ToggleButton.Size = UDim2.new(0, 30, 1, 0)
    ToggleButton.Position = UDim2.new(1, -30, 0, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "X"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16

    -- 4. CONTAINER UTAMA (Untuk Tab Kiri dan Konten Kanan)
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = MainFrame
    MainContainer.Size = UDim2.new(1, 0, 1, -30) -- Penuhi sisa ruang
    MainContainer.Position = UDim2.new(0, 0, 0, 30)
    MainContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    MainContainer.BorderSizePixel = 0

    -- 5. TAB BAR (Sidebar Kiri)
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Parent = MainContainer
    TabBar.Size = UDim2.new(0, 120, 1, 0) -- Lebar 120 piksel
    TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 3

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    -- 6. CONTENT FRAME (Konten Kanan)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainContainer
    ContentFrame.Size = UDim2.new(1, -120, 1, 0) -- Penuhi sisa ruang
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
            MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0) -- Buat lebih besar
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TabBar.Size = UDim2.new(0, 100, 1, 0) -- Tab lebih kecil
            ContentFrame.Size = UDim2.new(1, -100, 1, 0)
            ContentFrame.Position = UDim2.new(0, 100, 0, 0)
        end
    end
    CheckDevice() -- Jalankan saat inisialisasi

    -- Fungsi Toggle (Sembunyikan/Tampilkan)
    local isVisible = true
    local function ToggleUI()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end
    
    ToggleButton.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == hotkey then
            ToggleUI()
        end
    end)
    
    
    --- FUNGSI: MEMBUAT TAB BARU ---
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Buat Tombol Tab di Sidebar Kiri
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Parent = TabBar
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 16
        
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
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55) -- Warna aktif
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PageLayout:JumpTo(TabPage)
        end
        
        -- Fungsi Klik Tab
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end -- Jangan lakukan apa-apa jika tab sudah aktif
            
            -- Reset warna tab lama
            Window.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Window.CurrentTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            
            -- Atur warna tab baru
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Ganti Halaman
            PageLayout:JumpTo(TabPage)
            Window.CurrentTab = Tab
        end)
        
        --- FUNGSI ELEMEN (di dalam Tab) ---
        
        function Tab:CreateButton(btnOptions)
            local btnName = btnOptions.Name or "Button"
            local btnCallback = btnOptions.Callback or function() print(btnName .. " Ditekan") end
            
            local Button = Instance.new("TextButton")
            Button.Name = btnName
            Button.Parent = TabPage -- Tambahkan ke Halaman, BUKAN ke TabBar
            Button.Size = UDim2.new(1, -10, 0, 35) -- Lebar penuh dikurangi padding
            Button.Position = UDim2.new(0, 5, 0, 0) -- Posisi diatur ListLayout
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Button.BorderColor3 = Color3.fromRGB(80, 80, 80)
            Button.BorderSizePixel = 1
            Button.Font = Enum.Font.SourceSans
            Button.Text = btnName
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.TextSize = 16
            
            Button.MouseButton1Click:Connect(btnCallback)
            return Button
        end

        function Tab:CreateToggle(tglOptions)
            local tglName = tglOptions.Name or "Toggle"
            local tglCallback = tglOptions.Callback or function(val) print(tglName, "diatur ke", val) end
            local tglDefault = tglOptions.CurrentValue or false
            
            local isEnabled = tglDefault
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = tglName .. "_Frame"
            ToggleFrame.Parent = TabPage
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.Position = UDim2.new(0, 5, 0, 0)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            ToggleFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
            ToggleFrame.BorderSizePixel = 1
            
            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.Size = UDim2.new(1, -50, 1, 0) -- Sisakan ruang untuk tombol switch
            Label.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Label.BorderSizePixel = 0
            Label.Font = Enum.Font.SourceSans
            Label.Text = tglName
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            
            local Switch = Instance.new("TextButton")
            Switch.Parent = ToggleFrame
            Switch.Size = UDim2.new(0, 40, 0, 25) -- Switch kecil di kanan
            Switch.Position = UDim2.new(1, -45, 0.5, -12.5) -- Posisikan di kanan tengah
            Switch.Font = Enum.Font.SourceSansBold
            Switch.TextSize = 14
            
            local function updateVisuals()
                if isEnabled then
                    Switch.Text = "ON"
                    Switch.BackgroundColor3 = Color3.fromRGB(70, 150, 70) -- Hijau
                else
                    Switch.Text = "OFF"
                    Switch.BackgroundColor3 = Color3.fromRGB(150, 70, 70) -- Merah
                end
            end
            
            updateVisuals() -- Atur tampilan awal
            
            ToggleFrame.MouseButton1Click:Connect(function()
                isEnabled = not isEnabled
                updateVisuals()
                pcall(tglCallback, isEnabled) -- Panggil callback
            end)
            Switch.MouseButton1Click:Connect(function()
                isEnabled = not isEnabled
                updateVisuals()
                pcall(tglCallback, isEnabled) -- Panggil callback
            end)
            
            return ToggleFrame
        end

        function Tab:CreateLabel(labelText)
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = TabPage
            Label.Size = UDim2.new(1, -10, 0, 30)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            Label.BorderSizePixel = 0
            Label.Font = Enum.Font.SourceSansItalic
            Label.Text = labelText
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 14
            return Label
        end

        -- Anda bisa menambahkan :CreateSlider, :CreateInput, dll. di sini
        
        return Tab
    end
    
    --- FUNGSI: HANCURKAN GUI ---
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return VLib
