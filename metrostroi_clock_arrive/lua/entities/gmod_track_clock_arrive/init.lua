AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function FindPlatform(st,path)
	for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
		if not IsValid(v) then continue end
		if v.StationIndex == st and v.PlatformIndex == path then return v end
	end
end

local function GetTravelTime(src,dest)
	-- Determine direction of travel
	local direction = src.x < dest.x

	-- Accumulate travel time
	local travel_time = 0
	local travel_dist = 0
	local avg_speed = 0
	local travel_speed = 20
	local iter = 0
	local ars_rccount = 0
	function scan(node,path)		
		while (node) and (direction) and (node ~= dest) do
			local ars_speed
			local ars_joint = Metrostroi.GetARSJoint(node,node.x+0.01,path or true)
			if ars_joint then
				local ARSLimit = ars_joint:GetMaxARS()
				if ARSLimit >= 4  then
					ars_speed = ARSLimit*10
				end
			end
			
			-- count and sum all ARS Limits 
			if ars_speed then 
				avg_speed = avg_speed + ars_speed 
				ars_rccount = ars_rccount + 1
			end
			-- count and sum all node lengths
			travel_dist = travel_dist + node.length
			node = node.next
			
			if not node then break end
			-- restrict calculations within another track
			--if src.path == dest.path and node.branches and node.branches[1][2].path == src.path then scan(node,src.x > node.branches[1][2].x) end
			--if src.path == dest.path and node.branches and node.branches[2] and node.branches[2][2].path == src.path then scan(node,src.x > node.branches[1][1].x) end
			assert(iter < 10000, "OH SHI~")
			iter = iter + 1
		end
		avg_speed = (avg_speed*0.20)/ars_rccount
		travel_time = travel_dist/avg_speed
	end
	scan(src)
	return travel_time,travel_dist
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
	local NearestTrain
	local NearestTrainNode
	local min_dist
	local ArriveTime	
	
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

		local direction = TrainPos.x < StationPos[1].x
		if not direction then continue end
		
		-- временное ограничение по дальности просчета
		if math.abs(StationNodeID - TrainNodeID) > 750 then continue end 
		
		if StationPos[1] and TrainPos then 
			if not min_dist or math.abs(StationNodeID - TrainNodeID) < min_dist then
				min_dist = StationNodeID - TrainNodeID
				NearestTrain = train
				NearestTrainNode = TrainPos.node1
			end			
		end

		--[[if StationPos[1] and TrainPos then 
			local ArrTime,Dist = GetTravelTime(TrainPos.node1, StationPos[1].node1)
			if ArrTime < 600 then
				table.insert(ArriveTimes, math.Round(ArrTime))
			end
		end	]]
	end
	
	--[[if #ArriveTimes < 1 then 
		ArriveTime = -1
	else
		for k,v in pairs(ArriveTimes) do
			if not ArriveTime or v < ArriveTime then 
				ArriveTime = v 
			end
		end
	end ]]
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
