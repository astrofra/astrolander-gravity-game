
function	GlobalGetCurrentLevel()
{
	return	(ProjectGetScriptInstance(g_project).player_data.current_level)
}

function	GlobalLevelTableNameFromIndex(level_idx)
{
	local	season_idx = (level_idx / 8).tointeger()
	local	current_season_table = g_seasons["season_" + season_idx.tostring()]
	local	current_level_table = current_season_table.levels[level_idx - season_idx * 8]
	return	current_level_table
}

	//-------------------------------------
	function	GetSeasonCompletion(season)
	//-------------------------------------
	{
		local	season_first_level = season * 8, n, completion = 0
		for(n = 0; n < 8; n++)
			if (IsLevelCompleted(season_first_level + n)) completion++
		return completion
	}

	//----------------------------------
	function	IsLevelCompleted(_level)
	//----------------------------------
	{
		local	game = ProjectGetScriptInstance(g_project)
		local	_level_key = "level_" + _level.tostring()
		if (_level > 0 && game.player_data.rawin(_level_key) && game.player_data[_level_key].complete)
			return true
		else
		if (_level == 0)
			return true
		else
			return false
	}