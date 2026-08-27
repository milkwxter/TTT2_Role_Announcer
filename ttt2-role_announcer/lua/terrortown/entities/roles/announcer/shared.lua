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
		random = 25,
		shopFallback = SHOP_FALLBACK_DETECTIVE
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_DETECTIVE)
end

if SERVER then
	-- give loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentItem("item_ttt_armor")
	end

	-- remove loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:RemoveEquipmentItem("item_ttt_armor")
	end

	-- announcer logic
	hook.Add("TTT2OrderedEquipment", "TTT2_AnnouncerSomeonePurchased", function(ply, equipmentName, isItem, credits, ignoreCost)
		-- dont run if role is disabled
		if ttt_announcer.enabled == 0 then return end
		
		-- try to find the first living announcer
		local livingAnnouncer = nil
		for _, v in pairs(roles.GetTeamMembers(TEAM_INNOCENT)) do
			if v:IsValid() and v:Alive() and v:GetRole() == ROLE_ANNOUNCER then
				livingAnnouncer = v
				break
			end
		end
		
		-- no announcer left alive then return early
		if livingAnnouncer == nil then return end
		
		-- try to get actual equipment
		local equipmentTable = scripted_ents.GetStored(equipmentName)
		if equipmentTable == nil then return end
		
		-- make the announcement
		local equipmentNameLocalized = equipmentTable.PrintName
		equipmentNameLocalized = LANG.TryTranslation(equipmentNameLocalized)
		local textDescString = LANG.TryTranslation("ttt2_announcer_reveal_purchase_desc")
		local purchaseDisplayTime = GetConVar("ttt2_announcer_purchase_time_on_screen"):GetInt()
		if GetConVar("ttt2_announcer_show_purchaser_team"):GetBool() == true then
			local plyTeam = ply:GetTeam()
			local purchaserRoleLabel = "unidentified terrorist"
			if plyTeam == TEAM_INNOCENT then
				purchaserRoleLabel = "innocent terrorist"
			elseif plyTeam == TEAM_TRAITOR then
				purchaserRoleLabel = "traitorous terrorist"
			end
			
			local textString = LANG.GetParamTranslation("ttt2_announcer_reveal_purchase_team", {team = purchaserRoleLabel, equipment = equipmentNameLocalized})
		else
			local textString = LANG.GetParamTranslation("ttt2_announcer_reveal_purchase", {equipment = equipmentNameLocalized})
		end
		
		-- finally send the message
		EPOP:AddMessage(nil, {text = textString, color = ANNOUNCER.color}, textDescString, purchaseDisplayTime, true)
	end)
end

CreateConVar("ttt2_announcer_show_purchaser_team", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Should the purchase announcement include the team of the player who bought the equipment?", 0, 1)
CreateConVar("ttt2_announcer_purchase_time_on_screen", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long should the purchase notification stay on screen in seconds?", 1, 10)

if CLIENT then
	function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

		form:MakeCheckBox({
			serverConvar = "ttt2_announcer_show_purchaser_team",
			label = "ttt2_label_announcer_show_purchaser_team",
			min = 0,
			max = 1,
			decimal = 0,
		})

		form:MakeSlider({
			serverConvar = "ttt2_announcer_purchase_time_on_screen",
			label = "ttt2_label_announcer_purchase_time_on_screen",
			min = 0,
			max = 10,
			decimal = 0,
		})
	end
end