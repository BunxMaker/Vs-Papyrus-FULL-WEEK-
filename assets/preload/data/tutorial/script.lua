
function update (elapsed)
	local songPos = getSongPosition()

	local currentBeat = (songPos / 1000)*(bpm/60)
	
    if sway then
		setProperty("camHUD.angle", 5 * math.sin(currentBeat * 0.504))
    end
	
end

function stepHit (step)

	-- Sway hud timing
	if not sway and (step >= 687 and step < 1150) then
		sway = true
	elseif sway and (step > 1150) then
		sway = false
		camHudAngle = 0
	end
	
	
end