# https://developpaper.com/implementation-of-jwt-verification-by-nginx-based-on-openresty/

# For android https://stackoverflow.com/questions/31162441/setting-headers-for-streaming-mp4-video-and-playing-files-with-exoplayer

Remove-Item -Recurse -Path "download"  -ErrorAction SilentlyContinue
Remove-Item -Recurse -Path "lib" -ErrorAction SilentlyContinue

$hmacUrl = "https://github.com/jkeys089/lua-resty-hmac/releases/latest"
$jwtUrl = "https://github.com/SkyLothar/lua-resty-jwt/releases/latest"

function getSourceUrl($url) {
    $result = Invoke-WebRequest -Uri $url -UseBasicParsing
    $href = $($result.Links | Where-Object { $_ -match ".zip" })[0].href
    
    if ($href.Length -eq 0) { return $null;}
    if ($href -notcontains "://") {
        $uriData = [System.Uri]$url
        $downloadUrl = $uriData.Scheme + "://" + $uriData.DnsSafeHost + $href
        Write-Host "Registered download url: " -ForegroundColor Yellow -NoNewline
        Write-Host $downloadUrl -ForegroundColor Cyan
        return $downloadUrl;
    } else {
        Write-Host "Registered download url: " -ForegroundColor Yellow -NoNewline
        Write-Host $downloadUrl -ForegroundColor Cyan
        return $href;
    }
}

Import-Module BitsTransfer
function downloadAndShift($url, $name) {
    Write-Host "Downloading " -ForegroundColor Yellow -NoNewline; Write-Host $url -ForegroundColor Cyan
    $folder = Join-Path -Path $PWD -ChildPath "download"
    $ditem = $(Join-Path -Path $folder -ChildPath $($name + $url.Substring($url.LastIndexOf(".")))) 
    Start-BitsTransfer -Source $url -Destination $ditem

    $unzipPath = $(Join-Path -Path $folder -ChildPath $name) 
    Expand-Archive -Path $ditem -DestinationPath $unzipPath

    $dlibFolder = Get-ChildItem -Recurse -Directory -Path $unzipPath | Where-Object { $_.Name -eq "lib" } -ErrorAction SilentlyContinue
    if ($null -eq $dlibFolder) {
        return;
    }

    # Write-Host $dlibFolder.FullName
    $libs = Get-ChildItem -Recurse -File -Path $dlibFolder[0].FullName
    if ($libs.Length -eq 0) {
        return;
    }

    # Write-Host $libs
    $libFolder = Join-Path -Path $PWD -ChildPath "lib"
    foreach ($lib in $libs) {
        Move-Item -Path $lib.FullName -Destination $libFolder
    }

}

$hmacRefUrl = getSourceUrl -url $hmacUrl
$jwtRefUrl = getSourceUrl -url $jwtUrl


New-Item -ItemType Directory -Name "lib" | Out-Null
New-Item -ItemType Directory -Name "download" | Out-Null

downloadAndShift -url $hmacRefUrl -name "hmac"
downloadAndShift -url $jwtRefUrl -name "jwt"



docker build -t bskjon/streamit-igate:latest .
docker push bskjon/streamit-igate:latest

Remove-Item -Recurse -Path "download"
Remove-Item -Recurse -Path "lib"

Write-Host "Done!" -ForegroundColor Yellow