# Chrome Remote Desktop for NixOS:

## ** FOR KDE PLASMA/X11 ONLY **

Gnome/X11 is not tested but should be possible by replacing `startplasma-11` in `package.nix` with an appropriate command.
Wayland is not supported because you have to log out local Wayland session in order to connect remotely, or else you get only a black screen.

## Security Warning

Quoted from https://github.com/BromTeque/Google_Chrome_Remote_Desktop_Persisten
Ubuntu supports multiple display sessions, and Chrome Remote Desktop will (by default) leverage this feature. That means you can be connected on the machine itself, and have several applications open; when you connect over remote desktop, it will start a new session (without your existing state). Conversely, if you start doing something remotely, then try to finish it up on the machine locally, all the apps you had open won't appear on the local display. As well as being a bit annoying, this can cause all sorts of nasty bugs (e.g the most recent state in one session clobbering the other during shutdown; launching applications in one session and they actually appear in the other... it's a real mess). Follow these steps to override the "smart" functionality, and just have a single session that's shared between local and remote access.

_There are probably some very clever reasons to run it the default way, and changing it like this is less secure - for example, if you unlock the machine remotely over RDP, the machine unlocks on the local session too - someone with physical access could see your mouse moving around, watch what you were typing or even take over with a keyboard / mouse. ..._

## Installation Guide

1. Modify `configuration.nix`

```nix
    imports = [
        # existing imports
        ...

        ./<your-path>/chrome-remote-desktop.nix
    ];

    nixpkgs.overlays = [
        # existing overlays
        ...

        (_final: prev: {
            chrome-remote-desktop = prev.callPackage ./<your-path>/package.nix {};
        })
    ];

    service.chrome-remote-desktop = {
        enable = true;
        user = "<your-user-name>";
    };
```

2. Run `nixos-rebuild switch`

3. Make a symlink to `/opt/google/chrome-remote-desktop`

```
    sudo rm -f /opt/google/chrome-remote-desktop; sudo ln -s /$(echo $(readlink $(readlink /etc/chromium/NativeMessagingHosts/com.google.chrome.remote_desktop.json)) | cut -d/ -f 2,3,4)/opt/google/chrome-remote-desktop /opt/google/chrome-remote-desktop

```

4. Open Chromium/Google Chrome, log in your google account, and install Chrome Remote Desktop extention from https://chromewebstore.google.com/detail/chrome-remote-desktop/inomeogfingihgjfjlpeplalcfajhgai

5. Navigate to https://remotedesktop.google.com/access, scroll down to the bottom and click "Turn on" set up remote access on this device.

6. Name your host, set up a secret pin.

7. Confirm that you have a file `host#<hash>.json` in `~/.config/chrome-remote-desktop/`

8. Restart chrome-remote-desktop service.

```
    sudo systemctl restart chrome-remote-desktop@<your-user-name>.service
```

9. Refresh https://remotedesktop.google.com/access, your host should be shown as "Online".

## Troubleshooting Guide

`journalctl -b -u chrome-remote-desktop@<your-user-name>` gives useful information most of the time. Additional hints may be obtained by running Chromium/Google Chrome from command line to see error messages.
