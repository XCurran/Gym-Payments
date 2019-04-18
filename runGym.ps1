# Get script directory
Function Get-ScriptDirectory
{
$Invocation = (Get-Variable MyInvocation -Scope 1).Value
Split-Path $Invocation.MyCommand.Path
}

# For calculating months passing over to the next year and the remainder
Function Get-Remainder
{
    Param([int]$year, [int]$userYear, [int]$month)
    If($year -gt $userYear)
    {
        $TrueMonth = (($year - $userYear) * 12) + $month
        $remainder = ((($TrueMonth + 1) - $content[$i]) * 45) - $content[$i+2]
        Return $remainder
    }
    ElseIf($year -lt $userYear)
    {
        $TrueMonth = (($userYear - $Year) * 12) + $month
        $remainder = ((($TrueMonth + 1) - $content[$i]) * 45) - $content[$i+2]
        Return ($remainder * (-1))
    }
    Else
    {
        $TrueMonth = $month
        $remainder = ((($TrueMonth + 1) - $content[$i]) * 45) - $content[$i+2]
        Return $remainder
    }
}

Function Get-UserID
{
    $check = $True
    While($check)
    {
        $ID = Read-Host "What is your User ID? (1-$($user.length-1))"
        If(([int]$ID -lt 5) -AND ([int]$ID -gt 0)){
            Return [int]$ID
            $check = $False
        }
        Write-Host "Please enter a valid user ID!"
    }
}

Function Get-PaymentAmount
{
    $check = $True
    While($check)
    {
        $payment = Read-Host "$($user[$name]), how much are you paying today?"
        If(([int]$payment -lt 300) -AND ([int]$payment -gt 0)){
            Return [int]$payment
            $check = $False
        }
        Write-Host "Please enter a valid payment amount!"
    }
}

# For creating a backup file For version control
Function Set-Backup
{
    Param([string]$username, [int]$payment)
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value "============================================================"
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value "$($user[$name]) ADDED `$$payment TO HIS GYM PAYMENTS."
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value "============================================================"
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value $(Get-Date)
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value "============================================================"
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value $content
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value "------------------------------------------------------------------"
    Add-Content -path "$dir\version_control\$time_log-bill.txt" -value ""
    Write-Host "Backup file created: $time_log-bill.txt"
}

# Some location stuff
$dir = Get-ScriptDirectory
$file = "$dir\bill.txt"

# Get file content
$content = Get-Content -Path $file

# You can modify the list of months and people here
$ListofMonths = @("", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
$user = @("", "Javan", "Sunjer", "Kras", "Chow")

# Get current time, month and year
$date = Get-Date -DisplayHint Date
$month = [int](Get-Date -UFormat %m)
$year = [int](Get-Date -UFormat %Y)

$time_log = Get-Date -Format FileDate

$loop = $True

# The main program
While($loop){

    $ID = 1

    Write-Host ""
    Write-Host "Today's date:"
    $date
    Write-Host ""

    # Parsing the text file 
    For($i=0; $i -lt $content.length; $i++)
    {
        # Javan
        Write-Host "Name: $($content[$i]) ($ID)"
        $i += 1
        # 4, 2019, 2.5
        Write-Host "Month Paid: $($ListofMonths[$($content[$i])]), $($content[$i+1]) || `$$($content[$i+2])/45"

        $remainder = Get-Remainder -year $year -userYear $content[$i+1] -month $month
        
        Write-Host "Total owed: `$$remainder"
        $i += 3
        Write-Host "Last updated: $($content[$i])"
        Write-Host ""

        $ID += 1
    }

    Write-Host "What do you want to do?"
    $intro = Read-Host "(1) Add payments, or press any key to exit."

    If($intro -eq 1)
    {
        $name = Get-UserID
        $payment = Get-PaymentAmount 
        $confirm =  Read-Host "Confirm payment: $($user[$name]) -> `$$payment || Press enter to confirm, or press any other key to cancel."
        If($confirm -eq "")
        {
            Set-Backup -username $user[$name] -payment $payment
            $location = ((($name - 1) * 5) + 3)
            [int]$content[$location] += $payment

            While($content[$location] -gt 45)
            {
                [int]$content[$location-2] += 1
                If($content[$location-2] -gt 12)
                {
                    $content[$location-2] = 1
                    [int]$content[$location-1] += 1
                }
                [int]$content[$location] -= 45
            }

            $content[$location+1] = $date
            $content | Set-Content -Path $file
            Write-Host "============================================================"
            Write-Host "$($user[$name]) ADDED `$$payment TO HIS GYM PAYMENTS."
            Write-Host "============================================================"
            Write-Host $(Get-Date -DisplayHint Date)
            Write-Host "============================================================"
            Start-Sleep -s 2
        }
        Else{
            Write-Host "Payment cancelled."
        }
    }
    Else
    {
        $loop = $False
    }
}