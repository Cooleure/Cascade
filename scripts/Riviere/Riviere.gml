enum RIVIERE_STATE
{
	SEC,
	REMPLISSAGE,
	REMPLI,
	VIDAGE
};

enum RIVIERE_TYPE
{
	// NON CROISEMENTS
	VERTICAL,
	HORIZONTAL,
	BOUT_BAS,
	BOUT_HAUT,
	BOUT_DROITE,
	BOUT_GAUCHE,
	ANGLE_BAS_DROITE,
	ANGLE_BAS_GAUCHE,
	ANGLE_HAUT_DROITE,
	ANGLE_HAUT_GAUCHE,
	// CROISEMENTS
	T_BAS,
	T_HAUT,
	T_DROITE,
	T_GAUCHE,
	CROISEMENT
}



/// State Machine
function RiviereInit()
{
	SetState(RIVIERE_STATE.SEC);
	stateMachine[0] = RiviereStateSec;
	stateMachine[1] = RiviereStateRemplissage;
	stateMachine[2] = RiviereStateRempli;
	stateMachine[3] = RiviereStateVidage;
	
	RiviereTypeInit();
	RiviereSpriteInit();
	ecluse = undefined; // Si liée à une écluse
}

function RiviereUpdate()
{
	script_execute(stateMachine[state]);
}

function RiviereStateSec()
{
	sprite_index = spriteSec;
}

function RiviereStateRemplissage()
{
	sprite_index = SpriteChooseRemplissage();
}

function RiviereStateRempli()
{
	sprite_index = spriteRempli;
	
	// Remplissage des rivières suivantes
	var _voisins = GridGetVoisins(x, y);
	
	// Si l'écluse est fermée, on ne traite pas la rivière jumelle (celle derrière l'écluse)
	RiviereVoisinClearTwin(_voisins, id);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];

		if (_voisin.object_index != oRiviere) continue;

		if (IsState(RIVIERE_STATE.SEC, _voisin) and (CascadeGetPortee() < CascadeGetPorteeMax()))
		{
			SetState(RIVIERE_STATE.REMPLISSAGE, _voisin);
			oCascade.portee++;
			_voisin.image_index = 0;
		}
	}
}

function RiviereStateVidage()
{
	sprite_index = spriteVidage;
}



/// Events
function RiviereAnimationEnd()
{
	image_index = 0;

	if (IsState(RIVIERE_STATE.REMPLISSAGE))
	{
		SetState(RIVIERE_STATE.REMPLI);
	}
	if (IsState(RIVIERE_STATE.VIDAGE))
	{
		SetState(RIVIERE_STATE.SEC);
	}
}

function RiviereDraw()
{
	draw_self();
	draw_text(x + 10, y + 10, id);
}

/// Internal
function RiviereVoisinClearTwin(_voisins, _riviere)
{
	// On considère la rivière "jumelle" (celle de l'autre côté de l'écluse) comme un oNull
	for (var _i = 0; _i < 4; _i++)
	{
		if (_voisins[_i].object_index != oRiviere)			continue;
		if (_voisins[_i].ecluse == undefined)				continue;
		if (IsState(ECLUSE_STATE.OUVERT, _riviere.ecluse))	continue;
		if (_voisins[_i].ecluse != _riviere.ecluse)			continue;
		
		_voisins[_i] = GetNull();
	}
}

function RiviereTypeInit()
{
	var _voisins = GridGetVoisins(x, y);
	
	var _bas	= _voisins[VOISIN_BAS].object_index;
	var _haut	= _voisins[VOISIN_HAUT].object_index;
	var _droite	= _voisins[VOISIN_DROITE].object_index;
	var _gauche	= _voisins[VOISIN_GAUCHE].object_index;
	
	if ((_bas == oRiviere) and (_haut == oRiviere) and (_droite != oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.VERTICAL;
	}
	else if ((_bas != oRiviere) and (_haut != oRiviere) and (_droite == oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.HORIZONTAL;
	}
	else if ((_bas != oRiviere) and (_haut == oRiviere) and (_droite != oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.BOUT_BAS;
	}
	else if ((_bas == oRiviere) and (_haut != oRiviere) and (_droite != oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.BOUT_HAUT;
	}
	else if ((_bas != oRiviere) and (_haut != oRiviere) and (_droite != oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.BOUT_DROITE;
	}
	else if ((_bas != oRiviere) and (_haut != oRiviere) and (_droite == oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.BOUT_GAUCHE;
	}
	else if ((_bas != oRiviere) and (_haut == oRiviere) and (_droite != oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.ANGLE_BAS_DROITE;
	}
	else if ((_bas != oRiviere) and (_haut == oRiviere) and (_droite == oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.ANGLE_BAS_GAUCHE;
	}
	else if ((_bas == oRiviere) and (_haut != oRiviere) and (_droite != oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.ANGLE_HAUT_DROITE;
	}
	else if ((_bas == oRiviere) and (_haut != oRiviere) and (_droite == oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.ANGLE_HAUT_GAUCHE;
	}
	else if ((_bas != oRiviere) and (_haut == oRiviere) and (_droite == oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.T_BAS;
	}
	else if ((_bas == oRiviere) and (_haut != oRiviere) and (_droite == oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.T_HAUT;
	}
	else if ((_bas == oRiviere) and (_haut == oRiviere) and (_droite != oRiviere) and (_gauche == oRiviere))
	{
		riviereType = RIVIERE_TYPE.T_DROITE;
	}
	else if ((_bas == oRiviere) and (_haut == oRiviere) and (_droite == oRiviere) and (_gauche != oRiviere))
	{
		riviereType = RIVIERE_TYPE.T_GAUCHE;
	}
	else
	{
		riviereType = RIVIERE_TYPE.CROISEMENT;
	}
}

function RiviereSpriteInit()
{
	spriteSec = sVide;
	spriteVidage = sRiviereSeche;
	
	switch (riviereType)
	{
		case RIVIERE_TYPE.VERTICAL:				spriteRempli = sRiviereCalmeLigneVerticale;		break;
		case RIVIERE_TYPE.HORIZONTAL:			spriteRempli = sRiviereCalmeLigneHorizontale;	break;
		case RIVIERE_TYPE.BOUT_BAS:				spriteRempli = sRiviereCalmeBoutBas;			break;
		case RIVIERE_TYPE.BOUT_HAUT:			spriteRempli = sRiviereCalmeBoutHaut;			break;
		case RIVIERE_TYPE.BOUT_DROITE:			spriteRempli = sRiviereCalmeBoutDroite;			break;
		case RIVIERE_TYPE.BOUT_GAUCHE:			spriteRempli = sRiviereCalmeBoutGauche;			break;
		case RIVIERE_TYPE.ANGLE_BAS_DROITE:		spriteRempli = sRiviereCalmeAngleBasDroite;		break;
		case RIVIERE_TYPE.ANGLE_BAS_GAUCHE:		spriteRempli = sRiviereCalmeAngleBasGauche;		break;
		case RIVIERE_TYPE.ANGLE_HAUT_DROITE:	spriteRempli = sRiviereCalmeAngleHautDroite;	break;
		case RIVIERE_TYPE.ANGLE_HAUT_GAUCHE:	spriteRempli = sRiviereCalmeAngleHautGauche;	break;
		case RIVIERE_TYPE.T_BAS:				spriteRempli = sRiviereCalmeTBas;				break;
		case RIVIERE_TYPE.T_HAUT:				spriteRempli = sRiviereCalmeTHaut;				break;
		case RIVIERE_TYPE.T_DROITE:				spriteRempli = sRiviereCalmeTDroite;			break;
		case RIVIERE_TYPE.T_GAUCHE:				spriteRempli = sRiviereCalmeTGauche;			break;
		case RIVIERE_TYPE.CROISEMENT:			spriteRempli = sRiviereCalmeCroisement;			break;
	}
}

function SpriteChooseRemplissage()
{
	var _voisins = GridGetVoisins(x, y);
	
	var _bas	= _voisins[VOISIN_BAS];
	var _haut	= _voisins[VOISIN_HAUT];
	var _droite	= _voisins[VOISIN_DROITE];
	
	switch (riviereType)
	{
		case RIVIERE_TYPE.VERTICAL:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))	return sRiviereCourantLigneVerticaleVersHaut;
			else										return sRiviereCourantLigneVerticaleVersBas;
			
		case RIVIERE_TYPE.HORIZONTAL:
			if (IsState(RIVIERE_STATE.REMPLI, _droite))	return sRiviereCourantLigneHorizontaleVersGauche;
			else										return sRiviereCourantLigneHorizontaleVersDroite;
			
		case RIVIERE_TYPE.BOUT_BAS:
			return sRiviereCourantLigneVerticaleVersBas;
			
		case RIVIERE_TYPE.BOUT_HAUT:
			return sRiviereCourantLigneVerticaleVersHaut;
			
		case RIVIERE_TYPE.BOUT_DROITE:
			return sRiviereCourantLigneHorizontaleVersDroite;
			
		case RIVIERE_TYPE.BOUT_GAUCHE:
			return sRiviereCourantLigneHorizontaleVersGauche;
			
		case RIVIERE_TYPE.ANGLE_BAS_DROITE:
			if (IsState(RIVIERE_STATE.REMPLI, _haut))	return sRiviereCourantAngleBasDroiteVersGauche;
			else										return sRiviereCourantAngleBasDroiteVersHaut;
			
		case RIVIERE_TYPE.ANGLE_BAS_GAUCHE:
			if (IsState(RIVIERE_STATE.REMPLI, _haut))	return sRiviereCourantAngleBasGaucheVersDroite;
			else										return sRiviereCourantAngleBasGaucheVersHaut;
			
		case RIVIERE_TYPE.ANGLE_HAUT_DROITE:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))	return sRiviereCourantAngleHautDroiteVersGauche;
			else										return sRiviereCourantAngleHautDroiteVersBas;
			
		case RIVIERE_TYPE.ANGLE_HAUT_GAUCHE:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))	return sRiviereCourantAngleHautGaucheVersDroite;
			else										return sRiviereCourantAngleHautGaucheVersBas;
			
		case RIVIERE_TYPE.T_BAS:
			if (IsState(RIVIERE_STATE.REMPLI, _haut))			return sRiviereCourantCroisementVersBas;
			else if (IsState(RIVIERE_STATE.REMPLI, _droite))	return sRiviereCourantTBasVersHautGauche;
			else												return sRiviereCourantTBasVersHautDroite;
			
		case RIVIERE_TYPE.T_HAUT:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))			return sRiviereCourantCroisementVersHaut;
			else if (IsState(RIVIERE_STATE.REMPLI, _droite))	return sRiviereCourantTHautVersBasGauche;
			else												return sRiviereCourantTHautVersBasDroite;
			
		case RIVIERE_TYPE.T_DROITE:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))			return sRiviereCourantTDroiteVersHautGauche;
			else if (IsState(RIVIERE_STATE.REMPLI, _haut))		return sRiviereCourantTDroiteVersBasGauche;
			else												return sRiviereCourantCroisementVersGauche;
			
		case RIVIERE_TYPE.T_GAUCHE:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))			return sRiviereCourantTGaucheVersHautDroite;
			else if (IsState(RIVIERE_STATE.REMPLI, _haut))		return sRiviereCourantTGaucheVersBasDroite;
			else												return sRiviereCourantCroisementVersDroite;
			
		case RIVIERE_TYPE.CROISEMENT:
			if (IsState(RIVIERE_STATE.REMPLI, _bas))			return sRiviereCourantCroisementVersHaut;
			else if (IsState(RIVIERE_STATE.REMPLI, _haut))		return sRiviereCourantCroisementVersBas;
			else if (IsState(RIVIERE_STATE.REMPLI, _droite))	return sRiviereCourantCroisementVersGauche;
			else												return sRiviereCourantCroisementVersDroite;
	}
}


