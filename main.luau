local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Fine-tuned theme matching the warm dark hacker aesthetic of the image
local Theme = {
	Background = Color3.fromRGB(16, 15, 14),
	Top = Color3.fromRGB(12, 11, 10),
	Sidebar = Color3.fromRGB(20, 19, 18),
	Element = Color3.fromRGB(24, 23, 22),
	ElementHover = Color3.fromRGB(34, 33, 32),
	Border = Color3.fromRGB(35, 34, 33),
	Accent = Color3.fromRGB(219, 192, 90), -- The specific yellow from the image
	Text = Color3.fromRGB(220, 220, 220),
	SubText = Color3.fromRGB(140, 140, 140),
	Font = Enum.Font.Code,
	TextSize = 12
}

function Library:Tween(instance, properties, duration)
	local tweenInfo = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Library:MakeDraggable(topbar, window)
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

-- Core Window
function Library:CreateWindow(config)
	config = config or {}
	local title = config.Title or "Terminal UI"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TerminalUI"
	ScreenGui.ResetOnSpawn = false
	
	if RunService:IsStudio() then
		ScreenGui.Parent = LocalPlayer.PlayerGui
	else
		pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
		if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end
	end

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Parent = ScreenGui
	Main.BackgroundColor3 = Theme.Background
	Main.BorderColor3 = Theme.Border
	Main.BorderSizePixel = 1
	Main.Position = UDim2.new(0.5, -350, 0.5, -250)
	Main.Size = UDim2.new(0, 700, 0, 500)
	Main.ClipsDescendants = true

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Parent = Main
	Topbar.BackgroundColor3 = Theme.Top
	Topbar.BorderColor3 = Theme.Border
	Topbar.BorderSizePixel = 1
	Topbar.Size = UDim2.new(1, 0, 0, 25)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = Topbar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.Size = UDim2.new(1, -20, 1, 0)
	TitleLabel.Font = Theme.Font
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = Theme.TextSize
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	Library:MakeDraggable(Topbar, Main)

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderColor3 = Theme.Border
	Sidebar.BorderSizePixel = 1
	Sidebar.Position = UDim2.new(0, 0, 0, 24) -- Overlap border by 1
	Sidebar.Size = UDim2.new(0, 150, 1, -24)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Parent = Sidebar
	TabContainer.BackgroundTransparency = 1
	TabContainer.Position = UDim2.new(0, 0, 0, 10)
	TabContainer.Size = UDim2.new(1, 0, 1, -20)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.ScrollBarThickness = 1
	TabContainer.ScrollBarImageColor3 = Theme.Border
	TabContainer.BorderSizePixel = 0

	local TabList = Instance.new("UIListLayout")
	TabList.Parent = TabContainer
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 2)
	
	TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
	end)

	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Parent = Main
	Pages.BackgroundTransparency = 1
	Pages.Position = UDim2.new(0, 150, 0, 25)
	Pages.Size = UDim2.new(1, -150, 1, -25)

	local WindowInfo = { CurrentTab = nil, Tabs = {} }

	function WindowInfo:CreateTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Theme.Sidebar
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, 0, 0, 25)
		TabButton.Font = Theme.Font
		TabButton.Text = name
		TabButton.TextColor3 = Theme.SubText
		TabButton.TextSize = Theme.TextSize
		
		local LeftLine = Instance.new("Frame")
		LeftLine.Parent = TabButton
		LeftLine.BackgroundColor3 = Theme.Accent
		LeftLine.BorderSizePixel = 0
		LeftLine.Size = UDim2.new(0, 2, 1, 0)
		LeftLine.BackgroundTransparency = 1

		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."Page"
		Page.Parent = Pages
		Page.BackgroundTransparency = 1
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Border
		Page.BorderSizePixel = 0
		Page.Visible = false

		local PagePadding = Instance.new("UIPadding")
		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 15)
		PagePadding.PaddingLeft = UDim.new(0, 15)
		PagePadding.PaddingRight = UDim.new(0, 15)
		PagePadding.PaddingBottom = UDim.new(0, 15)

		local PageList = Instance.new("UIListLayout")
		PageList.Parent = Page
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		
		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 30)
		end)

		local TabInfo = { Page = Page }

		TabButton.MouseButton1Click:Connect(function()
			if WindowInfo.CurrentTab == TabButton then return end
			for _, t in pairs(WindowInfo.Tabs) do
				Library:Tween(t.Button, {TextColor3 = Theme.SubText, BackgroundColor3 = Theme.Sidebar})
				Library:Tween(t.Line, {BackgroundTransparency = 1})
				t.Page.Visible = false
			end
			Library:Tween(TabButton, {TextColor3 = Theme.Text, BackgroundColor3 = Theme.Element})
			Library:Tween(LeftLine, {BackgroundTransparency = 0})
			Page.Visible = true
			WindowInfo.CurrentTab = TabButton
		end)
		
		table.insert(WindowInfo.Tabs, {Button = TabButton, Page = Page, Line = LeftLine})
		
		if #WindowInfo.Tabs == 1 then
			Library:Tween(TabButton, {TextColor3 = Theme.Text, BackgroundColor3 = Theme.Element})
			LeftLine.BackgroundTransparency = 0
			Page.Visible = true
			WindowInfo.CurrentTab = TabButton
		end

		function TabInfo:CreateButton(config)
			local text = config.Name or "Button"
			local callback = config.Callback or function() end

			local Button = Instance.new("TextButton")
			Button.Parent = Page
			Button.BackgroundColor3 = Theme.Element
			Button.BorderColor3 = Theme.Border
			Button.BorderSizePixel = 1
			Button.Size = UDim2.new(1, 0, 0, 30)
			Button.Font = Theme.Font
			Button.Text = text
			Button.TextColor3 = Theme.Text
			Button.TextSize = Theme.TextSize

			Button.MouseEnter:Connect(function() Library:Tween(Button, {BackgroundColor3 = Theme.ElementHover}) end)
			Button.MouseLeave:Connect(function() Library:Tween(Button, {BackgroundColor3 = Theme.Element}) end)
			Button.MouseButton1Down:Connect(function() Library:Tween(Button, {BorderColor3 = Theme.Accent}) end)
			Button.MouseButton1Up:Connect(function() 
				Library:Tween(Button, {BorderColor3 = Theme.Border})
				callback() 
			end)
		end

		function TabInfo:CreateToggle(config)
			local text = config.Name or "Toggle"
			local default = config.Default or false
			local callback = config.Callback or function() end
			local state = default

			local ToggleFrame = Instance.new("TextButton")
			ToggleFrame.Parent = Page
			ToggleFrame.BackgroundColor3 = Theme.Element
			ToggleFrame.BorderColor3 = Theme.Border
			ToggleFrame.BorderSizePixel = 1
			ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
			ToggleFrame.Text = ""
			ToggleFrame.AutoButtonColor = false

			local ToggleLabel = Instance.new("TextLabel")
			ToggleLabel.Parent = ToggleFrame
			ToggleLabel.BackgroundTransparency = 1
			ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
			ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
			ToggleLabel.Font = Theme.Font
			ToggleLabel.Text = text
			ToggleLabel.TextColor3 = Theme.Text
			ToggleLabel.TextSize = Theme.TextSize
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

			local Box = Instance.new("Frame")
			Box.Parent = ToggleFrame
			Box.BackgroundColor3 = Theme.Background
			Box.BorderColor3 = Theme.Border
			Box.BorderSizePixel = 1
			Box.Position = UDim2.new(1, -25, 0.5, -7)
			Box.Size = UDim2.new(0, 14, 0, 14)

			local InnerBox = Instance.new("Frame")
			InnerBox.Parent = Box
			InnerBox.BackgroundColor3 = Theme.Accent
			InnerBox.BorderSizePixel = 0
			InnerBox.Position = UDim2.new(0, 2, 0, 2)
			InnerBox.Size = UDim2.new(1, -4, 1, -4)
			InnerBox.BackgroundTransparency = state and 0 or 1

			ToggleFrame.MouseEnter:Connect(function() Library:Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementHover}) end)
			ToggleFrame.MouseLeave:Connect(function() Library:Tween(ToggleFrame, {BackgroundColor3 = Theme.Element}) end)
			
			ToggleFrame.MouseButton1Click:Connect(function()
				state = not state
				Library:Tween(InnerBox, {BackgroundTransparency = state and 0 or 1})
				callback(state)
			end)
		end

		function TabInfo:CreateSlider(config)
			local text = config.Name or "Slider"
			local min = config.Min or 0
			local max = config.Max or 100
			local default = config.Default or min
			local callback = config.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Parent = Page
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.BorderColor3 = Theme.Border
			SliderFrame.BorderSizePixel = 1
			SliderFrame.Size = UDim2.new(1, 0, 0, 45)

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Parent = SliderFrame
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Position = UDim2.new(0, 10, 0, 5)
			TitleLabel.Size = UDim2.new(1, -20, 0, 15)
			TitleLabel.Font = Theme.Font
			TitleLabel.Text = text
			TitleLabel.TextColor3 = Theme.Text
			TitleLabel.TextSize = Theme.TextSize
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Parent = SliderFrame
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Position = UDim2.new(0, 10, 0, 5)
			ValueLabel.Size = UDim2.new(1, -20, 0, 15)
			ValueLabel.Font = Theme.Font
			ValueLabel.Text = tostring(default)
			ValueLabel.TextColor3 = Theme.Accent
			ValueLabel.TextSize = Theme.TextSize
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

			local Bar = Instance.new("TextButton")
			Bar.Parent = SliderFrame
			Bar.BackgroundColor3 = Theme.Background
			Bar.BorderColor3 = Theme.Border
			Bar.BorderSizePixel = 1
			Bar.Position = UDim2.new(0, 10, 0, 25)
			Bar.Size = UDim2.new(1, -20, 0, 10)
			Bar.Text = ""
			Bar.AutoButtonColor = false

			local Fill = Instance.new("Frame")
			Fill.Parent = Bar
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

			local dragging = false

			local function update(input)
				local perc = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				local value = math.floor(min + ((max - min) * perc))
				Library:Tween(Fill, {Size = UDim2.new(perc, 0, 1, 0)}, 0.05)
				ValueLabel.Text = tostring(value)
				callback(value)
			end

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					update(input)
				end
			end)
		end

		function TabInfo:CreateDropdown(config)
			local text = config.Name or "Dropdown"
			local options = config.Options or {}
			local callback = config.Callback or function() end
			local open = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Parent = Page
			DropdownFrame.BackgroundColor3 = Theme.Element
			DropdownFrame.BorderColor3 = Theme.Border
			DropdownFrame.BorderSizePixel = 1
			DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
			DropdownFrame.ClipsDescendants = true

			local DropBtn = Instance.new("TextButton")
			DropBtn.Parent = DropdownFrame
			DropBtn.BackgroundTransparency = 1
			DropBtn.Size = UDim2.new(1, 0, 0, 30)
			DropBtn.Text = ""

			local Title = Instance.new("TextLabel")
			Title.Parent = DropBtn
			Title.BackgroundTransparency = 1
			Title.Position = UDim2.new(0, 10, 0, 0)
			Title.Size = UDim2.new(1, -30, 1, 0)
			Title.Font = Theme.Font
			Title.Text = text
			Title.TextColor3 = Theme.Text
			Title.TextSize = Theme.TextSize
			Title.TextXAlignment = Enum.TextXAlignment.Left

			local Icon = Instance.new("TextLabel")
			Icon.Parent = DropBtn
			Icon.BackgroundTransparency = 1
			Icon.Position = UDim2.new(1, -20, 0, 0)
			Icon.Size = UDim2.new(0, 20, 1, 0)
			Icon.Font = Theme.Font
			Icon.Text = "+"
			Icon.TextColor3 = Theme.SubText
			Icon.TextSize = 14

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Parent = DropdownFrame
			OptionContainer.BackgroundTransparency = 1
			OptionContainer.Position = UDim2.new(0, 0, 0, 30)
			OptionContainer.Size = UDim2.new(1, 0, 1, -30)

			local OptionList = Instance.new("UIListLayout")
			OptionList.Parent = OptionContainer
			OptionList.SortOrder = Enum.SortOrder.LayoutOrder

			local function refresh()
				local h = 30
				if open then h = 30 + (#options * 25) end
				Library:Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, h)})
				Icon.Text = open and "-" or "+"
			end

			DropBtn.MouseButton1Click:Connect(function()
				open = not open
				refresh()
			end)

			for _, opt in ipairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Parent = OptionContainer
				OptBtn.BackgroundColor3 = Theme.ElementHover
				OptBtn.BorderSizePixel = 0
				OptBtn.Size = UDim2.new(1, 0, 0, 25)
				OptBtn.Font = Theme.Font
				OptBtn.Text = opt
				OptBtn.TextColor3 = Theme.SubText
				OptBtn.TextSize = Theme.TextSize
				
				OptBtn.MouseEnter:Connect(function() Library:Tween(OptBtn, {TextColor3 = Theme.Accent}) end)
				OptBtn.MouseLeave:Connect(function() Library:Tween(OptBtn, {TextColor3 = Theme.SubText}) end)
				OptBtn.MouseButton1Click:Connect(function()
					Title.Text = text .. " : " .. opt
					open = false
					refresh()
					callback(opt)
				end)
			end
		end

		return TabInfo
	end
	
	function WindowInfo:CreatePlayerList()
		local Tab = self:CreateTab("Players")
		local Page = Tab.Page
		
		Page.UIPadding:Destroy()
		Page.UIListLayout.Padding = UDim.new(0, 0)
		Page.ScrollBarThickness = 0

		local MainContainer = Instance.new("Frame")
		MainContainer.Parent = Page
		MainContainer.BackgroundTransparency = 1
		MainContainer.Size = UDim2.new(1, 0, 1, 0)
		
		-- Search Box
		local SearchContainer = Instance.new("Frame")
		SearchContainer.Parent = MainContainer
		SearchContainer.BackgroundColor3 = Theme.Background
		SearchContainer.BorderColor3 = Theme.Border
		SearchContainer.BorderSizePixel = 1
		SearchContainer.Position = UDim2.new(0, 10, 0, 10)
		SearchContainer.Size = UDim2.new(1, -20, 0, 30)
		
		local SearchBox = Instance.new("TextBox")
		SearchBox.Parent = SearchContainer
		SearchBox.BackgroundTransparency = 1
		SearchBox.Position = UDim2.new(0, 10, 0, 0)
		SearchBox.Size = UDim2.new(1, -20, 1, 0)
		SearchBox.Font = Theme.Font
		SearchBox.PlaceholderText = "Search players..."
		SearchBox.PlaceholderColor3 = Theme.SubText
		SearchBox.Text = ""
		SearchBox.TextColor3 = Theme.Text
		SearchBox.TextSize = Theme.TextSize
		SearchBox.TextXAlignment = Enum.TextXAlignment.Left

		-- List Header
		local ListHeader = Instance.new("Frame")
		ListHeader.Parent = MainContainer
		ListHeader.BackgroundColor3 = Theme.Element
		ListHeader.BorderColor3 = Theme.Border
		ListHeader.BorderSizePixel = 1
		ListHeader.Position = UDim2.new(0, 10, 0, 45)
		ListHeader.Size = UDim2.new(1, -20, 0, 20)
		
		-- List Scroll
		local ListContainer = Instance.new("Frame")
		ListContainer.Parent = MainContainer
		ListContainer.BackgroundColor3 = Theme.Background
		ListContainer.BorderColor3 = Theme.Border
		ListContainer.BorderSizePixel = 1
		ListContainer.Position = UDim2.new(0, 10, 0, 64) -- Overlap border
		ListContainer.Size = UDim2.new(1, -20, 0, 200)

		local ListScroll = Instance.new("ScrollingFrame")
		ListScroll.Parent = ListContainer
		ListScroll.BackgroundTransparency = 1
		ListScroll.Size = UDim2.new(1, 0, 1, 0)
		ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		ListScroll.ScrollBarThickness = 2
		ListScroll.ScrollBarImageColor3 = Theme.Border
		ListScroll.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = ListScroll
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Details View
		local DetailsContainer = Instance.new("Frame")
		DetailsContainer.Parent = MainContainer
		DetailsContainer.BackgroundTransparency = 1
		DetailsContainer.Position = UDim2.new(0, 10, 0, 275)
		DetailsContainer.Size = UDim2.new(1, -20, 0, 150)

		local AvatarImage = Instance.new("ImageLabel")
		AvatarImage.Parent = DetailsContainer
		AvatarImage.BackgroundColor3 = Theme.Element
		AvatarImage.BorderColor3 = Theme.Border
		AvatarImage.BorderSizePixel = 1
		AvatarImage.Position = UDim2.new(0, 0, 0, 0)
		AvatarImage.Size = UDim2.new(0, 70, 0, 70)
		AvatarImage.Image = ""


		local StatsLabel = Instance.new("TextLabel")
		StatsLabel.Parent = DetailsContainer
		StatsLabel.BackgroundTransparency = 1
		StatsLabel.Position = UDim2.new(0, 85, 0, 0)
		StatsLabel.Size = UDim2.new(1, -200, 0, 80)
		StatsLabel.Font = Theme.Font
		StatsLabel.Text = "Select a player...\nAccount Age: -"
		StatsLabel.TextColor3 = Theme.Text
		StatsLabel.TextSize = Theme.TextSize
		StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
		StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
		

		-- 4 Action Buttons
		local ButtonContainer = Instance.new("Frame")
		ButtonContainer.Parent = DetailsContainer
		ButtonContainer.BackgroundTransparency = 1
		ButtonContainer.Position = UDim2.new(0, 0, 1, -30)
		ButtonContainer.Size = UDim2.new(1, 0, 0, 30)

		local btnLayout = Instance.new("UIListLayout")
		btnLayout.Parent = ButtonContainer
		btnLayout.FillDirection = Enum.FillDirection.Horizontal
		btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
		btnLayout.Padding = UDim.new(0, 4)

		local actions = {"Teleport", "Spectate", "Highlight"}
		for i, action in ipairs(actions) do
			local actionBtn = Instance.new("TextButton")
			actionBtn.Parent = ButtonContainer
			actionBtn.BackgroundColor3 = Theme.Element
			actionBtn.BorderColor3 = Theme.Border
			actionBtn.BorderSizePixel = 1
			actionBtn.Size = UDim2.new(0.333, -3, 1, 0)
			actionBtn.Font = Theme.Font
			actionBtn.Text = action
			actionBtn.TextColor3 = Theme.Text
			actionBtn.TextSize = Theme.TextSize

			actionBtn.MouseEnter:Connect(function() Library:Tween(actionBtn, {BackgroundColor3 = Theme.ElementHover}) end)
			actionBtn.MouseLeave:Connect(function() Library:Tween(actionBtn, {BackgroundColor3 = Theme.Element}) end)
			actionBtn.MouseButton1Down:Connect(function() Library:Tween(actionBtn, {BorderColor3 = Theme.Accent}) end)
			actionBtn.MouseButton1Up:Connect(function() Library:Tween(actionBtn, {BorderColor3 = Theme.Border}) end)
		end

		local SelectedPlayer = nil
		local playerRows = {}

		local function selectPlayer(player, rowFrame, selectorLine)
			SelectedPlayer = player
			for _, r in pairs(playerRows) do Library:Tween(r.Line, {BackgroundTransparency = 1}) end
			Library:Tween(selectorLine, {BackgroundTransparency = 0})

			pcall(function()
				AvatarImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)

			StatsLabel.Text = string.format("%s - (@%s) - %d\nAccount Age: %d days",
				player.DisplayName, player.Name, player.UserId, player.AccountAge
			)
			
			-- Approximate health for flavor
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local hp = player.Character.Humanoid.Health
				local max = player.Character.Humanoid.MaxHealth
				local perc = math.clamp(hp/max, 0, 1)
				if perc > 0.8 then HealthHearts.Text = "❤❤❤❤❤"
				elseif perc > 0.6 then HealthHearts.Text = "❤❤❤❤"
				elseif perc > 0.4 then HealthHearts.Text = "❤❤❤"
				elseif perc > 0.2 then HealthHearts.Text = "❤❤"
				elseif perc > 0 then HealthHearts.Text = "❤"
				else HealthHearts.Text = "☠" end
			else
				HealthHearts.Text = "???"
			end
		end

		local function populatePlayers(filter)
			for _, child in ipairs(ListScroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			playerRows = {}
			local ySize = 0
			for _, player in ipairs(Players:GetPlayers()) do
				if filter and filter ~= "" and not string.find(string.lower(player.Name), string.lower(filter)) and not string.find(string.lower(player.DisplayName), string.lower(filter)) then
					continue
				end

				local PRow = Instance.new("TextButton")
				PRow.Parent = ListScroll
				PRow.BackgroundColor3 = Theme.Background
				PRow.BorderSizePixel = 0
				PRow.Size = UDim2.new(1, 0, 0, 25)
				PRow.Text = ""
				PRow.AutoButtonColor = false

				local SelectorLine = Instance.new("Frame")
				SelectorLine.Parent = PRow
				SelectorLine.BackgroundColor3 = Theme.Accent
				SelectorLine.BorderSizePixel = 0
				SelectorLine.Position = UDim2.new(1, -3, 0.2, 0)
				SelectorLine.Size = UDim2.new(0, 2, 0.6, 0)
				SelectorLine.BackgroundTransparency = (SelectedPlayer == player) and 0 or 1

				local NameLabel = Instance.new("TextLabel")
				NameLabel.Parent = PRow
				NameLabel.BackgroundTransparency = 1
				NameLabel.Position = UDim2.new(0, 10, 0, 0)
				NameLabel.Size = UDim2.new(0.5, 0, 1, 0)
				NameLabel.Font = Theme.Font
				NameLabel.Text = player.DisplayName .. " - (@" .. player.Name .. ")"
				NameLabel.TextColor3 = Theme.Text
				NameLabel.TextSize = Theme.TextSize
				NameLabel.TextXAlignment = Enum.TextXAlignment.Left

				local Col1 = Instance.new("TextLabel")
				Col1.Parent = PRow
				Col1.BackgroundTransparency = 1
				Col1.Position = UDim2.new(0.5, 0, 0, 0)
				Col1.Size = UDim2.new(0.25, 0, 1, 0)
				Col1.Font = Theme.Font
				Col1.Text = "None"
				Col1.TextColor3 = Theme.Text
				Col1.TextSize = Theme.TextSize
				Col1.TextXAlignment = Enum.TextXAlignment.Left

				local Col2 = Instance.new("TextLabel")
				Col2.Parent = PRow
				Col2.BackgroundTransparency = 1
				Col2.Position = UDim2.new(0.75, 0, 0, 0)
				Col2.Size = UDim2.new(0.25, -15, 1, 0)
				Col2.Font = Theme.Font
				Col2.Text = "Neutral"
				Col2.TextColor3 = Theme.Text
				Col2.TextSize = Theme.TextSize
				Col2.TextXAlignment = Enum.TextXAlignment.Right

				PRow.MouseEnter:Connect(function() Library:Tween(PRow, {BackgroundColor3 = Theme.ElementHover}) end)
				PRow.MouseLeave:Connect(function() Library:Tween(PRow, {BackgroundColor3 = Theme.Background}) end)
				PRow.MouseButton1Click:Connect(function() selectPlayer(player, PRow, SelectorLine) end)

				table.insert(playerRows, {Row = PRow, Line = SelectorLine})
				ySize = ySize + 25
			end
			ListScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
		end

		populatePlayers()
		SearchBox:GetPropertyChangedSignal("Text"):Connect(function() populatePlayers(SearchBox.Text) end)
		Players.PlayerAdded:Connect(function() populatePlayers(SearchBox.Text) end)
		Players.PlayerRemoving:Connect(function() populatePlayers(SearchBox.Text) end)

		return Tab
	end

	return WindowInfo
end

return Library
