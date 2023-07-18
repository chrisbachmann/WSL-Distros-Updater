# Some of our users have the need for WSL to develop scripts and process data.
# However, the tech execs want to make sure that they are updated on a regular basis and alert us when it fails.
# I started off with a smpe script, but it made some assumptions about the distro and that there was only one.
# This is an attempt at making a more robust script that addresses those failings.

#Make sure we use UTF-8 so we can properly parse the output from WSL
$env:WSL_UTF8=1

$reportEmailAddress = "<your email address here"

# Run wsl --list and store its output in an array
$wslList = (wsl --list)
#echo $wsllist

# Define a set of strings to search for
$strings = @("Ubuntu", "Debian", "Fedora", "Kali")
#echo $strings

# Create an empty array to store the matching lines
$matchingLines = @()

# Loop through the strings in $strings
foreach ($string in $strings) {
    # Filter the lines in $wslList that match the string and add them to $matchingLines
    $matchingLines += $wslList | where-object {$_ -match $string}
    # Getting the first word of that output to make sure we strip out the (Default) string from the default distro
    # I'll probably make this a bit smarter later, but for now I'll keep the first word assumption.
    $matchingLinesFirstWord = ($matchingLines -split ' ')[0]
}

# Loop through the elements in $matchingLines and echo them
foreach ($line in $matchingLines) {
    if ($matchingLinesFirstWord -match "^(Ubuntu|Debian|Kali)") {
        # Let's make sure we have the latest softwre catalog
        wsl --distribution $matchingLinesFirstWord -u root -e apt update
        # Do the update
        wsl --distribution $matchingLinesFirstWord -u root -e apt upgrade -y
        # Make sure we clean up anyhting that's no longer needed. I got that a lot with VMs and kernel libraries,
        # so I like to make sure this gets done so they don't fill up the disk.
        wsl --distribution $matchingLinesFirstWord -u root -e apt autoremove -y
    }
    if ($matchingLinesFirstWord -match "^(Fedora)") {
        # Do the update
        wsl --distribution $matchingLinesFirstWord -u root -e dnf upgrade -y
    }

    if( $Error = 1 ) {
        # So I was trying to figure out what the best way to send an email to us. Since any of our computers will have Outlook installed,
        # I figured that would be a safe bet since I had a day to get version 1 up. There may be a better way to do this through MS Graph,
        # but this is a safe bet.
        # create COM object named Outlook
        $Outlook = New-Object -ComObject Outlook.Application
    
        # create Outlook MailItem named Mail using CreateItem() method
        $Mail = $Outlook.CreateItem(0)
        
        # add properties as desired
        $Mail.To = $reportEmailAddress
        $Mail.Subject = "WSL update needs attention"
        $Mail.Body = "An update to the $matchingLinesFirstWord WSL instance on "+$env:COMPUTERNAME+" and needs some manual intervention. Please contact the user to schedule a time to do a manual update and resolve this problem."
        
        # send message
        $Mail.Send() 
    }
}
