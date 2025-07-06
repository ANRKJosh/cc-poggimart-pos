-- Poggimart POS System v2.3
-- Interactive terminal GUI with monitor mirroring + jingle support
-- Ctrl+T to exit

-- Find peripherals
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local screen = term -- terminal remains the primary UI

-- Check monitor size
local minWidth, minHeight = 10, 5
local useMonitor = false
if monitor then
  local w, h = monitor.getSize()
  if w >= minWidth and h >= minHeight then
    useMonitor = true
    monitor.setTextScale(1)
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
  end
end

-- Constants
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

-- Item list
local items = {
  "Pogi-Chiki", "Spicy Chicken", "Onigiri (Salmon)", "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)", "Sando (Pork Katsu)", "Melon Pan", "Anpan (Red Bean)",
  "Oden", "Nikuman (Pork Bun)", "Iced Coffee", "Iced Latte", "Green Tea",
  "Mugi-cha (Barley Tea)", "Pocari Sweat", "C.C. Lemon", "PogiMart Socks",
  "Pogi-Socks (Green)", "Pogi-Socks (Blue)"
}

-- Display state
local displayedItem = ""
local tickerText = "   *** Welcome to Poggimart! *** Try our famous Pogi-Chiki!   New socks in stock now!   Don't forget to grab an Onigiri for the road!   Poggimart -- Your happy place.   "
local tickerIndex = 1

-- Get terminal size
local termWidth, termHeight = term.getSize()

-- Jingle notes (rough FamilyMart)
local jingle = {
  {instrument = "bell", pitch = 12}, -- C
  {instrument = "bell", pitch = 16}, -- E
  {instrument = "bell", pitch = 19}, -- G
  {instrument = "bell", pitch = 24}, -- C
  {instrument = "bell", pitch = 21}, -- A
  {instrument = "bell", pitch = 16}, -- E
  {instrument = "bell", pitch = 24}, -- C (hold)
}

-- Play jingle
local function playJingle()
  if not speaker then return end
  for i, note in ipairs(jingle) do
    speaker.playNote(note.instrument, 1.0, note.pitch)
    sleep(0.2)
  end
end

-- Play simple beep on scan
local function playBeep()
  if speaker then
    speaker.playNote("bit", 1.0, 16)
  end
end

-- Monitor display
local function updateMonitor(item)
  if useMonitor then
    monitor.clear()
    monitor.setCursorPos(2, 2)
    monitor.setTextColor(colors.white)
    monitor.write("Poggimart Scan:")
    monitor.setCursorPos(2, 4)
    monitor.setTextColor(colors.green)
    monitor.write("> " .. item)
  end
end

-- Clear terminal UI
local function clearScreen()
  screen.setBackgroundColor(backgroundColor)
  screen.clear()
end

-- Header + clock
local function drawHeader()
  -- Green bar
  screen.setBackgroundColor(poggimartGreen)
  screen.setCursorPos(1, 1)
  screen.write(string.rep(" ", termWidth))
  -- Blue bar
  screen.setBackgroundColor(poggimartBlue)
  screen.setCursorPos(1, 2)
  screen.write(string.rep(" ", termWidth))
  -- Logo
  screen.setCursorPos(2, 1)
  screen.setTextColor(colors.white)
  screen.write("Poggimart")

  -- Time
  local time = textutils.formatTime(os.time(), false)
  screen.setCursorPos(termWidth - 8, 1)
  screen.write(" " .. time .. " ")
end

-- Layout UI
local function drawLayout()
  drawHeader()

  -- "Scanned Item" label
  screen.setBackgroundColor(headerColor)
  screen.setCursorPos(1, 4)
  screen.write(string.rep(" ", termWidth))
  screen.setCursorPos(3, 4)
  screen.setTextColor(textColor)
  screen.write("Scanned Item:")

  -- Display box
  screen.setBackgroundColor(colors.lightGray)
  for i = 1, 3 do
    screen.setCursorPos(2, 4 + i)
    screen.write(string.rep(" ", termWidth - 3))
  end

  -- Buttons
  local y = termHeight - 3
  screen.setCursorPos(2, y)
  screen.setBackgroundColor(buttonColor)
  screen.setTextColor(buttonTextColor)
  screen.write("  Scan Random Item  ")

  screen.setCursorPos(25, y)
  screen.setBackgroundColor(colors.orange)
  screen.write("   Clear   ")

  screen.setCursorPos(40, y)
  screen.setBackgroundColor(colors.cyan)
  screen.write(" Play Jingle ")
end

-- Show scanned item
local function displayItem(item)
  displayedItem = item
  screen.setBackgroundColor(colors.lightGray)
  screen.setCursorPos(4, 6)
  screen.setTextColor(textColor)
  screen.write(string.rep(" ", termWidth - 4))
  screen.setCursorPos(4, 6)
  screen.write(displayedItem)
  updateMonitor(item)
end

-- Ticker
local function updateTicker()
  screen.setBackgroundColor(poggimartBlue)
  screen.setTextColor(colors.white)
  screen.setCursorPos(1, termHeight)
  local displayStr = tickerText:sub(tickerIndex, tickerIndex + termWidth - 1)
  if #displayStr < termWidth then
    displayStr = displayStr .. tickerText:sub(1, termWidth - #displayStr)
  end
  screen.write(displayStr)
  tickerIndex = tickerIndex + 1
  if tickerIndex > #tickerText then
    tickerIndex = 1
  end
end

-- Main loop
local function main()
  clearScreen()
  drawLayout()
  displayItem("Welcome to Poggimart!")

  -- Play jingle at startup
  playJingle()

  -- Timers
  local tickerTimer = os.startTimer(0.25)
  local clockTimer = os.startTimer(1)

  while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "mouse_click" then
      local _, x, y = p1, p2, p3
      if y == termHeight - 3 then
        if x >= 2 and x <= 21 then
          local randItem = items[math.random(#items)]
          displayItem(randItem)
          playBeep()
        elseif x >= 25 and x <= 34 then
          displayItem("")
          playBeep()
        elseif x >= 40 and x <= 52 then
          playJingle()
        end
      end
    elseif event == "timer" then
      if p1 == tickerTimer then
        updateTicker()
        tickerTimer = os.startTimer(0.25)
      elseif p1 == clockTimer then
        drawHeader()
        clockTimer = os.startTimer(1)
      end
    end
  end
end

main()
