import QtQuick
import Quickshell
import Quickshell.Io
import "audio" as Audio
import "media" as Media

// Volume keys go through the shell so the sidebar shows their feedback.
Scope {
  IpcHandler {
    target: "volume"
    function increase(): void { Audio.State.adjustOutputVolume(0.02); }
    function decrease(): void { Audio.State.adjustOutputVolume(-0.02); }
    function muteOutput(): void { Audio.State.toggleOutputMute(); }
    function muteInput(): void { Audio.State.toggleInputMute(); }
  }
  IpcHandler {
    target: "media"
    function playPause(): void { Media.State.shortcut("playPause"); }
    function next(): void { Media.State.shortcut("next"); }
    function previous(): void { Media.State.shortcut("previous"); }
  }
}
