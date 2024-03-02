local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

local BetterSignal = require(script:WaitForChild('BetterSignal'))

local MultiTween = {}
MultiTween.__index = MultiTween

function MultiTween.new(...)
	local self = setmetatable({
		
		_Tweens = {},
		
		PlaybackState = Enum.PlaybackState.Begin,
		Completed = BetterSignal.new()
		
	}, MultiTween)
	
	for index, tweenOptions in ipairs({...}) do
		local tween = TweenService:Create(table.unpack(tweenOptions))
		
		table.insert(self._Tweens, tween)
		
		tween.Completed:Once(function()
			table.remove(self._Tweens, table.find(self._Tweens, tween))
		end)
		
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if #self._Tweens == 0 then
				connection:Disconnect()
				self.Completed:Fire()
				self.PlaybackState = Enum.PlaybackState.Completed
			end
		end)
	end
	
	return self
end

function MultiTween:Play()
	local playbackState = self.PlaybackState
	
	if playbackState == Enum.PlaybackState.Begin or playbackState == Enum.PlaybackState.Paused then
		for index, tween in ipairs(self._Tweens) do
			tween:Play()
		end
		self.PlaybackState = Enum.PlaybackState.Playing
	end
end

function MultiTween:Pause()
	if self.PlaybackState == Enum.PlaybackState.Playing then
		for index, tween in ipairs(self._Tweens) do
			tween:Pause()
		end
		self.PlaybackState = Enum.PlaybackState.Paused
	end
end

function MultiTween:Cancel()
	for index, tween in ipairs(self._Tweens) do
		tween:Cancel()
	end
	self.PlaybackState = Enum.PlaybackState.Cancelled
end

return MultiTween
