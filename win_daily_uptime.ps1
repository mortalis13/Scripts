# Collects total OS uptime by day for the last 7 days
# Run with "powershell .\win_daily_uptime.ps1"

# Define date range (last 7 days)
$endDate = Get-Date
$startDate = $endDate.AddDays(-7)

# Relevant Event IDs
$eventIDs = @(6005, 6006)

# Get events from the System log
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Id = $eventIDs
    StartTime = $startDate
    EndTime = $endDate
} | Sort-Object TimeCreated

# Separate into startup and shutdown events
$startups = $events | Where-Object { $_.Id -eq 6005 }
$shutdowns = $events | Where-Object { $_.Id -eq 6006 }

# Match each shutdown to the most recent startup
$sessions = @()
foreach ($shutdown in $shutdowns) {
    $startup = ($startups | Where-Object { $_.TimeCreated -lt $shutdown.TimeCreated } | Select-Object -Last 1)
    if ($startup) {
        $sessions += [PSCustomObject]@{
            StartTime = $startup.TimeCreated
            EndTime   = $shutdown.TimeCreated
            Day       = $startup.TimeCreated.Date
            Uptime    = $shutdown.TimeCreated - $startup.TimeCreated
        }
        # Remove used startup to prevent reuse
        $startups = $startups | Where-Object { $_.TimeCreated -ne $startup.TimeCreated }
    }
}

# Aggregate daily uptimes
$dailyUptime = $sessions |
    Group-Object Day |
    ForEach-Object {
        $uptimeSeconds = ($_.Group | ForEach-Object { $_.Uptime.TotalSeconds }) | Measure-Object -Sum
        [PSCustomObject]@{
            Date   = ([datetime]$_.Name).ToString("yyyy-MM-dd")
            Uptime = [TimeSpan]::FromSeconds($uptimeSeconds.Sum).ToString("hh\:mm")
        }
    } |
    Sort-Object Date -Descending

# Output daily uptime table in desired format
$dailyUptime | Format-Table @{Label="Date";Expression={$_.Date}}, @{Label="Uptime";Expression={$_.Uptime}} -AutoSize

# Calculate and display total uptime in hours
$totalSeconds = ($sessions | ForEach-Object { $_.Uptime.TotalSeconds }) | Measure-Object -Sum
$totalHours = [Math]::Round($totalSeconds.Sum / 3600, 2)
Write-Host "Total Uptime over last 7 days: $totalHours hours"
