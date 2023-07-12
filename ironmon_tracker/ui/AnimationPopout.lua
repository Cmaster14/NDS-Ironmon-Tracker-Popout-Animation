local function AnimationPopout(initialProgram, initialSettings)
	local self = {}
    local program = initialProgram
	local settings = initialSettings
	local created = false
	local orientation = "S"
	local maxAni = 1
	
	local Frame = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Frame.lua")
	local Box = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Box.lua")
	local Component = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Component.lua")
	local ImageLabel = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/ImageLabel.lua")
	local ImageField = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/ImageField.lua")
	local Layout = dofile(Paths.FOLDERS.UI_BASE_CLASSES .. "/Layout.lua")

	local box = {
		TRANSPARENCY_COLOR = "Magenta",
		POPUP_WIDTH = 250,
		POPUP_HEIGHT = 250,
		formWindow = 0,
		party = {0,0,0,0,0,0},
		pokemonID = {0,0,0,0,0,0},
		maxMonWidth = 200
	}	
	
	local relocate = {
		true,
		true,
		true,
		true,
		true,
		true
	}
	
	function self.getCreated()
		return created
	end
	
	function self.shouldRelocate()
		return relocate
	end
	
	local function destroy(window)
		created = false
		forms.destroy(window)
		box.formWindow = 0
		box.party = {0,0,0,0,0,0}
		box.pokemonID = {0,0,0,0,0,0}
		relocate = {
			true,
			true,
			true,
			true,
			true,
			true
		}
	end
	
	function self.hide()
		forms.setproperty(box.formWindow, "Visible", false)
	end
	
	function self.show()
		forms.setproperty(box.formWindow, "Visible", true)
	end
	
	function self.getMaxAni()
		return maxAni
	end
	
	local function getPathIfExists(filepath)
		-- Empty filepaths "" can be opened successfully on Linux, as directories are considered files
		if filepath == nil or filepath == "" then return nil end
	
		local file = io.open(filepath, "r")
		if file ~= nil then
			io.close(file)
			return filepath
		end
	
		-- Otherwise check the absolute path of the file
		filepath = Paths.CURRENT_DIRECTORY .. filepath
		file = io.open(filepath, "r")
		if file ~= nil then
			io.close(file)
			return filepath
		end
	
		return nil
	end
		
	local function fileExists(filepath)
		return getPathIfExists(filepath) ~= nil
	end
	
	function self.requiresRelocating(pos)
		return relocate[pos]
	end
	
	local function setOrientation(newOrientation)
		if newOrientation == "S" then
			box.POPUP_WIDTH = 250
			box.POPUP_HEIGHT = 250
			orientation = "S"
		end
		if newOrientation == "H" then
			box.POPUP_WIDTH = 1400
			box.POPUP_HEIGHT = 200
			orientation = "H"
		end
		if newOrientation == "V" then
			box.POPUP_WIDTH = 275
			box.POPUP_HEIGHT = 950
			orientation = "V"
		end
	end
	
	local function setupBox(formWindow)
		if orientation == "S" then
			local pokemon1 = forms.pictureBox(formWindow, 25, 10, 125, 1)
			box.party[1] = pokemon1		
		elseif orientation == "V" then
			local pokemon1 = forms.pictureBox(formWindow, 25, 1, 130, 120)
			local pokemon2 = forms.pictureBox(formWindow, 25, 150, 130, 120)
			local pokemon3 = forms.pictureBox(formWindow, 25, 280, 130, 120)
			local pokemon4 = forms.pictureBox(formWindow, 25, 450, 130, 120)
			local pokemon5 = forms.pictureBox(formWindow, 25, 610, 130, 120)
			local pokemon6 = forms.pictureBox(formWindow, 25, 750, 130, 120)
		
			box.party[1] = pokemon1
			box.party[2] = pokemon2
			box.party[3] = pokemon3
			box.party[4] = pokemon4
			box.party[5] = pokemon5
			box.party[6] = pokemon6
		else
			local pokemon1 = forms.pictureBox(formWindow, 10, 5, 220, 1)
			local pokemon2 = forms.pictureBox(formWindow, 230, 5, 220, 1)
			local pokemon3 = forms.pictureBox(formWindow, 450, 5, 220, 1)
			local pokemon4 = forms.pictureBox(formWindow, 670, 5, 220, 1)
			local pokemon5 = forms.pictureBox(formWindow, 890, 5, 220, 1)
			local pokemon6 = forms.pictureBox(formWindow, 1110, 5, 220, 1)
		
			box.party[1] = pokemon1
			box.party[2] = pokemon2
			box.party[3] = pokemon3
			box.party[4] = pokemon4
			box.party[5] = pokemon5
			box.party[6] = pokemon6			
		end
	end
	
	--unused, but created to attempt recreation of box to avoid resizing issues
	local function recreatePBox(pbox, pos)
		local pboxX = tonumber(forms.getproperty(pbox, "Left"))
		local pboxY = tonumber(forms.getproperty(pbox, "Top"))
		local path = forms.getproperty(pbox, "ImageLocation")
		local window = box.formWindow
		local newBox = forms.pictureBox(window, pboxX, pboxY, 1, 1)
		forms.clearImageCache(pbox)
		box.party[pos] = newBox
	end
	
	function self.setupAnimatedPictureBox()	
		destroy(box.formWindow)
		
		if settings.animateLead.ENABLED then
			maxAni = 1
		else
			maxAni = 6
		end
	
		if settings.animateLead.ENABLED then
			setOrientation("S")
		else
			if settings.animateHoriz.ENABLED then
				setOrientation("H")
			elseif settings.animateVert.ENABLED then
				setOrientation("V")
			end
		end
	
		local formWindow = forms.newform(box.POPUP_WIDTH, box.POPUP_HEIGHT, "Animated Pokemon ", function() client.unpause() end)
		box.formWindow = formWindow
		forms.setproperty(formWindow, "AllowTransparency", true)
		forms.setproperty(formWindow, "BackColor", box.TRANSPARENCY_COLOR)
		forms.setproperty(formWindow, "TransparencyKey", box.TRANSPARENCY_COLOR)
		forms.setproperty(formWindow, "Visible", true)
		
		setupBox(formWindow)
	
		created = true
		program.forceAnimatedUpdateBypass()
	end
	
	local function setAnimatedPokemon(pokemonID, pos)
		if pokemonID == 0 then
			return
		elseif pokemonID == nil then
			pokemonID = 0
		end
		
		if pokemonID ~= box.pokemonID[pos] then
			local pokemonData = PokemonData.POKEMON[pokemonID+1]
			local pbox = box.party[pos]
			
			if pokemonID == 0 then
				forms.setproperty(pbox, "Visible", false)
				relocate[pos] = false
				return
			end
			
			if pokemonData ~= nil then
				box.pokemonID[pos] = pokemonID
	
				local lowerPokemonName = pokemonData.name:lower()
				local imagepath = Paths.FOLDERS.ANIMATIONS_FOLDER .. "\\" .. lowerPokemonName .. ".gif"
				local fileExists = fileExists(imagepath)
				if fileExists then
					if orientation == "H" or orientation == "S" then
						forms.setproperty(pbox, "Height", 1)
					end
					forms.setproperty(pbox, "Width", 1)
					forms.clear(pbox, box.TRANSPARENCY_COLOR)
					forms.setproperty(pbox, "ImageLocation", imagepath)
					forms.refresh(pbox)
					forms.setproperty(pbox, "AutoSize", 2)
					relocate[pos] = true
				end
			end
		end
	end
	
	function self.animatePokemon(mon, monPos)
		setAnimatedPokemon(mon, monPos)
	end
	
	function self.refreshMon(pos)
		local refresh = relocate[pos]
		if not refresh then
			local pbox = box.party[pos]
			forms.refresh(pbox)			
		end
	end
	
	function self.refreshAnimations()
		for p=1, maxAni, 1 do
			forms.refresh(box.party[p])
		end
	end
	
	-- When the image is first set, the image size (height) is unknown. It requires a few frames before it can be updated
	function self.relocateAnimatedPokemon(pos)
		local pbox = box.party[pos]
		-- If the image is the same, then attempt to relocate it based on it's height
		local imageY = tonumber(forms.getproperty(pbox, "Top"))
		local imageHeight = tonumber(forms.getproperty(pbox, "Height"))
		local relocated = false
	
		-- Only relocate exactly once, 1=starting height of the box
		if imageY ~= nil and imageHeight ~= nil then
			local bottomUpY
			if orientation == "H" or orientation == "S" then
				bottomUpY = box.POPUP_HEIGHT - imageHeight - 40
				if bottomUpY ~= imageY then
					forms.setproperty(pbox, "Top", bottomUpY)
					relocate[pos] = (imageHeight == 1)
				end
			end
			if orientation == "V" then
				relocate[pos] = false
			end
		end
		forms.setproperty(pbox, "Visible", true)
	end
	
	return self
end

return AnimationPopout
