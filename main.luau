local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Main = Color3.fromRGB(20, 20, 25),
	Top = Color3.fromRGB(25, 25, 30),
	Sidebar = Color3.fromRGB(25, 25, 30),
	Element = Color3.fromRGB(35, 35, 40),
	ElementHover = Color3.fromRGB(45, 45, 50),
	Accent = Color3.fromRGB(59, 130, 246), -- Blue accent
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(150, 150, 150),
	Rounding = UDim.new(0, 6)
}

function Library:Tween(instance, properties, duration)
	local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
	Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	Main.Size = UDim2.new(0, 600, 0, 400)
	Main.ClipsDescendants = true

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = Theme.Rounding
	MainCorner.Parent = Main

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Parent = Main
	Topbar.BackgroundColor3 = Theme.Top
	Topbar.Size = UDim2.new(1, 0, 0, 40)

	local TopbarCorner = Instance.new("UICorner")
	TopbarCorner.CornerRadius = Theme.Rounding
	TopbarCorner.Parent = Topbar

	local TopbarExtension = Instance.new("Frame")
	TopbarExtension.Parent = Topbar
	TopbarExtension.BackgroundColor3 = Theme.Top
	TopbarExtension.BorderSizePixel = 0
	TopbarExtension.Position = UDim2.new(0, 0, 1, -10)
	TopbarExtension.Size = UDim2.new(1, 0, 0, 10)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = Topbar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.Size = UDim2.new(1, -30, 1, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	Library:MakeDraggable(Topbar, Main)

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Parent = Main
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.Size = UDim2.new(0, 150, 1, -40)
	Sidebar.BorderSizePixel = 0

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Parent = Sidebar
	TabContainer.Active = true
	TabContainer.BackgroundTransparency = 1
	TabContainer.Position = UDim2.new(0, 0, 0, 10)
	TabContainer.Size = UDim2.new(1, 0, 1, -20)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.ScrollBarThickness = 0

	local TabList = Instance.new("UIListLayout")
	TabList.Parent = TabContainer
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 5)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Parent = Main
	Pages.BackgroundTransparency = 1
	Pages.Position = UDim2.new(0, 160, 0, 50)
	Pages.Size = UDim2.new(1, -170, 1, -60)

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
		TabButton.Size = UDim2.new(1, -20, 0, 30)
		TabButton.Font = Enum.Font.GothamMedium
		TabButton.Text = name
		TabButton.TextColor3 = Theme.SubText
		TabButton.TextSize = 14

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = Theme.Rounding
		TabCorner.Parent = TabButton
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."Page"
		Page.Parent = Pages
		Page.Active = true
		Page.BackgroundTransparency = 1
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.ScrollBarThickness = 4
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = false

		local PageList = Instance.new("UIListLayout")
		PageList.Parent = Page
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		
		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
		end)

		local TabInfo = {
			Page = Page
		}

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
			Button.Name = "Button"
			Button.Parent = Page
			Button.BackgroundColor3 = Theme.Element
			Button.Size = UDim2.new(1, -10, 0, 35)
			Button.Font = Enum.Font.Gotham
			Button.Text = text
			Button.TextColor3 = Theme.Text
			Button.TextSize = 14

			local ButtonCorner = Instance.new("UICorner")
			ButtonCorner.CornerRadius = Theme.Rounding
			ButtonCorner.Parent = Button

			Button.MouseEnter:Connect(function()
				Library:Tween(Button, {BackgroundColor3 = Theme.ElementHover})
			end)

			Button.MouseLeave:Connect(function()
				Library:Tween(Button, {BackgroundColor3 = Theme.Element})
			end)

			Button.MouseButton1Down:Connect(function()
				Library:Tween(Button, {BackgroundColor3 = Theme.Accent})
			end)

			Button.MouseButton1Up:Connect(function()
				Library:Tween(Button, {BackgroundColor3 = Theme.ElementHover})
				callback()
			end)
		end

		function TabInfo:CreateToggle(tconfig)
			local text = tconfig.Name or "Toggle"
			local default = tconfig.Default or false
			local callback = tconfig.Callback or function() end

			local state = default

			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Name = "ToggleFrame"
			ToggleFrame.Parent = Page
			ToggleFrame.BackgroundColor3 = Theme.Element
			ToggleFrame.Size = UDim2.new(1, -10, 0, 35)

			local ToggleCorner = Instance.new("UICorner")
			ToggleCorner.CornerRadius = Theme.Rounding
			ToggleCorner.Parent = ToggleFrame

			local ToggleLabel = Instance.new("TextLabel")
			ToggleLabel.Parent = ToggleFrame
			ToggleLabel.BackgroundTransparency = 1
			ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
			ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
			ToggleLabel.Font = Enum.Font.Gotham
			ToggleLabel.Text = text
			ToggleLabel.TextColor3 = Theme.Text
			ToggleLabel.TextSize = 14
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

			local Switch = Instance.new("Frame")
			Switch.Parent = ToggleFrame
			Switch.BackgroundColor3 = state and Theme.Accent or Theme.Main
			Switch.Position = UDim2.new(1, -45, 0.5, -10)
			Switch.Size = UDim2.new(0, 35, 0, 20)

			local SwitchCorner = Instance.new("UICorner")
			SwitchCorner.CornerRadius = UDim.new(1, 0)
			SwitchCorner.Parent = Switch

			local Circle = Instance.new("Frame")
			Circle.Parent = Switch
			Circle.BackgroundColor3 = Theme.Text
			Circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			Circle.Size = UDim2.new(0, 16, 0, 16)

			local CircleCorner = Instance.new("UICorner")
			CircleCorner.CornerRadius = UDim.new(1, 0)
			CircleCorner.Parent = Circle

			local Button = Instance.new("TextButton")
			Button.Parent = ToggleFrame
			Button.BackgroundTransparency = 1
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.Text = ""

			local function toggle()
				state = not state
				Library:Tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Main})
				Library:Tween(Circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
				callback(state)
			end

			Button.MouseButton1Click:Connect(toggle)
		end

		function TabInfo:CreateSlider(sconfig)
			local text = sconfig.Name or "Slider"
			local min = sconfig.Min or 0
			local max = sconfig.Max or 100
			local default = sconfig.Default or min
			local callback = sconfig.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Name = "SliderFrame"
			SliderFrame.Parent = Page
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)

			local SliderCorner = Instance.new("UICorner")
			SliderCorner.CornerRadius = Theme.Rounding
			SliderCorner.Parent = SliderFrame

			local SliderLabel = Instance.new("TextLabel")
			SliderLabel.Parent = SliderFrame
			SliderLabel.BackgroundTransparency = 1
			SliderLabel.Position = UDim2.new(0, 10, 0, 5)
			SliderLabel.Size = UDim2.new(1, -20, 0, 20)
			SliderLabel.Font = Enum.Font.Gotham
			SliderLabel.Text = text
			SliderLabel.TextColor3 = Theme.Text
			SliderLabel.TextSize = 14
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Parent = SliderFrame
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Position = UDim2.new(0, 10, 0, 5)
			ValueLabel.Size = UDim2.new(1, -20, 0, 20)
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.Text = tostring(default)
			ValueLabel.TextColor3 = Theme.Text
			ValueLabel.TextSize = 14
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

			local BarBack = Instance.new("Frame")
			BarBack.Parent = SliderFrame
			BarBack.BackgroundColor3 = Theme.Main
			BarBack.Position = UDim2.new(0, 10, 0, 35)
			BarBack.Size = UDim2.new(1, -20, 0, 6)

			local BarBackCorner = Instance.new("UICorner")
			BarBackCorner.CornerRadius = UDim.new(1, 0)
			BarBackCorner.Parent = BarBack

			local Fill = Instance.new("Frame")
			Fill.Parent = BarBack
			Fill.BackgroundColor3 = Theme.Accent
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(1, 0)
			FillCorner.Parent = Fill

			local Button = Instance.new("TextButton")
			Button.Parent = BarBack
			Button.BackgroundTransparency = 1
			Button.Position = UDim2.new(0, -10, 0, -10)
			Button.Size = UDim2.new(1, 20, 1, 20)
			Button.Text = ""

			local dragging = false

			local function update(input)
				local percentage = math.clamp((input.Position.X - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X, 0, 1)
				local value = math.floor(min + (max - min) * percentage)
				
				Library:Tween(Fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
				ValueLabel.Text = tostring(value)
				callback(value)
			end

			Button.InputBegan:Connect(function(input)
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

		function TabInfo:CreateDropdown(dconfig)
			local text = dconfig.Name or "Dropdown"
			local options = dconfig.Options or {}
			local callback = dconfig.Callback or function() end

			local open = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Name = "DropdownFrame"
			DropdownFrame.Parent = Page
			DropdownFrame.BackgroundColor3 = Theme.Element
			DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
			DropdownFrame.ClipsDescendants = true

			local DropdownCorner = Instance.new("UICorner")
			DropdownCorner.CornerRadius = Theme.Rounding
			DropdownCorner.Parent = DropdownFrame

			local Button = Instance.new("TextButton")
			Button.Parent = DropdownFrame
			Button.BackgroundColor3 = Theme.Element
			Button.BackgroundTransparency = 1
			Button.Size = UDim2.new(1, 0, 0, 35)
			Button.Font = Enum.Font.Gotham
			Button.Text = ""
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Button
			Title.BackgroundTransparency = 1
			Title.Position = UDim2.new(0, 10, 0, 0)
			Title.Size = UDim2.new(1, -40, 1, 0)
			Title.Font = Enum.Font.Gotham
			Title.Text = text
			Title.TextColor3 = Theme.Text
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left

			local Icon = Instance.new("TextLabel")
			Icon.Parent = Button
			Icon.BackgroundTransparency = 1
			Icon.Position = UDim2.new(1, -30, 0, 0)
			Icon.Size = UDim2.new(0, 20, 1, 0)
			Icon.Font = Enum.Font.Gotham
			Icon.Text = "+"
			Icon.TextColor3 = Theme.Text
			Icon.TextSize = 18

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Parent = DropdownFrame
			OptionContainer.BackgroundTransparency = 1
			OptionContainer.Position = UDim2.new(0, 0, 0, 35)
			OptionContainer.Size = UDim2.new(1, 0, 1, -35)

			local OptionList = Instance.new("UIListLayout")
			OptionList.Parent = OptionContainer
			OptionList.SortOrder = Enum.SortOrder.LayoutOrder

			local function refreshList()
				local height = 35
				if open then
					height = 35 + (#options * 30)
				end
				Library:Tween(DropdownFrame, {Size = UDim2.new(1, -10, 0, height)})
				Library:Tween(Icon, {Rotation = open and 45 or 0})
			end

			Button.MouseButton1Click:Connect(function()
				open = not open
				refreshList()
			end)

			for _, option in ipairs(options) do
				local OptButton = Instance.new("TextButton")
				OptButton.Parent = OptionContainer
				OptButton.BackgroundColor3 = Theme.ElementHover
				OptButton.BackgroundTransparency = 1
				OptButton.Size = UDim2.new(1, 0, 0, 30)
				OptButton.Font = Enum.Font.Gotham
				OptButton.Text = option
				OptButton.TextColor3 = Theme.SubText
				OptButton.TextSize = 13

				OptButton.MouseEnter:Connect(function()
					Library:Tween(OptButton, {TextColor3 = Theme.Text, BackgroundTransparency = 0.5})
				end)

				OptButton.MouseLeave:Connect(function()
					Library:Tween(OptButton, {TextColor3 = Theme.SubText, BackgroundTransparency = 1})
				end)

				OptButton.MouseButton1Click:Connect(function()
					Title.Text = text .. " : " .. option
					open = false
					refreshList()
					callback(option)
				end)
			end
		end

		return TabInfo
	end
	
	function WindowInfo:CreatePlayerList()
		local Tab = self:CreateTab("Players")
		
		local refreshBtnConfig = {
			Name = "Refresh Player List",
			Callback = function() end 
		}
		Tab:CreateButton(refreshBtnConfig)

		local ListContainer = Instance.new("Frame")
		ListContainer.Parent = Tab.Page 
		ListContainer.BackgroundTransparency = 1
		ListContainer.Size = UDim2.new(1, -10, 0, 0)
		ListContainer.Position = UDim2.new(0, 0, 0, 45) 
		
		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = ListContainer
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 5)

		local function populatePlayers()
			for _, child in ipairs(ListContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			local ySize = 0
			for _, player in ipairs(Players:GetPlayers()) do
				local PFrame = Instance.new("Frame")
				PFrame.Parent = ListContainer
				PFrame.BackgroundColor3 = Theme.Element
				PFrame.Size = UDim2.new(1, 0, 0, 40)
				
				local PCorner = Instance.new("UICorner")
				PCorner.CornerRadius = Theme.Rounding
				PCorner.Parent = PFrame

				local Avatar = Instance.new("ImageLabel")
				Avatar.Parent = PFrame
				Avatar.BackgroundTransparency = 1
				Avatar.Position = UDim2.new(0, 5, 0, 5)
				Avatar.Size = UDim2.new(0, 30, 0, 30)
				
				local success, result = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				end)
				if success then Avatar.Image = result end

				local ACorner = Instance.new("UICorner")
				ACorner.CornerRadius = UDim.new(1, 0)
				ACorner.Parent = Avatar

				local NameLabel = Instance.new("TextLabel")
				NameLabel.Parent = PFrame
				NameLabel.BackgroundTransparency = 1
				NameLabel.Position = UDim2.new(0, 45, 0, 0)
				NameLabel.Size = UDim2.new(1, -50, 1, 0)
				NameLabel.Font = Enum.Font.GothamMedium
				NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
				NameLabel.TextColor3 = player == LocalPlayer and Theme.Accent or Theme.Text
				NameLabel.TextSize = 14
				NameLabel.TextXAlignment = Enum.TextXAlignment.Left

				ySize = ySize + 45
			end
			ListContainer.Size = UDim2.new(1, -10, 0, ySize)
			
			Tab.Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 60)
		end

		for _, child in ipairs(Tab.Page:GetChildren()) do
			if child:IsA("TextButton") and child.Text == "Refresh Player List" then
				child.MouseButton1Up:Connect(populatePlayers)
			end
		end

		populatePlayers()
		
		Players.PlayerAdded:Connect(populatePlayers)
		Players.PlayerRemoving:Connect(populatePlayers)

		return Tab
	end

	return WindowInfo
end

return Library
