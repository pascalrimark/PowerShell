function Decode-Bearer() {
    param(
        [Parameter(Mandatory=$True)]
        [string]$token
    )

    process {
        
        function NormalizePayload($Payload) {
            $Length = $Payload.Length % 4
            if($length -gt 0) {
                $Payload += '='
                NormalizePayload $Payload
            } else {
                return $Payload
            }
        }

        $token_chunks = $token.Split(".") 
        Write-Host "##-------------------- HEADER --------------------##"
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($token_chunks[0])) | convertfrom-json
       
        Write-Host "##------------------- Payload --------------------##"
        $NormalizedPayload = NormalizePayload -Payload $token_chunks[1]
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($NormalizedPayload)) | convertfrom-json

    }
}