if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_announcer.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(75, 104, 169, 255)

	self.abbr = "announcer"
	self.score.killsMultiplier = 8
	self.score.teamKillsMultiplier = -8
	self.score.bodyFoundMuliplier = 3
	self.unknownTeam = true

	self.defaultTeam = TEAM_INNOCENT
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.isPublicRole = true
	self.isPolicingRole = true

	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 6,
		minKarma = 600,
		credits = 2,
		creditsAwardDeadEnable = 1,
		creditsAwardKillEnable = 0,
		togglable = true,
		random = 33,
		shopFallback = SHOP_FALLBACK_DETECTIVE
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_DETECTIVE)
end

if SERVER then
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentItem("item_ttt_armor")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:RemoveEquipmentItem("item_ttt_armor")
	end

	-- When round begins reset cooldowns to prevent funky business
	hook.Add("TTT2OrderedEquipment", "TTT2_AnnouncerSomeonePurchased", function(ply, equipmentName, isItem, credits, ignoreCost)
		-- find the announcer if possible
		local livingAnnouncer = nil
		for k, v in pairs(roles.GetTeamMembers(TEAM_INNOCENT)) do
			if v:GetRoleString() == "announcer" and v:Alive() then
				livingAnnouncer = v
				break
			end
		end
		
		-- no announcer left alive then return early
		if livingAnnouncer == nil then return end
		
		-- make the announcement
		EPOP:AddMessage(nil, {text = "Someone has purchased an item: " .. equipmentName, color = ANNOUNCER.color}, "This message was broadcasted by your Announcer", 5, true)
	end)
end