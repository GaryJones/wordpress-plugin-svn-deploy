# WordPress Plugin Directory Deployment Script

Deploys a WordPress plugin from a local Git repo to the WordPress Plugin Repostiory (SVN).

Please note that if your repository contains a folder `/.wordpress-org` it will be used to contain those files that will be transferred to your SVN `/assets` folder. These assets are the plugin banner images, icons, and any `readme.txt` related files. If you use a diffent name for this folder you will be prompted for that name in the script.

## Steps

These are the steps that the script takes:

 1. Asks for plugin slug.
 2. Asks for local plugin directory.
 3. Checks local plugin directory exists.
 4. Asks for local SVN assets directory.
 5. Checks local SVN assets directory exists.
 6. Asks for main plugin file name.
 7. Checks main plugin file exists.
 8. Checks `readme.txt` version matches main plugin file version.
 9. Asks for temporary SVN checkout path.
 10. Asks for remote SVN repo URL.
 11. Asks for SVN username.
 12. Asks if input is correct, and gives chance to abort.
 13. Checks if Git tag exists for version number (must match exactly).
 14. Does checkout of SVN repo.
 15. Sets SVN ignore on some GitHub-related files.
 16. Exports `HEAD` of `master` from Git to the trunk of SVN.
 17. Initialises and updates any git submodules.
 18. Moves `/trunk/.wordpress-org` up to SVN `/assets`.
 19. Moves into `/trunk`, and does an SVN commit.
 20. Moves into `/assets`, and does an SVN commit.
 21. Copies `/trunk` into `/tags/{version}`, and does an SVN commit.
 22. Deletes temporary local SVN checkout.

## Install

1. In your terminal, `cd` into the directory which contains subdirectories for each of your plugins. i.e. on a local install of WordPress, this will probably be `wp-content/plugins`. Then `git clone https://github.com/GaryJones/wordpress-plugin-git-flow-svn-deploy.git .` to clone the deploy script locally.
2. Ensure that the shell script is executable. In Mac / Unix, run `chmod +x deploy.sh`.
3. Run the script with `sh deploy.sh`. You can also double-click it in Finder / Explorer to start it.
4. You'll now be guided through a set of questions.

I prefer to keep this script in the root of my projects directory. Each project directory is named as the plugin slug, as is the corresponding GitHub repo. To use, just call the script, enter the plugin slug, confirm or amend default suggestions, and sit back as the code is sent to SVN and git repos including tags. The commit messages here are hard-coded for consistency.

## Extras

You may define your own `.svnignore` file similar to an `svn propset svn:ignore .svnignore` command. This will remove any listed files and/or directories from committing to the Plugins Directory.

NB: you must list files separately, no wildcards.

Reference: https://stackoverflow.com/questions/17298668/svn-ignore-like-gitignore

## Credits

At one point, well over 90% of this script was written by others:

 - **[Dean Clatworthy](https://twitter.com/deanclatworthy)** - [Original script](https://github.com/deanc/wordpress-plugin-git-svn)
 - **[Brent Shepherd](https://twitter.com/thenbrent)** - [Avoids permanent local SVN repo, avoids sending redundant stuff to WP repo](http://thereforei.am/2011/04/21/git-to-svn-automated-wordpress-plugin-deployment/)
 - **[Patrick Rauland](https://twitter.com/BFTrick)** - [Support for WP assets folder for plugin page banner and screenshots](https://github.com/BFTrick/jotform-integration/blob/master/deploy.sh)
 - **[Ben Balter](https://twitter.com/benbalter)** - [Submodules support and plugin slug prompt](https://github.com/benbalter/Github-to-WordPress-Plugin-Directory-Deployment-Script/)
 - **[Gary Jones](https://twitter.com/GaryJ)** *(me)* - [Personalisation and commenting out bits not required when using git-flow](https://github.com/GaryJones/wordpress-plugin-git-flow-svn-deploy)

 There has been a significant amount of changes since then though.


## License

This package was created at a time when the above credited repositories had no license. For any amendements done since then, the code is [licensed](LICENSE.md) under MIT. For the original work, contact the previous authors.
