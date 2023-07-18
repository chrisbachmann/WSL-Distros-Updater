# WSL-Distros-Updater
A Simple script to update WSL distributions.

We wanted to make sure that WSL distributions were up to date on a regular basis. This script will go through a set of known distribution types and then run the relevant command(s) that updates the installed software.

In our environment, we distribute this through intune to any computer that has WSL installed and set a scheduled task to run this.

To-Do:
Add other distributions
SUSE (and openSUSE)
Oracle Linux (?)

Send email via MS Graph.
Teams integration.
Slack integration.
Make a variable that says which notification method to use.
