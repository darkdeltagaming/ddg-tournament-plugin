# ddg-tournament-plugin
## The DDG Tournament Project
This project was created to make a 2v2 (Wingman) Tournament System for any amount of players. 
Teams are selected randomly but with a little math so that every player plays the same amount of matches. The map picking takes place 
on the [DDG Tournament Website](https://github.com/darkdeltagaming/ddg-tournament-web). 
The [Backend](https://github.com/darkdeltagaming/ddg-tournament-steam-bot) manages all of the tournament actions. It also includes a minimal steam bot
which sends custom links to the participating players. This identifies the players. The last layer is the plugin for the CS:GO Server as it adjusts 
the teams and maps, and sends the leaderboard information to the backend server via a local WebSocket Connection.

## Overview
This is the CS:GO server plugin for the DDG Tournament System. 

The server is run from the [CSGO](https://github.com/CM2Walki/CSGO) docker container by [CM2Walki](https://github.com/CM2Walki).

## Prerequisites
Build the image using the provided dockerfile using  
`docker build -t mycsgoimage .`  
or pull the sourcemod image:  
`docker pull cm2network/csgo:sourcemod`

Create a directory `server` in the root of this repo.
Make sure everything works before building the plugin by starting the server and mounting the `server` directory.
Instructions on how to that can be found here: https://github.com/CM2Walki/CSGO#how-to-use-this-image  
Alternatively install a CS:GO Server into the server directory.

Use an RCON client to check if server has started and sourcemod is working properly.  
Check `sm version` and `meta version`

Add read, write and execute permission to the `./server` folder recursively to be able to edit files and execute the sourcepawn compiler.  
Once the file structure is created and the permissions are set you can build the plugin. There is no need to shut down the server.

## Building the plugin

The Makefile of this project expects the server to be mounted in the `./server` directory so make sure this is given. 
You can also use a dedicated server installed in the server directory. The docker image is just a way to make deploying the entire project more easy.

To build the plugin run the `make` command. This should compile the plugin and move it into the correct directory.
If the server is installed somewhere else adjust the parameters `PLUGIN_DIR` and `SPCOMP` in the Makefile respectively.
