

# concept and design - Arshad
# script will perform the pre-check required for OS upgrade including ISO copying
# always RUn the script in RUn as admin mode in powershell
#next duty to enter the drive letter and select the ISO rest will be performed by the script

<#reate localadmin in 2016 and above
$PASSWORD= ConvertTo-SecureString –AsPlainText -Force -String Welcome@123
New-LocalUser -Name "admin" -Description "for MG" -Password $PASSWORD
Add-LocalGroupMember -Group "Administrators" -Member "admin"
#>



#css - design for HTML page

$css = @"
<style>
h1,h3,h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$pcname=$env:computername


$username= "admin"


$user= Get-LocalUser -name $username

if ($user) {
Remove-LocalUser -name $username
write-host " user present - removed the user $username from the system "
}
else {
write-host "user didnot present $username from the system "
}



                                                                            
#check if c:\temp\post exist else create it 

$Folder_out = 'C:\Temp\post'
"Test to see if folder [$Folder_out]  exists"
if (Test-Path -Path $Folder_out) {
    "Path exists!"
} else {

    New-Item -Path "c:\temp" -Name "Post" -ItemType "directory"
    " c:\Temp\post Folder created"
}



#report section


Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID,@{n='size(GB)';e={[int]($_.size /1GB)}},@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }} |Export-csv -Path "c:\temp\post\diskinfo.csv"

Get-WmiObject -Class Win32_Product |select Name,version|Export-Csv -path "C:\temp\post\installed_apps.csv"
Get-Service | where {$_.Status -eq "Running"} | Select StartType, Status, Name, DisplayName|Export-Csv -path "C:\temp\post\All_services.csv"
Get-WindowsFeature | Where-Object {$_. installstate -eq "installed"} | select DisplayName,Name,Installstate |Export-Csv -path "C:\temp\Post\RolesandFeature.csv"
Get-CimInstance -Class Win32_OperatingSystem |select  Version,Caption,BuildNumber,Manufacturer| Export-Csv -path "c:\temp\post\osinfo.csv"
#Get-LocalGroupMember -group "administrators" | Out-File -filepath "c:\temp\admin_info.txt"
net localgroup "administrators" >>c:\temp\post\local_admin.csv
ipconfig /all >>c:\temp\Post\ipinfo.csv


Write-Host "============================================================================================================================="
Write-Host "                                                                               "
Write-Host "A copy of all required pre-check information has been made to C:/Temp `nfile name are : `nAll_services.csv `nadmin_info.csv `nipinfo.csv `ninstalled_apps.txt `nInstalledRolesandFeatures.csv " -ForegroundColor Green -BackgroundColor black
Write-Host "                                                                               "
Write-Host "=============================================================================================================================="
Write-Host "                                                                                "



# v1.3 email Change in html format

$file1= "c:\temp\post\osinfo.csv"
$file2= "c:\temp\Post\diskinfo.csv"
$file3= "c:\temp\post\ipinfo.csv"
$file4= "c:\temp\post\local_admin.csv"
$file5= "C:\temp\Post\RolesandFeature.csv"
$file6= "c:\temp\Post\All_Services.csv"
$file7= "c:\temp\Post\installed_apps.csv"

$Report1 = Import-CSV $file1 |ConvertTo-Html -Head $css -Body "<h3>HI,  `nFYI. OS-upgrade POST check has been completed for the server - $pcname. C:/temp has been used to store all reports, and ISO copied to  $folder.<p>`nPlease Note: Prior to upgrading, make sure the Clone/Snapshot was successful. Also, make sure there is sufficient disk space​ in C: Drive</p></h3>`n<h5>Current OS info </h5> `n<h5> Generated on $(Get-Date)</h5>"| Out-File C:\temp\post\post-check.html
$Report2 = Import-Csv $file2 |ConvertTo-Html -Head $css -Body "<h1> Available Disk Info.</h1> `n<h5>C drive must have at least 25GB free space for 2k19 upgrade</h5>"|Add-Content -Path C:\temp\pre-check.html
$Report3 = Import-Csv $file3 |ConvertTo-Html -Head $css -Body "<h1>Network Info</h1> `n<h5>IP address and other Info</h5>"|Add-Content -Path C:\temp\post\post-check.html
$Report4 = Import-csv $file4 |ConvertTo-Html -Head $css -Body "<h1>Local Admin INfo....</h1> `n<h5>administrators Group Members- look for admin</h5>"|Add-Content -Path C:\temp\post\post-check.html
$Report5 = Import-csv $file5 |ConvertTo-Html -Head $css -Body "<h1>Installed Roles and Features </h1>"|Add-Content -Path C:\temp\post\post-check.html
$Report6 = Import-Csv $file6 |ConvertTo-Html -Head $css -Body "<h1>Running service Information </h1>"|Add-Content -Path C:\temp\post\post-check.html
$Report7 = Import-csv $file7 |ConvertTo-Html -Head $css -Body "<h1>Installed Application Info </h1>"|Add-Content -Path C:\temp\post\post-check.html

Start-Sleep -Seconds 20
$Email_body = Get-Content "C:\temp\post\post-check.html" -raw
$builder = "arshad.pulikkal@news.com.au"
$Smtp_address = "smtp.news.newslimited.local"
$To ="dl-scomalertnotifications@news.com.au"



#updatd TO email address before sending 

Send-MailMessage -Body "$Email_body <br>Wintel Team<br> "-BodyAsHtml -From "OSupgradePost-check@news.com.au" -To $To -Cc $builder -Subject "OSupgrade post-check completion- $pcname - $(Get-Date)" -SmtpServer $Smtp_address


Write-Host "*************************************************************************************************** "-ForegroundColor Yellow -BackgroundColor black
Write-Host "                                                                                                                                    "
Write-Host "                                                                                                                                    "
Write-Host "                                                                                                                                    "
Write-Host "============ Prior to upgrading, make sure the clone/snippet was successful. Also, make sure there is sufficient disk space​ in C: Drive ==============" -ForegroundColor Green -BackgroundColor Black
Write-Host "                                                                                                                                    "
Write-Host "                                                                                                                                    "
Write-Host "                                                                                                                                    "
Write-Host "                                                                                                                                    "
Write-Host "============ The activity has been completed- you will receive an e-mail notification shortly ===================" -ForegroundColor cyan -BackgroundColor Black
Write-Host "                                                                                                                                    "
Write-Host "***************************************************************************************************** "-ForegroundColor Yellow -BackgroundColor black