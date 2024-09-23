Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Windows.Forms;
public class TrayIcon : Form {
    private NotifyIcon _trayIcon;
    private ContextMenuStrip _trayMenu;
    public TrayIcon() {
        _trayMenu = new ContextMenuStrip();
        _trayMenu.Items.Add("Open Settings", null, OpenSettings);
        _trayMenu.Items.Add("Exit", null, Exit);
        _trayIcon = new NotifyIcon();
        _trayIcon.Text = "Neko Settings";
        _trayIcon.Icon = SystemIcons.Application;
        _trayIcon.ContextMenuStrip = _trayMenu;
        _trayIcon.Visible = true;
    }
    private void OpenSettings(object sender, EventArgs e) {
        // Launch your settings form
        System.Diagnostics.Process.Start("powershell.exe", "-File 'C:\\path\\to\\your\\settings-form.ps1'");
    }
    private void Exit(object sender, EventArgs e) {
        _trayIcon.Visible = false;
        Application.Exit();
    }
}
"@
[TrayIcon]::new()
[System.Windows.Forms.Application]::Run()
