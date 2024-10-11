#Requires -Version 5.1.22621.2506
    <#


            Created by: Anton Willoughby
            Date: October 11th, 2024


            .SYNOPSIS
                This script will assign 4 Entra ID roles as eiligible PIM assignments to 3 Entra ID groups. This script will also create the 3 role-assignable groups.

            .DESCRIPTION
                Assigns 4 Entra ID roles as eligible PIM assignments to 3 Entra ID role-assignable security groups. The script will create the 3 groups as well. 

                Groups:
                'Level-One-Support'"
                    Roles:
                         'Helpdesk Administrator'"
                         'Global Reader'"

                'Level-Two-Support'"
                'Level-Three-Support'"
                    Roles:
                    'Helpdesk Administrator'"
                     'Global Reader'"
                     'Security Administrator'"
                     'Privileged Authentication Administrator'"

            .EXAMPLE

                .\GroupCreater_RoleAssigner.ps1 -TenantID "14XXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXd8f" 

                
                Runs the script with the specified input parameters
    #>
param(
    [Parameter(Mandatory)]
    $TenantID     
)

Connect-MgGraph -Scopes "Group.ReadWrite.All, Directory.ReadWrite.All, RoleManagement.ReadWrite.Directory" -TenantId $TenantID -NoWelcome


#Entra ID Roles => Vairables
$roleDefinition_HelpDeskAdmin = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Helpdesk Administrator'"
$roleDefinition_GlobalReader = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Global Reader'"
$roleDefinition_SecAdmin = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Security Administrator'"
$roleDefinition_PIMAdmin = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Privileged Authentication Administrator'"


#check if group exists
$varLevelOneSupport = Get-MgGroup -Filter "DisplayName eq 'Level-One-Support'"
$varLevelTwoSupport = Get-MgGroup -Filter "DisplayName eq 'Level-Two-Support'"
$varLevelThreeSupport = Get-MgGroup -Filter "DisplayName eq 'Level-Three-Support'"


########################################################################################################################################################


#Create role-assigable groups if they don't exist
#################################################

if($varLevelOneSupport -eq $null)
{
    #Create new role assignable group
    Write-Host "Creating new group..." -ForegroundColor DarkGreen -BackgroundColor White
    New-MgGroup -DisplayName "Level-One-Support" -IsAssignableToRole:$true -MailEnabled:$false -MailNickname "Level-One-Support" -SecurityEnabled
}
else
{
    Write-Host "Level-One-Support already exists" -ForegroundColor Yellow
}



if($varLevelTwoSupport -eq $null)
{
    #Create new role assignable group
    Write-Host "Creating new group..." -ForegroundColor DarkGreen -BackgroundColor White
    New-MgGroup -DisplayName "Level-Two-Support" -IsAssignableToRole:$true -MailEnabled:$false -MailNickname "Level-Two-Support" -SecurityEnabled
}
else
{
    Write-Host "Level-Two-Support already exists" -ForegroundColor Yellow
}


if($varLevelThreeSupport -eq $null)
{
    #Create new role assignable group
    Write-Host "Creating new group..." -ForegroundColor DarkGreen -BackgroundColor White
    New-MgGroup -DisplayName "Level-Three-Support" -IsAssignableToRole:$true -MailEnabled:$false -MailNickname "Level-Three-Support" -SecurityEnabled
}
else
{
    Write-Host "Level-Three-Support already exists" -ForegroundColor Yellow
}


#Create role assignments
#################################################

#Obtain group ID's now that they're created
$varLevelOneSupport = Get-MgGroup -Filter "DisplayName eq 'Level-One-Support'"
$varLevelTwoSupport = Get-MgGroup -Filter "DisplayName eq 'Level-Two-Support'"
$varLevelThreeSupport = Get-MgGroup -Filter "DisplayName eq 'Level-Three-Support'"


Start-Sleep -Seconds 3

# Assign Eligible PIM Roles to each group
################################################################
#Tier1 Roles
###############################################################

Write-Host "Assigning PIM roles for Tier1"

$params = @{
  "PrincipalId" = $varLevelOneSupport.Id
  "RoleDefinitionId" = $roleDefinition_GlobalReader.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
   New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelOneSupport.Id
  "RoleDefinitionId" = $roleDefinition_HelpDeskAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime


#Tier2 Roles
###############################################################
Write-Host "Assigning PIM roles for Tier2"
$params = @{
  "PrincipalId" = $varLevelTwoSupport.Id
  "RoleDefinitionId" = $roleDefinition_HelpDeskAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelTwoSupport.Id
  "RoleDefinitionId" = $roleDefinition_GlobalReader.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelTwoSupport.Id
  "RoleDefinitionId" = $roleDefinition_SecAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelTwoSupport.Id
  "RoleDefinitionId" = $roleDefinition_PIMAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

#Tier3 Roles
###############################################################
Write-Host "Assigning PIM roles for Tier3"
$params = @{
  "PrincipalId" = $varLevelThreeSupport.Id
  "RoleDefinitionId" = $roleDefinition_HelpDeskAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelThreeSupport.Id
  "RoleDefinitionId" = $roleDefinition_GlobalReader.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelThreeSupport.Id
  "RoleDefinitionId" = $roleDefinition_SecAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime

$params = @{
  "PrincipalId" = $varLevelThreeSupport.Id
  "RoleDefinitionId" = $roleDefinition_PIMAdmin.Id
  "Justification" = "Add eligible assignment"
  "DirectoryScopeId" = "/"
  "Action" = "AdminAssign"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
      "Type" = "noExpiration"
      #"Duration" = "PT10H"
      }
    }
   }
New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime



    $varLevelOneSupport = $null
    $varLevelTwoSupport = $null
    $varLevelThreeSupport = $null
Disconnect-MgGraph