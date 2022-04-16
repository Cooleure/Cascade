enum RIVIERE_STATE
{
	SEC,
	REMPLISSAGE,
	REMPLI,
	VIDAGE
};

#macro RIVIERE_REMPLISSAGE_TIME 30
#macro RIVIERE_VIDAGE_TIME 30

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
	sprite_index = sRiviere;
	
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
				_voisin.alarm[0] = RIVIERE_VIDAGE_TIME;
			}
		}
		else if (_voisin.object_index == oEcluse)
		{
			if (IsState(ECLUSE_STATE.OUVERT_SEC, _voisin) and (CascadeGetPortee() < CascadeGetPorteeMax()))
			{
				SetState(ECLUSE_STATE.OUVERT_REMPLISSAGE, _voisin);
				oCascade.portee++;
				_voisin.alarm[0] = RIVIERE_REMPLISSAGE_TIME;
			}
		}
	}
}

function RiviereStateVidage()
{
	sprite_index = sRiviereVidage;
}
