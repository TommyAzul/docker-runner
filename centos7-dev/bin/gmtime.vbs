Option Explicit

Dim ServiceSet
Dim Service
Dim Gmt

Set ServiceSet = GetObject("winmgmts:{impersonationLevel=impersonate}").InstancesOf("Win32_TimeZone")
for each Service in ServiceSet
    Gmt = Service.Bias / 60
    WScript.Echo Gmt
Next
