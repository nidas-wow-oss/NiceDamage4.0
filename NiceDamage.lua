-- ============================================================
--  NiceDamage - Standalone Addon
--  v4.2 - Independent (no framework required)
--         Dual Font Selector: Damage + Heals/Auras
--         MouseWheel scroll - no template dependency
-- ============================================================
local AddOnName = ...;

local ADDON_PATH   = "Interface\\AddOns\\NiceDamage4.0\\fonts\\";
local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF";

-- ── Font list ──────────────────────────────────────────────────
-- file = nil  →  uses default WoW font
-- file = "X"  →  loads ADDON_PATH .. "X"   (must be in NiceDamage\ folder)
-- ──────────────────────────────────────────────────────────────
local fontList = {
	-- ── Original fonts ────────────────────────────────────────
	{ name = "Default WoW",      file = nil                         },
	{ name = "Pepsi",            file = "font.ttf"                  },
	{ name = "Zombie",           file = "font2.ttf"                 },
	{ name = "Basket Hammers",   file = "font3.ttf"                 },
	{ name = "College",          file = "font4.ttf"                 },
	{ name = "Galaxy",           file = "font5.ttf"                 },
	{ name = "Elite",            file = "font6.ttf"                 },
	{ name = "Stentiga",         file = "font7.ttf"                 },
	{ name = "Skratch Punk",     file = "font8.ttf"                 },
	-- ── New fonts ─────────────────────────────────────────────
	{ name = "ABF",              file = "ABF.ttf"                   },
	{ name = "Accidental Pres.", file = "Accidental Presidency.ttf" },
	{ name = "Action Man",       file = "ActionMan.ttf"             },
	{ name = "Adventure",        file = "Adventure.ttf"             },
	{ name = "Continuum",        file = "ContinuumMedium.ttf"       },
	{ name = "Diablo",           file = "Diablo.ttf"                },
	{ name = "DieDieDie",        file = "DieDieDie.ttf"             },
	{ name = "Domyouji",         file = "DomyoujiRegular.ttf"       },
	{ name = "Dsdig",            file = "Dsdig.ttf"                 },
	{ name = "Expressway",       file = "Expressway.ttf"            },
	{ name = "Forced Square",    file = "FORCED SQUARE.ttf"         },
	{ name = "Homespun BRK",     file = "Homespun.ttf"              },
	{ name = "Hooge 05_55",      file = "Hooge.ttf"                 },
	{ name = "Vipnagorgialla",   file = "Vipnagorgiallarg.ttf"      },
	{ name = "Seagram",          file = "Seagram.ttf"               },
	{ name = "PT Sans Narrow",   file = "PTSansNarrow.ttf"          },
	{ name = "Yanone",           file = "yanone.ttf"                },
};

-- ── State ──────────────────────────────────────────────────────
local dmgFontIndex  = 2;
local healFontIndex = 1;

-- ── Helpers ────────────────────────────────────────────────────
local function GetFontPath(index)
	local data = fontList[index];
	if data and data.file then
		return ADDON_PATH .. data.file;
	end
	return DEFAULT_FONT;
end

local function SafeSetFont(fontObj, path, size, flags)
	if not fontObj then return false; end
	local ok = fontObj:SetFont(path, size or 18, flags or "");
	if not ok then
		fontObj:SetFont(DEFAULT_FONT, size or 18, flags or "");
		return false;
	end
	return true;
end

-- ── Font validation ────────────────────────────────────────────
local _testFS;
local function IsFontValid(path)
	if not path or path == DEFAULT_FONT then return true; end
	if not _testFS then
		local f = CreateFrame("Frame", nil, UIParent);
		f:Hide();
		_testFS = f:CreateFontString(nil, "ARTWORK");
	end
	return _testFS:SetFont(path, 12, "");
end

-- ── SavedVariables ─────────────────────────────────────────────
local function SaveChoice()
	NiceDamageDB = NiceDamageDB or {};
	NiceDamageDB.dmgFont  = dmgFontIndex;
	NiceDamageDB.healFont = healFontIndex;
end

local function LoadChoice()
	if NiceDamageDB then
		dmgFontIndex  = NiceDamageDB.dmgFont  or 2;
		healFontIndex = NiceDamageDB.healFont or 1;
		-- Legacy migration from older single-font version
		if NiceDamageDB.selectedFont and not NiceDamageDB.dmgFont then
			dmgFontIndex = NiceDamageDB.selectedFont;
		end
	end
	if type(dmgFontIndex)  ~= "number" then dmgFontIndex  = 2; end
	if type(healFontIndex) ~= "number" then healFontIndex = 1; end
	if dmgFontIndex  < 1 or dmgFontIndex  > #fontList then dmgFontIndex  = 2; end
	if healFontIndex < 1 or healFontIndex > #fontList then healFontIndex = 1; end
end

-- ── Apply fonts ────────────────────────────────────────────────
local function ApplyDamageFont()
	local path = GetFontPath(dmgFontIndex);
	if IsFontValid(path) then
		DAMAGE_TEXT_FONT = path;
	else
		DAMAGE_TEXT_FONT = DEFAULT_FONT;
		dmgFontIndex = 1;
		SaveChoice();
	end
end

local function ApplyHealFont()
	if CombatTextFont then
		local _, size, flags = CombatTextFont:GetFont();
		SafeSetFont(CombatTextFont, GetFontPath(healFontIndex), size, flags);
	end
end

local function ApplyAll()
	ApplyDamageFont();
	ApplyHealFont();
end

-- ── Menu layout constants ──────────────────────────────────────
local ROW_H     = 28;
local BTN_SIZE  = 22;
local PANEL_W   = 320;
local VISIBLE   = 12;                    -- rows visible without scrolling
local SCROLL_H  = VISIBLE * ROW_H;
local HEADER_H  = 56;
local FOOTER_H  = 68;
local PANEL_H   = HEADER_H + SCROLL_H + FOOTER_H;
local CONTENT_W = PANEL_W - 16;
local TOTAL_H   = #fontList * ROW_H;

local menuFrame;

local function BuildMenu()
	if menuFrame then return; end

	-- ── Outer panel ────────────────────────────────────────────
	menuFrame = CreateFrame("Frame", "NiceDamageMenuFrame", UIParent);
	menuFrame:SetWidth(PANEL_W);
	menuFrame:SetHeight(PANEL_H);
	menuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	menuFrame:SetFrameStrata("DIALOG");
	menuFrame:SetMovable(true);
	menuFrame:EnableMouse(true);
	menuFrame:RegisterForDrag("LeftButton");
	menuFrame:SetScript("OnDragStart", function() menuFrame:StartMoving(); end);
	menuFrame:SetScript("OnDragStop",  function() menuFrame:StopMovingOrSizing(); end);
	menuFrame:Hide();

	menuFrame:SetBackdrop({
		bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	});
	menuFrame:SetBackdropColor(0.08, 0.08, 0.15, 0.97);
	menuFrame:SetBackdropBorderColor(0.4, 0.4, 0.8, 1);

	-- Title
	local title = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOP", menuFrame, "TOP", 0, -12);
	title:SetText("|cff88aaffNiceDamage|r |cffaaaaaaFont Selector|r");

	-- Close button
	local closeBtn = CreateFrame("Button", nil, menuFrame, "UIPanelCloseButton");
	closeBtn:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -2, -2);
	closeBtn:SetScript("OnClick", function() menuFrame:Hide(); end);

	-- Column headers
	local lblFont = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	lblFont:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 14, -38);
	lblFont:SetText("|cffffff88Font|r");

	local lblD = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	lblD:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -38, -38);
	lblD:SetText("|cffff8844D|r");

	local lblH = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	lblH:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -14, -38);
	lblH:SetText("|cff44ff88H|r");

	-- ── ScrollFrame (pure Lua, no template) ───────────────────
	local sf = CreateFrame("ScrollFrame", nil, menuFrame);
	sf:SetPoint("TOPLEFT",     menuFrame, "TOPLEFT",     8,  -(HEADER_H));
	sf:SetPoint("BOTTOMRIGHT", menuFrame, "BOTTOMRIGHT", -8,  FOOTER_H);

	local sc = CreateFrame("Frame", nil, sf);
	sc:SetWidth(CONTENT_W);
	sc:SetHeight(TOTAL_H);
	sf:SetScrollChild(sc);

	-- MouseWheel scroll (3 rows per tick)
	sf:EnableMouseWheel(true);
	sf:SetScript("OnMouseWheel", function(self, delta)
		local cur      = self:GetVerticalScroll();
		local maxScroll = math.max(0, TOTAL_H - SCROLL_H);
		local new = math.max(0, math.min(maxScroll, cur - delta * ROW_H * 3));
		self:SetVerticalScroll(new);
	end);

	-- ── Font rows ──────────────────────────────────────────────
	local rows = {};
	for i, fontData in ipairs(fontList) do
		local idx  = i;
		local rowY = -(i - 1) * ROW_H;
		local row  = {};

		-- Row background
		local rowBg = sc:CreateTexture(nil, "BACKGROUND");
		rowBg:SetPoint("TOPLEFT",  sc, "TOPLEFT",  0, rowY);
		rowBg:SetPoint("TOPRIGHT", sc, "TOPRIGHT", 0, rowY);
		rowBg:SetHeight(ROW_H - 2);
		rowBg:SetTexture(0.12, 0.12, 0.22, 0.5);
		row.bg = rowBg;

		-- Font name label (rendered in that font when possible)
		local label = sc:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		label:SetPoint("TOPLEFT", sc, "TOPLEFT", 6, rowY - 5);
		label:SetWidth(CONTENT_W - 64);
		label:SetJustifyH("LEFT");
		if fontData.file then
			local path = ADDON_PATH .. fontData.file;
			local ok = label:SetFont(path, 13, "");
			if not ok then label:SetFontObject(GameFontNormal); end
		end
		label:SetText(fontData.name);
		row.label = label;

		-- ── [D] button ─────────────────────────────────────────
		local btnD = CreateFrame("Button", nil, sc);
		btnD:SetWidth(BTN_SIZE); btnD:SetHeight(BTN_SIZE);
		btnD:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -28, rowY - 3);

		local btnDbg = btnD:CreateTexture(nil, "BACKGROUND");
		btnDbg:SetAllPoints(); btnDbg:SetTexture(0.2, 0.15, 0.1, 0.8);
		row.btnDbg = btnDbg;

		local btnDhl = btnD:CreateTexture(nil, "HIGHLIGHT");
		btnDhl:SetAllPoints(); btnDhl:SetTexture(0.5, 0.3, 0.1, 0.5);

		local btnDtxt = btnD:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		btnDtxt:SetPoint("CENTER"); btnDtxt:SetText("|cffff8844D|r");
		row.btnDtxt = btnDtxt;

		btnD:SetScript("OnClick", function()
			dmgFontIndex = idx;
			SaveChoice();
			ApplyDamageFont();
			menuFrame:RefreshSelection();
		end);
		btnD:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(
				"|cffff8844Enemy Damage|r\n|cffaaaaaaRequires reopening WoW|r",
				nil, nil, nil, nil, true
			);
			GameTooltip:Show();
		end);
		btnD:SetScript("OnLeave", function() GameTooltip:Hide(); end);

		-- ── [H] button ─────────────────────────────────────────
		local btnH = CreateFrame("Button", nil, sc);
		btnH:SetWidth(BTN_SIZE); btnH:SetHeight(BTN_SIZE);
		btnH:SetPoint("TOPRIGHT", sc, "TOPRIGHT", -4, rowY - 3);

		local btnHbg = btnH:CreateTexture(nil, "BACKGROUND");
		btnHbg:SetAllPoints(); btnHbg:SetTexture(0.1, 0.2, 0.1, 0.8);
		row.btnHbg = btnHbg;

		local btnHhl = btnH:CreateTexture(nil, "HIGHLIGHT");
		btnHhl:SetAllPoints(); btnHhl:SetTexture(0.1, 0.5, 0.2, 0.5);

		local btnHtxt = btnH:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		btnHtxt:SetPoint("CENTER"); btnHtxt:SetText("|cff44ff88H|r");
		row.btnHtxt = btnHtxt;

		btnH:SetScript("OnClick", function()
			healFontIndex = idx;
			SaveChoice();
			ApplyHealFont();
			menuFrame:RefreshSelection();
		end);
		btnH:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(
				"|cff44ff88Heals, Auras & Self Text|r\n|cffaaaaaaApplies instantly|r",
				nil, nil, nil, nil, true
			);
			GameTooltip:Show();
		end);
		btnH:SetScript("OnLeave", function() GameTooltip:Hide(); end);

		rows[i] = row;
	end
	menuFrame.rows = rows;

	-- ── Footer ─────────────────────────────────────────────────
	local footerY = -(HEADER_H + SCROLL_H + 4);

	local hint = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	hint:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 12, footerY - 2);
	hint:SetText("|cff666666Scroll: mouse wheel|r");

	local sep = menuFrame:CreateTexture(nil, "ARTWORK");
	sep:SetHeight(1);
	sep:SetPoint("TOPLEFT",  menuFrame, "TOPLEFT",  10, footerY - 16);
	sep:SetPoint("TOPRIGHT", menuFrame, "TOPRIGHT", -10, footerY - 16);
	sep:SetTexture(0.4, 0.4, 0.6, 0.8);

	local legD = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	legD:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 12, footerY - 22);
	legD:SetText("|cffff8844D|r |cffaaaaaa= Enemy Damage (needs WoW restart)|r");

	local legH = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	legH:SetPoint("TOPLEFT", legD, "BOTTOMLEFT", 0, -4);
	legH:SetText("|cff44ff88H|r |cffaaaaaa= Heals / Auras / Self Text (instant)|r");

	local legSlash = menuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	legSlash:SetPoint("TOPLEFT", legH, "BOTTOMLEFT", 0, -4);
	legSlash:SetText("|cffaaaaaa/nd  |  /nd reset|r");

	-- ── RefreshSelection ───────────────────────────────────────
	function menuFrame:RefreshSelection()
		for i, row in ipairs(self.rows) do
			local isDmg  = (i == dmgFontIndex);
			local isHeal = (i == healFontIndex);

			if isDmg and isHeal then
				row.bg:SetTexture(0.25, 0.35, 0.2, 0.7);
			elseif isDmg then
				row.bg:SetTexture(0.3, 0.2, 0.1, 0.6);
			elseif isHeal then
				row.bg:SetTexture(0.1, 0.25, 0.15, 0.6);
			else
				row.bg:SetTexture(0.12, 0.12, 0.22, 0.5);
			end

			if isDmg then
				row.btnDbg:SetTexture(0.8, 0.4, 0.1, 0.9);
				row.btnDtxt:SetText("|cffffffffD|r");
			else
				row.btnDbg:SetTexture(0.2, 0.15, 0.1, 0.6);
				row.btnDtxt:SetText("|cff886644D|r");
			end

			if isHeal then
				row.btnHbg:SetTexture(0.1, 0.7, 0.3, 0.9);
				row.btnHtxt:SetText("|cffffffffH|r");
			else
				row.btnHbg:SetTexture(0.1, 0.2, 0.1, 0.6);
				row.btnHtxt:SetText("|cff448844H|r");
			end

			if isDmg and isHeal then
				row.label:SetTextColor(1, 1, 0.5);
			elseif isDmg then
				row.label:SetTextColor(1, 0.6, 0.3);
			elseif isHeal then
				row.label:SetTextColor(0.4, 1, 0.5);
			else
				row.label:SetTextColor(0.8, 0.8, 0.8);
			end
		end
	end
end

-- ── Toggle menu ────────────────────────────────────────────────
local function ToggleMenu()
	BuildMenu();
	if menuFrame:IsShown() then
		menuFrame:Hide();
	else
		menuFrame:RefreshSelection();
		menuFrame:Show();
	end
end

-- ── Events ─────────────────────────────────────────────────────
-- ADDON_LOADED: set DAMAGE_TEXT_FONT as early as possible.
-- WoW reads this global at startup to create font objects.
-- PLAYER_ENTERING_WORLD: re-apply heal font after zone changes.
local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("ADDON_LOADED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == AddOnName then
		LoadChoice();
		local path = GetFontPath(dmgFontIndex);
		if IsFontValid(path) then
			DAMAGE_TEXT_FONT = path;
		else
			DAMAGE_TEXT_FONT = DEFAULT_FONT;
			dmgFontIndex = 1;
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		ApplyAll();
	end
end);

-- ── Slash commands ─────────────────────────────────────────────
SLASH_NICEDAMAGE1 = "/nicedamage";
SLASH_NICEDAMAGE2 = "/nd";
SlashCmdList["NICEDAMAGE"] = function(msg)
	msg = string.lower(msg or "");
	if msg == "reset" then
		dmgFontIndex  = 2;
		healFontIndex = 1;
		SaveChoice();
		ApplyAll();
		print("|cff88aaffNiceDamage:|r Fonts reset to defaults.");
	else
		ToggleMenu();
	end
end