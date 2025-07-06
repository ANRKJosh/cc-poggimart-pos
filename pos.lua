-- Poggimart POS System v2.2
-- Now with monitor mirroring and jingle button!
-- To exit: Hold Ctrl+T

-- Peripheral setup
local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local screen = term

if monitor then
  monitor.setTextScale(1)
end

-- Helper function to draw to both terminal and monitor
local function onScreen(fn)
  fn(screen)
  if monitor then fn(monitor) end
end

-- Global settings
local termWidth, termHeight = screen.getSize()
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

local items = {
  "Pogi-Chiki", "Spicy Chicken", "Onigiri (Salmon)", "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)", "Sando (Pork Katsu)", "Melon Pan", "Anpan (Red Bean)",
  "Oden", "Nikuman (Pork Bun)", "Iced Coffee", "Iced Latte", "Green Tea",
  "Mugi-cha (Barley Tea)", "Pocari Sweat", "C.C. Lemon", "PogiMart Socks",
  "Pogi-Socks (Green)", "Pogi-Socks (Blue)"
}
local displayedItem = ""
local tickerText = "   *** Welcome to Poggimart! *** Try our legendary Pogi-Chiki!   Fresh socks available now!   Hydrate with Pocari Sweat!   "
local tickerIndex = 1

-- Fix timers: we store the IDs
local clockTimer = nil
local tickerTimer = nil

-- Play a jingle (simplified FamilyMart melody)
local function playJingle()
  if not speaker then return end
  local notes = {
    { note = 0,  delay = 0.1 },
    { note = 4,  delay = 0.1 },
    { note = 7,  delay = 0.1 },
    { note = 12, delay = 0.15 },
    { note = 7,  delay = 0.1 },
    { note = 9,  delay = 0.2 },
    { note = 14, delay = 0.3 }
  }
  for _, tone in ipairs(notes) do
    speaker.playNote("bell", 1.0, tone.note)
    sleep(tone.delay)
  end
end

-- Play short beep for button clicks
local function playSound()
  if speaker then
    speaker.playNote("bell", 1.0, 12)
  end
end

-- UI Drawing Functions
local function clearScreen()
  onScreen(function(scr)
    scr.setBackgroundColor(backgroundColor)
    scr.clear()
  end)
end

local function drawHeader()
  onScreen(function(scr)
    scr.setBackgroundColor(poggimartGreen)
    for y = 1, 3 do
      scr.setCursorPos(1, y)
      scr.write(string.rep(" ", termWidth))
    end
    scr.setBackgroundColor(poggimartBlue)
    for y = 4, 5 do
      scr.setCursorPos(1, y)
      scr.write(string.rep(" ", termWidth))
    end
    scr.setCursorPos(3, 2)
    scr.setBackgroundColor(poggimartGreen)
    scr.setTextColor(colors.white)
    scr.write("Poggimart")
  end)
end

local function drawLayout()
  drawHeader()
  onScreen(function(scr)
    scr.setBackgroundColor(headerColor)
    scr.setCursorPos(1, 7)
    scr.write(string.rep(" ", termWidth))
    scr.setCursorPos(3, 7)
    scr.setTextColor(textColor)
    scr.write("Scanned Item:")

    -- Display area
    scr.setBackgroundColor(colors.lightGray)
    for i = 1, 3 do
      scr.setCursorPos(2, 8 + i)
      scr.write(string.rep(" ", termWidth - 3))
    end

    -- Button bar
    scr.setCursorPos(1, termHeight - 4)
    scr.write(string.rep(" ", termWidth))

    -- Buttons
    local function drawButton(x, label, width, color)
      scr.setBackgroundColor(color)
      scr.setTextColor(buttonTextColor)
      scr.setCursorPos(x, termHeight - 2)
      scr.write(string.rep(" ", width))
      scr.setCursorPos(x + 2, termHeight - 2)
      scr.write(label)
    end

    drawButton(4, "Scan Random Item", 20, buttonColor)
    drawButton(26, "Clear", 10, colors.orange)
    drawButton(38, "Play Jingle", 13, colors.cyan)
  end)
end

local function displayItem(item)
  displayedItem = item
  onScreen(function(scr)
    scr.setBackgroundColor(colors.lightGray)
    scr.setTextColor(textColor)
    scr.setCursorPos(2, 10)
    scr.write(string.rep(" ", termWidth - 3))
    scr.setCursorPos(4, 10)
    scr.write(item or "")
  end)
  -- Show on monitor in large text
  if monitor then
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.lime)
    monitor.clear()
    monitor.setCursorPos(2, 2)
    monitor.write(">>>")
    monitor.setCursorPos(6, 4)
    monitor.write(item or "")
    monitor.setCursorPos(2, 6)
    monitor.write("<<<")
  end
end

local function updateClock()
  local time = textutils.formatTime(os.time(), false)
  onScreen(function(scr)
    scr.setBackgroundColor(poggimartGreen)
    scr.setTextColor(colors.white)
    scr.setCursorPos(termWidth - 9, 2)
    scr.write(" " .. time .. " ")
  end)
end

local function updateTicker()
  onScreen(function(scr)
    scr.setBackgroundColor(poggimartBlue)
    scr.setTextColor(colors.white)
    scr.setCursorPos(1, termHeight)
    local displayStr = tickerText:sub(tickerIndex, tickerIndex + termWidth - 1)
    if #displayStr < termWidth then
      displayStr = displayStr .. tickerText:sub(1, termWidth - #displayStr)
    end
    scr.write(displayStr)
  end)
  tickerIndex = tickerIndex + 1
  if tickerIndex > #tickerText then
    tickerIndex = 1
  end
end

-- Main logic
local function main()
  clearScreen()
  drawLayout()
  displayItem("Welcome to Poggimart!")
  updateClock()
  updateTicker()

  clockTimer = os.startTimer(1)
  tickerTimer = os.startTimer(0.25)

  while true do
    local event, p1, p2, p3 = os.pullEvent()

    if event == "mouse_click" or event == "monitor_touch" then
      local x, y = p2, p3
      -- Scan button
      if y == termHeight - 2 and x >= 4 and x < 4 + 20 then
        local item = items[math.random(#items)]
        displayItem(item)
        playSound()
      elseif y == termHeight - 2 and x >= 26 and x < 36 then
        displayItem("")
        playSound()
      elseif y == termHeight - 2 and x >= 38 and x < 38 + 13 then
        playJingle()
      end
    elseif event == "timer" then
      if p1 == clockTimer then
        updateClock()
        clockTimer = os.startTimer(1)
      elseif p1 == tickerTimer then
        updateTicker()
        tickerTimer = os.startTimer(0.25)
      end
    end
  end
end

main()
