$AD_list = Get-ADComputer -Filter * | select Name
$Online_list = @()
$Offline_list = @()
$Results = @()

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


Foreach ($item in $Temp_List) {
  Echo "DEBUG: Probing $item.."
  If (Test-Connection -Count 1 -ComputerName "$item" -Quiet)
  {
		Echo "	DEBUG: $item online..."
    #$Results += Invoke-Command -ComputerName "$item" -ScriptBlock { }
    $Online_list += Get-LocalGroupMember -Group "Administrators" |
    Select @{N="$item";E={$_.Name}}, @{N="Source";E={$_.PrincipalSource}} | ConvertTo-HTML -Fragment -as Table
  }
  Else
  {
    Echo "	DEBUG: $item offline..."
    $Offline_list += $item
  }
}

ConvertTo-HTML -Head $Table_Headers -PreContent $Online_list > index.html
