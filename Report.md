# Threat Hunt Report: "The Notepad Updater"

---
## Platforms and Languages Leveraged
* Windows 10 Virtual Machines (Microsoft Azure)
* EDR Platform: Microsoft Defender for Endpoint
* Kusto Query Language (KQL)

## Scenario

An unsuspecting employee receives an email from someone posing as her company's IT department, claiming they need to update outdated software for security reasons. The message cites an old version of Notepad on her computer and includes an attached “notepad_updater.exe” script, signed off by a real IT staff member.
Trusting the request, she downloads and runs the file, noticing nothing unusual. Later, she mentions the update to coworkers, who are unaware of any such initiative. Concerned, she contacts the actual IT department—only to learn the email was a fake.

## High Level IoC Discovery Plan
1. Check DeviceFileEvents for evidence of downloading a suspicious file
2. Check DeviceProcessEvents for evidence of powershell being run
3. Check DeviceNetwork Events to check for signs of exfiltration
4. Check DeviceRegistryEvents to check for signs of persistence

## Steps Taken

### Step 1 - Searched DeviceFileEvents Table to search for signs of download


### Step 2 - Search DeviceProcessEvents for signs of powershell execution

### Step 3 - Search DeviceNetworkEvents to check for signs of exfiltration

### Step 4 - Search DeviceRegistryEvents to search for persistence mechanisms

---

## Chronology Event Timeline

---
## Summary

---

## Response Taken
