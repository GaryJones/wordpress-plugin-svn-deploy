#! /bin/bash
# See https://github.com/GaryJones/wordpress-plugin-git-flow-svn-deploy for instructions and credits.

echo
echo "WordPress Plugin Git-Flow SVN Deploy v1.0.0-dev2"
echo
echo "Step 1. Let's collect some information first."
echo
echo "Default values are in brackets - just hit enter to accept them."
echo

# Get some user input
# Can't use the -i flag for read, since that doesn't work for bash 3
printf "1a) WordPress Repo Plugin Slug e.g. my-awesome-plugin: "
read -e PLUGINSLUG
echo

# Set up some default values. Feel free to change these in your own script
CURRENTDIR=`pwd`
default_svnpath="/tmp/$PLUGINSLUG"
default_svnurl="http://plugins.svn.wordpress.org/$PLUGINSLUG"
default_svnuser="GaryJ"
default_plugindir="$CURRENTDIR/$PLUGINSLUG"
default_mainfile="$PLUGINSLUG.php"

echo "1b) Path to a local directory where a temporary SVN checkout can be made."
printf "No trailing slash and don't add trunk ($default_svnpath): "
read -e input
input="${input%/}" # Strip trailing slash
SVNPATH="${input:-$default_svnpath}" # Populate with default if empty
echo

echo "1c) Remote SVN repo on WordPress.org. No trailing slash."
printf "($default_svnurl): "
read -e input
input="${input%/}" # Strip trailing slash
SVNURL="${input:-$default_svnurl}" # Populate with default if empty
echo

printf "1d) Your WordPress repo SVN username ($default_svnuser): "
read -e input
SVNUSER="${input:-$default_svnuser}" # Populate with default if empty
echo

echo "1e) Your local plugin root directory, the Git repo. No trailing slash."
printf "($default_plugindir): "
read -e  input
input="${input%/}" # Strip trailing slash
PLUGINDIR="${input:-$default_plugindir}" # Populate with default if empty
echo

printf "1f) Name of the main plugin file ($default_mainfile): "
read -e input
MAINFILE="${input:-$default_mainfile}" # Populate with default if empty
echo

echo "That's all of the data collected."
echo
echo "Slug: $PLUGINSLUG"
echo "Temp checkout path: $SVNPATH"
echo "Remote SVN repo: $SVNURL"
echo "SVN username: $SVNUSER"
echo "Plugin directory: $PLUGINDIR"
echo "Main file: $MAINFILE"
echo

printf "OK to proceed (y|n)? "
read -e input
PROCEED="${input:-y}"
echo

# Allow user cancellation
if [ "$PROCEED" != "y" ]; then echo "Aborting..."; exit 1; fi

# git config
GITPATH="$PLUGINDIR/" # this file should be in the base of your git repository

# Let's begin...
echo ".........................................."
echo 
echo "Preparing to deploy WordPress plugin"
echo 
echo ".........................................."
echo 

# Check version in readme.txt is the same as plugin file after translating both to unix line breaks to work around grep's failure to identify mac line breaks
NEWVERSION1=`grep "^Stable tag:" $GITPATH/readme.txt | awk -F' ' '{print $NF}' | tr -d '\r'`
echo "readme.txt version: $NEWVERSION1"
NEWVERSION2=`grep "Version:" $GITPATH/$MAINFILE | awk -F' ' '{print $NF}' | tr -d '\r'`
echo "$MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Version in readme.txt & $MAINFILE don't match. Exiting...."; exit 1; fi

echo "Versions match in readme.txt and $MAINFILE. Let's proceed..."

# GaryJ: Ignore check for git tag, as git flow release finish creates this.
#if git show-ref --tags --quiet --verify -- "refs/tags/$NEWVERSION1"
#	then 
#		echo "Version $NEWVERSION1 already exists as git tag. Exiting...."; 
#		exit 1; 
#	else
#		echo "Git version does not exist. Let's proceed..."
#fi

echo "Changing to $GITPATH"
cd $GITPATH
# GaryJ: Commit message variable not needed . Hard coded for SVN trunk commit for consistency.
#echo -e "Enter a commit message for this new version: \c"
#read COMMITMSG
# GaryJ: git flow release finish already covers this commit.
#git commit -am "$COMMITMSG"

# GaryJ: git flow release finish already covers this tag creation.
#echo "Tagging new version in git"
#git tag -a "$NEWVERSION1" -m "Tagging version $NEWVERSION1"

echo "Pushing git master to origin, with tags"
git push origin master
git push origin master --tags

echo 
echo "Creating local copy of SVN repo trunk ..."
svn checkout $SVNURL $SVNPATH --depth immediates
svn update --quiet $SVNPATH/trunk --set-depth infinity

echo "Ignoring GitHub specific files"
svn propset svn:ignore "README.md
Thumbs.db
.git
.gitignore" "$SVNPATH/trunk/"

echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/trunk/

# If submodule exist, recursively check out their indexes
if [ -f ".gitmodules" ]
	then
		echo "Exporting the HEAD of each submodule from git to the trunk of SVN"
		git submodule init
		git submodule update
		git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
			while read path_key path
			do
				#url_key=$(echo $path_key | sed 's/\.path/.url/')
				#url=$(git config -f .gitmodules --get "$url_key")
				#git submodule add $url $path
				echo "This is the submodule path: $path"
				echo "The following line is the command to checkout the submodule."
				echo "git submodule foreach --recursive 'git checkout-index -a -f --prefix=$SVNPATH/trunk/$path/'"
				git submodule foreach --recursive 'git checkout-index -a -f --prefix=$SVNPATH/trunk/$path/'
			done
fi

# Support for the /assets folder on the .org repo.
echo "Moving assets"
# Make the directory if it doesn't already exist
mkdir -p $SVNPATH/assets/
mv $SVNPATH/trunk/assets/* $SVNPATH/assets/
svn add --force $SVNPATH/assets/
svn delete --force $SVNPATH/trunk/assets

echo "Changing directory to SVN and committing to trunk"
cd $SVNPATH/trunk/
# Delete all files that should not now be added.
svn status | grep -v "^.[ \t]*\..*" | grep "^\!" | awk '{print $2}' | xargs svn del
# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
svn commit --username=$SVNUSER -m "Preparing for $NEWVERSION1 release"

echo "Updating WordPress plugin repo assets and committing"
cd $SVNPATH/assets/
# Delete all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^\!" | awk '{print $2}' | xargs svn del
# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
svn update --accept mine-full $SVNPATH/assets/*
svn commit --username=$SVNUSER -m "Updating assets"

echo "Creating new SVN tag and committing it"
cd $SVNPATH
svn update --quiet $SVNPATH/tags/$NEWVERSION1
svn copy --quiet trunk/ tags/$NEWVERSION1/
# Remove assets and trunk directories from tag directory
svn delete --force --quiet $SVNPATH/tags/$NEWVERSION1/assets
svn delete --force --quiet $SVNPATH/tags/$NEWVERSION1/trunk
cd $SVNPATH/tags/$NEWVERSION1
svn commit --username=$SVNUSER -m "Tagging version $NEWVERSION1"

echo "Removing temporary directory $SVNPATH"
cd $SVNPATH
cd ..
rm -fr $SVNPATH/

echo "*** FIN ***"
