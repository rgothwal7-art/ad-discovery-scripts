$Output = @()

$users = Get-ADUser -Filter * -Properties DisplayName,Mail,EmployeeID,UserPrincipalName,SamAccountName

# Duplicate Display Names
$dupDisplay = $users | Group-Object DisplayName | Where {$_.Count -gt 1}

foreach ($group in $dupDisplay){
    foreach ($user in $group.Group){
        $Output += [PSCustomObject]@{
            DuplicateType = "DisplayName"
            AttributeValue = $group.Name
            SamAccountName = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            Email = $user.Mail
            EmployeeID = $user.EmployeeID
        }
    }
}

# Duplicate Emails
$dupMail = $users | Where {$_.Mail} | Group-Object Mail | Where {$_.Count -gt 1}

foreach ($group in $dupMail){
    foreach ($user in $group.Group){
        $Output += [PSCustomObject]@{
            DuplicateType = "Email"
            AttributeValue = $group.Name
            SamAccountName = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            Email = $user.Mail
            EmployeeID = $user.EmployeeID
        }
    }
}

# Duplicate EmployeeID
$dupEmp = $users | Where {$_.EmployeeID} | Group-Object EmployeeID | Where {$_.Count -gt 1}

foreach ($group in $dupEmp){
    foreach ($user in $group.Group){
        $Output += [PSCustomObject]@{
            DuplicateType = "EmployeeID"
            AttributeValue = $group.Name
            SamAccountName = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            Email = $user.Mail
            EmployeeID = $user.EmployeeID
        }
    }
}

# Duplicate UPN
$dupUPN = $users | Group-Object UserPrincipalName | Where {$_.Count -gt 1}

foreach ($group in $dupUPN){
    foreach ($user in $group.Group){
        $Output += [PSCustomObject]@{
            DuplicateType = "UPN"
            AttributeValue = $group.Name
            SamAccountName = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            Email = $user.Mail
            EmployeeID = $user.EmployeeID
        }
    }
}

# Export
$Output | Export-Csv "C:\ADDiscovery\DuplicateAccounts.csv" -NoTypeInformation