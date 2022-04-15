enum ECLUSE_STATE
{
	FERME,
	OUVERT_SEC,
	OUVERT_REMPLISSAGE,
	OUVERT_REMPLI,
	OUVERT_VIDAGE
};

function EcluseInit()
{
	SetState(ECLUSE_STATE.FERME);
	stateMachine[0] = EcluseStateFerme;
	stateMachine[1] = EcluseStateOuvertSec;
	stateMachine[2] = EcluseStateOuvertRemplissage;
	stateMachine[3] = EcluseStateOuvertRempli;
	stateMachine[4] = EcluseStateOuvertVidage;
	
	sens = 0;
}

function EcluseUpdate()
{
	script_execute(stateMachine[state]);
}

function EcluseStateFerme()
{
	sprite_index = sEcluse;
}

function EcluseStateOuvertSec()
{
	sprite_index = sRiviereSec;
}

function EcluseStateOuvertRemplissage()
{
	sprite_index = sRiviereRemplissage;
}

function EcluseStateOuvertRempli()
{
	sprite_index = sRiviereRempli;
	
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
	}
}

function EcluseStateOuvertVidage()
{
	sprite_index = sRiviereVidage;
}

function EcluseMouseLeftPressed()
{
	if (IsState(ECLUSE_STATE.FERME))
	{
		SetState(ECLUSE_STATE.OUVERT_SEC);
	}
	else
	{
		SetState(ECLUSE_STATE.FERME);
	}
}

