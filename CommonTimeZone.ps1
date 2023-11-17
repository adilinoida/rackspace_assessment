<#
.SYNOPSIS
This function retrieves common time zones by using the provided name and offset inputs.

.DESCRIPTION
The Get-CommonTimeZone function retrieves time zone data in JSON format from a designated GitHub URL and applies filters based on the given parameters. Time zones can be filtered by either their name or offset value.

.PARAMETER Name
This parameter defines the time zone name for filtering. It is optional; if provided, the function will filter time zones that contain the specified name.

.PARAMETER Offset
This parameter allows filtering time zones based on their offset value. It is optional; if provided, the function will filter time zones with the specified offset value, which should fall between -12 and 12.

.EXAMPLE
Get-CommonTimeZone -Name 'Asia'
Retrieves time zones with the name "Asia".

.EXAMPLE
Get-CommonTimeZone -Offset 10
Retrieves time zones with an offset of 10 hours.

#>
function Get-CommonTimeZone {

    [CmdletBinding()]
    
    # Define function parameters
    param (
        [Parameter(Mandatory = $false)]
        [string]$Name, # Name of the time zone to filter (optional)
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(-12, 12)]
        [int]$Offset     # Offset value of the time zone to filter (optional)
    )

    # URL to fetch time zone data
    $uri = "https://raw.githubusercontent.com/dmfilipenko/timezones.json/master/timezones.json"
	
    try {
    
        Write-Verbose "Fetching time zone data from $uri"
		
        # Invoke REST method to get time zone data from the specified URL
        $timeZones = Invoke-RestMethod -Uri $uri -Method Get -UseBasicParsing
		
        Write-Verbose "Time zone data fetched successfully."
    }
    catch {
        Write-Error "Failed to fetch time zone data from $uri. $_"
        return
    }

    # Check if both Name and Offset parameters are provided
    if ($Name -and $Offset) {
        Write-Error "Cannot specify both 'Name' and 'Offset' parameters simultaneously."
        return
    }

    # Filter time zones based on the provided Name parameter
    if ($Name) {
        $timeZones = $timeZones | Where-Object { $_.value -match $Name }
        Write-Verbose "Filtering time zones by name: $Name"
    }

    # Filter time zones based on the provided Offset parameter
    if ($Offset) {
        $timeZones = $timeZones | Where-Object { $_.Offset -eq $Offset }
        Write-Verbose "Filtering time zones by offset: $Offset"
    }

    # Return the filtered time zone data
    return $timeZones
}

# Example usage: Get time zones with an offset of 10 hours and format the output as a table
Get-CommonTimeZone -Offset 10 | Format-Table


# Example usage: Get time zones with Name containing 'Asia' and format the output as a table
Get-CommonTimeZone -Name 'Asia' | Format-Table
