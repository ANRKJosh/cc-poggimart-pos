-- Poggimart POS System v2.3
-- Now with monitor fix, jingle button, and clock!
-- To exit: Hold Ctrl+T

-- === SETUP ===
local monitor = peripheral.find("monitor")
local screen = term
if monitor then
  monitor.setTextScale(1)
  term.redirect(monitor)
end

local speaker = peripheral.find("speaker")
local termWidth, termHeight = term.getSize()

-- === CONSTANTS ===
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

-- === ITEMS ===
local items = {
  "Pogi-Chiki", "Spicy Chicken", "Onigiri (Salmon)", "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)", "Sando (Pork Katsu)", "Melon Pan", "Anpan (Red Bean)",
  "Oden", "Nikuman (Pork Bun)", "Iced Coffee", "Iced Latte", "Green Tea",
  "Mugi-cha (Barley Tea)", "Pocari Sweat", "C.C. Lemon", "PogiMart Socks",
  "Pogi-Socks (Green)", "Pogi-Socks (Blue)"
}
local displayedItem = ""

-- === TICKER ===
local tickerText = "   *** Welcome to Poggimart! *** Try our famous Pogi-Chiki!   New socks in stock now!   Grab an Onigiri for the road!   Poggimart -- Your happy place.   "
local tickerIndex = 1

-- === SOUND ===
local function playSoundNote(inst, pitch)
  if speaker then
    speaker.playNote(inst, 1.0, pitch)
  end
end

-- FamilyMart-style jingle
local jingleNotes = {
  { "bit", 18 }, { "bit", 20 }, { "bit", 21 }, nil,
  { "bit", 18 }, { "bit", 20 }, { "bit", 21 }, nil,
  { "bit", 23 }, { "bit", 21 }, { "bit", 20 }, { "bit", 18 },
  { "bit", 20 }, nil, { "bit", 20 }, { "bit", 18 }
}

local function playJingle()
  for _, note in ipairs(jingleNotes) do
    if note then
      playSoundNote(note[1], note[2])
    end
    sleep(0.15)
  end
end

-- === DISPLAY FUNCTIONS ===
local function clearScreen()
  term.setBackgroundColor(backgroundColor)
  term.clear()
end

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
  -- Logo text
  term.setCursorPos(3, 2)
  term.setTextColor(colors.white)
  term.setBackgroundColor(poggimartGreen)
  term.write("Poggimart")
end

local function drawLayout()
  drawHeader()

  -- Clock (top-right)
  updateClock()

  -- Scanned Item Label
  term.setBackgroundColor(headerColor)
  term.setTextColor(textColor)
  term.setCursorPos(1, 7)
  term.write(string.rep(" ", termWidth))
  term.setCursorPos(3, 7)
  term.write("Scanned Item:")

  -- Item display area
  term.setBackgroundColor(colors.lightGray)
  for i = 1, 3 do
    term.setCursorPos(2, 8 + i)
    term.write(string.rep(" ", termWidth - 3))
  end

  -- Button background
  term.setBackgroundColor(colors.lightGray)
  term.setCursorPos(1, termHeight - 4)
  term.write(string.rep(" ", termWidth))

  -- Scan Button
  local scanX = 4
  term.setCursorPos(scanX, termHeight - 2)
  term.setBackgroundColor(buttonColor)
  term.write(string.rep(" ", 20))
  term.setCursorPos(scanX + 2, termHeight - 2)
  term.setTextColor(buttonTextColor)
  term.write("Scan Random Item")

  -- Clear Button
  local clearX = scanX + 22
  term.setCursorPos(clearX, termHeight - 2)
  term.setBackgroundColor(colors.orange)
  term.write(string.rep(" ", 10))
  term.setCursorPos(clearX + 2, termHeight - 2)
  term.write("Clear")

  -- Play Jingle Button
  local jingleX = clearX + 12
  term.setCursorPos(jingleX, termHeight - 2)
  term.setBackgroundColor(colors.green)
  term.write(string.rep(" ", 14))
  term.setCursorPos(jingleX + 2, termHeight - 2)
  term.write("Play Jingle")
end

local function displayItem(item)
  displayedItem = item
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(textColor)
  term.setCursorPos(2, 10)
  term.write(string.rep(" ", termWidth - 3))
  term.setCursorPos(4, 10)
  term.write(displayedItem)
end

function updateClock()
  local time = textutils.formatTime(os.time(), false)
  term.setBackgroundColor(poggimartGreen)
  term.setTextColor(colors.white)
  term.setCursorPos(termWidth - 9, 2)
  term.write(" " .. time .. " ")
end

function updateTicker()
  term.setBackgroundColor(poggimartBlue)
  term.setTextColor(colors.white)
  term.setCursorPos(1, termHeight)
  local displayStr = tickerText:sub(tickerIndex, tickerIndex + termWidth - 1)
  if #displayStr < termWidth then
    displayStr = displayStr .. tickerText:sub(1, termWidth - #displayStr)
  end
  term.write(displayStr)
  tickerIndex = tickerIndex + 1
  if tickerIndex > #tickerText then
    tickerIndex = 1
  end
end

-- === MAIN LOOP ===
local function main()
  clearScreen()
  drawLayout()
  displayItem("Welcome to Poggimart!")
  playJingle()

  local clockTimer = os.startTimer(1)
  local tickerTimer = os.startTimer(0.25)

  while true do
    local e, p1, p2, p3 = os.pullEvent()

    if e == "mouse_click" or e == "monitor_touch" then
      local x, y = p2, p3
      if y == termHeight - 2 then
        if x >= 4 and x < 24 then
          local rand = math.random(1, #items)
          displayItem(items[rand])
          playSoundNote("bit", 20)
        elseif x >= 26 and x < 36 then
          displayItem("")
          playSoundNote("bit", 16)
        elseif x >= 38 and x < 52 then
          playJingle()
        end
      end
    elseif e == "timer" then
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

-- === RUN ===
main()
