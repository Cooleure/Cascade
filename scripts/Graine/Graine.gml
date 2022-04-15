#macro NB_GRAINE 4

enum GRAINE_STATE
{
	VIDE,
	POUSSE,
	MATURITE,
	COUPE
};

enum TYPE_GRAINE
{
	CAROTTE,
	POIREAU,
	COURGE,
	CANABIS
};

function GraineInit()
{
	SetState(GRAINE_STATE.VIDE);
	stateMachine[0] = GraineStateVide;
	stateMachine[1] = GraineStatePousse;
	stateMachine[2] = GraineStateMaturite;
	stateMachine[3] = GraineStateCoupe;
	
	var _idTerreau = irandom(2)
	
	switch (_idTerreau)
	{
		case 0: sprite_index = sGraineTerreau1; break;
		case 1: sprite_index = sGraineTerreau2; break;
		case 2: sprite_index = sGraineTerreau3; break;
	}
}

function GraineUpdate()
{
	script_execute(stateMachine[state]);
}


function GraineStateVide()
{
	var _idGraine = irandom(NB_GRAINE - 1);
	
	switch (_idGraine)
	{
		case TYPE_GRAINE.CAROTTE:
			spritePousse = sGraineCarottePousse;
			spriteMaturite = sGraineCarottePret;
			duree = 3;
			scoring = 10;
			break;
			
		case TYPE_GRAINE.POIREAU:
			spritePousse = sGrainePoireauPousse;
			spriteMaturite = sGrainePoireauPret;
			duree = 5;
			scoring = 20;
			break;
			
		case TYPE_GRAINE.COURGE:
			spritePousse = sGraineCourge1;
			spriteMaturite = sGraineCourge2;
			duree = 7;
			scoring = 30;
			break;
			
		case TYPE_GRAINE.CANABIS:
			spritePousse = sGraineCanabis1;
			spriteMaturite = sGraineCanabis2;
			duree = 10;
			scoring = -100;
			break;
	}
	
	timer = 0;
	
	sprite = sVide;

	SetState(GRAINE_STATE.POUSSE);
}

function GraineStatePousse()
{
	var _voisins = GridGetVoisins(x, y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin == GRID.AUCUN) continue;
		
		if ((_voisin.object_index == oRiviere) and IsState(RIVIERE_STATE.REMPLI, _voisin))
		{
			timer++;
			break;
		}
	}
	
	if (timer > (duree * room_speed) div 2)
	{
		sprite = spritePousse;
	}
	else
	{
		sprite = sVide;
	}
	
	if (timer >= duree * room_speed)
	{
		SetState(GRAINE_STATE.MATURITE);
	}
}

function GraineStateMaturite()
{
	sprite = spriteMaturite;
}

function GraineStateCoupe()
{
	
}

function GraineDraw()
{
	draw_self();
	
	if (!IsState(GRAINE_STATE.COUPE))
	{
		draw_sprite(sprite, 0, x, y);
	}
}

function GraineMouseLeftPressed()
{
	if (IsState(GRAINE_STATE.POUSSE))
	{
		SetState(GRAINE_STATE.COUPE);
		alarm[0] = 10 * room_speed;
		audio_play_sound(sndCoupe, 10, false);
	}
	else if (IsState(GRAINE_STATE.MATURITE))
	{		
		oControl.scoring += scoring;
		oControl.scoring = clamp(oControl.scoring, 0, infinity);
		SetState(GRAINE_STATE.COUPE);
		alarm[0] = 10 * room_speed;
		audio_play_sound(sndCoupe, 10, false);
	}
}
