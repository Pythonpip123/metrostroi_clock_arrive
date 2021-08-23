AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function FindPlatform(st,path)
	for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
		if not IsValid(v) then continue end
		if v.StationIndex == st and v.PlatformIndex == path then return v end
	end
end

function ENT:Initialize()
	self:SetModel("models/alexell/clock_arrive.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.Station = self:GetNW2Int("Station",0)
	self.Path = self:GetNW2Int("Path",0)
	self.Platform = FindPlatform(self.Station,self.Path)
	self.ArriveTime = 0
end

function ENT:Think()
	if IsValid(self.Platform) then
		if IsValid(self.Platform.CurrentTrain) then
			local train = self.Platform.CurrentTrain
			if self:GetTrain() == false then self:SetTrain(true) end
			if train.Speed < 1 then
				if self:GetTrainStopped() == false then self:SetTrainStopped(true) end
			else
				if self:GetTrainStopped() == true then self:SetTrainStopped(false) end
			end
		else
			if self:GetTrain() == true then self:SetTrain(false) end
			if self:GetTrainStopped() == true then self:SetTrainStopped(false) end
		end
	else
		self.Platform = FindPlatform(self.Station,self.Path)
	end
	
	local MetrostroiTrainPositions = Metrostroi.TrainPositions or {}
	local ArriveTimes = {}
	local min_arr	
	
	local StationPos = Metrostroi.GetPositionOnTrack(self.Platform.PlatformStart)
	local StationPath = StationPos[1].node1.path.id	
	
	for train, position in pairs(MetrostroiTrainPositions) do	
		
		local TrainStation = train:ReadCell(49160)
		if TrainStation == 0 then TrainStation = train:ReadCell(49161) end
		if TrainStation == 0 then continue end
		local TrainPos = position[1]
		local TrainPath = position[1].node1.path.id
		if not TrainPath then continue end	
		
		if StationPath != TrainPath then continue end
		if math.abs(self.Station - TrainStation) > 2 then continue end
		
		local direction = TrainPos.x < StationPos[1].x
		if not direction then continue end
		
		if StationPos[1] and TrainPos then			
			local ArrTime,Dist = Metrostroi.GetTravelTime(TrainPos.node1, StationPos[1].node1)
			if ArrTime < 600 then
				table.insert(ArriveTimes, math.Round(ArrTime))
			end
		end			
	end
	
	if #ArriveTimes < 1 then 
		min_arr = -1
	else
		for k,v in pairs(ArriveTimes) do
			if not min_arr or v < min_arr then 
				min_arr = v 
			end
		end
	end
	self:SetNW2Int("ArriveTime",min_arr) 
	--[[ временно отключено, и вообще под вопросом 
	net.Start("ClockArriveTime")
	net.WriteInt(min_arr, 13)  
	net.Broadcast()]]
	self:NextThink(CurTime() + 1)
	return true
end
