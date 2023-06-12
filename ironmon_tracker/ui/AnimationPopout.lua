local function AnimationPopout(initialProgram, initialSettings)
	local self = {}
    local program = initialProgram
	local settings = initialSettings
	local created = false
	local partyChanged = true
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
		POPUP_WIDTH = 200,
		POPUP_HEIGHT = 200,
		formWindow = 0,
		party = {0,0,0,0,0,0},
		pokemonID = {0,0,0,0,0,0},
		pokemonNames = {0,0,0,0,0,0}
	}
	
	local relocate = {
		false,
		false,
		false,
		false,
		false,
		false
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
		box.pokemonNames = {0,0,0,0,0,0}
		relocate = {
			false,
			false,
			false,
			false,
			false,
			false
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
			box.POPUP_WIDTH = 200
			box.POPUP_HEIGHT = 200
			orientation = "S"
		end
		if newOrientation == "H" then
			box.POPUP_WIDTH = 750
			box.POPUP_HEIGHT = 200
			orientation = "H"
		end
		if newOrientation == "V" then
			box.POPUP_WIDTH = 275
			box.POPUP_HEIGHT = 800
			orientation = "V"
		end
	end
	
	local function setupBox(formWindow)
		if orientation == "S" then
			local pokemon1 = forms.pictureBox(formWindow, 50, 50, 125, 1)
			box.party[1] = pokemon1		
		elseif orientation == "V" then
			local pokemon1 = forms.pictureBox(formWindow, 25, 1, 125, 120)
			local pokemon2 = forms.pictureBox(formWindow, 25, 130, 125, 120)
			local pokemon3 = forms.pictureBox(formWindow, 25, 260, 125, 120)
			local pokemon4 = forms.pictureBox(formWindow, 25, 390, 125, 120)
			local pokemon5 = forms.pictureBox(formWindow, 25, 520, 125, 120)
			local pokemon6 = forms.pictureBox(formWindow, 25, 650, 125, 120)
		
			box.party[1] = pokemon1
			box.party[2] = pokemon2
			box.party[3] = pokemon3
			box.party[4] = pokemon4
			box.party[5] = pokemon5
			box.party[6] = pokemon6
		else
			local pokemon1 = forms.pictureBox(formWindow, 5, 5, 125, 1)
			local pokemon2 = forms.pictureBox(formWindow, 130, 5, 125, 1)
			local pokemon3 = forms.pictureBox(formWindow, 255, 5, 125, 1)
			local pokemon4 = forms.pictureBox(formWindow, 380, 5, 125, 1)
			local pokemon5 = forms.pictureBox(formWindow, 505, 5, 125, 1)
			local pokemon6 = forms.pictureBox(formWindow, 630, 5, 125, 1)
		
			box.party[1] = pokemon1
			box.party[2] = pokemon2
			box.party[3] = pokemon3
			box.party[4] = pokemon4
			box.party[5] = pokemon5
			box.party[6] = pokemon6			
		end
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
			end
			
			if pokemonData ~= nil then
				-- Track this ID so we don't have to preform as many checks later
				box.pokemonID[pos] = pokemonID
	
				local lowerPokemonName = pokemonData.name:lower()
				local imagepath = Paths.FOLDERS.ANIMATIONS_FOLDER .. "\\" .. lowerPokemonName .. ".gif"
				local fileExists = fileExists(imagepath)
				if fileExists then
					forms.setproperty(pbox, "ImageLocation", imagepath)
					forms.setproperty(pbox, "Visible", true)
					if orientation == "H" or orientation == "S" then
						forms.setproperty(pbox, "Height", 1)
						relocate[pos] = true
					end
					
					forms.setproperty(pbox, "AutoSize", 2) -- allows for relocate method to 'load' images bottom first
					forms.refresh(pbox)
					partyChanged = true
					box.pokemonNames[pos] = lowerPokemonName
				end
			end
		end
	end
	
	function self.animateParty(playerParty)
		for p=1, maxAni, 1 do
			setAnimatedPokemon(playerParty[p], p)
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
	
		-- Only relocate exactly once, 1=starting height of the box
		if imageY ~= nil and imageHeight ~= nil then
			local bottomUpY = box.POPUP_HEIGHT - imageHeight - 40
					-- If picture box hasn't been relocated yet, move it such that it's drawn from the bottom up
			if bottomUpY ~= imageY then
				forms.setproperty(pbox, "Top", bottomUpY)
				relocate[pos] = (imageHeight == 1) -- Keep updating until the height is known
			end
		end
	end
	
	return self
end

return AnimationPopout
