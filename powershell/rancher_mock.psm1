function Start-MockedRancher() {
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $JobName = "MockedRancher",

        [Parameter(Mandatory=$false)]
        [int]
        $Port = 8080
    )
    Stop-MockedRancher @PSBoundParameters

    $address = "http://localhost:{0}" -f $Port
    Log-Info "Listening on $address"
    Start-Job -Name $JobName -ScriptBlock {
        param (
            [string]$Address
        )
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("{0}/" -f $Address)
        $listener.Start()

        try {
            while ($listener.IsListening) {
                $context = $listener.GetContext()
                $response = $context.Response

                Write-Host $context.Request.Url.AbsolutePath
                switch ($context.Request.Url.AbsolutePath) {
                    "/healthz" {
                        $response.ContentType = "text/plain"
                        $response.StatusCode = 200
                        $response.StatusDescription = "OK"
                        $buf = [System.Text.Encoding]::UTF8.GetBytes("ok")
                        $response.OutputStream.Write($buf, 0, $buf.Length)
                    }
                    "/v3/connect/agent" {
                        $response.ContentType = "application/json"
                        $response.StatusCode = 200
                        $response.StatusDescription = "OK"

                        # mock the connection info
                        $mockedConnectionInfo = @{
                            kubeConfig = "<kubeconfig>"
                            namespace = "<namespace>"
                            secretName = "<secretName>"
                        } | ConvertTo-Json

                        $buf = [System.Text.Encoding]::UTF8.GetBytes($mockedConnectionInfo)
                        $response.OutputStream.Write($buf, 0, $buf.Length)
                    }
                    default {
                        $response.StatusCode = 404
                        $response.StatusDescription = "Not Found"
                    }
                }
                $response.Close()
            }
        } finally {
            # Stop the listener when done
            $listener.Stop()
        }
    } -ArgumentList $Address
}

function Stop-MockedRancher() {
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $JobName = "MockedRancher",

        [Parameter(Mandatory=$false)]
        [int]
        $Port = 8080
    )
    Stop-Job -Name $JobName -ErrorAction SilentlyContinue
    if ($?) {
        Log-Info "Stopped $JobName."
    }
    Remove-Job -Name $JobName -ErrorAction SilentlyContinue
    if ($?) {
        Log-Info "Removed $JobName."
    }
}

Export-ModuleMember -Function Start-MockedRancher
Export-ModuleMember -Function Stop-MockedRancher