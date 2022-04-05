#Ethan Suhr - 2022

#Define Variables
$Date = Get-Date -Format "MM-dd-yyyy"
$Name = "Hotfix_Report_$Date.html"

#Must explicity declare array otherwise will fail.
#This is b/c offline computers are stored in one table
$Offline_Comp = @()

#Grab list of computers
$AD_List = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
#Remove undesired computers. Ex) For locked down servers or RPC disabled computers
#$To_Scan = $AD_List | Select-string -pattern $Unwanted_List -notMatch

#Set CSS
$Page_Header = "<h1><b>Hotfix Report for $Date</b></h1>"
$Table_Headers = @"
<style>
table {
		font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
		width: 40%;
		border-collapse: collapse;
		margin-bottom: 20px;
		position: relative;
		margin-right: auto;
		margin-left: auto;
}
th {
		padding-top: 8px;
		padding-bottom: 8px;
		text-align: center;
		background-color: #30629B;
		color: White;
		width: 25%;
}
td {
		text-align: center;
		border: 1px ridge;
}
tr:nth-child(even) {
	background-color: #f2f2f2;
}
tr:hover {
	background-color: silver;
}
h1 {
	font-size: 3em;
	text-align: center;
}
</style>
"@

#Check if pc online or offline
#If online, grab security update, add to own table
#If offline, add to congregate table
Foreach ($item in $To_Scan) {
	If (Test-Connection -Count 1 -ComputerName "$item" -Quiet) {
		$Online_Table += Get-HotFix -ComputerName "$item" |
		Select-object @{N="$item";E={$_.PSComputerName}}, Description, @{N="Installed On";E={$_.InstalledOn.toshortdatestring()}}, @{N="Hot Fix ID";E={[int]$_.HotFixID.substring(2)}} |
		Where-object {$_.Description -EQ 'Security Update'} |
		Sort -descending "Hot Fix ID" |
		ConvertTo-HTML -Fragment
}
	Else {
		$Offline_Comp += Get-ADComputer -Identity "$item" -Properties * | select @{N="Offline Workstations";E={$_.Name}}, @{N="Last Logon";E={$_.LastLogonDate}} | sort -descending "Last Logon"
} }
$Offline_Table = [PSCustomobject]$Offline_Comp | ConvertTo-HTML -Fragment -As Table

#Create Final HTML Document
ConvertTo-HTML -Head $Page_Header -PreContent $Table_Headers -Body $Online_Table -PostContent $Offline_Table | out-file .\$Name
