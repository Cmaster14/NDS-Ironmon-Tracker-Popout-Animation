local function ExtrasScreen(initialSettings, initialTracker, initialProgram)
	local Frame = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Frame.lua")
	local Box = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Box.lua")
	local Component = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Component.lua")
	local TextLabel = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/TextLabel.lua")
	local TextField = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/TextField.lua")
	local TextStyle = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/TextStyle.lua")
	local ImageLabel = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/ImageLabel.lua")
	local ImageField = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/ImageField.lua")
	local Layout = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Layout.lua")
	local Icon = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Icon.lua")
	local MouseClickEventListener = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/MouseClickEventListener.lua")
	local SettingToggleButton = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/SettingToggleButton.lua")
	local settings = initialSettings
	local tracker = initialTracker
	local program = initialProgram
	local tourneyTracker
	local animatedPokemon

	local self = {}

	local constants = {
		MAIN_FRAME_HEIGHT = 290,
		EXTRAS_HEIGHT = 230,
		EXTRA_ENTRY_TITLE_ROW_HEIGHT = 21,
		EXTRA_ENTRY_TEXT_ROW_HEIGHT = 10,
		EXTRA_WIDTH = 124,
		EXTRA_HEIGHT = 90,
		BUTTON_SIZE = 10
	}
	local ui = {}
	local eventListeners = {}

	local extras = {
		{
			name = "Tourney Tracker",
			iconImage = "trophy.png",
			descriptionRows = {
				"Auto tracks your scores",
				"for Crozwords' tourneys."
			},
			settingsKey = "tourneyTracker"
		},
		{
			name = "Animation Popout",
			iconImage = "special2.png",
			descriptionRows = {
				"Create animated popout",
				"for lead or party."
			},
			settingsKey = "animationPopout",
			leadKey = "animateLead",
			partyKey = "animateParty",
			horizKey = "animateHoriz",
			vertKey = "animateVert"
		}
			
	}

	local function onToggleClick(button)
		button.onClick()
		if settings.tourneyTracker.ENABLED then
			tourneyTracker.loadData()
		end
		if settings.animationPopout.ENABLED then
			animatedPokemon.show()
		else
			animatedPokemon.hide()
		end
		program.drawCurrentScreens()
	end
	
	local function onLeadToggleClick(button)
		if settings.animateParty.ENABLED or not settings.animateLead.ENABLED then
			button.onClick()
		end
		program.drawCurrentScreens()
		animatedPokemon.setupAnimatedPictureBox()
		animatedPokemon.refreshAnimations()
	end
	
	local function onPartyToggleClick(button)
		if settings.animateLead.ENABLED or not settings.animateParty.ENABLED then
			button.onClick()
		end
		program.drawCurrentScreens()
		animatedPokemon.setupAnimatedPictureBox()
		animatedPokemon.refreshAnimations()
	end
	
	local function onHorizToggleClick(button)
		if settings.animateVert.ENABLED or not settings.animateHoriz.ENABLED then
			button.onClick()
		end
		program.drawCurrentScreens()
		animatedPokemon.setupAnimatedPictureBox()
		animatedPokemon.refreshAnimations()
	end
	
	local function onVertToggleClick(button)
		if settings.animateHoriz.ENABLED or not settings.animateVert.ENABLED then
			button.onClick()
		end
		program.drawCurrentScreens()
		animatedPokemon.setupAnimatedPictureBox()
		animatedPokemon.refreshAnimations()
	end

	local function initBottomFrame()
		ui.frames.goBackFrame =
			Frame(
			Box(
				{x = 0, y = 0},
				{
					width = 0,
					height = 0
				}
			),
			nil,
			ui.frames.mainInnerFrame
		)
		ui.controls.goBackButton =
			TextLabel(
			Component(
				ui.frames.goBackFrame,
				Box(
					{x = Graphics.SIZES.MAIN_SCREEN_WIDTH - 54, y = 8},
					{width = 40, height = 14},
					"Top box background color",
					"Top box border color",
					true,
					"Top box background color"
				)
			),
			TextField(
				"Go back",
				{x = 3, y = 1},
				TextStyle(
					Graphics.FONT.DEFAULT_FONT_SIZE,
					Graphics.FONT.DEFAULT_FONT_FAMILY,
					"Top box text color",
					"Top box background color"
				)
			)
		)
		table.insert(
			eventListeners,
			MouseClickEventListener(ui.controls.goBackButton, program.openScreen, program.UI_SCREENS.MAIN_OPTIONS_SCREEN)
		)
	end

	local function onClearClick()
		FormsUtils.createConfirmDialog(tourneyTracker.clearData)
	end

	local function initExtra(extra)
		local extraFrame =
			Frame(
			Box(
				{x = 0, y = 0},
				{
					width = constants.EXTRA_WIDTH,
					height = constants.EXTRA_HEIGHT
				},
				"Top box background color",
				"Top box border color"
			),
			Layout(Graphics.ALIGNMENT_TYPE.VERTICAL, 2, {x = 4, y = 1}),
			ui.frames.extrasFrame
		)
		local iconNameFrame =
			Frame(
			Box(
				{x = 0, y = 0},
				{
					width = 0,
					height = constants.EXTRA_ENTRY_TITLE_ROW_HEIGHT
				}
			),
			Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 0, {x = -2, y = 4}),
			extraFrame
		)
		local iconPath =
			Paths.CURRENT_DIRECTORY ..
			Paths.SLASH .. "ironmon_tracker" .. Paths.SLASH .. "images" .. Paths.SLASH .. "icons" .. Paths.SLASH .. extra.iconImage
		local icon =
			ImageLabel(
			Component(iconNameFrame, Box({x = 0, y = 0}, {width = 14, height = 0}, nil, nil)),
			ImageField(iconPath, {x = 0, y = 0}, nil)
		)
		local title =
			TextLabel(
			Component(iconNameFrame, Box({x = 0, y = 0}, {width = 0, height = 0})),
			TextField(
				extra.name,
				{x = 0, y = 0},
				TextStyle(11, Graphics.FONT.DEFAULT_FONT_FAMILY, "Top box text color", "Top box background color")
			)
		)
		for i = 1, 2, 1 do
			local row =
				TextLabel(
				Component(extraFrame, Box({x = 0, y = 0}, {width = 0, height = constants.EXTRA_ENTRY_TEXT_ROW_HEIGHT})),
				TextField(
					extra.descriptionRows[i] or "",
					{x = 0, y = 0},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
		end

		local enabledFrame =
			Frame(
			Box({x = 0, y = 0}, {width = 0, height = 18}, nil, nil),
			Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 2, {x = 2, y = 4}),
			extraFrame
		)
		local leadFrame = nil
		local partyFrame = nil
		if extra.name == "Animation Popout" then
			extraFrame.resize({width = constants.EXTRA_WIDTH, height = constants.EXTRA_HEIGHT + 25})
			leadFrame = 
				Frame(
				Box({x = 0, y = 0}, {width = 0, height = 40}, nil, nil),
				Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 2, {x = 5, y = 6}),
				extraFrame
			)
			partyFrame = 
				Frame(
				Box({x = 0, y = 0}, {width = 0, height = 18}, nil, nil),
				Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 0, {x = 55, y = 0}),
				leadFrame
			)
			vertFrame = 
				Frame(
				Box({x = 0, y = 0}, {width = 0, height = 18}, nil, nil),
				Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 0, {x = 4, y = 20}),
				leadFrame
			)
			horizFrame = 
				Frame(
				Box({x = 0, y = 0}, {width = 0, height = 18}, nil, nil),
				Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 0, {x = 51, y = 20}),
				leadFrame
			)
		end
		local toggle =
			SettingToggleButton(
			Component(
				enabledFrame,
				Box(
					{x = 0, y = 0},
					{width = constants.BUTTON_SIZE, height = constants.BUTTON_SIZE},
					"Top box background color",
					"Top box border color",
					true,
					"Top box background color"
				)
			),
			settings[extra.settingsKey],
			"ENABLED",
			nil,
			false,
			true,
			program.saveSettings
		)
		table.insert(eventListeners, MouseClickEventListener(toggle, onToggleClick, toggle))
		local label =
			TextLabel(
			Component(enabledFrame, Box({x = 0, y = 0}, {width = 0, height = 0}, nil, nil, false)),
			TextField(
				"Enabled",
				{x = 0, y = 0},
				TextStyle(
					Graphics.FONT.DEFAULT_FONT_SIZE,
					Graphics.FONT.DEFAULT_FONT_FAMILY,
					"Top box text color",
					"Top box background color"
				)
			)
		)
		if extra.name == "Tourney Tracker" then
			ui.controls.clearButton =
				TextLabel(
				Component(
					extraFrame,
					Box(
						{x = 0, y = 0},
						{width = 116, height = 18},
						"Top box background color",
						"Top box border color",
						true,
						"Top box background color"
					)
				),
				TextField(
					"Clear Tourney Scores",
					{x = 17, y = 3},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
			table.insert(eventListeners, MouseClickEventListener(ui.controls.clearButton, onClearClick))
		elseif extra.name == "Animation Popout" then
			local lead =
				SettingToggleButton(
				Component(
					leadFrame,
					Box(
						{x = 0, y = 0},
						{width = constants.BUTTON_SIZE, height = constants.BUTTON_SIZE},
						"Top box background color",
						"Top box border color",
						true,
						"Top box background color"
					)
				),
				settings[extra.leadKey],
				"ENABLED",
				nil,
				false,
				true,
				program.saveSettings
			)
			table.insert(eventListeners, MouseClickEventListener(lead, onToggleClick, lead))
			local leadLabel =
				TextLabel(
				Component(leadFrame, Box({x = 0, y = 0}, {width = 0, height = 0}, nil, nil, false)),
				TextField(
					"Lead",
					{x = 0, y = 0},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
			local party =
				SettingToggleButton(
				Component(
					partyFrame,
					Box(
						{x = 0, y = 0},
						{width = constants.BUTTON_SIZE, height = constants.BUTTON_SIZE},
						"Top box background color",
						"Top box border color",
						true,
						"Top box background color"
					)
				),
				settings[extra.partyKey],
				"ENABLED",
				nil,
				false,
				true,
				program.saveSettings
			)
			table.insert(eventListeners, MouseClickEventListener(party, onToggleClick, party))
			table.insert(eventListeners, MouseClickEventListener(party, onPartyToggleClick, lead)) --Have party and lead buttons turn each other off
			table.insert(eventListeners, MouseClickEventListener(lead, onLeadToggleClick, party))
			local partyLabel =
				TextLabel(
				Component(partyFrame, Box({x = 0, y = 0}, {width = 0, height = 0}, nil, nil, false)),
				TextField(
					"Party",
					{x = 2, y = 0},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
			local horizontal =
				SettingToggleButton(
				Component(
					horizFrame,
					Box(
						{x = 0, y = 0},
						{width = constants.BUTTON_SIZE, height = constants.BUTTON_SIZE},
						"Top box background color",
						"Top box border color",
						true,
						"Top box background color"
					)
				),
				settings[extra.horizKey],
				"ENABLED",
				nil,
				false,
				true,
				program.saveSettings
			)
			table.insert(eventListeners, MouseClickEventListener(horizontal, onToggleClick, horizontal))
			local horizLabel =
				TextLabel(
				Component(horizFrame, Box({x = 0, y = 0}, {width = 0, height = 0}, nil, nil, false)),
				TextField(
					"Horizontal",
					{x = 2, y = 0},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
			local vertical =
				SettingToggleButton(
				Component(
					vertFrame,
					Box(
						{x = 0, y = 0},
						{width = constants.BUTTON_SIZE, height = constants.BUTTON_SIZE},
						"Top box background color",
						"Top box border color",
						true,
						"Top box background color"
					)
				),
				settings[extra.vertKey],
				"ENABLED",
				nil,
				false,
				true,
				program.saveSettings
			)
			table.insert(eventListeners, MouseClickEventListener(vertical, onToggleClick, vertical))
			table.insert(eventListeners, MouseClickEventListener(vertical, onVertToggleClick, horizontal)) --Have vertical and horizontal buttons turn each other off
			table.insert(eventListeners, MouseClickEventListener(horizontal, onHorizToggleClick, vertical))
			local vertLabel =
				TextLabel(
				Component(vertFrame, Box({x = 0, y = 0}, {width = 0, height = 0}, nil, nil, false)),
				TextField(
					"Vertical",
					{x = 2, y = 0},
					TextStyle(
						Graphics.FONT.DEFAULT_FONT_SIZE,
						Graphics.FONT.DEFAULT_FONT_FAMILY,
						"Top box text color",
						"Top box background color"
					)
				)
			)
		end
	end

	local function initExtrasUI()
		ui.frames.extrasFrame =
			Frame(
			Box(
				{x = 0, y = 0},
				{
					width = 0,
					height = constants.EXTRAS_HEIGHT
				}
			),
			Layout(Graphics.ALIGNMENT_TYPE.VERTICAL, 5, {x = 8, y = 8}),
			ui.frames.mainInnerFrame
		)
		for _, extra in pairs(extras) do
			initExtra(extra)
		end
	end

	function self.injectExtraRelatedClasses(newTourneyTracker, newAnimatedPokemon)
		tourneyTracker = newTourneyTracker
		animatedPokemon = newAnimatedPokemon
	end

	local function initUI()
		ui.controls = {}
		ui.frames = {}
		ui.frames.mainFrame =
			Frame(
			Box(
				{x = Graphics.SIZES.SCREEN_WIDTH, y = 0},
				{width = Graphics.SIZES.MAIN_SCREEN_WIDTH, height = constants.MAIN_FRAME_HEIGHT},
				"Main background color",
				nil
			),
			Layout(Graphics.ALIGNMENT_TYPE.HORIZONTAL, 0, {x = 5, y = 5}),
			nil
		)
		ui.frames.mainInnerFrame =
			Frame(
			Box(
				{x = Graphics.SIZES.BORDER_MARGIN, y = Graphics.SIZES.BORDER_MARGIN},
				{
					width = Graphics.SIZES.MAIN_SCREEN_WIDTH - 2 * Graphics.SIZES.BORDER_MARGIN,
					height = constants.MAIN_FRAME_HEIGHT - 2 * Graphics.SIZES.BORDER_MARGIN
				},
				"Top box background color",
				"Top box border color"
			),
			Layout(Graphics.ALIGNMENT_TYPE.VERTICAL),
			ui.frames.mainFrame
		)
		ui.controls.topHeading =
			TextLabel(
			Component(
				ui.frames.mainInnerFrame,
				Box(
					{x = 0, y = 0},
					{width = Graphics.SIZES.MAIN_SCREEN_WIDTH - 2 * Graphics.SIZES.BORDER_MARGIN, height = 18},
					"Top box background color",
					"Top box border color",
					false
				)
			),
			TextField(
				"Extras",
				{x = 50, y = 1},
				TextStyle(13, Graphics.FONT.DEFAULT_FONT_FAMILY, "Top box text color", "Top box background color")
			)
		)
		initExtrasUI()
		initBottomFrame()
	end

	function self.runEventListeners()
		for _, eventListener in pairs(eventListeners) do
			eventListener.listen()
		end
	end

	function self.show()
		ui.frames.mainFrame.show()
	end

	initUI()

	return self
end

return ExtrasScreen
