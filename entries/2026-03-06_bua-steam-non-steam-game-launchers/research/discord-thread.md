# Discord Thread — Non-Steam Games in ES

Source: Discord conversation (2026-03-06). Participants: net_terminal_gene, Ophelia (NeverAnswers).

## Thread

**net_terminal_gene:**
> If not that's fine I'm glad it's working at all, I just like being able to see all my games in the collection instead of having them locked behind big picture mode

**Ophelia (NeverAnswers):**
> I think you can create a .steam file for your game in the /userdata/roms/steam folder, but for that you will have to figure how to launch it from the command line
> But I never tried. Might give a look at it later. This issue made me curious 😅

**net_terminal_gene:**
> Lmk if you figure anything out

**Ophelia (NeverAnswers):**
> Idk if this helps but I installed a game through steam to see what it looks like. Bua doesn't make a .steam file, it makes a .sh and a .sh.keys for the game

**net_terminal_gene:**
> Yeah, it might work too. Do you mind showing me what this .sh looks like?

**Ophelia (NeverAnswers):**
> ```
> #!/bin/bash
> export RIM_ALLOW_ROOT=1
> export HOME=/userdata/system/add-ons/steam
> ulimit -H -n 819200 && ulimit -S -n 819200
> #------------------------------------------------
> # Steam Game Launcher
> ```
> 504230_Celeste.sh (1 KB)

**net_terminal_gene:**
> im guessing no since it uses the appid
> which unless im confused a non-steam game wont have

**Ophelia (NeverAnswers):**
> Yeah, it will be trickier than a standard steam game. Well, I'm taking a better look on this later. Will return with news (good or bad 😬)

**net_terminal_gene:**
> Tysm :3

**net_terminal_gene:**
> Can you explain the steps on how to install a non-Steam title? I'll try something on my end. Is this like taking an existing windows game and adding it to Steam?

**Ophelia (NeverAnswers):**
> 1: pick a game you want to play that runs well under proton (https://www.protondb.com/ helps with this)
> 2: download the game, if it's in an archive extract it. It doesn't matter where you put the folder, as long as you know where the .exe file is
> 3: open steam, exit big picture mode if you're in it.
> 4: bottom left of screen has a button to add games, click it then select the browse option.
> 5: at the top of the menu it opens there's a drop down, select the option containing your game folder then locate and select the .exe
> 6: enter big picture mode (the next step doesn't work otherwise)
> 7: go to your library and find the game you just added, open it's properties and pick a proton version to use for it's compatibility options
>
> At this point you should be able to play the game as if it was any other steam game

**net_terminal_gene:**
> Forgot to reply, was in response to this

**Ophelia (NeverAnswers):**
> Lmk if you need anything else

**net_terminal_gene:**
> Thank you. And what you are trying to do is have it as an option in the Steam Games list in ES?

**Ophelia (NeverAnswers):**
> Yeah

## Key Takeaways

1. BUA generates `.sh` (not `.steam`) launchers plus `.sh.keys` metadata files
2. The launcher template includes `RIM_ALLOW_ROOT=1`, `HOME=/userdata/system/add-ons/steam`, and `ulimit` settings
3. Non-Steam games are added through Steam's desktop mode UI, then Proton is configured in Big Picture Mode
4. The user correctly identified that non-Steam games lack a real App ID, which is the core blocker
5. Ophelia committed to investigating a solution
