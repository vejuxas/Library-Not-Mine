--[[
    Nova UI Framework
    Author: Nova Dev Team
    License: MIT
    Version: 3.0
    
    Features:
    - Modern flat design
    - Smooth animations
    - Better performance
    - Customizable themes
    - Mobile support
    - Enhanced configurability
--]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Theme Configuration
local Theme = {
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(25, 30, 40),
    Background = Color3.fromRGB(20, 25, 35),
    Surface = Color3.fromRGB(30, 35, 45),
    Text = Color3.fromRGB(255, 255, 255),
    Subtext = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(45, 50, 60),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Info = Color3.fromRGB(52, 152, 219),
    
    -- Modern color palette
    Accent = Color3.fromRGB(108, 92, 231),
    Hover = Color3.fromRGB(40, 45, 55),
    Selected = Color3.fromRGB(50, 55, 65),
    Disabled = Color3.fromRGB(100, 100, 100),
}

-- Typography
local Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamMedium,
    Body = Enum.Font.Gotham,
    Monospace = Enum.Font.Code,
}

-- Animation Presets
local Animations = {
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- Utility Functions
local Utils = {}

function Utils.create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function Utils.tween(object, tweenInfo, properties)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

function Utils.isMouseOver(frame)
    local mousePos = UserInputService:GetMouseLocation()
    local framePos = frame.AbsolutePosition
    local frameSize = frame.AbsoluteSize
    
    return mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X
        and mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y
end

-- Core UI Components
local Nova = {
    Windows = {},
    Flags = {},
    CurrentWindow = nil,
    PerformanceMode = false,
    Mobile = UserInputService.TouchEnabled,
}

function Nova:createWindow(config)
    config = config or {}
    
    -- Default configuration
    local windowConfig = {
        Title = config.Title or "Nova UI",
        Size = config.Size or (self.Mobile and UDim2.new(0, 400, 0, 500) or UDim2.new(0, 500, 0, 600)),
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5),
        Visible = config.Visible ~= false,
        MinSize = config.MinSize or Vector2.new(300, 400),
        MaxSize = config.MaxSize or Vector2.new(800, 800),
        Theme = config.Theme or "Dark",
    }
    
    -- Create window container
    local window = {
        Tabs = {},
        CurrentTab = nil,
        Elements = {},
        Callbacks = {},
        Config = windowConfig,
    }
    
    -- Create screen gui
    local screenGui = Utils.create("ScreenGui", {
        Name = "NovaWindow_" .. math.random(10000, 99999),
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })
    
    -- Main frame
    local mainFrame = Utils.create("Frame", {
        Parent = screenGui,
        BackgroundColor3 = Theme.Background,
        BorderColor3 = Theme.Border,
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 1,
        Size = windowConfig.Size,
        Position = windowConfig.Position,
        AnchorPoint = windowConfig.AnchorPoint,
        ClipsDescendants = true,
    })
    
    -- Title bar
    local titleBar = Utils.create("Frame", {
        Parent = mainFrame,
        Name = "TitleBar",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2,
    })
    
    local titleLabel = Utils.create("TextLabel", {
        Parent = titleBar,
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.5, -15, 1, 0),
        Font = Fonts.Title,
        Text = windowConfig.Title,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    -- Close button
    local closeButton = Utils.create("TextButton", {
        Parent = titleBar,
        Name = "Close",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.Subtext,
        TextSize = 24,
    })
    
    -- Tab container
    local tabContainer = Utils.create("Frame", {
        Parent = mainFrame,
        Name = "TabContainer",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 2,
    })
    
    -- Content area
    local contentArea = Utils.create("Frame", {
        Parent = mainFrame,
        Name = "Content",
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 90),
        Size = UDim2.new(1, 0, 1, -90),
        ClipsDescendants = true,
    })
    
    -- Store references
    window.Gui = screenGui
    window.Frame = mainFrame
    window.TitleBar = titleBar
    window.Content = contentArea
    window.TabContainer = tabContainer
    
    -- Window methods
    function window:setTitle(title)
        titleLabel.Text = title
    end
    
    function window:setVisible(visible)
        screenGui.Enabled = visible
    end
    
    function window:destroy()
        screenGui:Destroy()
        for i, win in ipairs(self.Windows) do
            if win == window then
                table.remove(self.Windows, i)
                break
            end
        end
    end
    
    -- Drag functionality
    local dragging = false
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
    
    -- Close button functionality
    closeButton.MouseEnter:Connect(function()
        Utils.tween(closeButton, Animations.Quick, {
            TextColor3 = Theme.Error
        })
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utils.tween(closeButton, Animations.Quick, {
            TextColor3 = Theme.Subtext
        })
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        window:destroy()
    end)
    
    -- Add tab functionality
    function window:addTab(config)
        config = config or {}
        
        local tab = {
            Name = config.Name or "Tab",
            Icon = config.Icon or "",
            Content = {},
            Button = nil,
        }
        
        -- Create tab button
        local tabButton = Utils.create("TextButton", {
            Parent = tabContainer,
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 1, 0),
            Font = Fonts.Header,
            Text = tab.Name,
            TextColor3 = Theme.Subtext,
            TextSize = 14,
            AutoButtonColor = false,
        })
        
        -- Tab content frame
        local tabContent = Utils.create("ScrollingFrame", {
            Parent = contentArea,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Border,
            Visible = false,
        })
        
        local contentLayout = Utils.create("UIListLayout", {
            Parent = tabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })
        
        -- Update canvas size
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end)
        
        tab.Button = tabButton
        tab.ContentFrame = tabContent
        
        -- Tab selection logic
        local function selectTab()
            if window.CurrentTab then
                -- Deselect current tab
                Utils.tween(window.CurrentTab.Button, Animations.Quick, {
                    BackgroundColor3 = Theme.Surface,
                    TextColor3 = Theme.Subtext
                })
                window.CurrentTab.ContentFrame.Visible = false
            end
            
            -- Select new tab
            window.CurrentTab = tab
            Utils.tween(tabButton, Animations.Quick, {
                BackgroundColor3 = Theme.Selected,
                TextColor3 = Theme.Primary
            })
            tabContent.Visible = true
            
            -- Highlight indicator
            local indicator = tabButton:FindFirstChild("Indicator") or Utils.create("Frame", {
                Parent = tabButton,
                Name = "Indicator",
                BackgroundColor3 = Theme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 3),
                Position = UDim2.new(0, 0, 1, -3),
            })
            
            Utils.tween(indicator, Animations.Standard, {
                BackgroundTransparency = 0
            })
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Utils.tween(tabButton, Animations.Quick, {
                    BackgroundColor3 = Theme.Hover
                })
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Utils.tween(tabButton, Animations.Quick, {
                    BackgroundColor3 = Theme.Surface
                })
            end
        end)
        
        -- Add to window tabs
        table.insert(window.Tabs, tab)
        
        -- Select first tab
        if #window.Tabs == 1 then
            selectTab()
        end
        
        return tab
    end
    
    -- Add to windows list
    table.insert(self.Windows, window)
    
    return window
end

-- UI Elements Builder
function Nova:createElement(parent, elementType, config)
    config = config or {}
    
    local element = {
        Type = elementType,
        Value = config.Default,
        Callback = config.Callback or function() end,
    }
    
    if elementType == "Toggle" then
        local container = Utils.create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            LayoutOrder = config.LayoutOrder or 0,
        })
        
        local label = Utils.create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(0.7, -15, 1, 0),
            Font = Fonts.Body,
            Text = config.Name or "Toggle",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local toggleButton = Utils.create("TextButton", {
            Parent = container,
            Position = UDim2.new(1, -60, 0, 10),
            Size = UDim2.new(0, 50, 0, 20),
            BackgroundColor3 = Theme.Surface,
            BorderColor3 = Theme.Border,
            BorderSizePixel = 1,
            AutoButtonColor = false,
            Text = "",
        })
        
        local toggleCircle = Utils.create("Frame", {
            Parent = toggleButton,
            Position = UDim2.new(0, 2, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = Theme.Text,
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local corner = Utils.create("UICorner", {
            Parent = toggleButton,
            CornerRadius = UDim.new(1, 0),
        })
        
        local circleCorner = Utils.create("UICorner", {
            Parent = toggleCircle,
            CornerRadius = UDim.new(1, 0),
        })
        
        -- Toggle functionality
        local function updateToggle(state)
            element.Value = state
            if state then
                Utils.tween(toggleButton, Animations.Quick, {
                    BackgroundColor3 = Theme.Primary
                })
                Utils.tween(toggleCircle, Animations.Quick, {
                    Position = UDim2.new(1, -18, 0.5, -8)
                })
            else
                Utils.tween(toggleButton, Animations.Quick, {
                    BackgroundColor3 = Theme.Surface
                })
                Utils.tween(toggleCircle, Animations.Quick, {
                    Position = UDim2.new(0, 2, 0.5, -8)
                })
            end
            element.Callback(state)
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not element.Value)
        end)
        
        -- Initialize
        updateToggle(config.Default or false)
        
        element.Gui = container
        element.SetValue = updateToggle
        
    elseif elementType == "Button" then
        local button = Utils.create("TextButton", {
            Parent = parent,
            BackgroundColor3 = Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -30, 0, 40),
            Position = UDim2.new(0, 15, 0, 0),
            Font = Fonts.Header,
            Text = config.Name or "Button",
            TextColor3 = Theme.Text,
            TextSize = 14,
            AutoButtonColor = false,
        })
        
        local corner = Utils.create("UICorner", {
            Parent = button,
            CornerRadius = UDim.new(0, 6),
        })
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            Utils.tween(button, Animations.Quick, {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(Theme.Primary.R * 255 + 20, 255),
                    math.min(Theme.Primary.G * 255 + 20, 255),
                    math.min(Theme.Primary.B * 255 + 20, 255)
                )
            })
        end)
        
        button.MouseLeave:Connect(function()
            Utils.tween(button, Animations.Quick, {
                BackgroundColor3 = Theme.Primary
            })
        end)
        
        button.MouseButton1Click:Connect(function()
            element.Callback()
        end)
        
        element.Gui = button
        
    elseif elementType == "Slider" then
        local container = Utils.create("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 60),
        })
        
        local label = Utils.create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Fonts.Body,
            Text = config.Name or "Slider",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local valueLabel = Utils.create("TextLabel", {
            Parent = container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -100, 0, 0),
            Size = UDim2.new(0, 85, 0, 20),
            Font = Fonts.Body,
            Text = tostring(config.Default or config.Min or 0),
            TextColor3 = Theme.Subtext,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        
        local sliderTrack = Utils.create("Frame", {
            Parent = container,
            Position = UDim2.new(0, 15, 0, 30),
            Size = UDim2.new(1, -30, 0, 6),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
        })
        
        local trackCorner = Utils.create("UICorner", {
            Parent = sliderTrack,
            CornerRadius = UDim.new(1, 0),
        })
        
        local sliderFill = Utils.create("Frame", {
            Parent = sliderTrack,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Primary,
            BorderSizePixel = 0,
        })
        
        local fillCorner = Utils.create("UICorner", {
            Parent = sliderFill,
            CornerRadius = UDim.new(1, 0),
        })
        
        local sliderHandle = Utils.create("Frame", {
            Parent = sliderTrack,
            Position = UDim2.new(0, 0, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local handleCorner = Utils.create("UICorner", {
            Parent = sliderHandle,
            CornerRadius = UDim.new(1, 0),
        })
        
        -- Slider values
        local min = config.Min or 0
        local max = config.Max or 100
        local defaultValue = config.Default or min
        local round = config.Round or 0
        
        -- Update slider
        local function updateSlider(value, isDragging)
            value = math.clamp(value, min, max)
            if round > 0 then
                value = Utils.round(value, round)
            end
            
            element.Value = value
            valueLabel.Text = tostring(value)
            
            local percentage = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderHandle.Position = UDim2.new(percentage, -8, 0.5, -8)
            
            if not isDragging then
                element.Callback(value)
            end
        end
        
        -- Drag functionality
        local dragging = false
        
        local function updateFromInput(input)
            local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            local value = min + (max - min) * math.clamp(relativeX, 0, 1)
            updateSlider(value, dragging)
        end
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateFromInput(input)
            end
        end)
        
        sliderTrack.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                element.Callback(element.Value)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateFromInput(input)
            end
        end)
        
        -- Initialize
        updateSlider(defaultValue)
        
        element.Gui = container
        element.SetValue = updateSlider
        
    elseif elementType == "Dropdown" then
        -- Implementation for dropdown
        -- (Would include similar structure to other elements)
        
    elseif elementType == "Textbox" then
        -- Implementation for textbox
        
    end
    
    return element
end

-- Initialize Nova
function Nova:init()
    -- Create a default window if none exists
    if #self.Windows == 0 then
        self.CurrentWindow = self:createWindow({
            Title = "Nova UI",
            Size = self.Mobile and UDim2.new(0, 350, 0, 450) or UDim2.new(0, 500, 0, 600),
        })
    end
    
    print("Nova UI Framework initialized")
end

-- Return the Nova object
return Nova
