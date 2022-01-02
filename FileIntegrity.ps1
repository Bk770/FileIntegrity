#Calculate the Hash of a file
Function Calculate-File-Hash {
    param(
        [parameter(mandatory)]
        $filepath
    )
    
    Get-FileHash -Path $filepath -Algorithm SHA512          
}
 
 #Earse Baseline if already exists
 Function Erase-Baseline-If-AlreadyExists(){
    $baselineExists =  Test-Path -Path C:\baseline.txt

    If ($baselineExists) {
        #Delete it
        Remove-Item -Path C:\baseline.txt

    }
}
 
# Start of Menu
Write-Host "Choose from the following: "

# Collect New File Hash Baseline 
Write-Host "A) Collect new Baseline"

# Monitor Files with saved Baseline.txt
Write-Host "B) Begin monitoring files with saved Baseline file?"

# Save response of user to start of menu
$responseMenu = Read-Host  "Please Enter A or B"



switch ($responseMenu) {
    "A" {
        # Delete baseline.txt if it already exists
        Erase-Baseline-If-AlreadyExists
        
        Write-Host "Enter in file path: " -ForegroundColor Red
        $fileLocation = Get-ChildItem -Path (Read-Host -Prompt "Path")

        $hashes = 
        foreach ($f in $fileLocation) {
            $hash = Calculate-File-Hash $f.FullName
            "$($hash.Path)|$($hash.Hash)"
        }

        $hashes | Out-File -FilePath C:\baseline.txt -Append
    }
    "B" {
        Write-Host "Read existing basefile.txt, then start monitoring files" -ForegroundColor Yellow

        $fileHashDictionary = @{}

        # Load file|hash from baseline.txt and store them in a dictionary
        $filePathsAndHashes = Get-Content -Path C:\baseline.txt

        foreach ($f in $filePathsAndHashes) {
            $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        }

        while ($true) {

            Start-Sleep - seconds 1

            $fileLocation = Get-ChildItem -Path (Read-Host -Prompt "Path")

            # For each file, calculate the hash, and write to baseline.txt
            $hashes = 
            foreach ($f in $fileLocation) {
                $hash = Calculate-File-Hash $f.FullName
                "$($hash.Path)|$($hash.Hash)"
            }
            
            $hashes | Out-File -FilePath C:\baseline.txt -Append

            # Notify if a new file has been created
            if ($Null -eq $fileHashDictionary[$hash.Path]) {
                # A new file has been created
                Write-Host "$(hash.Path) has been created!" -ForegroundColor Magenta
            }
            else {
                # Notify if a new file has been changed
                if($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    # File has not changed
                    Write-Host "$($hash.Path) has not changed!" -ForegroundColor Yellow
                }
                else {
                    # File has been compromised, notify the user
                    Write-Host "$($hash.Path) has changed!" -ForegroundColor Red
                }
            }
        }
    }
    default {Write-Warning "Invalid choice, please select 'A' or 'B'"}
}