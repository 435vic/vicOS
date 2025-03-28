## Sync

1. Is `--edit` flag set?
    - yes: spawn $EDITOR, wait until exit
    - no: ?
2. check git status, store result. dirty?
    - yes: goto 3
    - no: goto 6
3. is `--[PH]quick` flag set?
    - yes: goto 4
    - no: exit, send message: "working tree is dirty."
4. does git status contain untracked files?
    - yes: prompt for confirmation to add files
    - no: continue
5. run `git commit -m "dude sync"` TODO: define good placeholder name
6. tag HEAD as current sync target
7. run `git switch generations/$(hostname)`
8. run `git merge [sync target tag] --no-ff --no-edit`
9. run `nixos-rebuild-ng switch --impure --flake git+file:$DOTFILES_HOME?submodules=1`
10. successful?
    - yes: ?
    - no: store log, show error, goto 11
11. cleanup: run `git reset --hard HEAD^`
12. cleanup: run `git switch [branch of sync target tag]`
13. IF commit was from dude sync (step 5): cleanup: run `git reset --soft [sync target tag]^`
14. exit
15. tag commit as deployed
16. move back to start branch
17. exit
