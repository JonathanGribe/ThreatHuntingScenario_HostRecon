# Scenario Creation – "The Notepad Updater"

## Bad Actor Steps
1. Create malicious script
2. Tricked the end-user into downloading the "notepad_updater"  in phising attack aimed at organizational employees

---

## Tables Used to Detect IoCs
| Parameter |         Description          | 
|-----------|------------------------------|
| Name      |      DeviceFileEvents        | 
| Info      |                              | 
| Purpose   |                              |

| Parameter |         Description          | 
|-----------|------------------------------|
| Name      |      DeviceProcessEvents     | 
| Info      |                              | 
| Purpose   |                              |

| Parameter |         Description          | 
|-----------|------------------------------|
| Name      |      DeviceNetworkEvents     | 
| Info      |                              | 
| Purpose   |                              |

| Parameter |         Description          | 
|-----------|------------------------------|
| Name      |      DeviceRegistryEvents    | 
| Info      |                              | 
| Purpose   |                              |

---

## Related Queries
1. Searching for file downloaded by user:

```kql
 DeviceFileEvents
| where DeviceName  == "workstation2"
| where InitiatingProcessFileName in~ ("powershell.exe", "pwsh.exe", "powershell_ise.exe")
| where InitiatingProcessAccountName != "system" 
| project Timestamp, DeviceName, ActionType, InitiatingProcessCommandLine
| order by Timestamp desc  
```
2. Searching Device Process Events for the powershell executible
```kql
DeviceProcessEvents
| where FileName == "powershell.exe"
| where AccountName == "jonuser"
| project Timestamp, ProcessCommandLine, InitiatingProcessFileName, AccountName
```
3. Trying to locate the notepad updater 
```kql
DeviceProcessEvents
| where DeviceName == "workstation2"
| where FileName == "notepad_updater.exe"
|order by Timestamp desc  
```

4. Searching for any additional accounts:

```kql
DeviceRegistryEvents
| where DeviceName == "workstation2"
| where RegistryKey has @"Winlogon\SpecialAccounts\UserList"
| where RegistryValueData == "0"  // Hidden if value = 0
| summarize LatestHideTime = max(Timestamp) by RegistryValueName, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine
| project LatestHideTime, DeviceName, HiddenAccount = RegistryValueName, InitiatingProcessFileName, InitiatingProcessCommandLine
| order by LatestHideTime desc
```

5. Finding exfiltration

```kql
DeviceNetworkEvents
| where DeviceName == "workstation2"
| where RemoteUrl has "blob.core.windows.net"
| where InitiatingProcessFileName == "powershell.exe"
| where RemotePort == 443  // HTTPS traffic
| where ActionType == "ConnectionSuccess"
| project Timestamp, DeviceName, InitiatingProcessCommandLine, RemoteUrl, RemoteIP
| order by Timestamp desc
```

## Created By
### Author Name: Jonathan Gribe
### Author Contact: [LinkedIn account]
### Date: 08/13/2025

## Validated By:
### Reviewer Name:
### Reviewer Contact:
### Validation Date:
---

## Additional Notes
---

## Revision History
