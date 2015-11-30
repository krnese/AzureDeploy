Param (
    [Parameter(Mandatory=$true)]
    [int]$count
)

$img = Get-ContainerImage
$ConNames =@(1..$count)

if ($count -ge 2)

    {
        Foreach ($Con in $ConNames) 

            {
                $Con = "WinCon"+$Count 
                new-container -name $con -ContainerImage $img -SwitchName (Get-VMSwitch).Name -RuntimeType Default -ContainerComputerName $con 
            }
    }

else
    {
        new-container -name Tp4 -ContainerImage $img -SwitchName (Get-VMSwitch).Name -RuntimeType Default -ContainerComputerName Tp4 
    }
