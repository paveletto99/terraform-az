param(
  [Parameter(Mandatory=$true)]
  [string]$ResourceGroupName,
  [Parameter(Mandatory=$true)]
  [string[]]$VMNames
)
Connect-AzAccount -Identity
foreach ($vmName in $VMNames) {
  Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Force
}