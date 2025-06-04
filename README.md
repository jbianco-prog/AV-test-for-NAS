# AV-test-for-NAS
Check if your NAS infrastructure has active antimalware (EICAR loop test)

This script is based on Powershell, it runs a test by writing an EICAR file (EICAR 64-byte character string, antivirus test) on each UNC path that represents your NAS infrastructures, if the file remains present after a delay, it means that your protection is not active and warns you by email. The original version of this script dates from 2014 and was built in CMD, the native evolution makes it a Powershell script