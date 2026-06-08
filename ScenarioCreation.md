# Scenario Creation – "The Notepad Updater"

## Overall Scenario
An unsuspecting employee receives an email from someone posing as her company's IT department, claiming they need to update outdated software for security reasons. The message cites an old version of Notepad on her computer and includes an attached “notepad_updater.exe” script, signed off by a real IT staff member. Trusting the request, she downloads and runs the file, noticing nothing unusual. Later, she mentions the update to coworkers, who are unaware of any such initiative. Concerned, she contacts the actual IT department—only to learn the email was a fake.

## User Perspective

## Bad Actor Perspective
The malicious actor is looking to attain information about the devices configuration to plan for a pivot within the network.

The bad actors goal is:

1. Create malicious executible
2. Tricked the end-user into downloading the "notepad_updater"  in phising attack aimed at organizational employees

### Creating the malicious script 
[View malicious script](  )
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
