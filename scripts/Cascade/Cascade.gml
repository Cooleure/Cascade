function CascadeCreate()
{
	SetState(0);
	porteeMax = 20;
	portee = 0;
}

function CascadeStep()
{
	var _voisins = GridGetVoisins(x, y);

	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if ((_voisin.object_index == oRiviere) and IsState(RIVIERE_STATE.SEC, _voisin) and (portee < porteeMax))
		{
			SetState(RIVIERE_STATE.REMPLISSAGE, _voisin);
			portee++;
			_voisin.alarm[0] = 60;
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

