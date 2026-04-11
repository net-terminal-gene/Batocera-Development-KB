# Add Non-Steam Games — Target UX Flow

**Cancel = exit to ES at every step. OK = proceed.**

## Step 1: Open App

User launches Add Non-Steam Games from ES > Steam.

## Step 2: Initial Screen

- **Cancel** button available immediately.
- **No OK button yet.**
- Cancel → exit back to ES anytime.

## Step 3: Scan Results

- App scans `non-steam-games/` and lists all directories with potential `.exe` files.
- **OK button appears here** to move forward.
- Cancel → exit to ES.
- OK → proceed to exe picker flow.

## Step 4: Exe Picker (per directory)

- For **each** directory, show which `.exe` file to use.
- **Even if only 1 exe in the folder, show the choice.**
- Cancel & OK buttons.
- Cancel → exit to ES.
- OK → proceed to next directory (or to final confirmation if last directory).
- Repeat for each directory.

## Step 5: Final Confirmation

- "Are you sure you want to add the games to your ES Steam library?"
- Cancel → exit to ES.
- OK → add games to gamelist, update ES, **automatically return to ES**.

---

## Implementation Requirement

**Cancel and OK must work at every step.** The current yad + evmapy approach fails because ES keeps X11 focus and controller keys never reach the dialogs. A Pygame-based UI (like BUA) that reads controller input directly would satisfy this requirement.
