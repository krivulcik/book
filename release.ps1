#.\build.ps1 pdf $true
.\build.ps1 docx $false

$token = Get-Content "$pwd\..\Credentials\github.txt"
$release = "v4.0.11-preview"


$json = Invoke-WebRequest -ErrorAction Stop `
     -Uri "https://api.github.com/repos/ravendb/book/releases" `
    -ContentType "application/json" `
    -Method "POST" `
    -Headers @{"Authorization" = "token $token"; "Accept" = "application/vnd.github.v3+json"} `
    -Body "{  
    `"tag_name`": `"$release`",   
    `"target_commitish`": `"v4.0`",   
    `"name`": `"$release`",   
    `"body`": `"Preview of the book`",   
    `"draft`": false,   
    `"prerelease`":  true
}"

if($json -eq $null) {
    return
}

$resp = ConvertFrom-Json $json

$id = $resp.id

echo "New release id: $id"


$pdf = [System.IO.File]::ReadAllBytes("$pwd\Output\Inside RavenDB 4.0.pdf")

Echo "Uploading .pdf"
Invoke-WebRequest -Uri "https://uploads.github.com/repos/ravendb/book/releases/$id/assets?name=Inside RavenDB 4.0.pdf" `
	-Headers @{"Authorization" = "token $token"; "Accept" = "application/vnd.github.v3+json"} `
    -ContentType "application/pdf" `
    -Method "POST" `
    -Body $pdf


$docx = [System.IO.File]::ReadAllBytes("$pwd\Output\Inside RavenDB 4.0.docx")

Echo "Uploading .docx"
Invoke-WebRequest -Uri "https://uploads.github.com/repos/ravendb/book/releases/$id/assets?name=Inside RavenDB 4.0.docx" `
    -Headers @{"Authorization" = "token $token"; "Accept" = "application/vnd.github.v3+json"} `
    -ContentType "application/vnd.openxmlformats-officedocument.wordprocessingml.document" `
    -Method "POST" `
    -Body $docx

.\build.ps1 epub $false

c:\tools\kindlegen\kindlegen.exe ".\Output\Inside RavenDB 4.0.epub"

Echo "Uploading .epub"

$epub = [System.IO.File]::ReadAllBytes("$pwd\Output\Inside RavenDB 4.0.epub")

Invoke-WebRequest -Uri "https://uploads.github.com/repos/ravendb/book/releases/$id/assets?name=Inside RavenDB 4.0.epub" `
	-Headers @{"Authorization" = "token $token"; "Accept" = "application/vnd.github.v3+json"} `
    -ContentType "application/epub+zip" `
    -Method "POST" `
    -Body $epub

$mobi = [System.IO.File]::ReadAllBytes("$pwd\Output\Inside RavenDB 4.0.mobi")

Echo "Uploading .mobi"

Invoke-WebRequest -Uri "https://uploads.github.com/repos/ravendb/book/releases/$id/assets?name=Inside RavenDB 4.0.mobi" `
	-Headers @{"Authorization" = "token $token"; "Accept" = "application/vnd.github.v3+json"} `
    -ContentType "application/octet-stream" `
    -Method "POST" `
    -Body $mobi