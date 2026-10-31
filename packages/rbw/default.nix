{ rbw }:
rbw.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./ssh-no-prompt.patch ];
})
