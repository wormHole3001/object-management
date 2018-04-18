# Project Info
  Created by: Fernando Gonzalez
  
  COSC 4365, Windows Security
  
  Assigned: Tuesday, April 3, 2018
  
  Due: Tuesday, April 17, 2018 11:59pm
  
  Use 'get-help' for info on the function

# SYNOPSIS
Powershell script for creating and removing objects.
# DESCRIPTION
Powershell script to manage the following the following objects: OUs, Users, and Groups. The only two options are to either create or remove

  # Following example is to create users with csv file
  object-management -create -object users-F -filePath file.csv
  # Following example is to delete users without csv
  object-management -delete -object users
  
# flags avaiable to use
  -create ................. flag used to specify you want to create
  
  -delete ................. flag used to specify you want to delete
  
  -object ................. flag used to specify the object type: ou, users, groups
  
  -F ............................ flag used to specify you want to use a file
  
  -filePath ............... flag used to specify the file path if you used the '-F' flag
