Import-Module ActiveDirectory
Import-Module GroupPolicy -ErrorAction SilentlyContinue

$OutputFile = "C:\ADDiscovery\ParentDomainDiscovery.csv"
New-Item -ItemType Directory -Path "C:\ADDiscovery" -Force | Out-Null

$Results = @()

# Parent Domain
$ParentDomain = (Get-ADForest).RootDomain

#################################################
# Domain Info
#################################################

$forest = Get-ADForest
$domain = Get-ADDomain -Server $ParentDomain

$Results += [PSCustomObject]@{

Label = "Domain Info"
Domain = $ParentDomain
Category = "Domain"
Name = $domain.DNSRoot
Detail1 = $forest.RootDomain
Detail2 = $forest.ForestMode
Detail3 = ""

}

#################################################
# All Trusts
#################################################

$trusts = nltest /domain_trusts

foreach ($trust in $trusts){

$Results += [PSCustomObject]@{

Label = "All Trusts"
Domain = $ParentDomain
Category = "Trust"
Name = $trust
Detail1 = ""
Detail2 = ""
Detail3 = ""

}

}

#################################################
# Domain Controllers
#################################################

Get-ADDomainController -Server $ParentDomain -Filter * | ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Domain Controllers"
Domain = $ParentDomain
Category = "Domain Controller"
Name = $_.HostName
Detail1 = $_.Site
Detail2 = $_.OperatingSystem
Detail3 = $_.IsGlobalCatalog

}

}

#################################################
# Users
#################################################

Get-ADUser -Server $ParentDomain -Filter * -ResultPageSize 1000 -ResultSetSize $null | ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Users"
Domain = $ParentDomain
Category = "User"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = ""
Detail3 = ""

}

}

#################################################
# Service Accounts (SPN)
#################################################

Get-ADUser -Server $ParentDomain -Filter "ServicePrincipalName -like '*'" -Properties ServicePrincipalName -ResultPageSize 1000 -ResultSetSize $null |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Service Accounts"
Domain = $ParentDomain
Category = "SPN Service Account"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = ($_.ServicePrincipalName -join ";")
Detail3 = ""

}

}

#################################################
# Managed Service Accounts
#################################################

Get-ADServiceAccount -Server $ParentDomain -Filter * | ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Service Accounts"
Domain = $ParentDomain
Category = "Managed Service Account"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = ""
Detail3 = ""

}

}

#################################################
# Password Never Expires
#################################################

Get-ADUser -Server $ParentDomain -Filter {PasswordNeverExpires -eq $True} -Properties PasswordNeverExpires |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Service Accounts"
Domain = $ParentDomain
Category = "Password Never Expires"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = ""
Detail3 = ""

}

}

#################################################
# Privileged Accounts
#################################################

$groups = @(
"Domain Admins",
"Enterprise Admins",
"Schema Admins",
"Administrators",
"Account Operators",
"Server Operators",
"Backup Operators",
"Print Operators"
)

foreach ($group in $groups){

try {

$members = Get-ADGroupMember -Server $ParentDomain -Identity $group -Recursive -ErrorAction Stop

$members | Where-Object {$_.objectClass -eq "user"} | ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Privileged Accounts"
Domain = $ParentDomain
Category = "Privileged User"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = $group
Detail3 = ""

}

}

}
catch {

Write-Host "Skipping $group"

}

}

#################################################
# Stale Users
#################################################

Get-ADUser -Server $ParentDomain -Filter * -Properties LastLogonDate -ResultPageSize 1000 -ResultSetSize $null |

Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-90) } |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Stale Users"
Domain = $ParentDomain
Category = "Inactive User"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = $_.LastLogonDate
Detail3 = ""

}

}

#################################################
# Computers
#################################################

Get-ADComputer -Server $ParentDomain -Filter * -Properties Enabled,OperatingSystem,LastLogonDate |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Computer Objects"
Domain = $ParentDomain
Category = "Computer"
Name = $_.Name
Detail1 = $_.OperatingSystem
Detail2 = $_.Enabled
Detail3 = $_.LastLogonDate

}

}

#################################################
# GPOs
#################################################

Get-GPO -All -Domain $ParentDomain | ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All GPOs"
Domain = $ParentDomain
Category = "GPO"
Name = $_.DisplayName
Detail1 = $_.CreationTime
Detail2 = $_.ModificationTime
Detail3 = ""

}

}

#################################################
# Security Groups
#################################################

Get-ADGroup -Server $ParentDomain -Filter "GroupCategory -eq 'Security'" |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All Security Groups"
Domain = $ParentDomain
Category = "Security Group"
Name = $_.Name
Detail1 = $_.SamAccountName
Detail2 = $_.GroupScope
Detail3 = ""

}

}

#################################################
# OUs
#################################################

Get-ADOrganizationalUnit -Server $ParentDomain -Filter * |

ForEach-Object {

$Results += [PSCustomObject]@{

Label = "All OUs"
Domain = $ParentDomain
Category = "OU"
Name = $_.Name
Detail1 = $_.DistinguishedName
Detail2 = ""
Detail3 = ""

}

}

#################################################
# Export
#################################################

$Results | Export-Csv $OutputFile -NoTypeInformation

Write-Host "Parent domain discovery completed"