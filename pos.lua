-- Poggimart POS System v2.2
-- Now with dual display and working sounds!
-- To exit: Hold Ctrl+T

--[[
  Updates:
  - Dual output: GUI shows on both terminal and attached monitor
  - Fixed speaker issue with valid instruments
  - Added FamilyMart-style jingle
  - Monitor displays scan results clearly if available

  To use:
  1. Save this code on a ComputerCraft computer.
  2. Optionally, place a monitor next to the computer. The script will use it.
  3. Attach a speaker peripheral to hear sound effects and the jingle.
  4. Run the program from the terminal.
]]

-- Detect peripherals
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

-- Set up displays
local displays = { term }
if monitor then table.insert(displays, monitor) end

-- Settings
local termWidth, termHeight = term.getSize()
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

-- Updated product list
local items = {
  "Pogi-Chiki", "Spicy Chicken", "Onigiri (Salmon)", "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)", "Sando (Pork Katsu)", "Melon Pan", "Anpan (Red Bean)",
  "Oden", "Nikuman (Pork Bun)", "Iced Coffee", "Iced Latte", "Green Tea",
  "Mugi-cha (Barley Tea)", "Pocari Sweat", "C.C. Lemon", "PogiMart Socks",
  "Pogi-Socks (Green)", "Pogi-Socks (Blue)"
}
local displayedItem = ""

-- Ticker text
local tickerText = "   *** Welcome to Poggimart! *** Try our famous Pogi-Chiki!   New socks in stock now!   Don't forget to grab an Onigiri for the road!   Poggimart -- Your happy place.   "
local tickerIndex = 1

-- Helper to draw on all displays
local function drawOnAll(func)
  for _, d in ipairs(displays) do func(d) end
end

-- Function to play a sound
local function playSound()
  if speaker then
    speaker.playNote("bit", 1.0, 12) -- F# with valid instrument and pitch
  end
end

-- Function to play the FamilyMart jingle
local function playJingle()
  if not speaker then return end
  local notes = {
    {"bit", 12}, {"bit", 16}, {"bit", 14}, {"bit", 21},
    {"bit", 19}, {"bit", 16}, {"bit", 24}, {"bit", 23}
  }
  for _, n in ipairs(notes) do
    speaker.playNote(n[1], 1.0, n[2])
    sleep(0.15)
  end
end

-- Clear screen
local function clearScreen()
  drawOnAll(function(d)
    d.setBackgroundColor(backgroundColor)
    d.clear()
  end)
end

-- Draw header
local function drawHeader()
  drawOnAll(function(d)
    d.setBackgroundColor(poggimartGreen)
    for y = 1, 3 do
      d.setCursorPos(1, y)
      d.write(string.rep(" ", termWidth))
    end
    d.setBackgroundColor(poggimartBlue)
    for y = 4, 5 do
      d.setCursorPos(1, y)
      d.write(string.rep(" ", termWidth))
    end
    d.setCursorPos(3, 2)
    d.setBackgroundColor(poggimartGreen)
    d.setTextColor(colors.white)
    d.write("Poggimart")
  end)
end

-- Draw layout
local function drawLayout()
  drawHeader()
  drawOnAll(function(d)
    d.setBackgroundColor(headerColor)
    d.setCursorPos(1, 7)
    d.write(string.rep(" ", termWidth))
    d.setCursorPos(3, 7)
    d.setTextColor(textColor)
    d.write("Scanned Item:")
    d.setBackgroundColor(colors.lightGray)
    for i = 1, 3 do
      d.setCursorPos(2, 8 + i)
      d.write(string.rep(" ", termWidth - 3))
    end
    d.setCursorPos(1, termHeight - 4)
    d.write(string.rep(" ", termWidth))

    -- Buttons
    local scanBtnX, scanBtnWidth = 4, 20
    d.setBackgroundColor(buttonColor)
    d.setCursorPos(scanBtnX, termHeight - 2)
    d.write(string.rep(" ", scanBtnWidth))
    d.setCursorPos(scanBtnX + 2, termHeight - 2)
    d.setTextColor(buttonTextColor)
    d.write("Scan Random Item")

    local clearBtnX, clearBtnWidth = scanBtnX + scanBtnWidth + 2, 10
    d.setBackgroundColor(colors.orange)
    d.setCursorPos(clearBtnX, termHeight - 2)
    d.write(string.rep(" ", clearBtnWidth))
    d.setCursorPos(clearBtnX + 2, termHeight - 2)
    d.setTextColor(buttonTextColor)
    d.write("Clear")
  end)
end

-- Display scanned item
local function displayItem(item)
  displayedItem = item
  drawOnAll(function(d)
    d.setBackgroundColor(colors.lightGray)
    d.setCursorPos(2, 10)
    d.write(string.rep(" ", termWidth - 3))
    d.setCursorPos(4, 10)
    d.setTextColor(textColor)
    d.write(item)
  end)

  -- Monitor-specific large text
  if monitor then
    local w, h = monitor.getSize()
    monitor.clear()
    if w >= 20 and h >= 3 then
      monitor.setCursorPos(2, 2)
      monitor.setTextColor(colors.yellow)
      monitor.setBackgroundColor(colors.black)
      monitor.write("SCAN COMPLETE")
      monitor.setCursorPos(2, 3)
      monitor.write("-> " .. item)
    else
      monitor.setCursorPos(1, 1)
      monitor.write("Monitor too small")
    end
  end
end

-- Update clock
local function updateClock()
  local time = textutils.formatTime(os.time(), false)
  drawOnAll(function(d)
    d.setBackgroundColor(poggimartGreen)
    d.setTextColor(colors.white)
    d.setCursorPos(termWidth - 9, 2)
    d.write(" " .. time .. " ")
  end)
end

-- Update ticker
local function updateTicker()
  local displayStr = tickerText:sub(tickerIndex, tickerIndex + termWidth - 1)
  if #displayStr < termWidth then
    displayStr = displayStr .. tickerText:sub(1, termWidth - #displayStr)
  end
  drawOnAll(function(d)
    d.setCursorPos(1, termHeight)
    d.setBackgroundColor(poggimartBlue)
    d.setTextColor(colors.white)
    d.write(displayStr)
  end)
  tickerIndex = tickerIndex + 1
  if tickerIndex > #tickerText then tickerIndex = 1 end
end

-- Main loop
local function main()
  clearScreen()
  drawLayout()
  displayItem("Welcome to Poggimart!")
  os.startTimer(1)
  os.startTimer(0.25)

  while true do
    local event, p1, p2, p3 = os.pullEvent()
    if event == "mouse_click" or event == "monitor_touch" then
      local x, y = p2, p3
      if y == termHeight - 2 and x >= 4 and x < 24 then
        local item = items[math.random(1, #items)]
        displayItem(item)
        playSound()
      elseif y == termHeight - 2 and x >= 26 and x < 36 then
        displayItem("")
        playSound()
      end
    elseif event == "timer" then
      if p1 == 1 then
        updateClock()
        os.startTimer(1)
      else
        updateTicker()
        os.startTimer(0.25)
      end
    elseif event == "key" and p1 == keys.j then
      playJingle()
    end
  end
end

main()
