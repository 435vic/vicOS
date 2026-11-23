import QtQuick
import Quickshell
import Quickshell.Services.Pam

// vicOS declares security.pam.services.pond-lock (password-only) and, when
// fprintd is enabled, pond-lock-fprint (fingerprint-only) so both can run in
// parallel without blocking each other.
AuthSession {
    id: root

    property string pamConfig: Quickshell.env("POND_PAM_SERVICE") || "pond-lock"
    property string fprintPamConfig: Quickshell.env("POND_FPRINT_PAM_SERVICE") || ""

    property double _fprintStartedAt: 0
    property int _fprintRapidFailures: 0

    backend: nativePam
    successResult: PamResult.Success
    failedResult: PamResult.Failed
    maxTriesResult: PamResult.MaxTries
    pamReady: true

    function startFingerprint() {
        if (!pamReady || fprintPamConfig.length === 0 || fprintPam.active)
            return;
        _fprintStartedAt = Date.now();
        if (!fprintPam.start()) {
            _fprintRapidFailures += 1;
            if (_fprintRapidFailures < 3)
                fprintRetryTimer.restart();
        }
    }

    function stopFingerprint() {
        fprintRetryTimer.stop();
        if (fprintPam.active)
            fprintPam.abort();
    }

    onPamReadyChanged: {
        if (!pamReady)
            stopFingerprint();
    }
    onSucceeded: stopFingerprint()
    Component.onCompleted: startFingerprint()
    Component.onDestruction: stopFingerprint()

    PamContext {
        id: nativePam
        configDirectory: "/etc/pam.d"
        config: root.pamConfig
        // An empty user makes PamContext resolve getuid() itself. Avoid trusting
        // a mutable environment variable for the authentication identity.
        user: ""
    }

    PamContext {
        id: fprintPam
        configDirectory: "/etc/pam.d"
        config: root.fprintPamConfig
        user: ""

        onPamMessage: {
            if (fprintPam.responseRequired && fprintPam.active)
                fprintPam.abort();
        }

        onCompleted: result => {
            if (!root.pamReady)
                return;

            if (result === PamResult.Success) {
                root.stopFingerprint();
                root.reset();
                root.succeeded();
                return;
            }

            const elapsed = Date.now() - root._fprintStartedAt;
            if (elapsed < 1000)
                root._fprintRapidFailures += 1;
            else
                root._fprintRapidFailures = 0;

            if (root._fprintRapidFailures < 3)
                fprintRetryTimer.restart();
        }
    }

    Timer {
        id: fprintRetryTimer
        interval: 1500
        onTriggered: root.startFingerprint()
    }
}
