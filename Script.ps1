## -
## - Downloaded from micro-one.com
## - Operational Security
## -
## - Antivirus test on network share
## - Script to test the antivirus protection on network share
## - Creation date        :: 06/06/2014
## - Last update on 	  :: 04/06/2025
## - Author 		      :: Micro-one (contact@micro-one.com)
## -
## ------

## --
## Set time interval beteween tests
## --
#
## Here default value, as a template
# $intervalMinutes = 5 		 		 		 		 		 		 		# Interval between each test (here, 5 minutes)
# $waitAfterWriteSeconds = 20 		 		 		 		 		 		# Delay after writing before verification (here, 20 seconds)

$intervalMinutes = 5 		 		 		 		 		 		 		# Interval between each test (in minutes)
$waitAfterWriteSeconds = 20 		 		 		 		 		 		# Delay after writing before verification (in seconds)


## --
## Set network drive
## --
#
## Here default value, as a template
# $uncPaths = @("\\192.168.1.1\temp$", "\\192.168.1.2\temp$") 		 	 	# Table of UNC paths to test, here 192.168.x.y shared folder

$uncPaths = @("\\192.168.1.1\temp$", "\\192.168.1.2\temp$") 		 	 		# Table of UNC paths to test, separated by a coma

## --
## Set SMTP server for email notifications
## --
#
## Here default value, as a template
# $adminEmail = "contact@example.org" 		 		 		 		 		# Operational management email (To), here "contact@example.org"
# $emailSubject = "Antivirus not working - File not deleted"		 		# Subject of the email
# $smtpServer = "smtp.example.com"	 		 		 		 		 		# SMTP Server
# $smtpPort = 587 		 		 		 		 		 		 		 	# SMTP Port - default value 587, or 25 in clear text
# $smtpUser = "smtp-user@example.com"		 		 		 		 		# SMTP Server
# $smtpPassword = "Pa$$w0rd" | ConvertTo-SecureString -AsPlainText -Force  # SMTP Password and data processing

$adminEmail = "contact@example.org" 		 		 		 		 	 	# Operational management email (To)
$emailSubject = "Antivirus not working - File not deleted"		 		# Subject of the email

$smtpServer = "smtp.example.com"	 		 		 		 		 		# SMTP Server
$smtpPort = 587 		 		 	 		 		 		 		 		# SMTP Port - default value 587, or 25 in clear text
$smtpUser = "smtp-user@example.com"	 		 		 		 		 		# SMTP Server
$smtpPassword = "Pa$$w0rd" | ConvertTo-SecureString -AsPlainText -Force		# SMTP Password and data processing

## --
## Set email template
## --
#
## Here default value, as a template
# $emailTemplate = @"	 		 		 		 			 		 		# Message template to security team
# Hello,
# 
# The EICAR test file was not deleted from the following path after $waitAfterWriteSeconds seconds:
# 
# Path: {0}
# Date: {1}
# 
# Please check that your antivirus or security system is working properly.
# 
# Sincerely,
# The monitoring script
# "@

$emailTemplate = @"
Hello,

The EICAR test file was not deleted from the following path after $waitAfterWriteSeconds seconds:

Path: {0}
Date: {1}

Please check that your antivirus or security system is working properly.

Sincerely,
The monitoring script
"@

## --
# EICAR string - DO NOT EDIT
$eicarContent = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'

## --
# SMTP Password data management - DO NOT EDIT
$credential = New-Object System.Management.Automation.PSCredential($smtpUser, $smtpPassword)

##
## -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
## Begin script
## -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
#
# Main loop
while ($true) {
    foreach ($path in $uncPaths) {
        try {
            $fileName = "EICAR_$(Get-Random).txt"
            $filePath = Join-Path -Path $path -ChildPath $fileName

            # Écriture du fichier EICAR
            Set-Content -Path $filePath -Value $eicarContent -Encoding ASCII -ErrorAction Stop
            Write-Host "[$(Get-Date)] Fichier écrit : $filePath"

            Start-Sleep -Seconds $waitAfterWriteSeconds

            # Vérifie si le fichier est toujours présent
            if (Test-Path -Path $filePath) {
                Write-Warning "[$(Get-Date)] Fichier toujours présent après $waitAfterWriteSeconds secondes !"

                $messageBody = [string]::Format($emailTemplate, $filePath, (Get-Date))
                Send-MailMessage -To $adminEmail `
                                 -From $smtpUser `
                                 -Subject $emailSubject `
                                 -Body $messageBody `
                                 -SmtpServer $smtpServer `
                                 -Port $smtpPort `
                                 -UseSsl `
                                 -Credential $credential

                Write-Host "[$(Get-Date)] Email envoyé à $adminEmail"
            }
        } catch {
            Write-Error "Erreur lors du traitement du chemin '$path' : $_"
        }
    }

    Write-Host "[$(Get-Date)] Attente de $intervalMinutes minute(s) avant le prochain test..."
    Start-Sleep -Seconds ($intervalMinutes * 60)
}
## --
## end script
##
