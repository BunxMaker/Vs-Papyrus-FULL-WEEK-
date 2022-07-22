function start (song)
end

function onUpdate (elapsed)

	local songPos = getPropertyFromClass('Conductor', 'songPosition') / 1000
	
    if curStep >= 687 and curStep < 1150 then
		setProperty("camHUD.angle", 5 * math.sin(songPos))
    end
	if curStep >= 1150 then
		setProperty("camHUD.angle", 0)
	end
end
