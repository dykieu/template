--Addon name, UPPERCASE
local addonName = "TEMPLATE";
local addonNameLower = string.lower(addonName);
--Author
local author = "AUTHOR";

--Create an area for use within the add-on. Below, in the scope in the file, it can be accessed with the global variable g
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--Configuration file save destination
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

--load library
local acutil = require('acutil');

--Default config
if not g.loaded then
  g.settings = {
    --enable/disable
    enable = true,
    --frame display location
    position = {
      x = 0,
      y = 0
    }
  };
end

--Loading message for lua
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

function TEMPLATE_SAVE_SETTINGS()
  acutil.saveJSON(g.settingsFileLoc, g.settings);
end


--Processing when loading the map (only once)
function TEMPLATE_ON_INIT(addon, frame)
  g.addon = addon;
  g.frame = frame;

  frame:ShowWindow(0);
  --acutil.slashCommand("/"..addonNameLower, TEMPLATE_PROCESS_COMMAND);
  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
      --Processing when reading the configuration file fails
      CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName));
    else
      --Processing when the configuration file is read successfully
      g.settings = t;
    end
    g.loaded = true;
  end

  --Setting file save process
  TEMPLATE_SAVE_SETTINGS();
  --Message reception registration process
  --addon: RegisterMsg ("message", "internal processing");

  --Context menu
  frame:SetEventScript(ui.RBUTTONDOWN, "TEMPLATE_CONTEXT_MENU");
  --drag
  frame:SetEventScript(ui.LBUTTONUP, "TEMPLATE_END_DRAG");

  --Frame initialization process
  TEMPLATE_INIT_FRAME(frame);

  --Redisplay process
  if g.settings.enable then
    frame:ShowWindow(1);
  else
    frame:ShowWindow(0);
  end
  --Move doesn't work, so use OffSet ...
  frame:Move(0, 0);
  frame:SetOffset(g.settings.position.x, g.settings.position.y);
end

function TEMPLATE_INIT_FRAME(frame)
  --If you write it in XML, you need to restart the client when adjusting the design, so it is recommended to write it in lua.
  --Frame initialization process
  local text = frame:CreateOrGetControl("richtext", "text", 0, 0, 0, 0);
  text:SetText(addonName);
end

--Context menu display processing
function TEMPLATE_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
  local context = ui.CreateContextMenu("TEMPLATE_RBTN", "Template", 0, 0, 300, 100);
  ui.AddContextMenuItem(context, "Hide", "TEMPLATE_TOGGLE_FRAME()");
  context:Resize(300, context:GetHeight());
  ui.OpenContextMenu(context);
end

--Show / hide switching process
function TEMPLATE_TOGGLE_FRAME()
  if g.frame:IsVisible() == 0 then
    --hide -> show
    g.frame:ShowWindow(1);
    g.settings.enable = true;
  else
    --Show-> Hide
    g.frame:ShowWindow(0);
    g.settings.show = false;
  end

  TEMPLATE_SAVESETTINGS();
end

--Frame location save process
function TEMPLATE_END_DRAG()
  g.settings.position.x = g.frame:GetX();
  g.settings.position.y = g.frame:GetY();
  TEMPLATE_SAVESETTINGS();
end

--Chat command processing (when using acutil)
function TEMPLATE_PROCESS_COMMAND(command)
  local cmd = "";

  if #command > 0 then
    cmd = table.remove(command, 1);
  else
    local msg = "ヘルプメッセージなど"
    return ui.MsgBox(msg,"","Nope")
  end

  if cmd == "on" then
    --valid
    g.settings.enable = true;
    CHAT_SYSTEM(string.format("[%s] is enable", addonName));
    TEMPLATE_SAVESETTINGS();
    return;
  elseif cmd == "off" then
    --invalid
    g.settings.enable = false;
    CHAT_SYSTEM(string.format("[%s] is disable", addonName));
    TEMPLATE_SAVESETTINGS();
    return;
  end
  CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
end

