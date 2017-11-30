# WordPress Plugin Directory Deployment Script

Deploys a WordPress plugin from a local Git repo to the WordPress Plugin Repostiory (SVN).
 
## Process
 
 1. Ask for plugin slug.
 2. Ask for local plugin directory.
 3. Check local plugin directory exists.
 4. Ask for main plugin file name.
 5. Check main plugin file exists.
 6. Check readme.txt version matches main plugin file version.
 7. Ask for temporary SVN path.
 8. Ask for remote SVN repo.
 9. Ask for SVN username.
 10. Ask if input is correct, and give chance to abort.
 11. Check if Git tag exists for version number (must match exactly).
 12. Checkout SVN repo.
 13. Set to SVN ignore some GitHub-related files.
 14. Export HEAD of master from git to the trunk of SVN.
 15. Initialise and update and git submodules.
 16. Move /trunk/assets up to /assets.
 17. Move into /trunk, and SVN commit.
 18. Move into /assets, and SVN commit.
 19. Copy /trunk into /tags/{version}, and SVN commit.
 20. Delete temporary local SVN checkout.

## Install

1. In your terminal, `cd` into the directory which contains subdirectories for each of your plugins. i.e. on a local install of WordPress, this will probably be `wp-content/plugins`. Then `git clone https://github.com/GaryJones/wordpress-plugin-git-flow-svn-deploy.git .` to clone the deploy script locally.
2. Ensure that the shell script is executable. In Mac / Unix, run `chmod +x deploy.sh`.
3. Run the script with `sh deploy.sh`. You can also double-click it in Finder / Explorer to start it.
4. You'll now be guided through a set of questions.
 
I prefer to keep this script in the root of my projects directory. Each project directory is named as the plugin slug, as is the corresponding GitHub repo. To use, just call the script, enter the plugin slug, confirm or amend default suggestions, and sit back as the code is sent to SVN and git repos including tags. The commit messages here are hard-coded for consistency.

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
