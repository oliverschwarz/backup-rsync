# Backup your Mac using rsync

This is a simple backup script using rsync that will enable you to backup any folder or directory on a mac into an external harddrive (if you want). I am using it to backup an iCloud folder to a external SSD. Here is what it does:

1. Checks folder to be backed up, then location to backup to
2. Synchronizes every folder you specify in the script into a backup folder with YYYYMMDD filename
3. Uses links to only backup changed files incrementally (`-a` flag)
4. Creates a symlink `latest` to link to the last backup 

## Set up

You have to install rsync which [can be done using Homebrew](https://formulae.brew.sh/formula/rsync).

    $ brew install rsync

Then check with

    $ rsync --version

Then edit lines 4-8 and 14-18 to enter your directories and the folders to back up. Finally give it executable rights.

    $ chmod +x ./backup.sh

Then simply run it

    $ ./backup.sh

It gives you an extended output on your console.

## Troubleshooting

I added some checks in the script so it validates directories and external hard drive before trying to write something. So it should not easily break things.