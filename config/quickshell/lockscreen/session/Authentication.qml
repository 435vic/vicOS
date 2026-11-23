import QtQuick
import Quickshell
import Quickshell.Services.Pam

// vicOS declares security.pam.services.pond-lock for this lock.
AuthSession {
    id: root

    property string pamConfig: Quickshell.env("POND_PAM_SERVICE") || "pond-lock"

    backend: nativePam
    successResult: PamResult.Success
    failedResult: PamResult.Failed
    maxTriesResult: PamResult.MaxTries
    pamReady: true

    PamContext {
        id: nativePam
        configDirectory: "/etc/pam.d"
        config: root.pamConfig
        // An empty user makes PamContext resolve getuid() itself. Avoid trusting
        // a mutable environment variable for the authentication identity.
        user: ""
    }
}
