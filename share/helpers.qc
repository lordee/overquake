float (float level) GetExpBar = {
    float bar = 0;
    if (level == 1)
        bar = EXP_LEVELTWO;
    else if (level == 2)
        bar = EXP_LEVELTHREE;
    else if (level == 3)
        bar = EXP_LEVELFOUR;
    else if (level == 4)
        bar = EXP_LEVELFIVE;
    else if (level == 5)
        bar = EXP_LEVELSIX;
    else if (level == 6)
        bar = EXP_LEVELSEVEN;
    else if (level == 7)
        bar = EXP_LEVELEIGHT;
    else if (level == 8)
        bar = EXP_LEVELNINE;
    else if (level == 9)
        bar = EXP_LEVELTEN;
    else if (level == 10)
        bar = EXP_LEVELELEVEN;
    else if (level == 11)
        bar = EXP_LEVELTWELVE;
    else if (level == 12)
        bar = EXP_LEVELTHIRTEEN;
    else if (level == 13)
        bar = EXP_LEVELFOURTEEN;
    else if (level == 14)
        bar = EXP_LEVELFIFTEEN;
    else if (level == 15)
        bar = EXP_LEVELSIXTEEN;
    else if (level == 16)
        bar = EXP_LEVELSEVENTEEN;
    else if (level == 17)
        bar = EXP_LEVELEIGHTEEN;

    return bar;
}