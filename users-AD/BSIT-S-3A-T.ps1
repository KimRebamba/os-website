Import-Module ActiveDirectory

$csvPath = "C:\Users\Administrator\Documents\BSIT-S-3A-T.csv"
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    
  
    $fName = $user.GivenName.Trim()
    $lName = $user.Surname.Trim()
    $fNameNoSpace = $fName -replace ' ', ''
    $lNameNoSpace = $lName -replace ' ', ''
    
     
    $first_initial = $fName.Substring(0,1)
    $baseSAM = "$first_initial.$lNameNoSpace"
    $sAM = $baseSAM
    $i = 1

   # collision code
    while (Get-ADUser -Filter "SamAccountName -eq '$sAM'") {
        $sAM = "$baseSAM$i"
        $i++
    }
    
    
    if ($sAM.Length -gt 20) { $sAM = $sAM.Substring(0,20) }

  # create user
    try {
        $newUserParams = @{
            SamAccountName        = $sAM 
            # FIX: Removed spaces from UPN and Email Address
            UserPrincipalName     = "$fNameNoSpace.$lNameNoSpace@tup.edu.ph"
            Description           = "Student"
            Name                  = $user.DisplayName.Trim() 
            GivenName             = $fName
            Initials              = $user.Initials.Trim()
            Surname               = $lName
            DisplayName           = $user.DisplayName.Trim()
            Path                  = "OU=BSIT-S-3A-T,OU=IT Department,DC=bsit,DC=com"                        
            AccountPassword       = (ConvertTo-SecureString "EndUser123&" -AsPlainText -Force)
            EmailAddress          = "$fNameNoSpace.$lNameNoSpace@tup.edu.ph"
            Enabled               = $true
            ChangePasswordAtLogon = $false
        }
        
        New-ADUser @newUserParams -ErrorAction Stop
        Write-Host "Created user: $sAM" -ForegroundColor Green

       # add user to existing group
        Add-ADGroupMember -Identity $user.Group.Trim() -Members $sAM -ErrorAction Stop
        Write-Host "Added $sAM to $($user.Group)" -ForegroundColor Cyan
    } 
    catch {
        
        Write-Warning "User $sAM was not created. Error: $($_.Exception.Message)"
    }
}