-- WeatherUI - A Modern Roblox UI Library
-- Version: 1.0.0
-- GitHub: https://github.com/Footagesus/WeatherUI

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

-- Internal variables
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Create main UI container
local WeatherUIInstance = Instance.new("ScreenGui")
WeatherUIInstance.Name = "WeatherUI"
WeatherUIInstance.ResetOnSpawn = false
WeatherUIInstance.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WeatherUIInstance.Parent = CoreGui

-- Main window creation function
function WeatherUI:CreateWindow(options)
    local window = {
        Tabs = {},
        CurrentTab = nil,
        Theme = options.Theme or self.Themes.Dark
    }
    
    -- Create main window frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = window.Theme.Main
    mainFrame.BorderColor3 = window.Theme.Border
    mainFrame.Parent = WeatherUIInstance
    
    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = window.Theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Text = options.Title or "WeatherUI Window"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.TextColor3 = window.Theme.Text
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = window.Theme.Text
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame:Destroy()
    end)
    
    -- Add tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, -30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = window.Theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Add content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, -30)
    contentContainer.Position = UDim2.new(0, 120, 0, 30)
    contentContainer.BackgroundColor3 = window.Theme.Main
    contentContainer.BorderSizePixel = 0
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- Make window draggable
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab creation function
    function window:CreateTab(name, icon)
        local tab = {
            Name = name,
            Sections = {}
        }
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Text = name
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.Position = UDim2.new(0, 0, 0, #window.Tabs * 40)
        tabButton.BackgroundColor3 = window.Theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.TextColor3 = window.Theme.Text
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 12
        tabButton.Parent = tabContainer
        
        -- Create tab content frame
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
        
        -- Set as current tab if first tab
        if #window.Tabs == 0 then
            window.CurrentTab = tab
            tabButton.BackgroundColor3 = window.Theme.Accent
            tabFrame.Visible = true
        end
        
        -- Tab selection logic
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tab frames
            for _, otherTab in pairs(window.Tabs) do
                contentContainer:FindFirstChild(otherTab.Name).Visible = false
                tabContainer:FindFirstChild(otherTab.Name).BackgroundColor3 = window.Theme.Secondary
            end
            
            -- Show this tab
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = window.Theme.Accent
            window.CurrentTab = tab
        end)
        
        -- Section creation function
        function tab:CreateSection(name)
            local section = {
                Name = name,
                Elements = {}
            }
            
            -- Create section frame
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
            sectionTitle.TextColor3 = window.Theme.Text
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
            sectionContent.BackgroundColor3 = window.Theme.Secondary
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
            
            -- Toggle creation function
            function section:CreateToggle(options)
                local toggle = {
                    Value = options.Default or false,
                    Callback = options.Callback or function() end
                }
                
                -- Create toggle frame
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = options.Name
                toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionContent
                
                -- Toggle label
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.Text = options.Name
                toggleLabel.Size = UDim2.new(1, -50, 1, 0)
                toggleLabel.Position = UDim2.new(0, 0, 0, 0)
                toggleLabel.TextColor3 = window.Theme.Text
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextSize = 12
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                -- Toggle switch
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "Switch"
                toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                toggleSwitch.Position = UDim2.new(1, -40, 0.5, -10)
                toggleSwitch.BackgroundColor3 = window.Theme.Secondary
                toggleSwitch.Parent = toggleFrame
                
                local toggleButton = Instance.new("Frame")
                toggleButton.Name = "Button"
                toggleButton.Size = UDim2.new(0, 16, 0, 16)
                toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
                toggleButton.BackgroundColor3 = window.Theme.Text
                toggleButton.Parent = toggleSwitch
                
                -- Toggle animation
                local function updateToggle()
                    if toggle.Value then
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                            Position = UDim2.new(1, -18, 0.5, -8),
                            BackgroundColor3 = window.Theme.Accent
                        }):Play()
                        TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(window.Theme.Accent.R * 255 * 0.7),
                                math.floor(window.Theme.Accent.G * 255 * 0.7),
                                math.floor(window.Theme.Accent.B * 255 * 0.7)
                            )
                        }):Play()
                    else
                        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, 2, 0.5, -8),
                            BackgroundColor3 = window.Theme.Text
                        }):Play()
                        TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = window.Theme.Secondary
                        }):Play()
                    end
                end
                
                -- Set initial state
                updateToggle()
                
                -- Toggle interaction
                toggleSwitch.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    updateToggle()
                    toggle.Callback(toggle.Value)
                end)
                
                -- Function to set toggle value
                function toggle:Set(value)
                    toggle.Value = value
                    updateToggle()
                    toggle.Callback(toggle.Value)
                end
                
                return toggle
            end
            
            -- Button creation function
            function section:CreateButton(options)
                local button = {
                    Callback = options.Callback or function() end
                }
                
                -- Create button frame
                local buttonFrame = Instance.new("TextButton")
                buttonFrame.Name = options.Name
                buttonFrame.Text = options.Name
                buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                buttonFrame.BackgroundColor3 = window.Theme.Accent
                buttonFrame.TextColor3 = window.Theme.Text
                buttonFrame.Font = Enum.Font.Gotham
                buttonFrame.TextSize = 12
                buttonFrame.Parent = sectionContent
                
                -- Button interaction
                buttonFrame.MouseButton1Click:Connect(function()
                    -- Animate button press
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(window.Theme.Accent.R * 255 * 0.7),
                            math.floor(window.Theme.Accent.G * 255 * 0.7),
                            math.floor(window.Theme.Accent.B * 255 * 0.7)
                        )
                    }):Play()
                    
                    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = window.Theme.Accent
                    }):Play()
                    
                    -- Call callback
                    button.Callback()
                end)
                
                return button
            end
            
            -- Slider creation function
            function section:CreateSlider(options)
                local slider = {
                    Value = options.Default or options.Min,
                    Min = options.Min or 0,
                    Max = options.Max or 100,
                    Callback = options.Callback or function() end
                }
                
                -- Create slider frame
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = options.Name
                sliderFrame.Size = UDim2.new(1, 0, 0, 50)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionContent
                
                -- Slider label
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.Text = options.Name
                sliderLabel.Size = UDim2.new(1, 0, 0, 20)
                sliderLabel.Position = UDim2.new(0, 0, 0, 0)
                sliderLabel.TextColor3 = window.Theme.Text
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextSize = 12
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame
                
                -- Slider value display
                local sliderValue = Instance.new("TextLabel")
                sliderValue.Name = "Value"
                sliderValue.Text = slider.Value
                sliderValue.Size = UDim2.new(0, 50, 0, 20)
                sliderValue.Position = UDim2.new(1, -50, 0, 0)
                sliderValue.TextColor3 = window.Theme.Text
                sliderValue.BackgroundTransparency = 1
                sliderValue.Font = Enum.Font.Gotham
                sliderValue.TextSize = 12
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.Parent = sliderFrame
                
                -- Slider track
                local sliderTrack = Instance.new("Frame")
                sliderTrack.Name = "Track"
                sliderTrack.Size = UDim2.new(1, 0, 0, 5)
                sliderTrack.Position = UDim2.new(0, 0, 0, 25)
                sliderTrack.BackgroundColor3 = window.Theme.Secondary
                sliderTrack.Parent = sliderFrame
                
                -- Slider fill
                local sliderFill = Instance.new("Frame")
                sliderFill.Name = "Fill"
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                sliderFill.Position = UDim2.new(0, 0, 0, 0)
                sliderFill.BackgroundColor3 = window.Theme.Accent
                sliderFill.Parent = sliderTrack
                
                -- Slider button
                local sliderButton = Instance.new("Frame")
                sliderButton.Name = "Button"
                sliderButton.Size = UDim2.new(0, 15, 0, 15)
                sliderButton.Position = UDim2.new(0, 0, 0.5, -7.5)
                sliderButton.BackgroundColor3 = window.Theme.Text
                sliderButton.Parent = sliderTrack
                
                -- Set initial value
                local function setValue(value)
                    slider.Value = math.clamp(value, slider.Min, slider.Max)
                    local ratio = (slider.Value - slider.Min) / (slider.Max - slider.Min)
                    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                    sliderButton.Position = UDim2.new(ratio, -7.5, 0.5, -7.5)
                    sliderValue.Text = tostring(math.floor(slider.Value * 100) / 100)
                    slider.Callback(slider.Value)
                end
                
                setValue(slider.Value)
                
                -- Slider interaction
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
                        local mousePos = Mouse.X
                        local absolutePos = sliderTrack.AbsolutePosition.X
                        local absoluteSize = sliderTrack.AbsoluteSize.X
                        
                        local ratio = math.clamp((mousePos - absolutePos) / absoluteSize, 0, 1)
                        setValue(slider.Min + ratio * (slider.Max - slider.Min))
                    end
                end)
                
                -- Function to set slider value
                function slider:Set(value)
                    setValue(value)
                end
                
                return slider
            end
            
            -- Dropdown creation function
            function section:CreateDropdown(options)
                local dropdown = {
                    Value = options.Default or options.Options[1],
                    Options = options.Options or {"Option 1", "Option 2"},
                    Callback = options.Callback or function() end
                }
                
                -- Create dropdown frame
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = options.Name
                dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionContent
                
                -- Dropdown label
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "Label"
                dropdownLabel.Text = options.Name
                dropdownLabel.Size = UDim2.new(1, 0, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                dropdownLabel.TextColor3 = window.Theme.Text
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextSize = 12
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame
                
                -- Dropdown button
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "Button"
                dropdownButton.Text = dropdown.Value
                dropdownButton.Size = UDim2.new(0, 120, 0, 25)
                dropdownButton.Position = UDim2.new(1, -120, 0.5, -12.5)
                dropdownButton.BackgroundColor3 = window.Theme.Secondary
                dropdownButton.TextColor3 = window.Theme.Text
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.TextSize = 12
                dropdownButton.Parent = dropdownFrame
                
                -- Dropdown list
                local dropdownList = Instance.new("Frame")
                dropdownList.Name = "List"
                dropdownList.Size = UDim2.new(0, 120, 0, 0)
                dropdownList.Position = UDim2.new(1, -120, 0, 30)
                dropdownList.BackgroundColor3 = window.Theme.Secondary
                dropdownList.Visible = false
                dropdownList.Parent = dropdownFrame
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.Padding = UDim.new(0, 2)
                listLayout.Parent = dropdownList
                
                -- Create dropdown options
                local function createOptions()
                    -- Clear existing options
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new options
                    for _, option in pairs(dropdown.Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option
                        optionButton.Text = option
                        optionButton.Size = UDim2.new(1, 0, 0, 25)
                        optionButton.BackgroundColor3 = window.Theme.Secondary
                        optionButton.TextColor3 = window.Theme.Text
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
                    
                    -- Update list size
                    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        dropdownList.Size = UDim2.new(0, 120, 0, listLayout.AbsoluteContentSize.Y)
                    end)
                end
                
                createOptions()
                
                -- Dropdown interaction
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if not dropdownButton:IsDescendantOf(input.Target) and not dropdownList:IsDescendantOf(input.Target) then
                            dropdownList.Visible = false
                        end
                    end
                end)
                
                -- Function to set dropdown value
                function dropdown:Set(value)
                    if table.find(dropdown.Options, value) then
                        dropdown.Value = value
                        dropdownButton.Text = value
                        dropdown.Callback(value)
                    end
                end
                
                -- Function to update options
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
    
    return window
end

return WeatherUI
