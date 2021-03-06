<#
.SYNOPSIS  
  The script collects all certficates under current user persoanl store and report on Subject,Thumbprint and Certficate and private key sizes
.DESCRIPTION
  Script gets ID of currently logged on user and then collect data from CurrentUser\My store. The script has limited output to the screen and all data is saved under a csv file located in the same directory from where the script is run.
  DISCLAIMER
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
    We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object
    code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software
    product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the
    Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims
    or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
    Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within
    the Premier Customer Services Description.
  
  .EXAMPLE
  powershell -executionpolicy bypass -file .\User-LocalcertSize.ps1
   Starts script for non priveleged user from command prompt
   
#>

$myCerts = Get-Item Cert:\CurrentUser\My
$myCerts.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$allcerts = Get-ChildItem  $myCerts.PSPath
$report = @()
foreach($usercert in $allcerts)
{
 
 if ($usercert.HasPrivateKey)
  {
    $PrivateKeyName = $usercert.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
    $PrivateKeySize =  $usercert.PrivateKey.KeySize
   }
  Else
  {
  
   $PrivateKeyName = "NONE"
    $PrivateKeySize =  0
  
  }
  

 $item = New-Object -TypeName psobject -Property @{
 "Subject" = $usercert.Subject
 "Thumbprint" = $usercert.Thumbprint
 "CertSizeBytes" = $usercert.RawData.Length
 "PrivateKeyName" = $PrivateKeyName
 "PrivateKeySize" = $PrivateKeySize
  }
  $Report += $item
 }

$Report | format-table "Thumbprint","CertSizeBytes","PrivateKeySize" -AutoSize 
$Report | export-csv "./$($env:USERNAME)-certreport.csv" -Force -NoTypeInformation
write-host "Full report can be found in a file ./$($env:USERNAME)-certreport.csv"