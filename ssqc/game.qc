void () GameThink = {
    entity p;
    p = find(world, classname, "player");
    while (p)
    {
        if (p.deadflag == DEAD_DEAD)
        {
            p.respawntime = p.respawntime - 1;
            if (p.respawntime <= 0)
            {
                oldself = self;
                self = p;
                PutClientInServer();
                self = oldself;
            }
        }

        p = find(p, classname, "player");
    }

    self.cnt2 = self.cnt2 + 1;
    if (self.cnt2 >= 60)
    {
        self.cnt = self.cnt + 1;
        self.cnt2 = 0;
    }

    self.nextthink = time + 1;
}

void () StartGame = {
    bprint(PRINT_HIGH, "GAME IS STARTING\n");
    // respawn champs
    entity p;
    p = find(world, classname, "player");
    while (p)
    {
        oldself = self;
        self = p;
        
        PutClientInServer();
        self = oldself;
        p = find(p, classname, "player");
    }
    // start game timer
    self.cnt2 = 0;
    self.think = GameThink;
    self.nextthink = time + 1;

    rounds = infokey(world, "rounds");
    if (!rounds)
    {
        rounds = 2;
    }

    GameStarted = TRUE;
}

void () LobbyThink = {
    // check all players selected champs
    entity p;
    p = find(world, classname, "player");
    if (p)
    {
        while (p)
        {
            // not everyone has a champ yet
            if (!p.champ_id)
            {
                self.nextthink = time + 1;
                return;
            }
            // not everyone is ready
            if (!p.ready)
            {
                self.nextthink = time + 1;
                return;
            }
            p = find(p, classname, "player");
        }
    }
    else // there are no players
    {
        self.nextthink = time + 1;
        return;
    }
    
    // champs are selected, everyone is /ready
    // countdown start of game
    if (self.cnt2 > 0)
    {
        bprint(PRINT_HIGH, "\s[\s", ftos(self.cnt2), "\s]\s second");
        if (self.cnt2 > 1)
        {
            bprint(PRINT_HIGH, "s");
        }
        bprint(PRINT_HIGH, " remaining\n");

        self.cnt2 = self.cnt2 - 1;
        self.nextthink = time + 1;
        return;
    }
    
    // we got this far, start the game
    StartGame();
}