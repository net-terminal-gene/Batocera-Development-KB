# VERDICT — CRT Graphics Settings Guide

## Status: IN PROGRESS

## Summary

Created a universal CRT graphics settings reference for modern PC games running on Batocera via CRT-Script HD Mode. The guide covers CRT physics rationale, universal base settings, complete Cyberpunk 2077 configuration, per-genre quick references, and hardware-specific notes for Philips 20PT6341/37 and Sony KV-9PT40 on AMD BC-250.

## Plan vs reality

Guide was created as designed. Not yet validated on actual hardware.

## Root Causes

N/A — this is a reference document, not a bug fix.

## Changes Applied

| File | Change |
|------|--------|
| `research/CRT-Graphics-Settings-Guide.md` | Main guide: universal settings, Cyberpunk 2077 complete, per-genre, per-engine |
| `research/README.md` | Sources, methodology, key findings |

## Models used

- Composer (claude-4.6-opus-max) for research, web search, CRT-Script codebase analysis, guide authoring

## What worked

- Web search provided solid per-setting performance impact data (SSR ~40%, fog ~12%, etc.)
- CRT-Script codebase verification confirmed HD Mode behavior (auto-detect, 1080p preference)
- CRT Database provided exact hardware specs for both displays

## Outstanding

- [ ] Test settings on actual Batocera system with Cyberpunk 2077
- [ ] Validate FPS estimates against real BC-250 performance
- [ ] Add more per-game sections as games are tested
