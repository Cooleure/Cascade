function CascadeCreate()
{
	SetState(0);
	porteeMax = 100;
	portee = 0;
}

function CascadeStep()
{
	var _voisins = GridGetVoisins(x, y);

	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin.object_index != oRiviere) continue;
		
		if (IsState(RIVIERE_STATE.SEC, _voisin) and (portee < porteeMax))
		{
			SetState(RIVIERE_STATE.REMPLISSAGE, _voisin);
			portee++;
		}
	}
}

function CascadeGetPortee()
{
	return oCascade.portee;
}

function CascadeGetPorteeMax()
{
	return oCascade.porteeMax;
}

