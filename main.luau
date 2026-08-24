local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Updated Theme based on the requested aesthetic (square, dark, monospace)
local Theme = {
	Main = Color3.fromRGB(18, 18, 18),
	Top = Color3.fromRGB(14, 14, 14),
	Sidebar = Color3.fromRGB(14, 14, 14),
	Element = Color3.fromRGB(22, 22, 22),
	ElementHover = Color3.fromRGB(30, 30, 30),
	Accent = Color3.fromRGB(220, 200, 100), -- Yellowish accent
	Text = Color3.fromRGB(220, 220, 220),
	SubText = Color3.fromRGB(150, 150, 150),
	Border = Color3.fromRGB(35, 35, 35),
	Rounding = UDim.new(0, 0), -- No rounding, sharp edges
	Font = Enum.Font.Code -- Monospace font
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function Library:CreateWindow(config)
	config = config or {}
	local title = config.Title or "AntiGravity UI"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AGLibrary"
	ScreenGui.ResetOnSpawn = false
	
	if RunService:IsStudio() then
		ScreenGui.Parent = LocalPlayer.PlayerGui
	else
		local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
		if not success then ScreenGui.Parent = LocalPlayer.PlayerGui end
	end

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Parent = ScreenGui
	Main.BackgroundColor3 = Theme.Main
	Main.BorderColor3 = Theme.Border
	Main.BorderSizePixel = 1
	Main.Position = UDim2.new(0.5, -350, 0.5, -250)
	Main.Size = UDim2.new(0, 700, 0, 500)
	Main.ClipsDescendants = true

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Parent = Main
	Topbar.BackgroundColor3 = Theme.Top
	Topbar.BorderSizePixel = 0
	Topbar.Size = UDim2.new(1, 0, 0, 30)

	local TopbarLine = Instance.new("Frame")
	TopbarLine.Parent = Topbar
	TopbarLine.BackgroundColor3 = Theme.Border
	TopbarLine.BorderSizePixel = 0
	TopbarLine.Position = UDim2.new(0, 0, 1, 0)
	TopbarLine.Size = UDim2.new(1, 0, 0, 1)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = Topbar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.Size = UDim2.new(1, -20, 1, 0)
	TitleLabel.Font = Theme.Font
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	Library:MakeDraggable(Topbar, Main)

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Position = UDim2.new(0, 0, 0, 31)
	Sidebar.Size = UDim2.new(0, 140, 1, -31)

	local SidebarLine = Instance.new("Frame")
	SidebarLine.Parent = Sidebar
	SidebarLine.BackgroundColor3 = Theme.Border
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Position = UDim2.new(1, 0, 0, 0)
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Parent = Sidebar
	TabContainer.Active = true
	TabContainer.BackgroundTransparency = 1
	TabContainer.Position = UDim2.new(0, 0, 0, 10)
	TabContainer.Size = UDim2.new(1, 0, 1, -20)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = Theme.Border

	local TabList = Instance.new("UIListLayout")
	TabList.Parent = TabContainer
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 2)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Parent = Main
	Pages.BackgroundTransparency = 1
	Pages.Position = UDim2.new(0, 141, 0, 31)
	Pages.Size = UDim2.new(1, -141, 1, -31)

	local WindowInfo = {
		CurrentTab = nil,
		Tabs = {}
	}

	function WindowInfo:CreateTab(name)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name
		TabButton.Parent = TabContainer
		TabButton.BackgroundColor3 = Theme.Element
		TabButton.BackgroundTransparency = 1
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, 0, 0, 25)
		TabButton.Font = Theme.Font
		TabButton.Text = name
		TabButton.TextColor3 = Theme.SubText
		TabButton.TextSize = 13

		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."Page"
		Page.Parent = Pages
		Page.Active = true
		Page.BackgroundTransparency = 1
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Border
		Page.Visible = false

		local PageList = Instance.new("UIListLayout")
		PageList.Parent = Page
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 5)
		
		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
		end)

		local PagePadding = Instance.new("UIPadding")
		PagePadding.Parent = Page
		PagePadding.PaddingTop = UDim.new(0, 10)
		PagePadding.PaddingLeft = UDim.new(0, 10)
		PagePadding.PaddingRight = UDim.new(0, 10)
		PagePadding.PaddingBottom = UDim.new(0, 10)

		local TabInfo = { Page = Page }

		TabButton.MouseButton1Click:Connect(function()
			if WindowInfo.CurrentTab == TabButton then return end
			
			for _, t in pairs(WindowInfo.Tabs) do
				Library:Tween(t.Button, {TextColor3 = Theme.SubText, BackgroundTransparency = 1})
				t.Page.Visible = false
			end

			Library:Tween(TabButton, {TextColor3 = Theme.Text, BackgroundTransparency = 0})
			Page.Visible = true
			WindowInfo.CurrentTab = TabButton
		end)
		
		table.insert(WindowInfo.Tabs, {Button = TabButton, Page = Page})
		
		if #WindowInfo.Tabs == 1 then
			Library:Tween(TabButton, {TextColor3 = Theme.Text, BackgroundTransparency = 0})
			Page.Visible = true
			WindowInfo.CurrentTab = TabButton
		end

		function TabInfo:CreateButton(bconfig)
			local text = bconfig.Name or "Button"
			local callback = bconfig.Callback or function() end

			local Button = Instance.new("TextButton")
			Button.Parent = Page
			Button.BackgroundColor3 = Theme.Element
			Button.BorderColor3 = Theme.Border
			Button.BorderSizePixel = 1
			Button.Size = UDim2.new(1, 0, 0, 30)
			Button.Font = Theme.Font
			Button.Text = text
			Button.TextColor3 = Theme.Text
			Button.TextSize = 13

			Button.MouseEnter:Connect(function() Library:Tween(Button, {BackgroundColor3 = Theme.ElementHover}) end)
			Button.MouseLeave:Connect(function() Library:Tween(Button, {BackgroundColor3 = Theme.Element}) end)
			Button.MouseButton1Down:Connect(function() Library:Tween(Button, {BorderColor3 = Theme.Accent}) end)
			Button.MouseButton1Up:Connect(function() 
				Library:Tween(Button, {BorderColor3 = Theme.Border})
				callback() 
			end)
		end

		return TabInfo
	end
	
	function WindowInfo:CreatePlayerList()
		local Tab = self:CreateTab("Players")
		local Page = Tab.Page
		
		-- Remove padding for this specific page to maximize space
		Page.UIPadding:Destroy()
		PageList = Page.UIListLayout
		PageList.Padding = UDim.new(0, 0)
		Page.ScrollBarThickness = 0 -- Hide scrollbar for cleaner look

		local MainContainer = Instance.new("Frame")
		MainContainer.Parent = Page
		MainContainer.BackgroundTransparency = 1
		MainContainer.Size = UDim2.new(1, 0, 1, 0)
		
		-- 1. Search Bar
		local SearchContainer = Instance.new("Frame")
		SearchContainer.Parent = MainContainer
		SearchContainer.BackgroundColor3 = Theme.Main
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
		SearchBox.TextSize = 13
		SearchBox.TextXAlignment = Enum.TextXAlignment.Left

		-- 2. Player List Scrolling Frame
		local ListContainer = Instance.new("Frame")
		ListContainer.Parent = MainContainer
		ListContainer.BackgroundColor3 = Theme.Main
		ListContainer.BorderColor3 = Theme.Border
		ListContainer.BorderSizePixel = 1
		ListContainer.Position = UDim2.new(0, 10, 0, 50)
		ListContainer.Size = UDim2.new(1, -20, 0, 200)

		local ListScroll = Instance.new("ScrollingFrame")
		ListScroll.Parent = ListContainer
		ListScroll.BackgroundTransparency = 1
		ListScroll.Size = UDim2.new(1, 0, 1, 0)
		ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		ListScroll.ScrollBarThickness = 4
		ListScroll.ScrollBarImageColor3 = Theme.Border
		ListScroll.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = ListScroll
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- 3. Selected Player Details Area
		local DetailsContainer = Instance.new("Frame")
		DetailsContainer.Parent = MainContainer
		DetailsContainer.BackgroundTransparency = 1
		DetailsContainer.Position = UDim2.new(0, 10, 0, 260)
		DetailsContainer.Size = UDim2.new(1, -20, 0, 190)

		local AvatarImage = Instance.new("ImageLabel")
		AvatarImage.Parent = DetailsContainer
		AvatarImage.BackgroundColor3 = Theme.Element
		AvatarImage.BorderSizePixel = 0
		AvatarImage.Position = UDim2.new(0, 0, 0, 0)
		AvatarImage.Size = UDim2.new(0, 70, 0, 70)
		AvatarImage.Image = ""

		local StatsLabel = Instance.new("TextLabel")
		StatsLabel.Parent = DetailsContainer
		StatsLabel.BackgroundTransparency = 1
		StatsLabel.Position = UDim2.new(0, 80, 0, 0)
		StatsLabel.Size = UDim2.new(1, -200, 0, 80)
		StatsLabel.Font = Theme.Font
		StatsLabel.Text = "Select a player...\nAccount Age: -"
		StatsLabel.TextColor3 = Theme.Text
		StatsLabel.TextSize = 12
		StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
		StatsLabel.TextYAlignment = Enum.TextXAlignment.Top
		
		-- Status Dropdown mock (static for visual)
		local StatusLabel = Instance.new("TextLabel")
		StatusLabel.Parent = DetailsContainer
		StatusLabel.BackgroundTransparency = 1
		StatusLabel.Position = UDim2.new(1, -120, 0, 20)
		StatusLabel.Size = UDim2.new(0, 120, 0, 15)
		StatusLabel.Font = Theme.Font
		StatusLabel.Text = "Status"
		StatusLabel.TextColor3 = Theme.Text
		StatusLabel.TextSize = 12
		StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

		local StatusBox = Instance.new("Frame")
		StatusBox.Parent = DetailsContainer
		StatusBox.BackgroundColor3 = Theme.Element
		StatusBox.BorderColor3 = Theme.Border
		StatusBox.BorderSizePixel = 1
		StatusBox.Position = UDim2.new(1, -120, 0, 40)
		StatusBox.Size = UDim2.new(0, 120, 0, 25)

		local StatusText = Instance.new("TextLabel")
		StatusText.Parent = StatusBox
		StatusText.BackgroundTransparency = 1
		StatusText.Position = UDim2.new(0, 5, 0, 0)
		StatusText.Size = UDim2.new(1, -20, 1, 0)
		StatusText.Font = Theme.Font
		StatusText.Text = "Neutral"
		StatusText.TextColor3 = Theme.Text
		StatusText.TextSize = 12
		StatusText.TextXAlignment = Enum.TextXAlignment.Left
		
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
		btnLayout.Padding = UDim.new(0, 5)

		local actions = {"Teleport", "Spectate", "Select as Target", "Highlight"}
		for i, action in ipairs(actions) do
			local actionBtn = Instance.new("TextButton")
			actionBtn.Parent = ButtonContainer
			actionBtn.BackgroundColor3 = Theme.Element
			actionBtn.BorderColor3 = Theme.Border
			actionBtn.BorderSizePixel = 1
			actionBtn.Size = UDim2.new(0.25, -3.75, 1, 0)
			actionBtn.Font = Theme.Font
			actionBtn.Text = action
			actionBtn.TextColor3 = Theme.Text
			actionBtn.TextSize = 12

			actionBtn.MouseEnter:Connect(function() Library:Tween(actionBtn, {BackgroundColor3 = Theme.ElementHover}) end)
			actionBtn.MouseLeave:Connect(function() Library:Tween(actionBtn, {BackgroundColor3 = Theme.Element}) end)
			actionBtn.MouseButton1Down:Connect(function() Library:Tween(actionBtn, {BorderColor3 = Theme.Accent}) end)
			actionBtn.MouseButton1Up:Connect(function() Library:Tween(actionBtn, {BorderColor3 = Theme.Border}) end)
		end

		local SelectedPlayer = nil
		local playerRows = {}

		local function selectPlayer(player, rowFrame, selectorLine)
			SelectedPlayer = player
			for _, r in pairs(playerRows) do
				Library:Tween(r.Line, {BackgroundTransparency = 1})
			end
			Library:Tween(selectorLine, {BackgroundTransparency = 0})

			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)
			if success then AvatarImage.Image = result else AvatarImage.Image = "" end

			StatsLabel.Text = string.format("%s - (@%s) - %d\nAccount Age: %d days",
				player.DisplayName, player.Name, player.UserId, player.AccountAge
			)
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
				PRow.BackgroundColor3 = Theme.Main
				PRow.BorderSizePixel = 0
				PRow.Size = UDim2.new(1, 0, 0, 30)
				PRow.Text = ""
				PRow.AutoButtonColor = false

				local SelectorLine = Instance.new("Frame")
				SelectorLine.Parent = PRow
				SelectorLine.BackgroundColor3 = Theme.Accent
				SelectorLine.BorderSizePixel = 0
				SelectorLine.Position = UDim2.new(1, -2, 0.1, 0)
				SelectorLine.Size = UDim2.new(0, 2, 0.8, 0)
				SelectorLine.BackgroundTransparency = (SelectedPlayer == player) and 0 or 1

				local NameLabel = Instance.new("TextLabel")
				NameLabel.Parent = PRow
				NameLabel.BackgroundTransparency = 1
				NameLabel.Position = UDim2.new(0, 10, 0, 0)
				NameLabel.Size = UDim2.new(0.5, 0, 1, 0)
				NameLabel.Font = Theme.Font
				NameLabel.Text = player.DisplayName .. " - (@" .. player.Name .. ")"
				NameLabel.TextColor3 = Theme.Text
				NameLabel.TextSize = 12
				NameLabel.TextXAlignment = Enum.TextXAlignment.Left

				local Col1 = Instance.new("TextLabel")
				Col1.Parent = PRow
				Col1.BackgroundTransparency = 1
				Col1.Position = UDim2.new(0.5, 0, 0, 0)
				Col1.Size = UDim2.new(0.25, 0, 1, 0)
				Col1.Font = Theme.Font
				Col1.Text = "None"
				Col1.TextColor3 = Theme.Text
				Col1.TextSize = 12
				Col1.TextXAlignment = Enum.TextXAlignment.Left

				local Col2 = Instance.new("TextLabel")
				Col2.Parent = PRow
				Col2.BackgroundTransparency = 1
				Col2.Position = UDim2.new(0.75, 0, 0, 0)
				Col2.Size = UDim2.new(0.25, -15, 1, 0)
				Col2.Font = Theme.Font
				Col2.Text = "Neutral"
				Col2.TextColor3 = Theme.Text
				Col2.TextSize = 12
				Col2.TextXAlignment = Enum.TextXAlignment.Right

				PRow.MouseEnter:Connect(function() Library:Tween(PRow, {BackgroundColor3 = Theme.Element}) end)
				PRow.MouseLeave:Connect(function() Library:Tween(PRow, {BackgroundColor3 = Theme.Main}) end)
				PRow.MouseButton1Click:Connect(function() selectPlayer(player, PRow, SelectorLine) end)

				table.insert(playerRows, {Row = PRow, Line = SelectorLine})
				ySize = ySize + 30
			end
			ListScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
		end

		populatePlayers()

		SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			populatePlayers(SearchBox.Text)
		end)
		
		Players.PlayerAdded:Connect(function() populatePlayers(SearchBox.Text) end)
		Players.PlayerRemoving:Connect(function() populatePlayers(SearchBox.Text) end)

		return Tab
	end

	return WindowInfo
end

return Library
