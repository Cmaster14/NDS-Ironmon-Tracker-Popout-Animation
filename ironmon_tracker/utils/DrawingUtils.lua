DrawingUtils = {}

local colorScheme
local colorSettings
local appearanceSettings

local UIClassFolder = Paths.FOLDERS.UI_BASE_CLASSES .. "/"
local Frame = dofile(UIClassFolder .. "Frame.lua")
local Box = dofile(UIClassFolder .. "Box.lua")
local Component = dofile(UIClassFolder .. "Component.lua")
local TextLabel = dofile(UIClassFolder .. "TextLabel.lua")
local TextField = dofile(UIClassFolder .. "TextField.lua")
local TextStyle = dofile(UIClassFolder .. "TextStyle.lua")
local Layout = dofile(UIClassFolder .. "Layout.lua")

function DrawingUtils.setColorScheme(newScheme)
    colorScheme = newScheme
    colorScheme["Black"] = 0xFF000000
end

function DrawingUtils.setColorSettings(newColorSettings)
    colorSettings = newColorSettings
end

function DrawingUtils.setAppearanceSettings(newAppearanceSettings)
    appearanceSettings = newAppearanceSettings
end

function DrawingUtils.clearGUI()
    gui.drawRectangle(
        Graphics.SIZES.SCREEN_WIDTH,
        0,
        Graphics.SIZES.SCREEN_WIDTH + Graphics.SIZES.MAIN_SCREEN_WIDTH,
        Graphics.SIZES.MAIN_SCREEN_HEIGHT,
        0x00000000,
        0x00000000
    )
end

function DrawingUtils.textToWrappedArray(text, maxWidth)
    local words = MiscUtils.split(text, " ")
    local newWords = {}
    local currentLineLength = 0
    local currentLine = ""
    for _, word in pairs(words) do
        --add 3 for space between words
        local wordPixelLength = DrawingUtils.calculateWordPixelLength(word)
        local nextLength = currentLineLength + wordPixelLength + 3
        if (nextLength - 3) > maxWidth then
            table.insert(newWords, currentLine)
            currentLine = word .. " "
            currentLineLength = wordPixelLength + 3
        else
            currentLine = currentLine .. word .. " "
            currentLineLength = nextLength
        end
    end
    table.insert(newWords, currentLine)
    return newWords
end

function DrawingUtils.calculateWordPixelLength(text)
    local totalLength = 0
    for i = 1, #text do
        local char = text:sub(i, i)
        if Graphics.LETTER_PIXEL_LENGTHS[char] then
            totalLength = totalLength + Graphics.LETTER_PIXEL_LENGTHS[char]
        else
            totalLength = totalLength + 1
        end
    end
    totalLength = totalLength + #text --space in between each character
    return totalLength
end

function DrawingUtils.drawBox(x, y, width, height, fill, background, shadowed, shadowColor)
    if shadowed and colorSettings["Draw shadows"] and not colorSettings["Transparent backgrounds"] then
        gui.drawRectangle(x, y, width + 2, height + 2, 0x00000000, shadowColor)
    end
    gui.drawRectangle(x, y, width, height, fill, background)
end

function DrawingUtils.drawBarGraph(position, size, dataSet, headingText, borderColorKey, textBarColorKey, graphPadding, maxValue)
    local borderColor = DrawingUtils.convertColorKeyToColor(borderColorKey)
    local textBarColor = DrawingUtils.convertColorKeyToColor(textBarColorKey)
    local x,y = position.x, position.y 
    local width, height = size.width, size.height
    local topPoint = {
        ["x"] = x + graphPadding,
        ["y"] = y + graphPadding
    }
    local bottomLeftPoint = {
        ["x"] = x + graphPadding,
        ["y"] = y + height - graphPadding
    }
    local bottomRightPoint = {
        ["x"] = x + width - graphPadding,
        ["y"] = y + height - graphPadding
    }
    gui.drawLine(topPoint.x, topPoint.y, bottomLeftPoint.x, bottomLeftPoint.y,borderColor)
    gui.drawLine(bottomLeftPoint.x, bottomLeftPoint.y, bottomRightPoint.x, bottomRightPoint.y, borderColor)
    local textLength = DrawingUtils.calculateWordPixelLength(headingText)
    local textX = x + graphPadding + ((width - 2 * graphPadding - textLength) / 2)
    local style = TextStyle(Graphics.FONT.DEFAULT_FONT_SIZE, Graphics.FONT.DEFAULT_FONT_FAMILY, "Top box text color", "Top box background color")
    DrawingUtils.drawText(textX,y-3,headingText,style,DrawingUtils.calcShadowColor("Top box background color"))
    local totalBars = 0
    for _, _ in pairs(dataSet) do
        totalBars = totalBars + 1
    end
    local barWidth = (width- 2 * graphPadding) / (totalBars + (totalBars / 2) + (1/2))
    local spacing = barWidth / 2
    local currentIndex = 0
    --basically leave some room
    local topValue = maxValue * 1.25 
    local verticalDistance = math.abs(topPoint.y - bottomRightPoint.y)
    for _, dataEntry in pairs(dataSet) do
        local name, value = dataEntry[1], dataEntry[2]
        local barX = math.floor(spacing + topPoint.x + ( (spacing+barWidth) * currentIndex) )
        local verticalDistanceFraction = verticalDistance * (value/topValue)
        local barY = bottomRightPoint.y - verticalDistanceFraction
        gui.drawRectangle(barX, barY, barWidth, verticalDistanceFraction, textBarColor, textBarColor)
        value = tostring(value)
        local nameLength = DrawingUtils.calculateWordPixelLength(name)
        local valueLength = DrawingUtils.calculateWordPixelLength(value)
        local nameX = (barX + (barWidth - nameLength)/2) - 1
        local valueX = (barX + (barWidth - valueLength)/2)  - 1
        DrawingUtils.drawText(valueX,barY-12,value,style,DrawingUtils.calcShadowColor("Top box background color"))
        DrawingUtils.drawText(nameX,bottomRightPoint.y + 2,name,style,DrawingUtils.calcShadowColor("Top box background color"))
        currentIndex = currentIndex + 1
    end
end

function DrawingUtils.drawText(x, y, text, textStyle, shadowColor, justifiable, justifiedSpacing)
    local drawShadow = colorSettings["Draw shadows"] and not colorSettings["Transparent backgrounds"]
    local color = DrawingUtils.convertColorKeyToColor(textStyle.getTextColorKey())
    local spacing = 0
    if appearanceSettings.RIGHT_JUSTIFIED_NUMBERS and justifiable then
        if text == "?" then
            spacing = 10
        end
        if text == "---" then
            if justifiedSpacing == 3 then
                spacing = 8
            elseif justifiedSpacing == 2 then
                spacing = 3
            end
        else
            local number = tonumber(text)
            if number ~= nil then
                spacing = (justifiedSpacing - string.len(tostring(number))) * 5
            end
        end
    end
    if drawShadow then
        gui.drawText(x + spacing + 1, y + 1, text, shadowColor, nil, textStyle.getFontSize(), textStyle.getFontFamily())
    end
    local bolded = textStyle.isBolded()
    gui.drawText(x + spacing, y, text, color, nil, textStyle.getFontSize(), textStyle.getFontFamily(), bolded)
end


function DrawingUtils.readPokemonIDIntoImageLabel(currentIconSet, pokemonID, imageLabel, imageOffset)
    local folderPath = Paths.FOLDERS.POKEMON_ICONS_FOLDER.."/"..currentIconSet.FOLDER_NAME.."/"
    local extension = currentIconSet.FILE_EXTENSION
    imageLabel.setOffset(imageOffset)
    local pokemonData = PokemonData.POKEMON[pokemonID+1]
    if not pokemonData.baseFormData then
        imageLabel.setPath(
            folderPath .. pokemonID .. extension
        )
    else
        local baseFormData = pokemonData.baseFormData
        if PokemonData.ALTERNATE_FORMS[baseFormData.baseFormName] then
            local index = baseFormData.alternateFormIndex
            local path = folderPath.."alternateForms/" .. baseFormData.baseFormName .. "/" .. index .. extension
            imageLabel.setPath(path)
        end
    end
end

function DrawingUtils.convertColorKeyToColor(colorKey, transparentOverride)
    local transparentKeys = {
        ["Main background color"] = true,
        ["Top box background color"] = true,
        ["Bottom box background color"] = true
    }
    if colorSettings["Transparent backgrounds"] and transparentKeys[colorKey] and not transparentOverride then
        return 0x00000000
    end
    local color = colorScheme[colorKey]
    if color == nil then
        color = Graphics.TYPE_COLORS[colorKey]
    end
    return color
end

function DrawingUtils.calcShadowColor(colorKey)
    local color = colorScheme[colorKey]
    local color_hexval = (color - 0xFF000000)

    local r = bit.rshift(color_hexval, 16)
    local g = bit.rshift(bit.band(color_hexval, 0x00FF00), 8)
    local b = bit.band(color_hexval, 0x0000FF)

    r = math.max(r * .92, 0)
    g = math.max(g * .92, 0)
    b = math.max(b * .92, 0)

    color_hexval = bit.lshift(r, 16) + bit.lshift(g, 8) + b
    return (0xFF000000 + color_hexval)
end

function DrawingUtils.drawTriangleRight(x, y, size, color)
    gui.drawRectangle(x, y, size, size, color)
    gui.drawPolygon({{4 + x, 4 + y}, {4 + x, y + size - 4}, {x + size - 4, y + size / 2}}, color, color)
end

function DrawingUtils.drawTriangleLeft(x, y, size, color)
    gui.drawRectangle(x, y, size, size, color)
    gui.drawPolygon({{x + size - 4, 4 + y}, {x + size - 4, y + size - 4}, {4 + x, y + size / 2}}, color, color)
end

local function drawChevronUp(position, colorKey)
    local color = DrawingUtils.convertColorKeyToColor(colorKey)
    local center = {x = position.x + 2, y = position.y}
    gui.drawLine(position.x, position.y + 2, center.x, center.y, color)
    gui.drawLine(center.x, center.y, position.x + 4, position.y + 2, color)
end

local function drawChevronDown(position, colorKey)
    local color = DrawingUtils.convertColorKeyToColor(colorKey)
    local center = {x = position.x + 2, y = position.y + 2}
    gui.drawLine(position.x, position.y, center.x, center.y, color)
    gui.drawLine(center.x, center.y, position.x + 4, position.y, color)
end

function DrawingUtils.drawChevron(direction, position, colorKey)
    if colorKey ~= nil then
        if direction == "up" then
            drawChevronUp(position, colorKey)
        else
            drawChevronDown(position, colorKey)
        end
    end
end

function DrawingUtils.drawStatStageChevrons(position, statStage)
    local colorStates = {"Negative text color", "Top box text color", nil, "Top box text color", "Positive text color"}
    local chevrons = {
        bottomChevron = {start = 2, position = {x = position.x, y = position.y}},
        middleChevron = {start = 1, position = {x = position.x, y = position.y - 2}},
        topChevron = {start = 0, position = {x = position.x, y = position.y - 4}}
    }
    local direction = "none"
    if statStage < 6 then
        direction = "down"
    else
        direction = "up"
    end
    for _, chevron in pairs(chevrons) do
        local colorState = math.floor((statStage + chevron.start) / 3) + 1
        local position = chevron.position
        if direction == "up" then
            position.y = position.y - 1
        end
        DrawingUtils.drawChevron(direction, position, colorStates[colorState])
    end
end

function DrawingUtils.drawMoveEffectiveness(position, effectiveness)
    if effectiveness ~= 1.0 then
        local x, y = position.x, position.y
        if effectiveness == 2 then
            drawChevronUp({x = x, y = y + 2}, "Positive text color")
        elseif effectiveness == 4 then
            drawChevronUp({x = x, y = y + 2}, "Positive text color")
            drawChevronUp({x = x, y = y}, "Positive text color")
        elseif effectiveness == 0.5 then
            drawChevronDown({x = x, y = y, 4}, "Negative text color")
        elseif effectiveness == 0.25 then
            drawChevronDown({x = x, y = y, 4}, "Negative text color")
            drawChevronDown({x = x, y = y + 2}, "Negative text color")
        elseif effectiveness == 0 then
            DrawingUtils.drawText(
                x,
                y,
                "X",
                TextStyle(7, Graphics.FONT.DEFAULT_FONT_FAMILY, "Negative text color", "Bottom box background color"),
                DrawingUtils.convertColorKeyToColor("Bottom box background color")
            )
        end
    end
end

function DrawingUtils.drawNaturePlusMinus(position, affect)
    local color = "Positive text color"
    local text = "+"
    if affect == "minus" then
        text = "---"
        color = "Negative text color"
    end
    DrawingUtils.drawText(
                position.x,
                position.y,
                text,
                TextStyle(5, Graphics.FONT.DEFAULT_FONT_FAMILY, color, "Top box background color"),
                DrawingUtils.convertColorKeyToColor("Top box background color")
            )
end

function DrawingUtils.getNatureColor(stat, nature)
    local neutral = "Top box text color"
    local increase = "Positive text color"
    local decrease = "Negative text color"

    local color = neutral
    if nature % 6 == 0 then
        color = neutral
    elseif stat == "ATK" then
        if nature < 5 then
            color = increase
        elseif nature % 5 == 0 then
            color = decrease
        end
    elseif stat == "DEF" then
        if nature > 4 and nature < 10 then
            color = increase
        elseif nature % 5 == 1 then
            color = decrease
        end
    elseif stat == "SPE" then
        if nature > 9 and nature < 15 then
            color = increase
        elseif nature % 5 == 2 then
            color = decrease
        end
    elseif stat == "SPA" then
        if nature > 14 and nature < 20 then
            color = increase
        elseif nature % 5 == 3 then
            color = decrease
        end
    elseif stat == "SPD" then
        if nature > 19 then
            color = increase
        elseif nature % 5 == 4 then
            color = decrease
        end
    end
    return color
end
