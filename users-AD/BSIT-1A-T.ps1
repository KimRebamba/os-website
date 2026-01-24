Import-Module ActiveDirectory

$csvPath = "C:\Users\Administrator\Documents\BSIT-1A-T.csv"
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
   	
	$fName = $user.GivenName.Trim()
	$lName = $user.Surname.Trim()
	
	$first_initial = $fName.Substring(0,1)
	$sAM = "$first_initial.$lname" -replace ' ', ''
	
	if ($sAM.Length -gt 20) { $sAM = $sAM.Substring(0,20) } # IMPORTANT Pre-2000 20 chars limit

    # Create User
    try {
        $newUserParams = @{
         SamAccountName        = $sAM 
    
	 UserPrincipalName     = "$fName.$lName@tup.edu.ph"     # school domain email format

    	 Description           = "Student"
    	 Name                  = $user.DisplayName.Trim() 
   	 GivenName             = $fName
    	 Initials              = $user.Initials.Trim()
    	 Surname               = $lName
    	 DisplayName           = $user.DisplayName.Trim()
    	 Path                  = "OU=BSIT-1A-T,OU=IT Department,DC=bsit,DC=com"						
   	 AccountPassword       = (ConvertTo-SecureString "EndUser123&" -AsPlainText -Force)     # cannot be plain string, SecureString NEED
   	 
   	 EmailAddress          = "$fName.$lName@tup.edu.ph"
    
   	 Enabled               = $true
         ChangePasswordAtLogon = $false		# Optional

        }
        
        New-ADUser @newUserParams -ErrorAction Stop
        Write-Host "Created user: $sAM" -ForegroundColor Green
    } 
    catch {
        Write-Warning "User $sAM was not created (it already exists)."
    }

    # Add to Existing Group
    try {
        Add-ADGroupMember -Identity $user.Group.Trim() -Members $sAM -ErrorAction Stop
        Write-Host "Added $sAM to $($user.Group)" -ForegroundColor Cyan
    } 
    catch {
        Write-Error "Failed to add $sAM to group $($user.Group)."
    }
}