# Define the path to the neko executable
$nekoPath = "C:\Users\there\OneDrive\Documents\Oneko-Windows\Oneko\neko.exe"

# Create a function to run the program
function Run-Neko {
    $arguments = "-scale $global:scale -speed $global:speed"
    if ($global:quiet) { $arguments += " -quiet" }
    if ($global:mousePassthrough) { $arguments += " -mousepassthrough" }
    
    Start-Process -FilePath $nekoPath -ArgumentList $arguments -NoNewWindow
}

# Create a function to end the program
function End-Neko {
    Stop-Process -Name "neko" -Force
}

# Variables for settings
$global:scale = 2.0
$global:speed = 2
$global:quiet = $true
$global:mousePassthrough = $false

# Load the WinForms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form (UI)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Neko Settings"
$form.Size = New-Object System.Drawing.Size(330, 250)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.MinimizeBox = $true
$form.ShowInTaskbar = $false

# Set the icon for the form window
$form.Icon = "C:\Users\there\OneDrive\Documents\Oneko-Windows\Oneko\assets\main icon.ico"

# Add system tray icon
$iconPath = "C:\Users\there\OneDrive\Documents\Oneko-Windows\Oneko\assets\main icon.ico"
$tooltip = "Neko Settings"

$trayIcon = [System.Windows.Forms.NotifyIcon]::new()
$trayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
$trayIcon.Text = $tooltip
$trayIcon.Visible = $true

$contextMenu = [System.Windows.Forms.ContextMenuStrip]::new()

# Show UI menu item
$showMenuItem = [System.Windows.Forms.ToolStripMenuItem]::new("Show UI")
$showMenuItem.add_Click({
    $form.Show()
    $form.WindowState = 'Normal'
    $form.Activate()
})
$contextMenu.Items.Add($showMenuItem)

# Exit menu item
$exitMenuItem = [System.Windows.Forms.ToolStripMenuItem]::new("Exit")
$exitMenuItem.add_Click({
    End-Neko
    $trayIcon.Visible = $false
    $form.Close()
})
$contextMenu.Items.Add($exitMenuItem)

$trayIcon.ContextMenuStrip = $contextMenu

# Handle double-click on tray icon to show UI
$trayIcon.add_MouseDoubleClick({
    $form.Show()
    $form.WindowState = 'Normal'
    $form.Activate()
})

# Scale Slider and Value Label
$scaleLabel = New-Object System.Windows.Forms.Label
$scaleLabel.Text = "Scale:"
$scaleLabel.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($scaleLabel)

$scaleSlider = New-Object System.Windows.Forms.TrackBar
$scaleSlider.Minimum = 0
$scaleSlider.Maximum = 10
$scaleSlider.Value = [math]::Round($global:scale)
$scaleSlider.TickFrequency = 1
$scaleSlider.Location = New-Object System.Drawing.Point(60, 10)
$scaleSlider.Size = New-Object System.Drawing.Size(200, 50)
$form.Controls.Add($scaleSlider)

$scaleValueLabel = New-Object System.Windows.Forms.Label
$scaleValueLabel.Text = $scaleSlider.Value
$scaleValueLabel.Location = New-Object System.Drawing.Point(270, 10)
$form.Controls.Add($scaleValueLabel)

# Tooltip for scale slider
$tooltip = New-Object System.Windows.Forms.ToolTip
$scaleSlider.Add_MouseMove({
    $tooltip.SetToolTip($scaleSlider, "Scale: $($scaleSlider.Value)")
})

# Update the scale value label dynamically
$scaleSlider.Add_ValueChanged({
    $scaleValueLabel.Text = $scaleSlider.Value
})

# Speed Slider and Value Label
$speedLabel = New-Object System.Windows.Forms.Label
$speedLabel.Text = "Speed:"
$speedLabel.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($speedLabel)

$speedSlider = New-Object System.Windows.Forms.TrackBar
$speedSlider.Minimum = 0
$speedSlider.Maximum = 10
$speedSlider.Value = $global:speed
$speedSlider.TickFrequency = 1
$speedSlider.Location = New-Object System.Drawing.Point(60, 60)
$speedSlider.Size = New-Object System.Drawing.Size(200, 50)
$form.Controls.Add($speedSlider)

$speedValueLabel = New-Object System.Windows.Forms.Label
$speedValueLabel.Text = $speedSlider.Value
$speedValueLabel.Location = New-Object System.Drawing.Point(270, 60)
$form.Controls.Add($speedValueLabel)

# Tooltip for speed slider
$speedTooltip = New-Object System.Windows.Forms.ToolTip
$speedSlider.Add_MouseMove({
    $speedTooltip.SetToolTip($speedSlider, "Speed: $($speedSlider.Value)")
})

# Update the speed value label dynamically
$speedSlider.Add_ValueChanged({
    $speedValueLabel.Text = $speedSlider.Value
})

# Toggle for Quiet Mode
$quietCheckBox = New-Object System.Windows.Forms.CheckBox
$quietCheckBox.Text = "Quiet Mode"
$quietCheckBox.Location = New-Object System.Drawing.Point(10, 110)
$quietCheckBox.Checked = $global:quiet
$form.Controls.Add($quietCheckBox)

# Toggle for Mouse Passthrough
$mousePassthroughCheckBox = New-Object System.Windows.Forms.CheckBox
$mousePassthroughCheckBox.Text = "Mouse Passthrough"
$mousePassthroughCheckBox.Location = New-Object System.Drawing.Point(10, 140)
$mousePassthroughCheckBox.Checked = $global:mousePassthrough
$form.Controls.Add($mousePassthroughCheckBox)

# Buttons for Run and End
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Run Neko"
$runButton.Location = New-Object System.Drawing.Point(10, 180)
$runButton.Add_Click({
    $global:scale = $scaleSlider.Value
    $global:speed = $speedSlider.Value
    $global:quiet = $quietCheckBox.Checked
    $global:mousePassthrough = $mousePassthroughCheckBox.Checked
    Run-Neko
})
$form.Controls.Add($runButton)

$endButton = New-Object System.Windows.Forms.Button
$endButton.Text = "End Neko"
$endButton.Location = New-Object System.Drawing.Point(120, 180)
$endButton.Add_Click({
    End-Neko
})
$form.Controls.Add($endButton)

# Add the "Confirm" button
$confirmButton = New-Object System.Windows.Forms.Button
$confirmButton.Text = "Confirm"
$confirmButton.Location = New-Object System.Drawing.Point(230, 180)
$confirmButton.Enabled = $false
$form.Controls.Add($confirmButton)

# Function to enable the Confirm button when a setting changes
function Enable-ConfirmButton {
    $confirmButton.Enabled = $true
}

# Event handlers for the sliders and checkboxes to enable the Confirm button
$scaleSlider.Add_ValueChanged({ Enable-ConfirmButton })
$speedSlider.Add_ValueChanged({ Enable-ConfirmButton })
$quietCheckBox.Add_CheckedChanged({ Enable-ConfirmButton })
$mousePassthroughCheckBox.Add_CheckedChanged({ Enable-ConfirmButton })

# Confirm button click event to end and re-run Neko
$confirmButton.Add_Click({
    End-Neko
    $global:scale = $scaleSlider.Value
    $global:speed = $speedSlider.Value
    $global:quiet = $quietCheckBox.Checked
    $global:mousePassthrough = $mousePassthroughCheckBox.Checked
    Run-Neko
    $confirmButton.Enabled = $false  # Disable the button again after use
})



# Show the form when the script starts
$form.Show()
$form.WindowState = 'Normal'

# Handle minimize and close events
$form.Add_Resize({
    if ($form.WindowState -eq 'Minimized') {
        $form.Hide()
    }
})

$form.Add_FormClosing({
    if ($_.CloseReason -eq "UserClosing") {
        $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to exit?", "Confirm Exit", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            End-Neko
            $trayIcon.Visible = $false
            $_.Cancel = $false
        } else {
            $_.Cancel = $true
        }
    }
})

# Main loop to keep the script running
try {
    while ($true) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }
}
finally {
    $trayIcon.Dispose()
    Write-Verbose 'Exiting.'
}
