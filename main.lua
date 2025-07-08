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
    Version = "1.0.0",
    Themes = {
        Dark = {
            Main = Color3.fromRGB(25, 25, 25),
            Secondary = Color3.fromRGB(35, 35, 35),
            Accent = Color3.fromRGB(0, 120, 215),
            Text = Color3.fromRGB(240, 240, 240),
            Border = Color3.fromRGB(60, 60, 60)
        },
        Light = {
            Main = Color3.fromRGB(240, 240, 240),
            Secondary = Color3.fromRGB(220, 220, 220),
            Accent = Color3.fromRGB(0, 90, 180),
            Text = Color3.fromRGB(30, 30, 30),
            Border = Color3.fromRGB(180, 180, 180)
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
    mainFrame.BorderColor3 = theme.Border
    mainFrame.BorderSizePixel = 1
    mainFrame.Parent = WeatherUIInstance
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
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
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = theme.Text
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
        window.Instance = nil
    end)
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -30)
    contentContainer.Position = UDim2.new(0, 120, 0, 30)
    contentContainer.BackgroundColor3 = theme.Main
    contentContainer.BorderSizePixel = 0
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- Dragging functionality
    self:DragFunc(titleBar, mainFrame)
    
    -- Tab creation
    function window:CreateTab(name)
        local tab = {
            Name = name,
            Sections = {}
        }
        
        -- Tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Text = name
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.Position = UDim2.new(0, 0, 0, #window.Tabs * 40)
        tabButton.BackgroundColor3 = theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.TextColor3 = theme.Text
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 12
        tabButton.Parent = tabContainer
        
        -- Tab content
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = name
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Position = UDim2.new(0, 0, 0, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.ScrollBarThickness = 5
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
        function tab:CreateSection(name)
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
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 5)
            contentLayout.Parent = sectionContent
            
            -- Auto-size sections
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, -20, 0, contentLayout.AbsoluteContentSize.Y + 25)
                tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
            end)
            
            -- Toggle element
            function section:CreateToggle(options)
                local toggle = {
                    Value = options.Default or false,
                    Callback = options.Callback or function() end
                }
                
                -- Toggle frame
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = options.Name
                toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionContent
                
                -- Label
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.Text = options.Name
                toggleLabel.Size = UDim2.new(1, -50, 1, 0)
                toggleLabel.Position = UDim2.new(0, 0, 0, 0)
                toggleLabel.TextColor3 = theme.Text
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextSize = 12
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                -- Switch
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "Switch"
                toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                toggleSwitch.Position = UDim2.new(1, -40, 0.5, -10)
                toggleSwitch.BackgroundColor3 = theme.Secondary
                toggleSwitch.Parent = toggleFrame
                
                local toggleButton = Instance.new("Frame")
                toggleButton.Name = "Button"
                toggleButton.Size = UDim2.new(0, 16, 0, 16)
                toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
                toggleButton.BackgroundColor3 = theme.Text
                toggleButton.Parent = toggleSwitch
                
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
            
            -- Button element
            function section:CreateButton(options)
                local button = {
                    Callback = options.Callback or function() end
                }
                
                -- Button frame
                local buttonFrame = Instance.new("TextButton")
                buttonFrame.Name = options.Name
                buttonFrame.Text = options.Name
                buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                buttonFrame.BackgroundColor3 = theme.Accent
                buttonFrame.TextColor3 = theme.Text
                buttonFrame.Font = Enum.Font.Gotham
                buttonFrame.TextSize = 12
                buttonFrame.Parent = sectionContent
                
                -- Interaction
                buttonFrame.MouseButton1Click:Connect(function()
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(theme.Accent.R * 255 * 0.7),
                            math.floor(theme.Accent.G * 255 * 0.7),
                            math.floor(theme.Accent.B * 255 * 0.7)
                        )
                    }):Play()
                    
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = theme.Accent
                    }):Play()
                    
                    button.Callback()
                end)
                
                return button
            end
            
            -- Slider element
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
                sliderFrame.Size = UDim2.new(1, 0, 0, 50)
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
                
                -- Fill
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.Position = UDim2.new(0, 0, 0, 0)
                sliderFill.BackgroundColor3 = theme.Accent
                sliderFill.Parent = sliderTrack
                
                -- Button
                local sliderButton = Instance.new("Frame")
                sliderButton.Name = "Button"
                sliderButton.Size = UDim2.new(0, 15, 0, 15)
                sliderButton.Position = UDim2.new(0, 0, 0.5, -7.5)
                sliderButton.BackgroundColor3 = theme.Text
                sliderButton.Parent = sliderTrack
                
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
            
            -- Dropdown element
            function section:CreateDropdown(options)
                local dropdown = {
                    Value = options.Default or options.Options[1],
                    Options = options.Options or {"Option 1", "Option 2"},
                    Callback = options.Callback or function() end
                }
                
                -- Dropdown frame
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = options.Name
                dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionContent
                
                -- Label
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "Label"
                dropdownLabel.Text = options.Name
                dropdownLabel.Size = UDim2.new(1, 0, 1, 0)
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
                dropdownButton.Size = UDim2.new(0, 120, 0, 25)
                dropdownButton.Position = UDim2.new(1, -120, 0.5, -12.5)
                dropdownButton.BackgroundColor3 = theme.Secondary
                dropdownButton.TextColor3 = theme.Text
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.TextSize = 12
                dropdownButton.Parent = dropdownFrame
                
                -- List
                local dropdownList = Instance.new("Frame")
                dropdownList.Name = "List"
                dropdownList.Size = UDim2.new(0, 120, 0, 0)
                dropdownList.Position = UDim2.new(1, -120, 0, 30)
                dropdownList.BackgroundColor3 = theme.Secondary
                dropdownList.Visible = false
                dropdownList.Parent = dropdownFrame
                
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
                        optionButton.Size = UDim2.new(1, 0, 0, 25)
                        optionButton.BackgroundColor3 = theme.Secondary
                        optionButton.TextColor3 = theme.Text
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.TextSize = 12
                        optionButton.Parent = dropdownList
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdown.Value = option
                            dropdownButton.Text = option
                            dropdownList.Visible = false
                            dropdown.Callback(option)
                        end)
                    end
                    
                    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        dropdownList.Size = UDim2.new(0, 120, 0, listLayout.AbsoluteContentSize.Y)
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
    
    if IsOnMobile and not IsOnEmulator then
        local mobileButton = Instance.new("TextButton")
        mobileButton.Name = "MobileToggle"
        mobileButton.Size = UDim2.new(0, 50, 0, 50)
        mobileButton.Position = UDim2.new(0, 20, 0.5, -25)
        mobileButton.BackgroundColor3 = theme.Accent
        mobileButton.TextColor3 = theme.Text
        mobileButton.Text = "☰"
        mobileButton.Font = Enum.Font.GothamBold
        mobileButton.TextSize = 24
        mobileButton.Parent = WeatherUIInstance
        
        mobileButton.MouseButton1Click:Connect(function()
            self:ToggleUI()
        end)
        
        self:DragFunc(mobileButton)
    end
    
    return window
end

return WeatherUI
