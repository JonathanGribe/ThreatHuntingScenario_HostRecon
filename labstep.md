“The notepad updater v.2”

## Basic Lab Information:

Prerequisite:  
Basic familiarity with using Azure portal  
\-Creating Virtual machines  
\-Creating Storage accounts



## Platform Information and key lab info:

Platforms:

1.      Azure Portal w/created resources:

\-Virtual machine

\-Blob storage à container

2.      Microsoft Defender for Endpoint  
\-Uploaded VM to defender for endpoint  
\- Advanced Threat Hunt

3.      Powershell ISE (Script already created)

Azure VM Info:

Azure hostname: AdminWorkstation1

VM Hostname: AdminWorkstatio  
IP address: 20.81.225.156  
  

Azure Blob Storage Information and configurations:

Storage Account name: guyxstorage  
Container Name: guyscontainer

SAS Key configuration:  
SAS URL:

Exploit added account:  
Username: NetSync  
Password:P@ssw0rd123!

$username \= "NetSync"

$password \= "P@ssw0rd123!"

### Notepad updater exploit – Powershell:

How it works:

This script is designed to be a “notepad updater”.  It tricks the user into thinking their notepad application needs updated for security reasons. For he purpose of this lab we assume that we have some form of initial access. When the .exe file is clicked it will load a ‘updating notepad’ alert and simultaneously open notepad.
It will gather all of the users host information and attempt to exfiltrate the data onto an Azure Blob storage account(Certain parts of the script to be edited are highlighted). Finally, a backdoor is created via an additional account that is secretly added as to not appear during the login process.

## Steps:

1.      Create Virtual Machine

2.      Create Azure  Blob Storage Account  
\-Create container (to receive host information from script)

3.      Add VM to Microsoft Defender for Endpoint

4.      “Bad Actor” - Create exploit (Script and executable)

5.      Run executable

6.      “Analyst” – Run KQL queries to determine what happened

7.      Remediation – Device reimaged and alerts created

**1.	Create Virtual Machine:**
Created a virtual machine to be used to represent an administrators computer. Hostname: AdminWorkstation1.  IP: 20.81.225.156.

<img width="975" height="489" alt="image" src="https://github.com/user-attachments/assets/3c28e016-a8e1-49eb-b418-b6f4a2ac8d36" />


**2.	Create Blob Storage Account:**
  <img width="975" height="194" alt="image" src="https://github.com/user-attachments/assets/df018207-5ef8-4e92-9598-4f7fce3133d0" />

**3.	Add VM to Microsoft Defender for Endpoint**
   1.	Locate the link to copy/paste into cmd
A.	Go to MDE (https://security.microsoft.com)
B.	Left column: Settings  Endpoints  Device Management  Onboarding
C.	Download Onboarding package
If package not available contact your administrator

<img width="975" height="194" alt="image" src="https://github.com/user-attachments/assets/9066dd19-e131-4ebc-a137-cfe3fef92a7e" />

2.	Once package downloaded:
A.	Right-click
B.	Run as administrator
C.	Copy/paste into cmd

3.	Once command ran:
Check Asset Management -- > Devices  Search hostname (as seen in the VM)

<img width="975" height="305" alt="image" src="https://github.com/user-attachments/assets/4bb5b558-e265-4962-82b3-d4251415181b" />

OR run query in Advanced Hunting:
DeviceInfo
| where DeviceName contains "Admin" and OnboardingStatus == "Onboarded"
| project Timestamp, DeviceName, PublicIP, OnboardingStatus

Substitute “Admin” with the beginning of your device name.

<img width="975" height="750" alt="image" src="https://github.com/user-attachments/assets/a4c0bb95-c12e-4510-bd0b-8c29ae65f2e0" />

If do not have host name:
Log into VM  Type cmd in search box by windows icon  Pull up command prompt  type ‘hostname’ in the field.

<img width="642" height="209" alt="image" src="https://github.com/user-attachments/assets/c10042aa-7f2b-4db9-a394-277e777c2144" />


**4.      Create and edit powershell script and .exe file**

Script provided above. Working in virtual machine.

Creating .ps1 file:

1.      In VM open up Powershell ISE

2.      Create ‘new script’ (top left) and copy/paste script

3.      Save .ps1 file on desktop

Editing the .ps1 file:

Background: This .ps1 file will need to be edited in order to have the host information gathered off of the vm to your blob storage account in Azure. To do this we will need to grab the Blob URL which will include the SAS token.

1.      Reopen the script for editing

2.      Gathering the SAS token (In blob storage account):

Creating .exe file (Using PS2EXE module):

1.      Open Powershell

2.      Install PS2exe:

A.     In powershell: Install-Module -Name ps2exe

B.     To convert:  ps2exe .\\MyScript.ps1 .\\MyScript.exe -noConsole -noOutput -noError

The first part .\\MyScript.ps1 is the name and  filepath were the script file is that we saved onto the desktop.  The .\\MyScript.exe is the name that you want the executable to be included with the filepath. The -noConsole -noOutput -noError is for hiding anykind of background processes that maybe going on while script is executing to avoid suspicion.

Once created you should get an icon showing the .exe file as such:
<img width="691" height="486" alt="image" src="https://github.com/user-attachments/assets/e3283d91-c0eb-4771-a7ad-cdbf4f7f2f0b" />

**5.	Run the .exe file**

**6.	Security Analyst – Research**

**1. Find any newly cread file within the past three days under the current user profile** 
KQL Query:

```kql
DeviceFileEvents
| where DeviceName contains "adminworkstatio" and  Timestamp > ago(3d)
| where ActionType == "FileCreated"
| where FolderPath startswith @"C:\Users\johnUser\appdata"
| project Timestamp, DeviceName, FileName, FolderPath
|  order by  Timestamp desc 
```
**Findings:**

<img width="975" height="557" alt="image" src="https://github.com/user-attachments/assets/8c145a3c-0c99-4238-ba00-2410e0401544" />

**2.Searching for device processes:**

```kql
DeviceProcessEvents
| where Timestamp > ago(1d)
| where DeviceName == "adminworkstatio"  and AccountName  == "johnuser"
| where InitiatingProcessCommandLine matches regex @"notepad|calc|cmd|powershell"
| project Timestamp, FileName, FolderPath, InitiatingProcessCommandLine
| order by Timestamp desc  
```

<img width="975" height="221" alt="image" src="https://github.com/user-attachments/assets/f3881517-e333-4cb7-afdc-8a000b1fc91a" />

**3.Searching for any outbound connections (for data exfiltration)

```kql
DeviceNetworkEvents
| where Timestamp > ago(1d) and DeviceName == "adminworkstatio"
| where RemoteIPType == "Public"
| where ActionType == "ConnectionSuccess" and RemoteUrl has "azure"
| project Timestamp, RemoteIP, RemotePort, RemoteUrl, InitiatingProcessFileName
| order by Timestamp desc  
```
<img width="975" height="131" alt="image" src="https://github.com/user-attachments/assets/8357e3cf-ad0d-4f5c-8d0c-e85fb7689548" />


**4.	Querying Device Registry Events table to search for backdoors and other accounts**

1.	Auto-run
Query:
```kql
DeviceRegistryEvents
| where DeviceName contains "adminworkstatio"
| where RegistryKey startswith @"HEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
| order by Timestamp asc 
| project Timestamp, DeviceName, RegistryKey, RegistryValueName 
```
2. Scheduled Tasks

3. Powershell obfuscation

```kql
DeviceProcessEvents
| where DeviceName contains "adminworkstatio"
| where ProcessCommandLine contains "-EncodedCommand"
|project Timestamp, DeviceName, FileName, ProcessCommandLine, InitiatingProcessAccountName 
```
<img width="975" height="475" alt="image" src="https://github.com/user-attachments/assets/a3775fa9-0710-460d-bd3b-bea58f408f80" />

Discovery of additional account:

<img width="975" height="193" alt="image" src="https://github.com/user-attachments/assets/de8cf1d1-032f-4f43-9b68-21d4e78eae7a" />



**7.	Remediation:
Since it was discovered that adminworkstation was the only infected computer a device reimage was performed.**





