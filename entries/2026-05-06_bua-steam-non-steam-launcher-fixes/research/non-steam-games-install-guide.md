# How to Install Non-Steam Games on Batocera (via BUA Steam Addon)

## Prerequisites

- Batocera v43 or later
- BUA (Batocera Unofficial Add-Ons) installed
- A Windows game with a `.exe` file you want to run via Proton
- (Optional) A free SteamGridDB API key from https://www.steamgriddb.com/profile/preferences/api

## Step 1: Install Steam from BUA

Open **Emulation Station > Steam > Batocera Unofficial Add-Ons Installer** and install the **Steam** addon.

## Step 2: Add Your SteamGridDB Key (Optional, for Artwork)

Place your API key in a file at:

```
/userdata/system/add-ons/steam/steamgriddb.key
```

The file should contain only the key (32 characters, no spaces or newlines). This enables automatic artwork downloads for your non-Steam games.

**Important:** This file must exist before launching Steam. The launcher generator reads it once at startup.

## Step 3: Place Your Game Files

Copy your game folder to:

```
/userdata/system/add-ons/steam/non-steam-games/
```

For example:

```
non-steam-games/
└── My Game Name/
    └── game/
        └── MyGame.exe
```

The folder name is used for artwork lookup, so name it after the game (not something generic like "game").

## Step 4: Launch Steam

Open **Emulation Station > Steam > Steam Big Picture**. Steam will open in Big Picture Mode.

## Step 5: Switch to Desktop Mode

In Big Picture Mode, go to **Power > Exit Big Picture Mode**. This will land you in Steam Desktop Mode.

## Step 6: Install Proton Experimental and Steam Linux Runtime 4.0

Click on **LIBRARY** and use the search bar to find and install both of these (they are free):

1. **Proton Experimental**
2. **Steam Linux Runtime 4.0**

Both are required for non-Steam games to run. They will not auto-install, you must search for them manually.

## Step 7: Add Your Non-Steam Game

In the top menu, go to **Games > Add a Non-Steam Game to My Library...**

1. Click **Browse** (this opens the file manager)
2. Navigate to your game folder and select the `.exe` file
3. Click **OPEN** (bottom right)
4. Click **Add Selected Programs** (bottom right)

This registers the game as a Steam shortcut. When Steam exits, the launcher generator will automatically:
- Create a launcher script in Emulation Station
- Download artwork from SteamGridDB (if key is configured)
- Set up basic controller hotkeys (Hotkey+Start to kill game)

## Step 8: Exit Steam

In the top menu, go to **Steam > Exit**. You will land back in Emulation Station.

## Step 9: Update Gamelists

In Emulation Station, open **MAIN MENU > GAME SETTINGS > UPDATE GAMELISTS**.

## Done

Your game should now be available in **Emulation Station > Steam**. Select it and launch. The game will run via Steam Linux Runtime + Proton Experimental with full audio and controller support.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Game doesn't appear in ES | Did you Update Gamelists? (Step 9) |
| No artwork | Verify `steamgriddb.key` was in place before launching Steam |
| Game fails to launch | Verify both Proton Experimental and Steam Linux Runtime 4.0 are installed |
| No sound | This fix uses SLR which routes audio automatically. If still no sound, check Batocera audio settings |
| Controller not working | SLR provides SDL environment. Verify your controller works in ES first |
| Steam crashes on first launch | This is a known first-launch-only issue with the libcurl fix. Simply relaunch Steam from ES |
