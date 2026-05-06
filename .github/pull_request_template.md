**Summary**
What this PR changes in one or two sentences.

**Why**
The motivating problem or use case.

**Test plan**
- [ ] `pwsh -NoProfile -File profile.ps1` parses without errors
- [ ] `ws`, `cheat`, `rules`, `paths` still produce the expected output
- [ ] `install.ps1 -SkipScoop -SkipPip -SkipNpm` reapplies profile + settings cleanly
