-- Poggimart POS System v2.0
-- A continuously running display for ComputerCraft (CC: Tweaked)
-- To exit: Hold Ctrl+T

--[[
  To use:
  1. Save this code as a file on a ComputerCraft computer.
  2. For sound, attach a Speaker peripheral to any side of the computer.
  3. Run the program from the terminal.
  4. An advanced computer and monitor are required.
]]

-- Global settings
local termWidth, termHeight = term.getSize()
local speaker = peripheral.find("speaker")

-- Poggimart branding & colors
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

-- Product list
local items = {
  "Pogi-Chiki", "Spicy Chicken", "Onigiri (Salmon)", "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)", "Sando (Pork Katsu)", "Melon Pan", "Anpan (Red Bean)",
  "Oden", "Nikuman (Pork Bun)", "Iced Coffee", "Iced Latte", "Green Tea",
  "Mugi-cha (Barley Tea)", "Pocari Sweat", "C.C. Lemon", "PogiMart Socks",
  "Pogi-Socks (Green)", "Pogi-Socks (Blue)"
}
local displayedItem = ""

-- Ticker settings
local tickerText = "   *** Welcome to Poggimart! *** Try our famous Pogi-Chiki!   New socks in stock now!   Don't forget to grab an Onigiri for the road!   Poggimart -- Your happy place.   "
local tickerIndex = 1

-- Function to play a sound if a speaker is available
local function playSound()
  if speaker then
    speaker.playNote("f#", 0.5, 120)
  end
end

-- Function to clear the screen
local function clearScreen()
  term.setBackgroundColor(backgroundColor)
  term.clear()
end

-- Function to draw the header and logo
local function drawHeader()
  -- Green stripe
  term.setBackgroundColor(poggimartGreen)
  for y = 1, 3 do
    term.setCursorPos(1, y)
    term.write(string.rep(" ", termWidth))
  end
  -- Blue stripe
  term.setBackgroundColor(poggimartBlue)
  for y = 4, 5 do
    term.setCursorPos(1, y)
    term.write(string.rep(" ", termWidth))
  end
  -- Logo Text
  term.setCursorPos(3, 2)
  term.setBackgroundColor(poggimartGreen)
  term.setTextColor(colors.white)
  term.write("Poggimart")
end

-- Function to draw the main static layout
local function drawLayout()
  drawHeader()
  -- Header for the item display
  term.setBackgroundColor(headerColor)
  term.setCursorPos(1, 7)
  term.write(string.rep(" ", termWidth))
  term.setCursorPos(3, 7)
  term.setTextColor(textColor)
  term.write("Scanned Item:")
  -- Item display area
  term.setBackgroundColor(colors.lightGray)
  for i = 1, 3 do
    term.setCursorPos(2, 8 + i)
    term.write(string.rep(" ", termWidth - 3))
  end
  -- Button area background
  term.setBackgroundColor(colors.lightGray)
  term.setCursorPos(1, termHeight - 4)
  term.write(string.rep(" ", termWidth))
  -- "Scan Random Item" button
  local scanBtnWidth = 20
  local scanBtnX = 4
  term.setBackgroundColor(buttonColor)
  term.setCursorPos(scanBtnX, termHeight - 2)
  term.write(string.rep(" ", scanBtnWidth))
  term.setCursorPos(scanBtnX + 2, termHeight - 2)
  term.setTextColor(buttonTextColor)
  term.write("Scan Random Item")
  -- "Clear" button
  local clearBtnWidth = 10
  local clearBtnX = scanBtnX + scanBtnWidth + 2
  term.setBackgroundColor(colors.orange)
  term.setCursorPos(clearBtnX, termHeight - 2)
  term.write(string.rep(" ", clearBtnWidth))
  term.setCursorPos(clearBtnX + 2, termHeight - 2)
  term.setTextColor(buttonTextColor)
  term.write("Clear")
end

-- Function to display a scanned item
local function displayItem(item)
  displayedItem = item
  term.setBackgroundColor(colors.lightGray)
  term.setCursorPos(2, 10)
  term.write(string.rep(" ", termWidth - 3)) -- Clear previous item
  term.setCursorPos(4, 10)
  term.setTextColor(textColor)
  term.write(displayedItem)
end

-- Function to update the clock
local function updateClock()
  local time = textutils.formatTime(os.time(), false)
  term.setBackgroundColor(poggimartGreen)
  term.setTextColor(colors.white)
  term.setCursorPos(termWidth - 9, 2)
  term.write(" " .. time .. " ")
end

-- Function to update the scrolling ticker
local function updateTicker()
  term.setBackgroundColor(poggimartBlue)
  term.setTextColor(colors.white)
  term.setCursorPos(1, termHeight)
  -- Create the visible portion of the ticker string
  local displayStr = tickerText:sub(tickerIndex, tickerIndex + termWidth - 1)
  -- If the substring is too short (end of the main string), wrap around
  if #displayStr < termWidth then
    displayStr = displayStr .. tickerText:sub(1, termWidth - #displayStr)
  end
  term.write(displayStr)
  -- Move the index for the next frame
  tickerIndex = tickerIndex + 1
  if tickerIndex > #tickerText then
    tickerIndex = 1
  end
end

-- Main program
local function main()
  clearScreen()
  drawLayout()
  displayItem("Welcome to Poggimart!")
  -- Start timers for clock and ticker
  os.startTimer(1) -- Clock timer
  os.startTimer(0.25) -- Ticker timer
  
  while true do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "mouse_click" then
      local button, x, y = p1, p2, p3
      -- Check for "Scan Random Item" button click
      if y == termHeight - 2 and x >= 4 and x < 4 + 20 then
        local randomIndex = math.random(1, #items)
        displayItem(items[randomIndex])
        playSound()
      -- Check for "Clear" button click
      elseif y == termHeight - 2 and x >= 26 and x < 26 + 10 then
        displayItem("")
        playSound()
      end
    elseif event == "timer" then
      local timerId = p1
      if timerId == 1 then -- Clock timer
        updateClock()
        os.startTimer(1) -- Reset the timer
      else -- Ticker timer (assumes any other ID is the ticker)
        updateTicker()
        os.startTimer(0.25) -- Reset the timer
      end
    end
  end
end

-- Run the program
main()
