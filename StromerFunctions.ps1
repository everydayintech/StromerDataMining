#     ..        ~JYYYYYYYYY5^ JYYYYYYYYYYYY:.JYYYYYYYYYYJ^   ~JYYYYYYYYY?.  7YYYYYYYYYYYYYYYY7.  .7YYYYYYYYYYY~ .JYYYYYYYYYYJ^               
#    .&?       J@@P^^^^^^^^~. ^~^^^#@@Y^^~~.^@@#^^^^^^^#@@~ ?@@G^^^^^^7&@#. #@@7^^^7&@@7^^^?@@#. B@@?^^^^^^^^~. ~@@#^^^^^^~#@@~              
# ...:&Y ..    P@@J                G@@~     ^@@B       P@@? 5@@?       #@&: #@&:    #@&.   .&@&..&@&:           ~@@B       G@@7   .......... 
#^PPPG&#PPPJ   .5BBPPPPPP##P:      G@@!     ^@@&PPPPB#&@&J. Y@@?      .#@&: #@&:   .&@&.   .&@&..&@&GPPPPPPPPG! ~@@&PPPPB#&@&J.  .5PPPPPPPP5.
#    .@J                 J@@5      G@@!     ^@@B    .^G@&?  5@@?       #@&: #@@:   .&@&.   .&@&..&@&.           ~@@B    .^B@&?               
#    .#7       :!!!!!!!!!B@@7      G@@!     ^@@B       B@@~ 7@@B!!!!!!?&@#. #@@:   .&@&.   .&@&. G@@Y!!!!!!!!!: ~@@B       B@@~              
#     .        ^J?????????7^       ^?7.     .7?~       :??:  :7?????????!.  ~?7.    !?7     !?!  .~??????????J^ .7?^       :??.              


#Stromer Data Mining by everydayintech (joel@everydayintech.com)

$Global:API_BASE_URL = 'https://api3.stromer-portal.ch/rapi/mobile/v4.1'
$Global:STROMER_USER_AGENT = 'mystromer/2123 CFNetwork/1399 Darwin/22.1.0'
$Global:STROMER_CLIENT_ID = '4P3VE9rBYdueKQioWb7nv7RJDU8EQsn2wiQaNqhG'

$Global:DATA_DIR = Join-Path $PSScriptRoot 'stromer-data'
$Global:EXPORT_DIR = Join-Path $PSScriptRoot 'export'
$Global:CONFIG_FILE_PATH = Join-Path $PSScriptRoot 'config.json'


function Get-GlobalStromerConfig {
    [CmdletBinding()]
    param()

    $Global:CONFIG = Get-Content -Path $Global:CONFIG_FILE_PATH -Encoding utf8 | ConvertFrom-Json

    #Update read-only global Variables
    $Global:STROMER_AUTHORIZATION = "Bearer $($Global:CONFIG.access_token)"

    $Global:DEFAULT_HEADERS = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Global:DEFAULT_HEADERS.Add("User-Agent", $Global:STROMER_USER_AGENT)
    $Global:DEFAULT_HEADERS.Add("Authorization", $Global:STROMER_AUTHORIZATION)
}

function Save-GlobalStromerConfig {
    [CmdletBinding()]
    param()

    $Global:CONFIG | ConvertTo-Json | Set-Content -Path $Global:CONFIG_FILE_PATH -Encoding utf8
    #Write-Host "Global Stromer Config was saved."
}

function Get-StromerAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $UserName,
  
        [Parameter(Mandatory = $false)]
        [string]
        $PasswordString
    )
    
    <#


    #GET https://stromer-portal.ch/mobile/v4/o/authorize/?response_type=code&scope=bikestatus&client_id=4P3VE9rBYdueKQioWb7nv7RJDU8EQsn2wiQaNqhG 
    #   302 -> https://stromer-portal.ch/mobile/v4/login/?next=/mobile/v4/o/authorize/%3Fresponse_type%3Dcode%26scope%3Dbikestatus%26client_id%3D4P3VE9rBYdueKQioWb7nv7RJDU8EQsn2wiQaNqhG
    Client ID: 4P3VE9rBYdueKQioWb7nv7RJDU8EQsn2wiQaNqhG

    csrftoken=ugKSlMbwsU7jIOgQctLhMuDk098siaZCPw7CjMmMsL3qpLMx0KopjgyUMCn9ySfA; expires=Sun, 12 Nov 2023 13:07:12 GMT; Max-Age=31449600; Path=/; SameSite=Lax
    sessionid=7gdjygsf92rz9otofhm8e36dl1b3hylo; expires=Sun, 27 Nov 2022 13:07:12 GMT; HttpOnly; Max-Age=1209600; Path=/; SameSite=Lax; Secure


    #Login
    #POST 
    csrftoken=ugKSlMbwsU7jIOgQctLhMuDk098siaZCPw7CjMmMsL3qpLMx0KopjgyUMCn9ySfA; expires=Sun, 12 Nov 2023 13:07:12 GMT; Max-Age=31449600; Path=/; SameSite=Lax
    sessionid=7gdjygsf92rz9otofhm8e36dl1b3hylo; expires=Sun, 27 Nov 2022 13:07:12 GMT; HttpOnly; Max-Age=1209600; Path=/; SameSite=Lax; Secure

    csrfmiddlewaretoken	ug7jnRiQiY7beb85Kp66hSXDf1CDnF5LPwu3lRt6iP3iV8EMyGJeOESd1uRkDnlJ
    next	/mobile/v4/o/authorize/?response_type=code&scope=bikestatus&client_id=4P3VE9rBYdueKQioWb7nv7RJDU8EQsn2wiQaNqhG
    username	tom@example.com
    password	xxxxxxxxxxxx

    #Login response

    csrftoken=GbO48qZPM9wTEG6pao65R9s6VdWemoSsgP2LyYMhA8HdSglPWZ8T5kq5LWWGH5CH; expires=Sun, 12 Nov 2023 13:08:16 GMT; Max-Age=31449600; Path=/; SameSite=Lax
    sessionid=4rtc368fr4c17meoy6wj2dcl02mng9lg; expires=Sun, 27 Nov 2022 13:08:16 GMT; HttpOnly; Max-Age=1209600; Path=/; SameSite=Lax; Secure



    #>

    Get-GlobalStromerConfig

    if(!$UserName)
    {
        $UserName = $Global:CONFIG.user_name
    }

    if(!$PasswordString)
    {
        $PasswordString = $Global:CONFIG.user_pass
    }
    
    ### Load Login Page and save csrfmiddlewaretoken & cookies
  
    Write-Host "Loading login page, saving (unauthenticated) cookies and csrfmiddlewaretoken..."
    $response = $null
    $response = Invoke-WebRequest "https://stromer-portal.ch/mobile/v4/o/authorize/?response_type=code&scope=bikestatus&client_id=$($Global:STROMER_CLIENT_ID)" -Method 'GET'
  
    $response.Headers.'Set-Cookie' | Where-Object { $_ -match 'csrftoken=([A-Za-z0-9]{64})' } | Out-Null
    $csrfCookie = $Matches[0]
    $csrfCookieValue = $Matches[1]
  
    $Global:COOKIES = @()
    $Global:COOKIES += [PSCustomObject]@{
        Domain       = 'stromer-portal.ch'
        Name         = 'csrftoken'
        Value        = $csrfCookieValue
        CookieString = $csrfCookie
    }
  
    $response.Headers.'Set-Cookie' | Where-Object { $_ -match 'sessionid=([a-z0-9]{32})' } | Out-Null
    $sessionIdCookie = $Matches[0]
    $sessionIdCookieValue = $Matches[1]
  
    $Global:COOKIES += [PSCustomObject]@{
        Domain       = 'stromer-portal.ch'
        Name         = 'sessionid'
        Value        = $sessionIdCookieValue
        CookieString = $sessionIdCookie
    }
  
    $response.Content -match 'csrfmiddlewaretoken"\svalue="([A-Za-z0-9]{64})">' | Out-Null
    $csrfmiddlewaretoken = $Matches[1]
  
    ### Post Login Information and get authenticated sessionId and csrftoken
  
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("User-Agent", $Global:STROMER_USER_AGENT)
    $headers.Add("Referer", "https://stromer-portal.ch/mobile/v4/login/?next=/mobile/v4/o/authorize/%3Fresponse_type%3Dcode%26scope%3Dbikestatus%26client_id%gBb1eAIyVs1sESwkscnCNRauWaVNKQevFeuPjPaSr0sUrioHGt8dq58I42CJ7PPe")
    $headers.Add("Cookie", "$(($Global:COOKIES | Where-Object{$_.Name -eq 'csrftoken'}).CookieString); $(($Global:COOKIES | Where-Object{$_.Name -eq 'sessionid'}).CookieString)")
  
    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "csrfmiddlewaretoken"
    $stringContent = [System.Net.Http.StringContent]::new($csrfmiddlewaretoken)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "next"
    $stringContent = [System.Net.Http.StringContent]::new("/mobile/v4/o/authorize/?response_type=code&scope=bikestatus&client_id=$($Global:STROMER_CLIENT_ID)")
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "username"
    $stringContent = [System.Net.Http.StringContent]::new($UserName)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "password"
    $stringContent = [System.Net.Http.StringContent]::new($PasswordString)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $body = $multipartContent
  
    Write-Host "Sending login information with csrfmiddlewaretoken and receiving authenticated cookies..."
    $response = $null
    $response = Invoke-WebRequest 'https://stromer-portal.ch/mobile/v4/login/' -Method 'POST' -Headers $headers -Body $body -UserAgent $Global:STROMER_USER_AGENT -SkipHttpErrorCheck -MaximumRedirection 0 -ErrorAction SilentlyContinue
  
    $response.Headers.'Set-Cookie' | Where-Object { $_ -match 'csrftoken=([A-Za-z0-9]{64})' } | Out-Null
    $csrfCookie = $Matches[0]
    $csrfCookieValue = $Matches[1]
  
    $Global:COOKIES = @()
    $Global:COOKIES += [PSCustomObject]@{
        Domain       = 'stromer-portal.ch'
        Name         = 'csrftoken'
        Value        = $csrfCookieValue
        CookieString = $csrfCookie
    }
  
    $response.Headers.'Set-Cookie' | Where-Object { $_ -match 'sessionid=([a-z0-9]{32})' } | Out-Null
    $sessionIdCookie = $Matches[0]
    $sessionIdCookieValue = $Matches[1]
  
    $Global:COOKIES += [PSCustomObject]@{
        Domain       = 'stromer-portal.ch'
        Name         = 'sessionid'
        Value        = $sessionIdCookieValue
        CookieString = $sessionIdCookie
    }
  
    $headerLocation = $response.headers.Location
  
    ### Follow redirect with authenticated cookies and get stromer auth token
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Cookie", "$(($Global:COOKIES | Where-Object{$_.Name -eq 'csrftoken'}).CookieString); $(($Global:COOKIES | Where-Object{$_.Name -eq 'sessionid'}).CookieString)")
  
    Write-Host "Following the 302 redirect from login to receive auth code for context hop (Browser to App)..."
    $response = Invoke-WebRequest "https://stromer-portal.ch/$($headerLocation)" -Method 'GET' -Headers $headers -SkipHttpErrorCheck
  
    Write-Host "Received redirect: [$($response.Headers.Location)]"
  
    [string]$headerLocation = $response.Headers.Location
    $headerLocation -match 'code=([A-Za-z0-9]{30})'
    $StromerAppAuthCode = $Matches[1]
  
  
    ### Use Auth Code to get access token (Access code sent with custom URI is used to switch over to the Stromer App)
  
    #We don't need the cookies anymore because we switched context from browser to app
    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "grant_type"
    $stringContent = [System.Net.Http.StringContent]::new("authorization_code")
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "client_id"
    $stringContent = [System.Net.Http.StringContent]::new($Global:STROMER_CLIENT_ID)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "code"
    $stringContent = [System.Net.Http.StringContent]::new($StromerAppAuthCode)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "redirect_uri"
    $stringContent = [System.Net.Http.StringContent]::new("stromer://auth")
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
  
    $body = $multipartContent
  
    Write-Host "Sending Code from redirect ($($StromerAppAuthCode)) to receive AccessToken..."

    try {
        $response = Invoke-RestMethod 'https://stromer-portal.ch/mobile/v4/o/token/' -Method 'POST' -Body $body  

        $Global:CONFIG.access_token = $response.access_token
        $Global:CONFIG.refresh_token = $response.refresh_token
    
        Save-GlobalStromerConfig    

        return $response
      
    }
    catch {
        Write-Host 'AccessToken retrieval failed:' -ForegroundColor Red
        $Message = $_

        if ($false) {
            Write-Host 'The XXX is invalid (invalid_grant)' -ForegroundColor Red
            return $false
        }
        else {
            Write-Host 'An unknown Error occured:' -ForegroundColor Red
            Write-Host $Message
            return $false
        }
    }
  
}

function Get-StromerAccessTokenByRefresh {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $RefreshToken
    )

    Get-GlobalStromerConfig

    if(!$RefreshToken)
    {
        $RefreshToken = $Global:CONFIG.refresh_token
    }

    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "grant_type"
    $stringContent = [System.Net.Http.StringContent]::new("refresh_token")
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "client_id"
    $stringContent = [System.Net.Http.StringContent]::new($Global:STROMER_CLIENT_ID)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "refresh_token"
    $stringContent = [System.Net.Http.StringContent]::new($RefreshToken)
    $stringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $body = $multipartContent

    try {
        $response = Invoke-RestMethod 'https://stromer-portal.ch/mobile/v4/o/token/' -Method 'POST' -Body $body

        $Global:CONFIG.access_token = $response.access_token
        $Global:CONFIG.refresh_token = $response.refresh_token

        Save-GlobalStromerConfig

        return $response
    }
    catch {
        Write-Host 'AccessToken refresh failed:' -ForegroundColor Red
        $Message = $_

        if($Message -match '"error": "invalid_grant"')
        {
            Write-Host 'The RefreshToken is invalid (invalid_grant):' -ForegroundColor Red
            Write-Host $Message
            return $false
        }
        else
        {
            Write-Host 'An unknown Error occured:' -ForegroundColor Red
            Write-Host $Message
            return $false
        }
    }

}

function Save-StromerApiRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $RequestUrl,

        [Parameter(Mandatory=$true)]
        [string]
        $FileNameTemplate
    )

    $doRetry = $false
    $maxRetries = 3
    $retriesLeft = $maxRetries

    do {
        $retriesLeft--

        Get-GlobalStromerConfig

        try{
            Write-Host "Requesting API: [$($RequestUrl)]"
            $response = Invoke-RestMethod $RequestUrl -Method 'GET' -Headers $Global:DEFAULT_HEADERS
            $doRetry = $false
        }
        catch
        {
            $Message = $_
            if($Message -match "Authentication credentials were not provided.")
            {
                Write-Host "AccessToken invalid or expired:" -ForegroundColor Red
                Write-Host $Message

                Write-Host "Trying to refresh AccessToken..."

                $refreshAttemptSuccess = Get-StromerAccessTokenByRefresh

                if($refreshAttemptSuccess)
                {
                    Write-Host "AccessToken refreshed successfully, retrying API request..."
                    $doRetry = $true
                }
                else
                {
                    Write-Host "AccessToken refreshed failed, trying to re-logon..." -ForegroundColor Red
                    $logonAttemptSuccess = Get-StromerAccessToken

                    if($logonAttemptSuccess)
                    {
                        Write-Host "Re-Logon successful, retrying API request..."
                        $doRetry = $true
                    }
                    else
                    {
                        Write-Host "Login failed. will not retry API request." -ForegroundColor Red
                        $doRetry = $false
                        return $false
                    }
                }

            }
            else {
                Write-Host "an unknown error occured while requesting the API:"
                Write-Host "Request URL: [$($RequestUrl)]"
                Write-Host $Message
                return $false
            }
        }

        if($retriesLeft -lt 1)
        {
            Write-Host "Maximum ammount of retries [$($maxRetries)] reached, aboring."
            return $false
        }

    } while ($doRetry)

    try {
        $responseJson = $response | ConvertTo-Json -Depth 10

        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $fileName = $FileNameTemplate -f $timestamp
        $filePath = Join-Path $Global:DATA_DIR $fileName
    
        $responseJson | Out-File -FilePath $filePath -Encoding utf8
            
    }
    catch {
        $Message = $_
        Write-Host "Error while saving Data:"
        Write-Host $Message
    }

}

<###
### Data Collection Functions
###>

function Get-StromerState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Int32]
        $BikeId,
    
        [Parameter(Mandatory=$false)]
        [switch]
        $Cached = $false
    )

    Get-GlobalStromerConfig

    if(!$BikeId)
    {
        $BikeId = $Global:CONFIG.bike_id
    }
      
    $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/state/?cached=false"
    if($Cached)
    {
        $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/state/?cached=true"
    }
    
    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-$($BikeId)-state-{0}.json")
}

function Get-StromerStatistics {
    [CmdletBinding()]
    param ()

    $requestUrl = "$($Global:API_BASE_URL)/bike/statistics/all/"

    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-statistics-{0}.json")
}

function Get-StromerPosition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Int32]
        $BikeId,
    
        [Parameter(Mandatory=$false)]
        [switch]
        $Cached = $false
    )
      
    Get-GlobalStromerConfig

    if(!$BikeId)
    {
        $BikeId = $Global:CONFIG.bike_id
    }
    
    $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/position/?cached=false"
    if($Cached)
    {
        $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/position/?cached=true"
    }
    
    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-$($BikeId)-position-{0}.json")
}

function Get-StromerServiceInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Int32]
        $BikeId
    )
      
    Get-GlobalStromerConfig

    if(!$BikeId)
    {
        $BikeId = $Global:CONFIG.bike_id
    }
    
    $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/service_info/"
    
    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-$($BikeId)-serviceinfo-{0}.json")
}

function Get-StromerBikeOverview {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Int32]
        $BikeId
    )
      
    Get-GlobalStromerConfig

    if(!$BikeId)
    {
        $BikeId = $Global:CONFIG.bike_id
    }
    
    $requestUrl = "$($Global:API_BASE_URL)/bike/$($BikeId)/"
    
    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-$($BikeId)-overview-{0}.json")
}

function Get-StromerBikelist {
    [CmdletBinding()]
    param ()

    $requestUrl = "$($Global:API_BASE_URL)/bike/"

    Save-StromerApiRequest -RequestUrl $requestUrl -FileNameTemplate ("bike-bikelist-{0}.json")
}
