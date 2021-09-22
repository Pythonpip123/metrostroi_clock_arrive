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
	self.Distance = self:GetNW2Int("Distance",1500)
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
	local NearestTrain
	local NearestTrainNode
	local min_dist
	local ArriveTime	
	local NodesRange = self.Distance/10 
	
	local StationPos = Metrostroi.GetPositionOnTrack(self.Platform.PlatformStart)
	local StationPath = StationPos[1].node1.path.id	
	local StationNodeID = StationPos[1].node1.id	
	
	for train, position in pairs(MetrostroiTrainPositions) do
		
		local TrainPos = position[1]
		if not TrainPos then continue end
		
		local TrainPath = TrainPos.node1.path.id
		if not TrainPath then continue end	
		
		if StationPath != TrainPath then continue end
		
		local TrainNodeID = TrainPos.node1.id

		local direction = TrainNodeID < StationNodeID
		if not direction then continue end
		
		-- удобное ограничение по дальности просчета
		if math.abs(StationNodeID - TrainNodeID) > NodesRange then continue end 
		
		if StationPos[1] and TrainPos then 
			if not min_dist or math.abs(StationNodeID - TrainNodeID) < min_dist then
				min_dist = StationNodeID - TrainNodeID
				NearestTrain = train
				NearestTrainNode = TrainPos.node1
			end			
		end
	end
	
	if NearestTrainNode and StationPos[1] then
		ArriveTime = Metrostroi.GetTravelTime(NearestTrainNode, StationPos[1].node1)
	else
		ArriveTime = -1
	end
	if ArriveTime < 600 then
		self:SetNW2Int("ArriveTime",ArriveTime) 
	end
	--[[ временно отключено, и вообще под вопросом 
	net.Start("ClockArriveTime")
	net.WriteInt(ArriveTime, 13)  
	net.Broadcast()]]
	self:NextThink(CurTime() + 3)
	return true
end
