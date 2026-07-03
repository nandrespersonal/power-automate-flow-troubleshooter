[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RunUrl,

    [ValidateRange(1, 100)]
    [int]$MaxActions = 100,

    [ValidateRange(1, 100)]
    [int]$MaxRepetitions = 25,

    [switch]$RawLocalOutput
)

$ErrorActionPreference = 'Stop'

function Import-PowerAppsModules {
    $moduleNames = @(
        'Microsoft.PowerApps.Administration.PowerShell',
        'Microsoft.PowerApps.PowerShell'
    )

    foreach ($moduleName in $moduleNames) {
        if (Get-Module -ListAvailable -Name $moduleName) {
            Import-Module $moduleName -ErrorAction Stop
        }
    }
}

function Assert-CommandAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Command -Name $Name -ErrorAction SilentlyContinue)) {
        throw "Required PowerApps PowerShell command '$Name' is unavailable. Import/install the Microsoft PowerApps PowerShell modules, then retry."
    }
}

function Ensure-FlowAuth {
    Import-PowerAppsModules

    Assert-CommandAvailable -Name 'Get-JwtToken'
    Assert-CommandAvailable -Name 'InvokeApiNoParseContent'

    try {
        $null = Get-JwtToken -Audience 'https://service.flow.microsoft.com/' 2>$null
        return
    } catch {
        if (-not (Get-Command -Name 'Add-PowerAppsAccount' -ErrorAction SilentlyContinue)) {
            throw "No active Power Platform auth session was found, and Add-PowerAppsAccount is unavailable. Sign in with PowerApps PowerShell, then retry. Original error: $($_.Exception.Message)"
        }
    }

    $null = Add-PowerAppsAccount
    $null = Get-JwtToken -Audience 'https://service.flow.microsoft.com/' 2>$null
}

function Parse-RunUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $patterns = @(
        '/environments/([^/]+)/flows/shared/([^/]+)/runs/([^/?#]+)',
        '/environments/([^/]+)/flows/([^/]+)/runs/([^/?#]+)'
    )

    foreach ($pattern in $patterns) {
        if ($Url -match $pattern) {
            return [pscustomobject]@{
                EnvironmentId = [uri]::UnescapeDataString($Matches[1])
                FlowId        = [uri]::UnescapeDataString($Matches[2])
                RunId         = [uri]::UnescapeDataString($Matches[3])
            }
        }
    }

    throw 'Unsupported Power Automate run URL. Expected /environments/<envId>/flows/shared/<flowId>/runs/<runId> or /environments/<envId>/flows/<flowId>/runs/<runId>.'
}

function Invoke-FlowGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Route
    )

    $result = InvokeApiNoParseContent -Method GET -Route $Route -ThrowOnFailure
    if (-not $result.Content) {
        return $null
    }

    return $result.Content | ConvertFrom-Json
}

function Invoke-OptionalFlowGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Route
    )

    try {
        return Invoke-FlowGet -Route $Route
    } catch {
        return $null
    }
}

function ConvertTo-SafeAction {
    param(
        [Parameter(Mandatory = $true)]
        $Action
    )

    $errorObject = $Action.properties.error
    $safeError = $null
    if ($errorObject) {
        $safeError = [pscustomobject]@{
            Code    = $errorObject.code
            Message = if ($errorObject.message) { [string]$errorObject.message } else { $null }
        }
    }

    $safe = [ordered]@{
        Name       = $Action.name
        Status     = $Action.properties.status
        Code       = $Action.properties.code
        StartTime  = $Action.properties.startTime
        EndTime    = $Action.properties.endTime
        Error      = $safeError
    }

    if ($RawLocalOutput) {
        $safe.Inputs = $Action.properties.inputs
        $safe.Outputs = $Action.properties.outputs
    } else {
        $safe.HasInputs = $null -ne $Action.properties.inputs
        $safe.HasOutputs = $null -ne $Action.properties.outputs
    }

    return [pscustomobject]$safe
}

function Get-NonSucceededActions {
    param(
        [object[]]$Actions
    )

    return @($Actions | Where-Object { $_.properties.status -notin @('Succeeded', 'Skipped') })
}

function Get-RepetitionDiagnostics {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,

        [Parameter(Mandatory = $true)]
        [string]$RunId,

        [Parameter(Mandatory = $true)]
        [object[]]$Actions,

        [Parameter(Mandatory = $true)]
        [int]$Limit
    )

    $findings = @()
    $endpointShapes = @(
        @{ RepetitionSegment = 'repetitions'; Label = 'loop repetition' },
        @{ RepetitionSegment = 'scopeRepetitions'; Label = 'scope repetition' }
    )

    foreach ($action in $Actions) {
        foreach ($shape in $endpointShapes) {
            $segment = $shape.RepetitionSegment
            $label = $shape.Label
            $repRoute = "$BaseUrl/runs/$RunId/actions/$($action.name)/$segment`?api-version=2016-11-01"
            $repResponse = Invoke-OptionalFlowGet -Route $repRoute

            if (-not $repResponse -or -not $repResponse.value) {
                continue
            }

            $repetitions = @($repResponse.value) | Select-Object -First $Limit
            $interestingRepetitions = @($repetitions | Where-Object {
                $_.properties.status -notin @('Succeeded', 'Skipped') -or
                $_.properties.error -or
                $_.properties.code
            })

            foreach ($rep in $interestingRepetitions) {
                $childRoute = "$BaseUrl/runs/$RunId/actions/$($action.name)/$segment/$($rep.name)/actions`?api-version=2016-11-01"
                $childResponse = Invoke-OptionalFlowGet -Route $childRoute
                $children = if ($childResponse -and $childResponse.value) { @($childResponse.value) } else { @() }
                $nonSucceededChildren = Get-NonSucceededActions -Actions $children

                $findings += [pscustomobject]@{
                    ParentActionName     = $action.name
                    ParentActionStatus   = $action.properties.status
                    RepetitionType       = $label
                    RepetitionName       = $rep.name
                    RepetitionStatus     = $rep.properties.status
                    RepetitionCode       = $rep.properties.code
                    RepetitionError      = if ($rep.properties.error) { $rep.properties.error } else { $null }
                    ChildActionCount     = @($children).Count
                    NonSucceededChildren = @($nonSucceededChildren | ForEach-Object { ConvertTo-SafeAction -Action $_ })
                }
            }
        }
    }

    return $findings
}

function Get-FailureCategory {
    param(
        [string[]]$Messages
    )

    $text = ($Messages -join "`n").ToLowerInvariant()

    if ($text -match 'unauthorized|authentication|token|sign.?in|login') { return 'authentication or token failure' }
    if ($text -match 'forbidden|access denied|does not have permission|not authorized') { return 'authorization / missing permission' }
    if ($text -match 'connection|connector') { return 'connector or connection failure' }
    if ($text -match 'excel|workbook|worksheet|table|row|column') { return 'Excel/table/schema failure' }
    if ($text -match 'teams|channel|chat|message') { return 'Teams posting failure' }
    if ($text -match 'http|status code|404|409|429|500|502|503|504') { return 'HTTP/API failure' }
    if ($text -match 'expression|template language|null|array|object|property') { return 'expression or data-shape failure' }
    if ($text -match 'repetition|foreach|loop|scope') { return 'loop/repetition child-action failure' }
    if ($text -match 'timeout|timed out|throttl') { return 'timeout or throttling' }

    return 'unknown / needs escalation'
}

$ids = Parse-RunUrl -Url $RunUrl
Ensure-FlowAuth

$baseUrl = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$($ids.EnvironmentId)/flows/$($ids.FlowId)"
$run = Invoke-FlowGet -Route "$baseUrl/runs/$($ids.RunId)?api-version=2016-11-01"
$actionsResponse = Invoke-FlowGet -Route "$baseUrl/runs/$($ids.RunId)/actions?api-version=2016-11-01"

$actions = @($actionsResponse.value) | Select-Object -First $MaxActions
$failedActions = @($actions | Where-Object { $_.properties.status -in @('Failed', 'TimedOut') })
$skippedActions = @($actions | Where-Object { $_.properties.status -eq 'Skipped' })
$repetitionFindings = @(Get-RepetitionDiagnostics -BaseUrl $baseUrl -RunId $ids.RunId -Actions $actions -Limit $MaxRepetitions)

$messages = @()
foreach ($action in $failedActions) {
    if ($action.properties.error.message) {
        $messages += [string]$action.properties.error.message
    }
    if ($action.properties.code) {
        $messages += [string]$action.properties.code
    }
}
foreach ($finding in $repetitionFindings) {
    $messages += [string]$finding.RepetitionType
    if ($finding.RepetitionError.message) {
        $messages += [string]$finding.RepetitionError.message
    }
    foreach ($child in @($finding.NonSucceededChildren)) {
        if ($child.Error.Message) {
            $messages += [string]$child.Error.Message
        }
        if ($child.Code) {
            $messages += [string]$child.Code
        }
    }
}

$diagnosis = [ordered]@{
    Mode = 'diagnose'
    ParsedIds = [ordered]@{
        EnvironmentId = $ids.EnvironmentId
        FlowId        = $ids.FlowId
        RunId         = $ids.RunId
    }
    Run = [ordered]@{
        Name      = $run.name
        Status    = $run.properties.status
        StartTime = $run.properties.startTime
        EndTime   = $run.properties.endTime
        Code      = $run.properties.code
    }
    ActionSummary = [ordered]@{
        Total      = @($actions).Count
        Failed     = @($failedActions).Count
        Skipped    = @($skippedActions).Count
        Successful = @($actions | Where-Object { $_.properties.status -eq 'Succeeded' }).Count
        TimedOut   = @($actions | Where-Object { $_.properties.status -eq 'TimedOut' }).Count
        RepetitionFindings = @($repetitionFindings).Count
    }
    LikelyFailureCategory = Get-FailureCategory -Messages $messages
    FailedActions = @($failedActions | ForEach-Object { ConvertTo-SafeAction -Action $_ })
    SkippedActions = @($skippedActions | ForEach-Object { ConvertTo-SafeAction -Action $_ })
    RepetitionFindings = $repetitionFindings
    RawLocalOutputIncluded = [bool]$RawLocalOutput
    SafetyNote = if ($RawLocalOutput) {
        'Raw local output was requested. Do not paste sensitive action inputs/outputs into broad channels.'
    } else {
        'Action inputs and outputs were not expanded. Use -RawLocalOutput only for local-only troubleshooting.'
    }
}

$diagnosis | ConvertTo-Json -Depth 20
