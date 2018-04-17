
function object-management()
{
    param(
        [switch]$create,
        [switch]$delete,
        [switch]$F,
        [string]$object,
        [string]$filePath
    )
    #lowercase the param, makes it easiser to use in code
    $object.ToLower()
    # Clearing the host
    Clear-Host
    # Creating Objects
    if ($create)
    {
        # Creating OUs
        if ($object -eq "ou")
        {
            Write-Host "Organizational Unit Creation" -ForegroundColor Green -BackgroundColor Black
            # Creating OUs from csv file
            if ($F)
            {
                # Checking if file exists
                Write-Host "Validating file exists."
                while ((Test-Path $filePath) -eq $false)
                {
                    Write-Host "Error! File does not exists" -ForegroundColor Red -BackgroundColor Black
                    $filePath = Read-Host "Enter file name, If file is in a different location enter the full path"
                }
                if ((Test-Path $filePath) -eq $true)
                {
                    Write-Host "File Verified" -ForegroundColor Green -BackgroundColor Black
                    # Importing csv file and storing the in var. for easiser usage
                    $csvFile = Import-CSV $filePath
                    # Looping through the csv file and validating weather ou exist or not
                    foreach ($ou in $csvFile)
                    {
                        # Creating temp var for path and name
                        $ouName = $ou.Name
                        $ouPath = $ou.DistinguishedName
                        if (([adsi]::Exists("LDAP://$ouPath")) -eq $true)
                        {
                            Write-Host "$ouName already exists" -ForegroundColor Red -BackgroundColor Black
                        }
                        else
                        {
                            New-ADOrganizationalUnit -Name $ouName -Path $ouPath
                        }
                    }
                }
            }
            # Creating OUs manually
            elseif ($F -eq $false)
            {
                # Collecting info to create single OU
                $ouName = Read-Host "OU Name"
                $ouPath = Read-Host "OU Path"
                # Verify that ou does not exist
                if (([adsi]::Exists("LDAP://$ouPath")) -eq $true)
                {
                    Write-Host "$ouName already exists" -ForegroundColor Red -BackgroundColor Black
                }
                else
                {
                    New-ADOrganizationalUnit -Name $ouName -Path $ouPath
                }
            }
        }
        # Creating Users
        elseif ($object -eq "users")
        {
            Write-Host "User Creation Center" -ForegroundColor Green -BackgroundColor Black
            # Creating users from csv file
            if ($F)
            {
                Write-Host "Validating file exists"
                while ((Test-Path $filePath) -eq $false)
                {
                    Write-Host "Error! File does not exist" -ForegroundColor Red -BackgroundColor Black
                    $filePath = Read-Host "Enter file name, If file is in a different location enter the full path"
                }
                if ((Test-Path $filePath) -eq $true)
                {
                    Write-Host "File Verified" -ForegroundColor Green -BackgroundColor Black
                    $userCSV = Import-CSV -Delimiter "," -Path $filePath
                    foreach ($u in $userCSV)
                    {
                        $DisplayName = $u.Firstname + " " + $u.Lastname
                        $UserFirstname = $u.Firstname
                        $UserLastname = $u.Lastname
                        $OU = "$o.OU"
                        $SAM = $o.SAM
                        $UPN = $o.Firstname + $u.Lastname + "@" + $u.Maildomain
                        $Description = $u.Description
                        $Password = $u.Password
                        # Checking if user exists
                        try
                        {
                            $userValidation = Get-ADUser -Identity $SAM -ErrorAction Stop
                        }
                        catch
                        {
                            if ($_ -like "*Cannot find an object with identity: '$SAM'*")
                            {
                                # Create user
                                New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false -PasswordNeverExpires $true
                            }
                            else
                            {
                                Write-Host "There was an error" -ForegroundColor Red -BackgroundColor Black
                            }
                            continue
                        }
                        Write-Host "User Already Exists" -ForegroundColor Red -BackgroundColor Black
                    }
                }
            }
            # Creating users without csv file
            elseif ($F -eq $false)
            {
                # Collecting info to create user
                $Displayname = Read-Host "Enter displayname"
                $Firstname = Read-Host "Enter first name"
                $Lastname = Read-Host "Enter last name"
                $OU = Read-Host "Enter ou location"
                $SAM = Read-Host "Enter SAM name"
                $UPN = Read-Host "Enter UPN info"
                $Description = Read-Host "Enter description"
                $Password = Read-Host "Enter password"
                # Verify that user does not exists
                try
                {
                    $userValidation = Get-ADUser -Identity $SAM -ErrorAction Stop
                }
                catch
                {
                    if ($_ -like "*Cannot find an object with identity: '$SAM'*")
                    {
                        # Create user
                        New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false -PasswordNeverExpires $true
                    }
                    else
                    {
                        Write-Host "There was an error" -ForegroundColor Red -BackgroundColor Black
                    }
                    continue
                }
                Write-Host "User Already Exists" -ForegroundColor Red -BackgroundColor Black
            }
        }
        # Creating groups
        elseif ($object -eq "groups")
        {
            Write-Host "Group Creation Center" -ForegroundColor Green -BackgroundColor Black
            $groups = import-csv $filePath
            # Creating groups from csv file.
            if ($F)
            {
                # Validating file exits
                Write-Host "Validating file exists"
                while ((Test-Path $filePath) -eq $false)
                {
                    Write-Host "Error! File does not exist" -ForegroundColor Red -BackgroundColor Black
                    $filePath = Read-Host "Enter file name, If file is in a different directory enter full path"
                }
                if ((Test-Path $filePath) -eq $true)
                {
                    foreach ($group in $groups)
                    {
                        $path = $group.DistinguishedName -replace '^.+?(?<!\\),',''
                        $name = $group.Name
                        $groupScope = $group.GroupScope
                        $SAM = $group.SamAccountName
                        # Checking if group exists
                        if (Get-ADGroup -Filter 'samAccountName -like "$SAM"')
                        {
                            Write-Host "$SAM already exists" -ForegroundColor Red -BackgroundColor Black
                        }
                        else
                        {
                            Write-Verbose -Message "Creating Groups"
                            New-ADGroup -Name $name -GroupScope $groupScope -Path "$path"
                        }
                    }
                }
            }
            # Creating groups manually without csv file
            elseif ($F -eq $false)
            {
                $name = Read-Host "The Group Name"
                $groupScope = Read-Host "Enter the Group Scope"
                $SAM = Read-Host "Enter the SAM account for the Group"
                if (Get-ADGroup -Filter 'samAccountName -like "$SAM"')
                {
                    Write-Host "$SAM already exists" -ForegroundColor Red -BackgroundColor Black
                }
                else
                {
                  Write-Host -Message "Creating Groups" -ForegroundColor Green -BackgroundColor Black
                  New-ADGroup -Name $name -GroupScope $groupScope -Path "$path"
                }
            }
        }
    }
#################################################################################################################################################################
######################################################################## Deleting Objects #######################################################################
#################################################################################################################################################################
  if ($delete)
  {
    if ($object -eq "ou")
    {
      Write-Host "OU Removal Center"
      # Validating if file Exists
      while ((Test-Path $filePath) -eq $false)
      {
        Write-Host "Error! File does not exist" -ForegroundColor Red -BackgroundColor -Black
        # pass 
      }
    }
  }
}
