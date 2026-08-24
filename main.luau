-- =====================================================
--         BankaiUI Library - v2.0
--         Dark Terminal Aesthetic
-- =====================================================

local Library = {}

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local LocalPlayer     = Players.LocalPlayer

-- ─────────────────────────────────────────
--  Theme
-- ─────────────────────────────────────────
local T = {
	Background  = Color3.fromRGB(16, 15, 14),
	Top         = Color3.fromRGB(11, 10,  9),
	Sidebar     = Color3.fromRGB(20, 19, 18),
	Element     = Color3.fromRGB(26, 25, 24),
	ElementHover= Color3.fromRGB(36, 35, 34),
	Border      = Color3.fromRGB(42, 41, 40),
	Accent      = Color3.fromRGB(219, 192, 90),
	AccentDim   = Color3.fromRGB(140, 120, 50),
	Text        = Color3.fromRGB(215, 215, 215),
	SubText     = Color3.fromRGB(120, 120, 120),
	Danger      = Color3.fromRGB(200,  60,  60),
	Font        = Enum.Font.Code,
	TextSize    = 12,
}

-- ─────────────────────────────────────────
--  Utilities
-- ─────────────────────────────────────────
local function tween(obj, props, dur)
	TweenService:Create(obj, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function makeDraggable(handle, frame)
	local dragging, startPos, startMouse
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startPos  = frame.Position
			startMouse= i.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - startMouse
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Creates a labelled section separator inside a page
local function makeSection(page, text)
	local f = Instance.new("Frame")
	f.Parent = page
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, 0, 0, 18)

	local lbl = Instance.new("TextLabel")
	lbl.Parent = f
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.Font = T.Font
	lbl.Text = "── " .. text .. " ──"
	lbl.TextColor3 = T.AccentDim
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ─────────────────────────────────────────
--  CreateWindow
-- ─────────────────────────────────────────
function Library:CreateWindow(config)
	config = config or {}
	local title   = config.Title   or "BankaiUI"
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	-- ── ScreenGui ──
	local sg = Instance.new("ScreenGui")
	sg.Name           = "BankaiUI"
	sg.ResetOnSpawn   = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	if RunService:IsStudio() then
		sg.Parent = LocalPlayer.PlayerGui
	else
		pcall(function() sg.Parent = game:GetService("CoreGui") end)
		if not sg.Parent or not sg.Parent:IsA("CoreGui") then
			sg.Parent = LocalPlayer.PlayerGui
		end
	end

	-- ── Main Frame ──
	local Main = Instance.new("Frame")
	Main.Name            = "Main"
	Main.Parent          = sg
	Main.BackgroundColor3= T.Background
	Main.BorderColor3    = T.Border
	Main.BorderSizePixel = 1
	Main.Position        = UDim2.new(0.5, -350, 0.5, -250)
	Main.Size            = UDim2.new(0, 700, 0, 500)
	Main.ClipsDescendants= true

	-- ── Topbar ──
	local Topbar = Instance.new("Frame")
	Topbar.Name            = "Topbar"
	Topbar.Parent          = Main
	Topbar.BackgroundColor3= T.Top
	Topbar.BorderColor3    = T.Border
	Topbar.BorderSizePixel = 1
	Topbar.Size            = UDim2.new(1, 0, 0, 28)

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Parent           = Topbar
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Position         = UDim2.new(0, 10, 0, 0)
	TitleLbl.Size             = UDim2.new(1, -80, 1, 0)
	TitleLbl.Font             = T.Font
	TitleLbl.Text             = title
	TitleLbl.TextColor3       = T.Text
	TitleLbl.TextSize         = T.TextSize
	TitleLbl.TextXAlignment   = Enum.TextXAlignment.Left

	-- Toggle key hint label
	local HintLbl = Instance.new("TextLabel")
	HintLbl.Parent           = Topbar
	HintLbl.BackgroundTransparency = 1
	HintLbl.Position         = UDim2.new(1, -110, 0, 0)
	HintLbl.Size             = UDim2.new(0, 100, 1, 0)
	HintLbl.Font             = T.Font
	HintLbl.Text             = "[" .. toggleKey.Name .. "] toggle"
	HintLbl.TextColor3       = T.SubText
	HintLbl.TextSize         = 10
	HintLbl.TextXAlignment   = Enum.TextXAlignment.Right

	makeDraggable(Topbar, Main)

	-- ── Sidebar ──
	local Sidebar = Instance.new("Frame")
	Sidebar.Name            = "Sidebar"
	Sidebar.Parent          = Main
	Sidebar.BackgroundColor3= T.Sidebar
	Sidebar.BorderColor3    = T.Border
	Sidebar.BorderSizePixel = 1
	Sidebar.Position        = UDim2.new(0, 0, 0, 27)
	Sidebar.Size            = UDim2.new(0, 145, 1, -27)

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Parent          = Sidebar
	TabScroll.BackgroundTransparency = 1
	TabScroll.Position        = UDim2.new(0, 0, 0, 8)
	TabScroll.Size            = UDim2.new(1, 0, 1, -16)
	TabScroll.CanvasSize      = UDim2.new(0, 0, 0, 0)
	TabScroll.ScrollBarThickness = 1
	TabScroll.ScrollBarImageColor3 = T.Border
	TabScroll.BorderSizePixel = 0

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Parent       = TabScroll
	TabLayout.SortOrder    = Enum.SortOrder.LayoutOrder
	TabLayout.Padding      = UDim.new(0, 1)
	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
	end)

	-- ── Pages Container ──
	local Pages = Instance.new("Frame")
	Pages.Name            = "Pages"
	Pages.Parent          = Main
	Pages.BackgroundTransparency = 1
	Pages.Position        = UDim2.new(0, 145, 0, 28)
	Pages.Size            = UDim2.new(1, -145, 1, -28)

	-- ── Open/Close Toggle ──
	local visible = true
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == toggleKey then
			visible = not visible
			tween(Main, {Size = visible and UDim2.new(0, 700, 0, 500) or UDim2.new(0, 700, 0, 28)}, 0.2)
			Sidebar.Visible = visible
			Pages.Visible   = visible
		end
	end)

	-- ─────────────────────────────────────────
	local W = { CurrentTab = nil, Tabs = {} }

	-- ─────────────────────────────────────────
	--  CreateTab
	-- ─────────────────────────────────────────
	function W:CreateTab(name)
		-- Tab button
		local Btn = Instance.new("TextButton")
		Btn.Name            = name
		Btn.Parent          = TabScroll
		Btn.BackgroundColor3= T.Sidebar
		Btn.BorderSizePixel = 0
		Btn.Size            = UDim2.new(1, 0, 0, 28)
		Btn.Font            = T.Font
		Btn.Text            = "  " .. name
		Btn.TextColor3      = T.SubText
		Btn.TextSize        = T.TextSize
		Btn.TextXAlignment  = Enum.TextXAlignment.Left
		Btn.AutoButtonColor = false

		-- Left accent line (hidden by default)
		local AccentLine = Instance.new("Frame")
		AccentLine.Parent          = Btn
		AccentLine.BackgroundColor3= T.Accent
		AccentLine.BorderSizePixel = 0
		AccentLine.Size            = UDim2.new(0, 2, 1, 0)
		AccentLine.BackgroundTransparency = 1

		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name            = name .. "_Page"
		Page.Parent          = Pages
		Page.BackgroundTransparency = 1
		Page.Size            = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize      = UDim2.new(0, 0, 0, 0)
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = T.Border
		Page.BorderSizePixel = 0
		Page.Visible         = false

		local Padding = Instance.new("UIPadding")
		Padding.Parent        = Page
		Padding.PaddingTop    = UDim.new(0, 12)
		Padding.PaddingLeft   = UDim.new(0, 12)
		Padding.PaddingRight  = UDim.new(0, 12)
		Padding.PaddingBottom = UDim.new(0, 12)

		local PLayout = Instance.new("UIListLayout")
		PLayout.Parent    = Page
		PLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PLayout.Padding   = UDim.new(0, 6)
		PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 24)
		end)

		Btn.MouseButton1Click:Connect(function()
			if W.CurrentTab == Btn then return end
			for _, t in ipairs(W.Tabs) do
				tween(t.Btn, { TextColor3 = T.SubText, BackgroundColor3 = T.Sidebar })
				tween(t.Line, { BackgroundTransparency = 1 })
				t.Page.Visible = false
			end
			tween(Btn, { TextColor3 = T.Text, BackgroundColor3 = T.Element })
			tween(AccentLine, { BackgroundTransparency = 0 })
			Page.Visible   = true
			W.CurrentTab   = Btn
		end)

		table.insert(W.Tabs, { Btn = Btn, Line = AccentLine, Page = Page })
		if #W.Tabs == 1 then
			tween(Btn, { TextColor3 = T.Text, BackgroundColor3 = T.Element })
			AccentLine.BackgroundTransparency = 0
			Page.Visible = true
			W.CurrentTab = Btn
		end

		local Tab = { Page = Page }

		-- ─────────────────────────────────────────
		--  CreateLabel
		-- ─────────────────────────────────────────
		function Tab:CreateLabel(config)
			local text    = type(config) == "string" and config or (config.Text or "Label")
			local color   = type(config) == "table" and config.Color or T.SubText

			local f = Instance.new("Frame")
			f.Parent = Page
			f.BackgroundTransparency = 1
			f.Size = UDim2.new(1, 0, 0, 20)

			local lbl = Instance.new("TextLabel")
			lbl.Parent           = f
			lbl.BackgroundTransparency = 1
			lbl.Size             = UDim2.new(1, 0, 1, 0)
			lbl.Font             = T.Font
			lbl.Text             = text
			lbl.TextColor3       = color
			lbl.TextSize         = T.TextSize
			lbl.TextXAlignment   = Enum.TextXAlignment.Left
			lbl.TextWrapped      = true

			return { SetText = function(_, t) lbl.Text = t end }
		end

		-- ─────────────────────────────────────────
		--  CreateButton
		-- ─────────────────────────────────────────
		function Tab:CreateButton(config)
			local text     = config.Name     or "Button"
			local callback = config.Callback or function() end

			local Btn = Instance.new("TextButton")
			Btn.Parent          = Page
			Btn.BackgroundColor3= T.Element
			Btn.BorderColor3    = T.Border
			Btn.BorderSizePixel = 1
			Btn.Size            = UDim2.new(1, 0, 0, 30)
			Btn.Font            = T.Font
			Btn.Text            = text
			Btn.TextColor3      = T.Text
			Btn.TextSize        = T.TextSize
			Btn.AutoButtonColor = false

			Btn.MouseEnter:Connect(function()    tween(Btn, { BackgroundColor3 = T.ElementHover }) end)
			Btn.MouseLeave:Connect(function()    tween(Btn, { BackgroundColor3 = T.Element      }) end)
			Btn.MouseButton1Down:Connect(function() tween(Btn, { BorderColor3 = T.Accent        }) end)
			Btn.MouseButton1Up:Connect(function()
				tween(Btn, { BorderColor3 = T.Border })
				callback()
			end)
		end

		-- ─────────────────────────────────────────
		--  CreateToggle
		-- ─────────────────────────────────────────
		function Tab:CreateToggle(config)
			local text     = config.Name     or "Toggle"
			local state    = config.Default  or false
			local callback = config.Callback or function() end

			local Row = Instance.new("TextButton")
			Row.Parent          = Page
			Row.BackgroundColor3= T.Element
			Row.BorderColor3    = T.Border
			Row.BorderSizePixel = 1
			Row.Size            = UDim2.new(1, 0, 0, 30)
			Row.Text            = ""
			Row.AutoButtonColor = false

			local Lbl = Instance.new("TextLabel")
			Lbl.Parent           = Row
			Lbl.BackgroundTransparency = 1
			Lbl.Position         = UDim2.new(0, 10, 0, 0)
			Lbl.Size             = UDim2.new(1, -42, 1, 0)
			Lbl.Font             = T.Font
			Lbl.Text             = text
			Lbl.TextColor3       = T.Text
			Lbl.TextSize         = T.TextSize
			Lbl.TextXAlignment   = Enum.TextXAlignment.Left

			-- Checkbox outer
			local CheckOuter = Instance.new("Frame")
			CheckOuter.Parent          = Row
			CheckOuter.BackgroundColor3= T.Background
			CheckOuter.BorderColor3    = T.Border
			CheckOuter.BorderSizePixel = 1
			CheckOuter.AnchorPoint     = Vector2.new(0, 0.5)
			CheckOuter.Position        = UDim2.new(1, -28, 0.5, 0)
			CheckOuter.Size            = UDim2.new(0, 16, 0, 16)

			-- Checkbox fill
			local CheckFill = Instance.new("Frame")
			CheckFill.Parent          = CheckOuter
			CheckFill.BackgroundColor3= T.Accent
			CheckFill.BorderSizePixel = 0
			CheckFill.Position        = UDim2.new(0, 2, 0, 2)
			CheckFill.Size            = UDim2.new(1, -4, 1, -4)
			CheckFill.BackgroundTransparency = state and 0 or 1

			Row.MouseEnter:Connect(function() tween(Row, { BackgroundColor3 = T.ElementHover }) end)
			Row.MouseLeave:Connect(function() tween(Row, { BackgroundColor3 = T.Element      }) end)
			Row.MouseButton1Click:Connect(function()
				state = not state
				tween(CheckFill, { BackgroundTransparency = state and 0 or 1 })
				tween(CheckOuter, { BorderColor3 = state and T.Accent or T.Border })
				callback(state)
			end)

			return {
				SetValue = function(_, v)
					state = v
					tween(CheckFill, { BackgroundTransparency = state and 0 or 1 })
					tween(CheckOuter, { BorderColor3 = state and T.Accent or T.Border })
				end
			}
		end

		-- ─────────────────────────────────────────
		--  CreateSlider
		-- ─────────────────────────────────────────
		function Tab:CreateSlider(config)
			local text     = config.Name     or "Slider"
			local minVal   = config.Min      or 0
			local maxVal   = config.Max      or 100
			local default  = math.clamp(config.Default or minVal, minVal, maxVal)
			local callback = config.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Parent          = Page
			Frame.BackgroundColor3= T.Element
			Frame.BorderColor3    = T.Border
			Frame.BorderSizePixel = 1
			Frame.Size            = UDim2.new(1, 0, 0, 46)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Parent           = Frame
			NameLbl.BackgroundTransparency = 1
			NameLbl.Position         = UDim2.new(0, 10, 0, 5)
			NameLbl.Size             = UDim2.new(1, -20, 0, 16)
			NameLbl.Font             = T.Font
			NameLbl.Text             = text
			NameLbl.TextColor3       = T.Text
			NameLbl.TextSize         = T.TextSize
			NameLbl.TextXAlignment   = Enum.TextXAlignment.Left

			local ValLbl = Instance.new("TextLabel")
			ValLbl.Parent           = Frame
			ValLbl.BackgroundTransparency = 1
			ValLbl.Position         = UDim2.new(0, 10, 0, 5)
			ValLbl.Size             = UDim2.new(1, -20, 0, 16)
			ValLbl.Font             = T.Font
			ValLbl.Text             = tostring(default)
			ValLbl.TextColor3       = T.Accent
			ValLbl.TextSize         = T.TextSize
			ValLbl.TextXAlignment   = Enum.TextXAlignment.Right

			local Track = Instance.new("Frame")
			Track.Parent          = Frame
			Track.BackgroundColor3= T.Background
			Track.BorderColor3    = T.Border
			Track.BorderSizePixel = 1
			Track.Position        = UDim2.new(0, 10, 0, 28)
			Track.Size            = UDim2.new(1, -20, 0, 10)

			local Fill = Instance.new("Frame")
			Fill.Parent          = Track
			Fill.BackgroundColor3= T.Accent
			Fill.BorderSizePixel = 0
			Fill.Size            = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)

			-- Invisible button overlay for input
			local Hitbox = Instance.new("TextButton")
			Hitbox.Parent          = Track
			Hitbox.BackgroundTransparency = 1
			Hitbox.Size            = UDim2.new(1, 0, 1, 0)
			Hitbox.Text            = ""
			Hitbox.AutoButtonColor = false

			local dragging = false
			local function applyInput(i)
				local pct = math.clamp((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local v   = math.floor(minVal + (maxVal - minVal) * pct)
				tween(Fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.07)
				ValLbl.Text = tostring(v)
				callback(v)
			end

			Hitbox.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true; applyInput(i)
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then applyInput(i) end
			end)
		end

		-- ─────────────────────────────────────────
		--  CreateDropdown
		-- ─────────────────────────────────────────
		function Tab:CreateDropdown(config)
			local text     = config.Name    or "Dropdown"
			local options  = config.Options or {}
			local callback = config.Callback or function() end
			local isOpen   = false
			local selected = nil

			local Wrapper = Instance.new("Frame")
			Wrapper.Parent          = Page
			Wrapper.BackgroundColor3= T.Element
			Wrapper.BorderColor3    = T.Border
			Wrapper.BorderSizePixel = 1
			Wrapper.Size            = UDim2.new(1, 0, 0, 28)
			Wrapper.ClipsDescendants= true

			local Header = Instance.new("TextButton")
			Header.Parent          = Wrapper
			Header.BackgroundTransparency = 1
			Header.Size            = UDim2.new(1, 0, 0, 28)
			Header.Text            = ""
			Header.AutoButtonColor = false

			local HeaderLbl = Instance.new("TextLabel")
			HeaderLbl.Parent         = Header
			HeaderLbl.BackgroundTransparency = 1
			HeaderLbl.Position       = UDim2.new(0, 10, 0, 0)
			HeaderLbl.Size           = UDim2.new(1, -30, 1, 0)
			HeaderLbl.Font           = T.Font
			HeaderLbl.Text           = text
			HeaderLbl.TextColor3     = T.Text
			HeaderLbl.TextSize       = T.TextSize
			HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left

			local Arrow = Instance.new("TextLabel")
			Arrow.Parent         = Header
			Arrow.BackgroundTransparency = 1
			Arrow.Position       = UDim2.new(1, -22, 0, 0)
			Arrow.Size           = UDim2.new(0, 20, 1, 0)
			Arrow.Font           = T.Font
			Arrow.Text           = "▾"
			Arrow.TextColor3     = T.SubText
			Arrow.TextSize       = 14

			local OptionList = Instance.new("Frame")
			OptionList.Parent          = Wrapper
			OptionList.BackgroundTransparency = 1
			OptionList.Position        = UDim2.new(0, 0, 0, 28)
			OptionList.Size            = UDim2.new(1, 0, 0, #options * 26)

			local OLayout = Instance.new("UIListLayout")
			OLayout.Parent    = OptionList
			OLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local function setOpen(v)
				isOpen = v
				local h = 28 + (v and (#options * 26) or 0)
				tween(Wrapper, { Size = UDim2.new(1, 0, 0, h) })
				tween(Arrow, { Rotation = v and 180 or 0 })
			end

			Header.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

			for _, opt in ipairs(options) do
				local OBtn = Instance.new("TextButton")
				OBtn.Parent          = OptionList
				OBtn.BackgroundColor3= T.Background
				OBtn.BorderColor3    = T.Border
				OBtn.BorderSizePixel = 0
				OBtn.Size            = UDim2.new(1, 0, 0, 26)
				OBtn.Font            = T.Font
				OBtn.Text            = "  " .. opt
				OBtn.TextColor3      = T.SubText
				OBtn.TextSize        = T.TextSize
				OBtn.TextXAlignment  = Enum.TextXAlignment.Left
				OBtn.AutoButtonColor = false

				-- Separator line between options
				local Sep = Instance.new("Frame")
				Sep.Parent          = OBtn
				Sep.BackgroundColor3= T.Border
				Sep.BorderSizePixel = 0
				Sep.Position        = UDim2.new(0, 0, 0, 0)
				Sep.Size            = UDim2.new(1, 0, 0, 1)

				OBtn.MouseEnter:Connect(function() tween(OBtn, { TextColor3 = T.Text, BackgroundColor3 = T.ElementHover }) end)
				OBtn.MouseLeave:Connect(function()
					tween(OBtn, { TextColor3 = selected == opt and T.Accent or T.SubText, BackgroundColor3 = T.Background })
				end)
				OBtn.MouseButton1Click:Connect(function()
					selected = opt
					HeaderLbl.Text = text .. "  ›  " .. opt
					tween(HeaderLbl, { TextColor3 = T.Accent })
					setOpen(false)
					callback(opt)
					-- reset all option colours
					for _, c in ipairs(OptionList:GetChildren()) do
						if c:IsA("TextButton") then
							tween(c, { TextColor3 = c.Text:find(opt) and T.Accent or T.SubText })
						end
					end
				end)
			end
		end

		-- ─────────────────────────────────────────
		--  CreateTextBox (input box)
		-- ─────────────────────────────────────────
		function Tab:CreateTextBox(config)
			local text       = config.Name        or "Input"
			local placeholder= config.Placeholder or ""
			local callback   = config.Callback    or function() end

			local Frame = Instance.new("Frame")
			Frame.Parent          = Page
			Frame.BackgroundColor3= T.Element
			Frame.BorderColor3    = T.Border
			Frame.BorderSizePixel = 1
			Frame.Size            = UDim2.new(1, 0, 0, 48)

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Parent           = Frame
			NameLbl.BackgroundTransparency = 1
			NameLbl.Position         = UDim2.new(0, 10, 0, 5)
			NameLbl.Size             = UDim2.new(1, -20, 0, 14)
			NameLbl.Font             = T.Font
			NameLbl.Text             = text
			NameLbl.TextColor3       = T.SubText
			NameLbl.TextSize         = 10
			NameLbl.TextXAlignment   = Enum.TextXAlignment.Left

			local InputBg = Instance.new("Frame")
			InputBg.Parent          = Frame
			InputBg.BackgroundColor3= T.Background
			InputBg.BorderColor3    = T.Border
			InputBg.BorderSizePixel = 1
			InputBg.Position        = UDim2.new(0, 10, 0, 22)
			InputBg.Size            = UDim2.new(1, -20, 0, 20)

			local Box = Instance.new("TextBox")
			Box.Parent           = InputBg
			Box.BackgroundTransparency = 1
			Box.Position         = UDim2.new(0, 6, 0, 0)
			Box.Size             = UDim2.new(1, -12, 1, 0)
			Box.Font             = T.Font
			Box.PlaceholderText  = placeholder
			Box.PlaceholderColor3= T.SubText
			Box.Text             = ""
			Box.TextColor3       = T.Text
			Box.TextSize         = T.TextSize
			Box.TextXAlignment   = Enum.TextXAlignment.Left
			Box.ClearTextOnFocus = false

			Box.Focused:Connect(function()     tween(InputBg, { BorderColor3 = T.Accent }) end)
			Box.FocusLost:Connect(function(enter)
				tween(InputBg, { BorderColor3 = T.Border })
				if enter then callback(Box.Text) end
			end)

			return { GetValue = function() return Box.Text end }
		end

		-- ─────────────────────────────────────────
		--  CreateKeybind
		-- ─────────────────────────────────────────
		function Tab:CreateKeybind(config)
			local text     = config.Name     or "Keybind"
			local default  = config.Default  or Enum.KeyCode.Unknown
			local callback = config.Callback or function() end
			local binding  = default
			local listening = false

			local Row = Instance.new("TextButton")
			Row.Parent          = Page
			Row.BackgroundColor3= T.Element
			Row.BorderColor3    = T.Border
			Row.BorderSizePixel = 1
			Row.Size            = UDim2.new(1, 0, 0, 30)
			Row.Text            = ""
			Row.AutoButtonColor = false

			local NameLbl = Instance.new("TextLabel")
			NameLbl.Parent           = Row
			NameLbl.BackgroundTransparency = 1
			NameLbl.Position         = UDim2.new(0, 10, 0, 0)
			NameLbl.Size             = UDim2.new(1, -90, 1, 0)
			NameLbl.Font             = T.Font
			NameLbl.Text             = text
			NameLbl.TextColor3       = T.Text
			NameLbl.TextSize         = T.TextSize
			NameLbl.TextXAlignment   = Enum.TextXAlignment.Left

			local KeyBox = Instance.new("TextLabel")
			KeyBox.Parent           = Row
			KeyBox.BackgroundColor3 = T.Background
			KeyBox.BorderColor3     = T.Border
			KeyBox.BorderSizePixel  = 1
			KeyBox.AnchorPoint      = Vector2.new(1, 0.5)
			KeyBox.Position         = UDim2.new(1, -10, 0.5, 0)
			KeyBox.Size             = UDim2.new(0, 72, 0, 18)
			KeyBox.Font             = T.Font
			KeyBox.Text             = binding.Name
			KeyBox.TextColor3       = T.Accent
			KeyBox.TextSize         = T.TextSize

			Row.MouseEnter:Connect(function() tween(Row, { BackgroundColor3 = T.ElementHover }) end)
			Row.MouseLeave:Connect(function() tween(Row, { BackgroundColor3 = T.Element      }) end)
			Row.MouseButton1Click:Connect(function()
				if listening then return end
				listening   = true
				KeyBox.Text = "..."
				tween(KeyBox, { BorderColor3 = T.Accent })
			end)

			UserInputService.InputBegan:Connect(function(i, gp)
				if gp or not listening then return end
				if i.UserInputType == Enum.UserInputType.Keyboard then
					binding     = i.KeyCode
					KeyBox.Text = binding.Name
					tween(KeyBox, { BorderColor3 = T.Border })
					listening   = false
				end
			end)

			UserInputService.InputBegan:Connect(function(i, gp)
				if gp then return end
				if i.KeyCode == binding then callback() end
			end)
		end

		return Tab
	end -- CreateTab

	-- ─────────────────────────────────────────
	--  CreatePlayerList
	-- ─────────────────────────────────────────
	function W:CreatePlayerList()
		local Tab  = self:CreateTab("Players")
		local Page = Tab.Page

		-- Remove default page padding/layout for full-control layout
		for _, c in ipairs(Page:GetChildren()) do
			if c:IsA("UIPadding") or c:IsA("UIListLayout") then c:Destroy() end
		end
		Page.ScrollBarThickness = 0

		-- ── Search Bar ──
		local SearchBg = Instance.new("Frame")
		SearchBg.Parent          = Page
		SearchBg.BackgroundColor3= T.Background
		SearchBg.BorderColor3    = T.Border
		SearchBg.BorderSizePixel = 1
		SearchBg.Position        = UDim2.new(0, 10, 0, 10)
		SearchBg.Size            = UDim2.new(1, -20, 0, 28)

		local SearchBox = Instance.new("TextBox")
		SearchBox.Parent          = SearchBg
		SearchBox.BackgroundTransparency = 1
		SearchBox.Position        = UDim2.new(0, 8, 0, 0)
		SearchBox.Size            = UDim2.new(1, -16, 1, 0)
		SearchBox.Font            = T.Font
		SearchBox.PlaceholderText = "Search players..."
		SearchBox.PlaceholderColor3 = T.SubText
		SearchBox.Text            = ""
		SearchBox.TextColor3      = T.Text
		SearchBox.TextSize        = T.TextSize
		SearchBox.TextXAlignment  = Enum.TextXAlignment.Left
		SearchBox.ClearTextOnFocus = false
		SearchBox.Focused:Connect(function()   tween(SearchBg, { BorderColor3 = T.Accent }) end)
		SearchBox.FocusLost:Connect(function() tween(SearchBg, { BorderColor3 = T.Border }) end)

		-- ── Column Headers ──
		local Headers = Instance.new("Frame")
		Headers.Parent          = Page
		Headers.BackgroundColor3= T.Element
		Headers.BorderColor3    = T.Border
		Headers.BorderSizePixel = 1
		Headers.Position        = UDim2.new(0, 10, 0, 42)
		Headers.Size            = UDim2.new(1, -20, 0, 18)

		for i, h in ipairs({"Player", "Team", "Status"}) do
			local l = Instance.new("TextLabel")
			l.Parent           = Headers
			l.BackgroundTransparency = 1
			l.Position         = UDim2.new((i-1)/3, 8, 0, 0)
			l.Size             = UDim2.new(1/3, -8, 1, 0)
			l.Font             = T.Font
			l.Text             = h
			l.TextColor3       = T.SubText
			l.TextSize         = 10
			l.TextXAlignment   = Enum.TextXAlignment.Left
		end

		-- ── Player List Scroll ──
		local ListBg = Instance.new("Frame")
		ListBg.Parent          = Page
		ListBg.BackgroundColor3= T.Background
		ListBg.BorderColor3    = T.Border
		ListBg.BorderSizePixel = 1
		ListBg.Position        = UDim2.new(0, 10, 0, 59)
		ListBg.Size            = UDim2.new(1, -20, 0, 190)

		local ListScroll = Instance.new("ScrollingFrame")
		ListScroll.Parent          = ListBg
		ListScroll.BackgroundTransparency = 1
		ListScroll.Size            = UDim2.new(1, 0, 1, 0)
		ListScroll.CanvasSize      = UDim2.new(0, 0, 0, 0)
		ListScroll.ScrollBarThickness = 2
		ListScroll.ScrollBarImageColor3 = T.Border
		ListScroll.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent    = ListScroll
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
		end)

		-- ── Details Panel ──
		local DetailsBg = Instance.new("Frame")
		DetailsBg.Parent          = Page
		DetailsBg.BackgroundColor3= T.Element
		DetailsBg.BorderColor3    = T.Border
		DetailsBg.BorderSizePixel = 1
		DetailsBg.Position        = UDim2.new(0, 10, 0, 260)
		DetailsBg.Size            = UDim2.new(1, -20, 0, 80)

		local Avatar = Instance.new("ImageLabel")
		Avatar.Parent          = DetailsBg
		Avatar.BackgroundColor3= T.Background
		Avatar.BorderColor3    = T.Border
		Avatar.BorderSizePixel = 1
		Avatar.Position        = UDim2.new(0, 6, 0.5, 0)
		Avatar.AnchorPoint     = Vector2.new(0, 0.5)
		Avatar.Size            = UDim2.new(0, 58, 0, 58)
		Avatar.Image           = ""

		local InfoLbl = Instance.new("TextLabel")
		InfoLbl.Parent           = DetailsBg
		InfoLbl.BackgroundTransparency = 1
		InfoLbl.Position         = UDim2.new(0, 76, 0, 6)
		InfoLbl.Size             = UDim2.new(1, -82, 1, -12)
		InfoLbl.Font             = T.Font
		InfoLbl.Text             = "Select a player..."
		InfoLbl.TextColor3       = T.SubText
		InfoLbl.TextSize         = T.TextSize
		InfoLbl.TextXAlignment   = Enum.TextXAlignment.Left
		InfoLbl.TextYAlignment   = Enum.TextYAlignment.Top
		InfoLbl.TextWrapped      = true

		-- ── Action Buttons ──
		local ActionsRow = Instance.new("Frame")
		ActionsRow.Parent          = Page
		ActionsRow.BackgroundTransparency = 1
		ActionsRow.Position        = UDim2.new(0, 10, 0, 348)
		ActionsRow.Size            = UDim2.new(1, -20, 0, 28)

		local ActLayout = Instance.new("UIListLayout")
		ActLayout.Parent         = ActionsRow
		ActLayout.FillDirection  = Enum.FillDirection.Horizontal
		ActLayout.SortOrder      = Enum.SortOrder.LayoutOrder
		ActLayout.Padding        = UDim.new(0, 4)

		local actions   = {"Teleport", "Spectate", "Highlight"}
		local callbacks = {}

		for i, act in ipairs(actions) do
			local B = Instance.new("TextButton")
			B.Parent          = ActionsRow
			B.BackgroundColor3= T.Element
			B.BorderColor3    = T.Border
			B.BorderSizePixel = 1
			B.Size            = UDim2.new(1/3, -3, 1, 0)
			B.Font            = T.Font
			B.Text            = act
			B.TextColor3      = T.Text
			B.TextSize        = T.TextSize
			B.AutoButtonColor = false

			local idx = i
			B.MouseEnter:Connect(function()    tween(B, { BackgroundColor3 = T.ElementHover }) end)
			B.MouseLeave:Connect(function()    tween(B, { BackgroundColor3 = T.Element      }) end)
			B.MouseButton1Down:Connect(function() tween(B, { BorderColor3 = T.Accent        }) end)
			B.MouseButton1Up:Connect(function()
				tween(B, { BorderColor3 = T.Border })
				if callbacks[idx] then callbacks[idx]() end
			end)
		end

		-- ── Player Rows ──
		local SelectedPlayer = nil
		local playerRows     = {}

		local function selectPlayer(player, selLine)
			SelectedPlayer = player
			for _, r in ipairs(playerRows) do tween(r.Line, { BackgroundTransparency = 1 }) end
			tween(selLine, { BackgroundTransparency = 0 })

			pcall(function()
				Avatar.Image = Players:GetUserThumbnailAsync(
					player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)

			InfoLbl.TextColor3 = T.Text
			InfoLbl.Text = string.format(
				"%s  (@%s)\nUser ID:  %d\nAccount Age:  %d days",
				player.DisplayName, player.Name, player.UserId, player.AccountAge
			)
		end

		local function buildRows(filter)
			for _, c in ipairs(ListScroll:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() end
			end
			playerRows = {}

			for _, player in ipairs(Players:GetPlayers()) do
				local lc = string.lower
				if filter and filter ~= "" then
					if not lc(player.Name):find(lc(filter), 1, true)
					and not lc(player.DisplayName):find(lc(filter), 1, true) then
						continue
					end
				end

				local Row = Instance.new("Frame")
				Row.Parent          = ListScroll
				Row.BackgroundColor3= T.Background
				Row.BorderSizePixel = 0
				Row.Size            = UDim2.new(1, 0, 0, 28)

				-- Right selection line
				local SelLine = Instance.new("Frame")
				SelLine.Parent          = Row
				SelLine.BackgroundColor3= T.Accent
				SelLine.BorderSizePixel = 0
				SelLine.Position        = UDim2.new(1, -2, 0.15, 0)
				SelLine.Size            = UDim2.new(0, 2, 0.7, 0)
				SelLine.BackgroundTransparency = (SelectedPlayer == player) and 0 or 1

				-- Bottom separator
				local Sep = Instance.new("Frame")
				Sep.Parent          = Row
				Sep.BackgroundColor3= T.Border
				Sep.BorderSizePixel = 0
				Sep.Position        = UDim2.new(0, 0, 1, -1)
				Sep.Size            = UDim2.new(1, 0, 0, 1)

				-- Name column
				local NameLbl = Instance.new("TextLabel")
				NameLbl.Parent           = Row
				NameLbl.BackgroundTransparency = 1
				NameLbl.Position         = UDim2.new(0, 8, 0, 0)
				NameLbl.Size             = UDim2.new(1/3, -8, 1, 0)
				NameLbl.Font             = T.Font
				NameLbl.Text             = player.DisplayName .. " (@" .. player.Name .. ")"
				NameLbl.TextColor3       = player == LocalPlayer and T.Accent or T.Text
				NameLbl.TextSize         = T.TextSize
				NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
				NameLbl.TextTruncate     = Enum.TextTruncate.AtEnd

				-- Team column
				local TeamLbl = Instance.new("TextLabel")
				TeamLbl.Parent           = Row
				TeamLbl.BackgroundTransparency = 1
				TeamLbl.Position         = UDim2.new(1/3, 8, 0, 0)
				TeamLbl.Size             = UDim2.new(1/3, -8, 1, 0)
				TeamLbl.Font             = T.Font
				TeamLbl.Text             = player.Team and player.Team.Name or "None"
				TeamLbl.TextColor3       = T.SubText
				TeamLbl.TextSize         = T.TextSize
				TeamLbl.TextXAlignment   = Enum.TextXAlignment.Left

				-- Status column
				local StatLbl = Instance.new("TextLabel")
				StatLbl.Parent           = Row
				StatLbl.BackgroundTransparency = 1
				StatLbl.Position         = UDim2.new(2/3, 8, 0, 0)
				StatLbl.Size             = UDim2.new(1/3, -20, 1, 0)
				StatLbl.Font             = T.Font
				StatLbl.Text             = "Neutral"
				StatLbl.TextColor3       = T.SubText
				StatLbl.TextSize         = T.TextSize
				StatLbl.TextXAlignment   = Enum.TextXAlignment.Left

				-- Hover / click
				local btn = Instance.new("TextButton")
				btn.Parent          = Row
				btn.BackgroundTransparency = 1
				btn.Size            = UDim2.new(1, 0, 1, 0)
				btn.Text            = ""
				btn.AutoButtonColor = false

				btn.MouseEnter:Connect(function()    tween(Row, { BackgroundColor3 = T.ElementHover }) end)
				btn.MouseLeave:Connect(function()    tween(Row, { BackgroundColor3 = T.Background   }) end)
				btn.MouseButton1Click:Connect(function() selectPlayer(player, SelLine) end)

				table.insert(playerRows, { Row = Row, Line = SelLine })
			end
		end

		buildRows()
		SearchBox:GetPropertyChangedSignal("Text"):Connect(function() buildRows(SearchBox.Text) end)
		Players.PlayerAdded:Connect(function()   task.wait(0.5); buildRows(SearchBox.Text) end)
		Players.PlayerRemoving:Connect(function() task.wait(0.1); buildRows(SearchBox.Text) end)

		return Tab
	end -- CreatePlayerList

	return W
end -- CreateWindow

return Library
