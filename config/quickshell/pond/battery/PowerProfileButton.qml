import QtQuick
import Quickshell.Services.UPower
import ".." as Shell

Shell.IconButton {
  id: root
  required property var modelData

  readonly property bool selected: PowerProfiles.profile === modelData.profile
  readonly property bool available: modelData.profile !== PowerProfile.Performance
      || PowerProfiles.hasPerformanceProfile
  readonly property bool highlighted: enabled && (hovered || activeFocus)

  enabled: available
  activeFocusOnTab: true
  accessibleName: modelData.name
  iconWidth: 20
  iconHeight: 20
  animateGlyphOpacity: false

  Accessible.role: Accessible.RadioButton
  Accessible.name: accessibleName
  Accessible.checkable: true
  Accessible.checked: selected
  Accessible.onPressAction: choose()

  onClicked: choose()
  Keys.onSpacePressed: choose()
  Keys.onReturnPressed: choose()
  Keys.onEnterPressed: choose()

  function choose() {
    if (available)
      PowerProfiles.profile = modelData.profile;
  }
}
