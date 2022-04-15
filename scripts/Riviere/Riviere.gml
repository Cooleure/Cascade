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
	
}

function RiviereStateRemplissage()
{
	
}

function RiviereStateRempli()
{
	
}

function RiviereStateVidage()
{
	
}
