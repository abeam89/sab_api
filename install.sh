#!/bin/bash

# Install script for the sab_api script

# Return values
SUCCESS=0
ERROR=1

# Welcome message
echo "\
                              ___.                      .__ 
                  ___________ \_ |__      _____  ______ |__|
                 /  ___/\__  \ | __ \     \__  \ \____ \|  |
                 \___ \  / __ \| \_\ \     / __ \|  |_> >  |
                /____  >(____  /___  /____(____  /   __/|__|
                     \/      \/    \/_____/    \/|__|       
                
"
echo "\
-------------------------------------------------------------------------------"
echo "\
This script will help you get started using sab_api. It will ask you various
questions to complete the install process. This script will not move any files,
but rather create links to the files that exist in `pwd`
so you can easily update from GitHub in the future. 

Keep in mind config files are also linked here to keep everything in one
easy-access directory. This means any future changes to your sab_api config
should be made from here.

If files with the same names already exist in the locations that the install
script attempts to create links, the script will prompt for each action and
require double confirmation before any files/links are removed to be replaced
by the new link. Enjoy, and please submit any feedback (including bugs) on the
sab_api GitHub page.

                      https://github.com/abeam89/sab_api                       "
echo "\
-------------------------------------------------------------------------------
"

sab_apiInstallSuccess()
{
  echo
  echo
  echo "\
       .__            ._.
  ____ |__| ____  ____| |
 /    \|  |/ ___\/ __ \ |
|   |  \  \  \__\  ___/\|
|___|  /__|\___  >___  >_
     \/        \/    \/\/
"
  echo "The sab_api installation was a success."
  echo
  echo "The following was performed:"
  echo "Dependencies were verified."
  if [ "$GENCONFIG" ]; then
    echo "$SAB_API_CONF_FILE modified to include:"
    echo "SABnzbd URL: $SAB_API_URL"
    echo "SABnzbd API Key: $SAB_API_KEY"
  fi
  if [ "$CONFIG" ]; then
    echo "$SAB_API_CONF_FILE installed to $SAB_API_CONF_PATH"
  fi
  if [ "$INSTALL" ]; then
    echo "$SAB_API_INSTALL_FILE installed to $SAB_API_INSTALL_PATH"
  fi
  if [ "$COMPLETION" ]; then
    echo "$SAB_API_BC_FILE installed to $SAB_API_BC_PATH"
    echo "Note: Bash autocompletion won't work until you've opened a new shell"
    echo "      or, alternatively, you can run the following command:"
    echo "      source /etc/bash_completion"
  fi
  echo "Enjoy!"
  exit $SUCCESS
}

# Ensure dependencies are satisfied
sab_apiDependencies(){
  DEPENDENCIES="curl xpath"

  echo "Checking dependencies..."
  for dep in $DEPENDENCIES; do
    if [ ! $(command -v $dep 2>/dev/null) ]; then
      echo "sab_api requires the installation of $dep to run properly. Please"
      echo "verify that $dep is installed and try to run the installer again."
      echo "If you are using Ubuntu or some derivative of Debian, you might"
      echo "try the following command to install $dep:"
      if [ "$dep" == "xpath" ]; then
        echo "sudo apt-get install libxml-xpath-perl"
      else
        echo "sudo apt-get install $dep"
      fi
      exit $ERROR
    fi
    echo "Dependency $dep satisfied."
  done
  echo "All dependencies satisfied! Let's get this show on the road!"
}
sab_apiDependencies

# Populate/create the sab_api configuration file
SAB_API_CONF_PATH='/etc'
SAB_API_CONF_FILE='sab_api.conf'
SAB_API_EXAMPLE_CONF='sab_api.example.conf'

get_sab_apiConfPath(){
  read -ep "What location would you prefer? (path only): " \
    SAB_API_CONF_PATH
  echo
  if [ -d $SAB_API_CONF_PATH ]; then
    # Remove a trailing slash if present
    SAB_API_CONF_PATH=$(cd $SAB_API_CONF_PATH; pwd)
    # Populate the path change to the sab_api script
    sed -i 's#/etc/sab_api.conf#$SAB_API_CONF_PATH#'
  else
    echo "Invalid path specified."
    get_sab_apiConfPath
  fi
}
sab_apiConfigLinked(){
  echo "Config linked successfully."
  CONFIG=true
}
sab_apiConfigNotLinked(){
  echo "Config not linked. Make sure this is what you wanted."
}
linkSABConfig(){
 sudo ln -s "`pwd`/$SAB_API_CONF_FILE" \
   "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE"
}
linkExistingSABConfig(){
  if [ $? != 0 ]; then
    echo "It seems that there is already a config file/link in place." 
    read -n1 -p \
      "Replace it? (y or n) " \
      RESPONSE
    echo
    if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
      echo "Performing the following before linking:"
      echo "sudo rm -f "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE""
      read -n1 -p "Okay? (y or n) " RESPONSE
      echo
      if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
        sudo rm -f "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE"
        sudo ln -s "`pwd`/$SAB_API_CONF_FILE" \
          "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE"
        if [ $? != 0 ]; then
          echo "Something went wrong, config not linked."
        else
          sab_apiConfigLinked
        fi
      else
        sab_apiConfigNotLinked
      fi
    else
      sab_apiConfigNotLinked
    fi
  else
    sab_apiConfigLinked
  fi
}
installSABConfig(){
  read -n1 -p \
    "Link your config from '$SAB_API_CONF_PATH/$SAB_API_CONF_FILE'? (y or n) " \
    RESPONSE
  echo
  if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
    linkSABConfig
    if [ $? != 0 ]; then
      echo "It seems that there is already a config file/link in place." 
      read -n1 -p \
        "Replace it? (y or n) " \
        RESPONSE
      echo
      if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
        echo "Performing the following before linking:"
        echo "sudo rm -f "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE""
        read -n1 -p "Okay? (y or n) " RESPONSE
        echo
        if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
          sudo rm -f "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE"
          sudo ln -s "`pwd`/$SAB_API_CONF_FILE" \
            "$SAB_API_CONF_PATH/$SAB_API_CONF_FILE"
          if [ $? != 0 ]; then
            echo "Something went wrong, config not linked."
          else
            sab_apiConfigLinked
          fi
        else
          sab_apiConfigNotLinked
        fi
      else
        sab_apiConfigNotLinked
      fi
    else
      sab_apiConfigLinked
    fi
  else
    read -n1 -p \
      "Link it somewhere else? (y or n) " \
      RESPONSE
    echo
    if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
      get_sab_apiConfPath
      linkSABConfig
      linkExistingSABConfig
    else
      sab_apiConfigNotLinked
    fi
  fi
}

if [ -f sab_api.conf ]; then
 installSABConfig 
else
  read -n1 -p \
    "Config file not present. Help you create it? (y or n) " \
    RESPONSE
  echo
  if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
    if [ -f $SAB_API_EXAMPLE_CONF ]; then
      echo "Copying the example config file to $SAB_API_CONF_FILE"
      cp $SAB_API_EXAMPLE_CONF $SAB_API_CONF_FILE
      echo "What is the hostname/ip and port of your SABnzbd installation?"
      echo "     Form: http://HOSTNAME:PORT  or  http://IP:PORT"
      echo "(Examples: http://localhost:8080 or  http://192.168.1.5:8000):" 
      read -e SAB_API_URL
      echo
      echo "What is your SABnzbd API key?:"
      read -e SAB_API_KEY
      echo
      echo "Modifying the example config file with your information..."
      sed -i "s#YOUR\ KEY\ HERE#$SAB_API_KEY#" $SAB_API_CONF_FILE
      sed -i "s#http://localhost:8080#$SAB_API_URL#" $SAB_API_CONF_FILE
      echo "Config file created/modified successfully..."
      GENCONFIG=true
      installSABConfig 
    else
      echo "It doesn't seem like the example config is here. Make sure"
      echo "this is an unchanged sab_api directory structure if you'd like"
      echo "help generating the sab_api config file, then try running install.sh"
      echo "again."
      exit $ERROR
    fi
  else
    echo "Config not created. Make sure this is what you wanted."
  fi
fi

# Install sab_api
SAB_API_INSTALL_PATH='/usr/bin'
SAB_API_INSTALL_FILE='sab_api'
get_sab_apiInstallPath(){
  read -ep "What location would you prefer? (path only): " \
    SAB_API_INSTALL_PATH
  echo
  if [ -d $SAB_API_INSTALL_PATH ]; then
    # Remove a trailing slash if present
    SAB_API_INSTALL_PATH=$(cd $SAB_API_INSTALL_PATH; pwd)
  else
    echo "Invalid path specified."
    get_sab_apiInstallPath
  fi
}
link_sab_api(){
  if [ -f "sab_api" ]; then
    sudo ln -s "`pwd`/sab_api" "$SAB_API_INSTALL_PATH/$SAB_API_INSTALL_FILE"
    if [ $? != 0 ]; then
     echo "It seems that there is already a $SAB_API_INSTALL_FILE in place."
     read -n1 -p \
       "Replace it? (y or n) " \
       RESPONSE
     echo
     if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
       echo "Performing the following before linking:"
       echo "sudo rm -f "$SAB_API_INSTALL_PATH/$SAB_API_INSTALL_FILE""
       read -n1 -p "Okay? (y or n) " RESPONSE
       echo
       if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
         sudo rm -f "$SAB_API_INSTALL_PATH/$SAB_API_INSTALL_FILE"
         sudo ln -s "`pwd`/$SAB_API_INSTALL_FILE" \
           "$SAB_API_INSTALL_PATH/$SAB_API_INSTALL_FILE"
         if [ $? != 0 ]; then
           echo "Something went wrong, $SAB_API_INSTALL_FILE not linked."
         else
           echo "$SAB_API_INSTALL_FILE linked successfully."
           INSTALL=true
         fi
       else
         echo "$SAB_API_INSTALL_FILE not linked. Make sure this is what you wanted."
       fi
     else
       echo "$SAB_API_INSTALL_FILE not linked. Make sure this is what you wanted."
     fi
    else
      echo "$SAB_API_INSTALL_FILE linked successfully."
      INSTALL=true
    fi
  else
    echo "It doesn't seem like sab_api is here. Make sure this is an unchanged"
    echo "sab_api directory structure if you'd like help installing sab_api,"
    echo "then try again."
    exit $ERROR
  fi
}

read -n1 -p \
  "Install $SAB_API_INSTALL_FILE to '$SAB_API_INSTALL_PATH'? (y or n) " \
  RESPONSE
echo
if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
  link_sab_api
else
  read -n1 -p \
    "Install $SAB_API_INSTALL_FILE elsewhere? (y or n) " \
    RESPONSE
  echo
  if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
    get_sab_apiInstallPath
    link_sab_api
  else
    echo "$SAB_API_INSTALL_FILE not linked. Make sure this is what you wanted."
  fi
fi

# Install sab_api bash completion
SAB_API_BC_PATH='/etc/bash_completion.d'
SAB_API_BC_FILE='sab_api'
read -n1 -p "Install sab_api bash completion support? (y or n) " RESPONSE
echo
if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
  if [ -f "bash_completion/$SAB_API_BC_FILE" ]; then
    sudo ln -s "`pwd`/bash_completion/$SAB_API_BC_FILE" \
      "$SAB_API_BC_PATH/$SAB_API_BC_FILE"
    if [ $? != 0 ]; then
     echo "It seems that there is already a $SAB_API_BC_FILE bash completion"
     echo "file in place."
     read -n1 -p \
       "Replace it? (y or n) " \
       RESPONSE
     echo
     if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
       echo "Performing the following before linking:"
       echo "sudo rm -f "$SAB_API_BC_PATH/$SAB_API_BC_FILE""
       read -n1 -p "Okay? (y or n) " RESPONSE
       echo
       if [ "$RESPONSE" == "y" -o "$RESPONSE" == "Y" ]; then
         sudo rm -f "$SAB_API_BC_PATH/$SAB_API_BC_FILE"
         sudo ln -s "`pwd`/bash_completion/$SAB_API_BC_FILE" \
           "$SAB_API_BC_PATH/$SAB_API_BC_FILE"
         if [ $? != 0 ]; then
           echo "Something went wrong, bash completion file not linked."
         else
           COMPLETION=true
           echo "$SAB_API_BC_FILE linked successfully."
         fi
       else
         echo "$SAB_API_BC_FILE not linked. Make sure this is what you wanted."
       fi
     else
       echo "$SAB_API_BC_FILE not linked. Make sure this is what you wanted."
     fi
    else
      COMPLETION=true
      echo "$SAB_API_BC_FILE linked successfully."
    fi
  else
    echo "It doesn't seem like the sab_api bash completion file is here. Make"
    echo "sure this is an unchanged sab_api directory structure if you'd like"
    echo "help installing sab_api, then try again."
    exit $ERROR
  fi
else
  sab_apiInstallSuccess
fi

sab_apiInstallSuccess
