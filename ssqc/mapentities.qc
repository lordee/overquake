// player/team spawn
void () info_player_teamspawn = {
    switch (self.team_no)
    {
        case 1:
            self.team_str = "teamspawnone";
            break;
        case 2:
            self.team_str = "teamspawntwo";
            break;
        default:
            objerror
            ("error: bad team_no associated with info_player_teamspawn\n");
            remove(self);
            return;
    }
}
