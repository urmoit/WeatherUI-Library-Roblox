--!native
--!optimize 2

local game = game
local GetService = game.GetService

cloneref = cloneref or function(...)
    return ...
end

local TweenService = GetService(game, "TweenService")
local UserInputService = GetService(game, "UserInputService")
local RunService = GetService(game, "RunService")
local Players = GetService(game, "Players")
local CoreGui = cloneref(GetService(game, "CoreGui"))
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local IsOnMobile = table.find({
    Enum.Platform.IOS,
    Enum.Platform.Android
}, UserInputService:GetPlatform())

local IsOnEmulator = IsOnMobile and UserInputService.KeyboardEnabled

local WeatherUI = {
    Version = "2.0.0",
    Themes = {
        Dark = {
            Main = Color3.fromRGB(25, 25, 25),
            Secondary = Color3.fromRGB(35, 35, 35),
            Accent = Color3.fromRGB(0, 120, 215),
            Text = Color3.fromRGB(240, 240, 240),
            Border = Color3.fromRGB(60, 60, 60),
            CornerRadius = 8,
            ShadowColor = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.7
        },
        Light = {
            Main = Color3.fromRGB(240, 240, 240),
            Secondary = Color3.fromRGB(220, 220, 220),
            Accent = Color3.fromRGB(0, 90, 180),
            Text = Color3.fromRGB(30, 30, 30),
            Border = Color3.fromRGB(180, 180, 180),
            CornerRadius = 8,
            ShadowColor = Color3.fromRGB(150, 150, 150),
            ShadowTransparency = 0.5
        }
    }
}

local function GenerateString()
    local Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local Result = ""
    for I = 1, 12 do
        local RandIndex = math.random(1, #Charset)
        Result = Result .. Charset:sub(RandIndex, RandIndex)
    end
    return Result
end

function WeatherUI:DragFunc(g, h)
    h = h or g
    local dragging = false
    local dragStart, frameStart
    
    g.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = h.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            h.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
end

-- Apply modern styling to UI elements
local function applyModernStyle(frame, theme)
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.CornerRadius)
    corner.Parent = frame
    
    -- Add border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Parent = frame
    
    -- Add shadow (for main window)
    if frame.Name == "MainWindow" then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, -5, 0, -5)
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = theme.ShadowColor
        shadow.ImageTransparency = theme.ShadowTransparency
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.BackgroundTransparency = 1
        shadow.ZIndex = -1
        shadow.Parent = frame
    end
end

-- Main UI container
local WeatherUIInstance = Instance.new("ScreenGui")
WeatherUIInstance.Name = "WeatherUI_"..GenerateString()
WeatherUIInstance.ResetOnSpawn = false
WeatherUIInstance.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WeatherUIInstance.Parent = CoreGui

if gethui then
    WeatherUIInstance.Parent = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
    WeatherUIInstance.Parent = CoreGui:FindFirstChild("RobloxGui")
end

function WeatherUI:ToggleUI(State)
    if self.MainWindow then
        self.MainWindow.Visible = State or not self.MainWindow.Visible
        if self.ToggleButton then
            self.ToggleButton.Text = self.MainWindow.Visible and "◄" or "►"
        end
    end
end

function WeatherUI:CreateWindow(options)
    options = options or {}
    local theme = options.Theme or self.Themes.Dark
    
    local window = {
        Tabs = {},
        CurrentTab = nil,
        Theme = theme,
        Instance = nil
    }
    
    -- Main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = theme.Main
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = WeatherUIInstance
    
    -- Apply modern styling
    applyModernStyle(mainFrame, theme)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Text = options.Title or "WeatherUI Window"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.TextColor3 = theme.Text
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button (modern style)
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0.5, -10)
    closeButton.Image = "rbxassetid://10734891696" -- X icon
    closeButton.ImageColor3 = theme.Text
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
        window.Instance = nil
        if self.ToggleButton then
            self.ToggleButton:Destroy()
        end
    end)
    
    -- Tab container (modern style)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Content container
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -30)
    contentContainer.Position = UDim2.new(0, 120, 0, 30)
    contentContainer.BackgroundColor3 = theme.Main
    contentContainer.BorderSizePixel = 0
    contentContainer.ClipsDescendants = true
    contentContainer.ScrollBarThickness = 5
    contentContainer.ScrollBarImageColor3 = theme.Accent
    contentContainer.Parent = mainFrame
    
    -- Dragging functionality
    self:DragFunc(titleBar, mainFrame)
    
    -- Create UI toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "UIToggle"
    toggleButton.Size = UDim2.new(0, 40, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0.5, -20)
    toggleButton.BackgroundColor3 = theme.Secondary
    toggleButton.TextColor3 = theme.Text
    toggleButton.Text = "◄"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 16
    toggleButton.ZIndex = 100
    toggleButton.Parent = WeatherUIInstance
    
    -- Style toggle button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toggleButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Parent = toggleButton
    
    -- Toggle functionality
    toggleButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    
    -- Make toggle draggable
    self:DragFunc(toggleButton)
    
    -- Keybind to toggle UI (F5)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F5 then
            self:ToggleUI()
        end
    end)
    
    self.ToggleButton = toggleButton
    
    -- Tab creation
    function window:CreateTab(tabOptions)
        local name = typeof(tabOptions) == "table" and tabOptions.Name or tabOptions
        local icon = typeof(tabOptions) == "table" and tabOptions.Icon or nil
        
        local tab = {
            Name = name,
            Sections = {}
        }
        
        -- Tab button (modern style)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Text = ""
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, #window.Tabs * 40 + 5)
        tabButton.BackgroundColor3 = theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer
        
        -- Tab icon (if provided)
        if icon then
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Name = "Icon"
            tabIcon.Size = UDim2.new(0, 20, 0, 20)
            tabIcon.Position = UDim2.new(0, 10, 0.5, -10)
            tabIcon.Image = icon
            tabIcon.BackgroundTransparency = 1
            tabIcon.Parent = tabButton
        end
        
        -- Tab label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Text = name
        tabLabel.Size = UDim2.new(1, icon and -40 or -20, 1, 0)
        tabLabel.Position = UDim2.new(0, icon and 35 or 15, 0, 0)
        tabLabel.TextColor3 = theme.Text
        tabLabel.BackgroundTransparency = 1
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.TextSize = 12
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton
        
        -- Tab content
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = name
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Position = UDim2.new(0, 0, 0, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 5
        tabFrame.ScrollBarImageColor3 = theme.Accent
        tabFrame.Visible = false
        tabFrame.Parent = contentContainer
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = tabFrame
        
        -- Set as current tab if first
        if #window.Tabs == 0 then
            window.CurrentTab = tab
            tabButton.BackgroundColor3 = theme.Accent
            tabFrame.Visible = true
        end
        
        -- Tab selection
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(window.Tabs) do
                contentContainer:FindFirstChild(otherTab.Name).Visible = false
                tabContainer:FindFirstChild(otherTab.Name).BackgroundColor3 = theme.Secondary
            end
            
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = theme.Accent
            window.CurrentTab = tab
        end)
        
        -- Section creation
        function tab:CreateSection(name, style)
            style = style or "Normal"
            local section = {
                Name = name,
                Elements = {}
            }
            
            -- Section frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = name
            sectionFrame.Size = UDim2.new(1, -20, 0, 0)
            sectionFrame.Position = UDim2.new(0, 10, 0, 0)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = tabFrame
            
            -- Section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Text = name
            sectionTitle.Size = UDim2.new(1, 0, 0, 20)
            sectionTitle.Position = UDim2.new(0, 0, 0, 0)
            sectionTitle.TextColor3 = theme.Text
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Font = Enum.Font.GothamSemibold
            sectionTitle.TextSize = 14
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionFrame
            
            -- Section content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Position = UDim2.new(0, 0, 0, 25)
            sectionContent.BackgroundColor3 = theme.Secondary
            sectionContent.Parent = sectionFrame
            
            -- Apply modern styling to section
            applyModernStyle(sectionContent, theme)
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 5)
            contentLayout.Parent = sectionContent
            
            -- Auto-size sections
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, -20, 0, contentLayout.AbsoluteContentSize.Y + 25)
                tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
            end)
            
            -- Toggle element (modern style)
            function section:CreateToggle(options)
                local toggle = {
                    Value = options.Default or false,
                    Callback = options.Callback or function() end
                }
                
                -- Toggle frame
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = options.Name
                toggleFrame.Size = UDim2.new(1, -10, 0, 30)
                toggleFrame.Position = UDim2.new(0, 5, 0, 0)
                toggleFrame.BackgroundColor3 = theme.Secondary
                toggleFrame.Parent = sectionContent
                
                -- Apply modern styling
                applyModernStyle(toggleFrame, theme)
                
                -- Label
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.Text = options.Name
                toggleLabel.Size = UDim2.new(1, -50, 1, 0)
                toggleLabel.Position = UDim2.new(0, 10, 0, 0)
                toggleLabel.TextColor3 = theme.Text
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextSize = 12
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                -- Switch (modern style)
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "Switch"
                toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                toggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
                toggleSwitch.BackgroundColor3 = theme.Secondary
                toggleSwitch.Parent = toggleFrame
                
                applyModernStyle(toggleSwitch, theme)
                
                local toggleButton = Instance.new("Frame")
                toggleButton.Name = "Button"
                toggleButton.Size = UDim2.new(0, 16, 0, 16)
                toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
                toggleButton.BackgroundColor3 = theme.Text
                toggleButton.Parent = toggleSwitch
                
                applyModernStyle(toggleButton, theme)
                
                -- Update toggle state
                local function updateToggle()
                    if toggle.Value then
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                            Position = UDim2.new(1, -18, 0.5, -8),
                            BackgroundColor3 = theme.Accent
                        }):Play()
                        TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(theme.Accent.R * 255 * 0.7),
                                math.floor(theme.Accent.G * 255 * 0.7),
                                math.floor(theme.Accent.B * 255 * 0.7)
                            )
                        }):Play()
                    else
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, 2, 0.5, -8),
                            BackgroundColor3 = theme.Text
                        }):Play()
                        TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = theme.Secondary
                        }):Play()
                    end
                end
                
                -- Initial state
                updateToggle()
                
                -- Interaction
                toggleSwitch.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    updateToggle()
                    toggle.Callback(toggle.Value)
                end)
                
                -- Set function
                function toggle:Set(value)
                    toggle.Value = value
                    updateToggle()
                    toggle.Callback(toggle.Value)
                end
                
                return toggle
            end
            
            -- Button element (modern style)
            function section:CreateButton(options)
                local button = {
                    Callback = options.Callback or function() end
                }
                
                -- Button frame
                local buttonFrame = Instance.new("TextButton")
                buttonFrame.Name = options.Name
                buttonFrame.Text = options.Name
                buttonFrame.Size = UDim2.new(1, -10, 0, 30)
                buttonFrame.Position = UDim2.new(0, 5, 0, 0)
                buttonFrame.BackgroundColor3 = theme.Accent
                buttonFrame.TextColor3 = theme.Text
                buttonFrame.Font = Enum.Font.Gotham
                buttonFrame.TextSize = 12
                buttonFrame.AutoButtonColor = false
                buttonFrame.Parent = sectionContent
                
                -- Apply modern styling
                applyModernStyle(buttonFrame, theme)
                
                -- Interaction
                buttonFrame.MouseEnter:Connect(function()
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(theme.Accent.R * 255 * 0.8),
                            math.floor(theme.Accent.G * 255 * 0.8),
                            math.floor(theme.Accent.B * 255 * 0.8)
                        )
                    }):Play()
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = theme.Accent
                    }):Play()
                end)
                
                buttonFrame.MouseButton1Click:Connect(function()
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(theme.Accent.R * 255 * 0.6),
                            math.floor(theme.Accent.G * 255 * 0.6),
                            math.floor(theme.Accent.B * 255 * 0.6)
                        )
                    }):Play()
                    
                    TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = theme.Accent
                    }):Play()
                    
                    button.Callback()
                end)
                
                return button
            end
            
            -- Slider element (modern style)
            function section:CreateSlider(options)
                local slider = {
                    Value = options.Default or options.Min,
                    Min = options.Min or 0,
                    Max = options.Max or 100,
                    Callback = options.Callback or function() end
                }
                
                -- Slider frame
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = options.Name
                sliderFrame.Size = UDim2.new(1, -10, 0, 50)
                sliderFrame.Position = UDim2.new(0, 5, 0, 0)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionContent
                
                -- Label
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.Text = options.Name
                sliderLabel.Size = UDim2.new(1, 0, 0, 20)
                sliderLabel.Position = UDim2.new(0, 0, 0, 0)
                sliderLabel.TextColor3 = theme.Text
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextSize = 12
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                -- Value display
                local sliderValue = Instance.new("TextLabel")
                sliderValue.Name = "Value"
                sliderValue.Text = slider.Value
                sliderValue.Size = UDim2.new(0, 50, 0, 20)
                sliderValue.Position = UDim2.new(1, -50, 0, 0)
                sliderValue.TextColor3 = theme.Text
                sliderValue.BackgroundTransparency = 1
                sliderValue.Font = Enum.Font.Gotham
                sliderValue.TextSize = 12
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.Parent = sliderFrame
                
                -- Track
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Size = UDim2.new(1, 0, 0, 5)
                sliderTrack.Position = UDim2.new(0, 0, 0, 25)
                sliderTrack.BackgroundColor3 = theme.Secondary
                sliderTrack.Parent = sliderFrame
                
                applyModernStyle(sliderTrack, theme)
                
                -- Fill
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.Position = UDim2.new(0, 0, 0, 0)
                sliderFill.BackgroundColor3 = theme.Accent
                sliderFill.Parent = sliderTrack
                
                applyModernStyle(sliderFill, theme)
                
                -- Button
                local sliderButton = Instance.new("Frame")
                sliderButton.Name = "Button"
                sliderButton.Size = UDim2.new(0, 15, 0, 15)
                sliderButton.Position = UDim2.new(0, 0, 0.5, -7.5)
                sliderButton.BackgroundColor3 = theme.Text
                sliderButton.Parent = sliderTrack
                
                applyModernStyle(sliderButton, theme)
                
                -- Set value function
                local function setValue(value)
                    slider.Value = math.clamp(value, slider.Min, slider.Max)
                    local ratio = (slider.Value - slider.Min) / (slider.Max - slider.Min)
                    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                    sliderButton.Position = UDim2.new(ratio, -7.5, 0.5, -7.5)
                    sliderValue.Text = tostring(math.floor(slider.Value * 100) / 100)
                    slider.Callback(slider.Value)
                end
                
                -- Initial value
                setValue(slider.Value)
                
                -- Interaction
                local dragging = false
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = input.Position.X
                        local absolutePos = sliderTrack.AbsolutePosition.X
                        local absoluteSize = sliderTrack.AbsoluteSize.X
                        
                        local ratio = math.clamp((mousePos - absolutePos) / absoluteSize, 0, 1)
                        setValue(slider.Min + ratio * (slider.Max - slider.Min))
                    end
                end)
                
                -- Set function
                function slider:Set(value)
                    setValue(value)
                end
                
                return slider
            end
            
            -- Dropdown element (modern style)
            function section:CreateDropdown(options)
                local dropdown = {
                    Value = options.Default or options.Options[1],
                    Options = options.Options or {"Option 1", "Option 2"},
                    Callback = options.Callback or function() end
                }
                
                -- Dropdown frame
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = options.Name
                dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
                dropdownFrame.Position = UDim2.new(0, 5, 0, 0)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionContent
                
                -- Label
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "Label"
                dropdownLabel.Text = options.Name
                dropdownLabel.Size = UDim2.new(1, -120, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                dropdownLabel.TextColor3 = theme.Text
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextSize = 12
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                -- Button
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "Button"
                dropdownButton.Text = dropdown.Value
                dropdownButton.Size = UDim2.new(0, 100, 0, 25)
                dropdownButton.Position = UDim2.new(1, -100, 0.5, -12.5)
                dropdownButton.BackgroundColor3 = theme.Secondary
                dropdownButton.TextColor3 = theme.Text
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.TextSize = 12
                dropdownButton.AutoButtonColor = false
                dropdownButton.Parent = dropdownFrame
                
                applyModernStyle(dropdownButton, theme)
                
                -- List
                local dropdownList = Instance.new("Frame")
                dropdownList.Name = "List"
                dropdownList.Size = UDim2.new(0, 100, 0, 0)
                dropdownList.Position = UDim2.new(1, -100, 0, 30)
                dropdownList.BackgroundColor3 = theme.Secondary
                dropdownList.Visible = false
                dropdownList.Parent = dropdownFrame
                
                applyModernStyle(dropdownList, theme)
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.Padding = UDim.new(0, 2)
                listLayout.Parent = dropdownList
                
                -- Create options
                local function createOptions()
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, option in pairs(dropdown.Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option
                        optionButton.Text = option
                        optionButton.Size = UDim2.new(1, -10, 0, 25)
                        optionButton.Position = UDim2.new(0, 5, 0, 0)
                        optionButton.BackgroundColor3 = theme.Secondary
                        optionButton.TextColor3 = theme.Text
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.TextSize = 12
                        optionButton.AutoButtonColor = false
                        optionButton.Parent = dropdownList
                        
                        applyModernStyle(optionButton, theme)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdown.Value = option
                            dropdownButton.Text = option
                            dropdownList.Visible = false
                            dropdown.Callback(option)
                        end)
                    end
                    
                    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        dropdownList.Size = UDim2.new(0, 100, 0, listLayout.AbsoluteContentSize.Y)
                    end)
                end
                
                createOptions()
                
                -- Interaction
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not dropdownButton:IsDescendantOf(input.Target) and not dropdownList:IsDescendantOf(input.Target) then
                            dropdownList.Visible = false
                        end
                    end
                end)
                
                -- Set function
                function dropdown:Set(value)
                    if table.find(dropdown.Options, value) then
                        dropdown.Value = value
                        dropdownButton.Text = value
                        dropdown.Callback(value)
                    end
                end
                
                -- Update options
                function dropdown:UpdateOptions(newOptions)
                    dropdown.Options = newOptions
                    createOptions()
                end
                
                return dropdown
            end
            
            table.insert(section.Elements, section)
            return section
        end
        
        table.insert(window.Tabs, tab)
        return tab
    end
    
    window.Instance = mainFrame
    self.MainWindow = mainFrame
    
    return window
end

return WeatherUI
