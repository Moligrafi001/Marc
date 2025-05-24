--[[ 
    test.lua
    UI Library puramente cliente para Roblox (estilo Rayfield), carregável via loadstring.
    Cole este arquivo em um repositório (por exemplo, GitHub) e use:
    
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/test.lua"))()
    local UILib = Library.Init()
    
    Depois, crie janelas e componentes normalmente:
    local window = UILib:CreateWindow({ Title = "Minha Janela" })
    -- etc.
--]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Tema padrão (cores, fontes)
local DefaultTheme = {
    PrimaryColor       = Color3.fromRGB(35, 35, 35),
    SecondaryColor     = Color3.fromRGB(25, 25, 25),
    AccentColor        = Color3.fromRGB(0, 170, 255),
    FontColor          = Color3.fromRGB(255, 255, 255),
    ToggleOnColor      = Color3.fromRGB(0, 200, 0),
    ToggleOffColor     = Color3.fromRGB(200, 0, 0),
    SliderBackground   = Color3.fromRGB(50, 50, 50),
    SliderFillColor    = Color3.fromRGB(0, 170, 255),
    DropdownBGColor    = Color3.fromRGB(30, 30, 30),
    DropdownHoverColor = Color3.fromRGB(50, 50, 50),
    Font               = Enum.Font.SourceSansBold,
    TextSize           = 14,
}

-- Helper para criar instâncias com propriedades
local function New(className, props)
    local inst = Instance.new(className)
    if props then
        for prop, val in pairs(props) do
            inst[prop] = val
        end
    end
    return inst
end

-- Função para tornar um frame arrastável
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            0, startPos.X + delta.X,
            0, startPos.Y + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- Cria o ScreenGui principal (injetado no CoreGui se possível)
local function CreateScreenGui()
    local screenGui = New("ScreenGui", {
        Name = "UILibraryClientScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    if game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
    return screenGui
end

-- Cria uma nova janela (Window) no UI
function UILibrary:CreateWindow(opts)
    opts = opts or {}
    local titleText = opts.Title or "Janela"
    local width     = opts.Width or 400
    local height    = opts.Height or 300
    local theme     = opts.Theme or DefaultTheme

    -- Container principal
    local windowFrame = New("Frame", {
        Name               = titleText .. "_Window",
        Size               = UDim2.new(0, width, 0, height),
        Position           = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3    = theme.PrimaryColor,
        BorderSizePixel     = 0,
        ClipsDescendants    = true,
    })

    -- Título e barra de arraste
    local titleBar = New("Frame", {
        Name               = "TitleBar",
        Size               = UDim2.new(1, 0, 0, 30),
        BackgroundColor3    = theme.SecondaryColor,
        Parent             = windowFrame,
    })
    local titleLabel = New("TextLabel", {
        Name               = "TitleLabel",
        Size               = UDim2.new(1, -10, 1, 0),
        Position           = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text               = titleText,
        Font               = theme.Font,
        TextSize           = theme.TextSize + 2,
        TextColor3         = theme.FontColor,
        TextXAlignment     = Enum.TextXAlignment.Left,
        Parent             = titleBar,
    })
    -- Botão de fechar (X)
    local closeButton = New("TextButton", {
        Name               = "CloseButton",
        Size               = UDim2.new(0, 25, 0, 25),
        Position           = UDim2.new(1, -30, 0, 2),
        BackgroundColor3    = theme.AccentColor,
        Text               = "X",
        Font               = theme.Font,
        TextSize           = theme.TextSize,
        TextColor3         = theme.FontColor,
        AutoButtonColor    = false,
        Parent             = titleBar,
    })
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = theme.ToggleOnColor
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = theme.AccentColor
    end)
    closeButton.MouseButton1Click:Connect(function()
        windowFrame:Destroy()
    end)

    -- Conteúdo (scrollable)
    local contentFrame = New("ScrollingFrame", {
        Name               = "Content",
        Size               = UDim2.new(1, 0, 1, -30),
        Position           = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize         = UDim2.new(0, 0, 0, 0),
        Parent             = windowFrame,
    })
    local uiListLayout = New("UIListLayout", {
        Name      = "ListLayout",
        Parent    = contentFrame,
        Padding   = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    uiListLayout.Changed:Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Torna a janela arrastável
    MakeDraggable(windowFrame, titleBar)

    -- Adiciona à screenGui
    windowFrame.Parent = self.ScreenGui

    -- Objeto da janela com métodos para adicionar componentes
    local windowObj = {
        Frame       = windowFrame,
        Content     = contentFrame,
        Theme       = theme,
        LayoutOrder = 1,
    }

    -- Adiciona seção (header)
    function windowObj:AddSection(text)
        local label = New("TextLabel", {
            Name               = "Section_" .. tostring(self.LayoutOrder),
            Size               = UDim2.new(1, -20, 0, 24),
            BackgroundTransparency = 1,
            Text               = text,
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize + 2,
            TextColor3         = self.Theme.AccentColor,
            TextXAlignment     = Enum.TextXAlignment.Left,
            LayoutOrder        = self.LayoutOrder,
            Parent             = self.Content,
        })
        self.LayoutOrder = self.LayoutOrder + 1
        return label
    end

    -- Adiciona botão
    function windowObj:AddButton(opts)
        opts = opts or {}
        local btnText = opts.Text or "Botão"
        local callback = opts.Callback or function() end

        local btnFrame = New("Frame", {
            Name               = "Button_" .. tostring(self.LayoutOrder),
            Size               = UDim2.new(1, -20, 0, 30),
            BackgroundColor3    = self.Theme.SecondaryColor,
            LayoutOrder        = self.LayoutOrder,
            Parent             = self.Content,
        })
        local btn = New("TextButton", {
            Name               = "Btn",
            Size               = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text               = btnText,
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize,
            TextColor3         = self.Theme.FontColor,
            AutoButtonColor    = false,
            Parent             = btnFrame,
        })
        btn.MouseEnter:Connect(function()
            btnFrame.BackgroundColor3 = self.Theme.PrimaryColor
        end)
        btn.MouseLeave:Connect(function()
            btnFrame.BackgroundColor3 = self.Theme.SecondaryColor
        end)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        self.LayoutOrder = self.LayoutOrder + 1
        return btn
    end

    -- Adiciona toggle (checkbox)
    function windowObj:AddToggle(opts)
        opts = opts or {}
        local toggText = opts.Text or "Toggle"
        local default   = opts.Default or false
        local callback  = opts.Callback or function(state) end

        local toggleFrame = New("Frame", {
            Name               = "Toggle_" .. tostring(self.LayoutOrder),
            Size               = UDim2.new(1, -20, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder        = self.LayoutOrder,
            Parent             = self.Content,
        })
        local label = New("TextLabel", {
            Name               = "ToggleLabel",
            Size               = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1,
            Text               = toggText,
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize,
            TextColor3         = self.Theme.FontColor,
            TextXAlignment     = Enum.TextXAlignment.Left,
            Parent             = toggleFrame,
        })
        local box = New("Frame", {
            Name               = "Checkbox",
            Size               = UDim2.new(0, 20, 0, 20),
            Position           = UDim2.new(0.85, 0, 0, 2),
            BackgroundColor3    = default and self.Theme.ToggleOnColor or self.Theme.ToggleOffColor,
            Parent             = toggleFrame,
        })
        New("UICorner", { Parent = box, CornerRadius = UDim.new(0, 4) })

        local state = default

        local function updateVisual()
            box.BackgroundColor3 = state and UILibrary.Theme.ToggleOnColor or UILibrary.Theme.ToggleOffColor
        end

        box.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                updateVisual()
                pcall(callback, state)
            end
        end)

        updateVisual()
        self.LayoutOrder = self.LayoutOrder + 1
        return {
            GetState = function() return state end,
            SetState = function(val) state = val; updateVisual() end,
        }
    end

    -- Adiciona slider
    function windowObj:AddSlider(opts)
        opts = opts or {}
        local text     = opts.Text or "Slider"
        local min      = opts.Min or 0
        local max      = opts.Max or 100
        local default  = opts.Default or min
        local callback = opts.Callback or function(val) end

        local sliderFrame = New("Frame", {
            Name               = "Slider_" .. tostring(self.LayoutOrder),
            Size               = UDim2.new(1, -20, 0, 40),
            BackgroundTransparency = 1,
            LayoutOrder        = self.LayoutOrder,
            Parent             = self.Content,
        })
        local label = New("TextLabel", {
            Name               = "SliderLabel",
            Size               = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text               = text .. " (" .. tostring(default) .. ")",
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize,
            TextColor3         = self.Theme.FontColor,
            TextXAlignment     = Enum.TextXAlignment.Left,
            Parent             = sliderFrame,
        })
        local barBg = New("Frame", {
            Name               = "BarBg",
            Size               = UDim2.new(1, -40, 0, 6),
            Position           = UDim2.new(0, 0, 0, 18),
            BackgroundColor3    = self.Theme.SliderBackground,
            Parent             = sliderFrame,
        })
        local barFill = New("Frame", {
            Name               = "BarFill",
            Size               = UDim2.new((default - min)/(max - min), 0, 1, 0),
            BackgroundColor3    = self.Theme.SliderFillColor,
            Parent             = barBg,
        })
        local handle = New("ImageLabel", {
            Name               = "Handle",
            Size               = UDim2.new(0, 18, 0, 18),
            Position           = UDim2.new((default - min)/(max - min), -9, 0.5, -9),
            BackgroundTransparency = 1,
            Image              = "rbxassetid://3926305904",
            ImageColor3        = self.Theme.AccentColor,
            Parent             = barBg,
        })
        local dragging = false

        local function updateValue(x)
            local relative = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative + 0.5)
            barFill.Size = UDim2.new(relative, 0, 1, 0)
            handle.Position = UDim2.new(relative, -9, 0.5, -9)
            label.Text = text .. " (" .. tostring(value) .. ")"
            pcall(callback, value)
        end

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input.Position.X)
            end
        end)

        self.LayoutOrder = self.LayoutOrder + 1
        return {
            GetValue = function()
                local relative = barFill.Size.X.Scale
                return math.floor(min + (max - min) * relative + 0.5)
            end,
            SetValue = function(val)
                val = math.clamp(val, min, max)
                local rel = (val - min)/(max - min)
                barFill.Size = UDim2.new(rel, 0, 1, 0)
                handle.Position = UDim2.new(rel, -9, 0.5, -9)
                label.Text = text .. " (" .. tostring(val) .. ")"
            end,
        }
    end

    -- Adiciona dropdown
    function windowObj:AddDropdown(opts)
        opts = opts or {}
        local text     = opts.Text or "Dropdown"
        local choices  = opts.Choices or {}
        local callback = opts.Callback or function(selected) end
        local default  = opts.Default or choices[1] or ""

        local dropdownFrame = New("Frame", {
            Name               = "Dropdown_" .. tostring(self.LayoutOrder),
            Size               = UDim2.new(1, -20, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder        = self.LayoutOrder,
            Parent             = self.Content,
        })
        local label = New("TextLabel", {
            Name               = "DropdownLabel",
            Size               = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1,
            Text               = text .. ":",
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize,
            TextColor3         = self.Theme.FontColor,
            TextXAlignment     = Enum.TextXAlignment.Left,
            Parent             = dropdownFrame,
        })
        local current = New("TextButton", {
            Name               = "CurrentChoice",
            Size               = UDim2.new(0, 100, 1, 0),
            Position           = UDim2.new(1, -100, 0, 0),
            BackgroundColor3    = self.Theme.SecondaryColor,
            Text               = tostring(default),
            Font               = self.Theme.Font,
            TextSize           = self.Theme.TextSize,
            TextColor3         = self.Theme.FontColor,
            AutoButtonColor    = false,
            Parent             = dropdownFrame,
        })
        current.MouseEnter:Connect(function()
            current.BackgroundColor3 = self.Theme.PrimaryColor
        end)
        current.MouseLeave:Connect(function()
            current.BackgroundColor3 = self.Theme.SecondaryColor
        end)

        local listFrame = New("Frame", {
            Name               = "ListFrame",
            Size               = UDim2.new(0, 100, 0, #choices * 24),
            Position           = UDim2.new(1, -100, 1, 2),
            BackgroundColor3    = self.Theme.DropdownBGColor,
            Visible            = false,
            Parent             = dropdownFrame,
        })
        local listLayout = New("UIListLayout", { Parent = listFrame, SortOrder = Enum.SortOrder.LayoutOrder })

        local selectedValue = default

        for i, choice in ipairs(choices) do
            local item = New("TextButton", {
                Name               = "Choice_" .. i,
                Size               = UDim2.new(1, 0, 0, 24),
                BackgroundColor3    = self.Theme.DropdownBGColor,
                Text               = tostring(choice),
                Font               = self.Theme.Font,
                TextSize           = self.Theme.TextSize,
                TextColor3         = self.Theme.FontColor,
                AutoButtonColor    = false,
                LayoutOrder        = i,
                Parent             = listFrame,
            })
            item.MouseEnter:Connect(function()
                item.BackgroundColor3 = self.Theme.DropdownHoverColor
            end)
            item.MouseLeave:Connect(function()
                item.BackgroundColor3 = self.Theme.DropdownBGColor
            end)
            item.MouseButton1Click:Connect(function()
                selectedValue = choice
                current.Text = tostring(choice)
                listFrame.Visible = false
                pcall(callback, choice)
            end)
        end

        current.MouseButton1Click:Connect(function()
            listFrame.Visible = not listFrame.Visible
        end)

        self.LayoutOrder = self.LayoutOrder + 1
        return {
            GetValue = function() return selectedValue end,
            SetValue = function(val)
                if table.find(choices, val) then
                    selectedValue = val
                    current.Text = tostring(val)
                end
            end,
        }
    end

    return windowObj
end

-- Inicialização da biblioteca
function UILibrary.Init()
    if UILibrary.ScreenGui then return UILibrary end
    UILibrary.ScreenGui = CreateScreenGui()
    UILibrary.Theme = DefaultTheme
    return UILibrary
end

return UILibrary