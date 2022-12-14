local addonName, addon = ...
local module = addon:CreateModule("Interface")

module.defaultSettings = {
	hideLOCBackground = false,
	hideUIErrorsFrame = false,
	hideBags = false,
	hideMicroButtons = false,
	hideGlow = false,
	hideEffects = false,
	hideZoom = false,
	sellGrays = false,
	repair = false,
}

module.optionsTable = {
	header_visibility = {
		order = 1,
		type = "header",
		name = "Visibility",
	},
	hideLOCBackground = {
		order = 2,
		type = "toggle",
		name = "Hide Loss of Control Background",
		desc = "Black background on the \"Loss of Control\" frame",
		width = "full",
	},
	hideUIErrorsFrame = {
		order = 3,
		type = "toggle",
		name = "Hide UI Errors & Objective Updates",
		desc = "Text at center of screen that appears when errors occur or quest objectives are updated (Out of range spells, killing quest NPCs, etc)",
		width = "full",
	},
	hideBags = {
		order = 4,
		type = "toggle",
		name = "Hide Bags",
		width = "full",
	},
	hideMicroButtons = {
		order = 5,
		type = "toggle",
		name = "Hide Micro Buttons",
		desc = "Buttons at the bottom right corner",
		width = "full",
	},
	hideGlow = {
		order = 6,
		type = "toggle",
		name = "Disable Screen Glow",
		desc = "Bloom effects in the world",
		width = "full",
	},
	hideEffects = {
		order = 7,
		type = "toggle",
		name = "Disable Screen Effects",
		desc = "Effects such as \"blurry\" invisibility",
		width = "full",
	},
	header_minimap = {
		order = 8,
		type = "header",
		name = "Minimap",
	},
	hideMinimapButton = {
		order = 9,
		type = "toggle",
		name = "Hide " .. addon.addonTitle .. " Button",
		width = "full",
		get = function(info) return addon.db.profile.minimap.hide end,
		set = function(info, val)
			addon.db.profile.minimap.hide = val
			if val then
				addon.icon:Hide(addonName)
			else
				addon.icon:Show(addonName)
			end
		end,
	},
	hideZoom = {
		order = 10,
		type = "toggle",
		name = "Hide Zoom Buttons",
		width = "full",
	},
	header_automation = {
		order = 12,
		type = "header",
		name = "Automation",
	},
	sellGrays = {
		order = 13,
		type = "toggle",
		name = "Auto Sell Grays",
		width = "full",
	},
	repair = {
		order = 14,
		type = "toggle",
		name = "Auto Repair",
		width = "full",
	},
}

local eventHandler = CreateFrame("Frame", nil , UIParent)
eventHandler:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function module:XaryuSettings()
	local db = self.db

	db.hideLOCBackground = true
	db.hideUIErrorsFrame = false
	db.hideBags = true
	db.hideMicroButtons = false
	db.hideGlow = true
	db.hideEffects = true
	db.hideZoom = true
	db.sellGrays = true
	db.repair = true
end

function module:OnLoad()
	local db = self.db

	eventHandler:RegisterEvent("MERCHANT_SHOW")

	if db.hideLOCBackground then
		LossOfControlFrame.blackBg:SetAlpha(0)
		LossOfControlFrame.RedLineTop:SetAlpha(0)
		LossOfControlFrame.RedLineBottom:SetAlpha(0)
	end

	if db.hideUIErrorsFrame then
		UIErrorsFrame:Hide()
	end

	if db.hideBags then
		-- Hide backpack symbol
		MainMenuBarBackpackButton:Hide()
		-- Hide toggle
		BagBarExpandToggle:Hide()
		-- Loop through all bag buttons
		for i = 0, 3 do
			local bagButton = _G["CharacterBag"..i.."Slot"]
			bagButton:Hide()
		end
		-- Hide reagent bag
		CharacterReagentBag0Slot:Hide()

	end

	if db.hideMicroButtons then
		local micro_buttons_to_hide = {
			"CharacterMicroButton",
			"SpellbookMicroButton",
			"TalentMicroButton",
			"AchievementMicroButton",
			"QuestLogMicroButton",
			"GuildMicroButton",
			"LFDMicroButton",
			"CollectionsMicroButton",
			"EJMicroButton",
			"StoreMicroButton",
			"MainMenuMicroButton"
		}
		-- Hide all micro buttons - Character, Spellbook, Talent, Achievement, Quest, Guild, LFD, Collections, Store, MainMenu
		for i = 1, #micro_buttons_to_hide do
			local button = _G[micro_buttons_to_hide[i]]
			button:SetScript("OnShow", button.Hide)
			button.Show = function () end
			button:Hide()
		end
	end

	if db.hideZoom then
		Minimap.ZoomIn:SetAlpha(0)
		Minimap.ZoomOut:SetAlpha(0)
	end

	SetCVar("ffxGlow", db.hideGlow and 0 or 1)

	SetCVar("ffxDeath", db.hideEffects and 0 or 1)
	SetCVar("ffxNether", db.hideEffects and 0 or 1)

end

function eventHandler:MERCHANT_SHOW()
	if module.db.sellGrays then
		local timer = 0.15
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link and select(3, GetItemInfo(link)) == 0 then
					C_Timer.After(timer, function() UseContainerItem(bag, slot) end)
					timer = timer + 0.15
				end
			end
		end
	end

	if module.db.repair then
		local repairAllCost, canRepair = GetRepairAllCost()
		if canRepair and repairAllCost <= GetMoney() then
			RepairAllItems(false)
		end
	end
end