-- Poggimart POS System
-- An easter egg for ComputerCraft (CC: Tweaked)
-- Inspired by FamilyMart

--[[
  To use:
  1. Save this code as a file (e.g., "poggimart_pos") on a ComputerCraft computer.
  2. Run the program by typing the filename in the terminal.
  3. An advanced computer and monitor are recommended for color and mouse support.
]]

-- Global settings
local termWidth, termHeight = term.getSize()
local running = true

-- Poggimart branding
local poggimartBlue = colors.blue
local poggimartGreen = colors.green
local backgroundColor = colors.white
local textColor = colors.black
local headerColor = colors.lightGray
local buttonColor = colors.gray
local buttonTextColor = colors.white

-- Product list (inspired by FamilyMart)
local items = {
  "Pogi-Chiki",
  "Spicy Chicken",
  "Onigiri (Salmon)",
  "Onigiri (Tuna Mayo)",
  "Sando (Egg Salad)",
  "Sando (Pork Katsu)",
  "Melon Pan",
  "Anpan (Red Bean)",
  "Oden",
  "Nikuman (Pork Bun)",
  "Iced Coffee",
  "Iced Latte",
  "Green Tea",
  "Mugi-cha (Barley Tea)",
  "Pocari Sweat",
  "C.C. Lemon",
  "PogiMart Socks",
  "Pogi-Socks (Green)",
  "Pogi-Socks (Blue)"
}
local displayedItem = ""

-- Function to clear the screen with the background color
local function clearScreen()
  term.setBackgroundColor(backgroundColor)
  term.clear()
end

-- Function to draw the Poggimart logo
local function drawLogo()
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

  -- Text
  term.setCursorPos(3, 2)
  term.setBackgroundColor(poggimartGreen)
  term.setTextFont("sans-serif") -- A simple font choice
  term.setTextColor(colors.white)
  term.write("Poggimart")
end

-- Function to draw the main layout
local function drawLayout()
  -- Header for the item display
  term.setBackgroundColor(headerColor)
  term.setCursorPos(1, 7)
  term.write(string.rep(" ", termWidth))
  term.setCursorPos(3, 7)
  term.setTextColor(textColor)
  term.write("Scanned Item:")

  -- Item display area
  term.setBackgroundColor(colors.lightGray)
  term.setCursorPos(2, 9)
  for i = 1, 3 do
    term.setCursorPos(2, 8 + i)
    term.write(string.rep(" ", termWidth - 3))
  end

  -- "Scan Random Item" button
  term.setBackgroundColor(buttonColor)
  term.setCursorPos(4, termHeight - 3)
  for i = 1, 3 do
      term.setCursorPos(4, termHeight - 4 + i)
      term.write(string.rep(" ", termWidth - 7))
  end
  term.setCursorPos(6, termHeight - 2)
  term.setTextColor(buttonTextColor)
  term.write("Scan Random Item")

  -- "Exit" button
  term.setCursorPos(termWidth - 8, 2)
  term.setBackgroundColor(colors.red)
  term.setTextColor(colors.white)
  term.write(" Exit ")
end

-- Function to display a scanned item
local function displayItem(item)
  displayedItem = item
  -- Clear previous item
  term.setBackgroundColor(colors.lightGray)
    for i = 1, 3 do
        term.setCursorPos(2, 8 + i)
        term.write(string.rep(" ", termWidth - 3))
    end

  -- Display new item
  term.setCursorPos(4, 10)
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(textColor)
  term.write(displayedItem)
end

-- Function to handle mouse clicks
local function handleMouseClick(button, x, y)
  -- Check for "Scan Random Item" button click
  if y >= termHeight - 3 and y <= termHeight - 1 and x >= 4 and x <= termWidth - 4 then
    local randomIndex = math.random(1, #items)
    displayItem(items[randomIndex])
  end

  -- Check for "Exit" button click
  if y == 2 and x >= termWidth - 8 and x <= termWidth - 2 then
    running = false
  end
end

-- Main program loop
local function main()
  clearScreen()
  drawLogo()
  drawLayout()
  displayItem("Welcome to Poggimart!")

  while running do
    local event, button, x, y = os.pullEvent()
    if event == "mouse_click" then
      handleMouseClick(button, x, y)
    elseif event == "key" and button == keys.q then
      running = false
    end
  end

  clearScreen()
  term.setCursorPos(1, 1)
  term.setTextColor(textColor)
  term.write("Thank you for visiting Poggimart!")
end

-- Run the program
main()
