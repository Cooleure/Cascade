enum RIVIERE_STATE
{
	SEC,
	REMPLISSAGE,
	REMPLI,
	VIDAGE
};

function RiviereInit()
{
	SetState(RIVIERE_STATE.SEC);
	stateMachine[0] = RiviereStateSec;
	stateMachine[1] = RiviereStateRemplissage;
	stateMachine[2] = RiviereStateRempli;
	stateMachine[3] = RiviereStateVidage;
}

function RiviereUpdate()
{
	script_execute(stateMachine[state]);
}


function RiviereStateSec()
{
	sprite_index = sRiviereSec;
}

function RiviereStateRemplissage()
{
	sprite_index = sRiviereRemplissage;
}

function RiviereStateRempli()
{
	sprite_index = sEau2;
	
	var _voisins = GridGetVoisins(x, y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin == GRID.AUCUN) continue;
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.SEC, _voisin) and (CascadeGetPortee() < CascadeGetPorteeMax()))
			{
				SetState(RIVIERE_STATE.REMPLISSAGE, _voisin);
				oCascade.portee++;
				_voisin.alarm[0] = 60;
			}
		}
		else if (_voisin.object_index == oEcluse)
		{
			if (_voisin.sens == 0)
			{
				_voisin.sens = (y > _voisin.y) ? -1 : 1;
			}

			if (IsState(ECLUSE_STATE.OUVERT_SEC, _voisin) and (CascadeGetPortee() < CascadeGetPorteeMax()))
			{
				SetState(ECLUSE_STATE.OUVERT_REMPLISSAGE, _voisin);
				oCascade.portee++;
				_voisin.alarm[0] = 60;
			}
		}
	}
}

function RiviereStateVidage()
{
	sprite_index = sRiviereVidage;
}
