#oneline bulk disable ADuser

Get-content "user.txt" | ForEach-Object -Process { Disable-ADAccount -Identity $_ }

#---------------------------

#check user status and export in excel

Get-content "user.txt" | ForEach-Object -Process { Get-ADUser -Identity $_ -Server '[GlobalCatalogAddress:port]' | Select-Object -Property samaccountname,enabled | Export-Csv userStatus.csv -NoTypeInformation}
#exploded version
$users = Get-content "user.txt"  #txt file with users to unlock
$server = "globalCatalog:port" #GC server  - DON'T CHANGE

foreach ($user in $users)
{
    Get-ADUser -Identity $user -Server $server | Select-Object -Property samaccountname,enabled | Export-Csv userStatus.csv -NoTypeInformation
}

#---------------------------------

#uninstall sw on specific server the csv file need to have the following column name: ComputerName,Domain,SwName

$csv = Import-Csv "toberemoved.csv" -Delimiter ';'

foreach($dc in $csv)
{write-host "------------------"
    Write-Host $dc.Computername

    $app = Get-WmiObject -Class Win32_Product -Computer $dc.Computername | Where-Object { $_.name -eq $dc.SwName } #uninstalling sw
        if($app)
        {
            Write-Host  "Removing:" $dc.SwName -ForegroundColor Green
            $app.Uninstall()
        }
}

#---------------------------
#disable/stop services in bulk, from a list of ip/hostname

$service = "Spooler" #service name
$pcs = Get-Content c:\temp\ip.txt #list of ip address/hostname where disable it
foreach ($computer in $pcs)
{ 
$result = (gwmi win32_service -computername $computer -filter "name='$service'").stopservice()
$result = (gwmi win32_service -computername $computer -filter "name='$service'").ChangeStartMode("Disabled") 
} 
#$result = (gwmi win32_service -computername $computer -filter "name='$service'").stopservice() 
#$result = (gwmi win32_service -computername $computer -filter "name='$service'").ChangeStartMode("Disabled") 
#$result = (gwmi win32_service -computername $computer -filter "name='$service'").ChangeStartMode("Automatic") 
#-----------------------------
# 
