# Managing Microsoft Defender Attack Surface Reduction (ASR) Rules
You can use these two Datto RMM Components to deploy and generate a report of the ASR Rules configuration on a Datto RMM Device. 

## Components
- [Deploy Microsoft Defender ASR Rules](https://github.com/madhuperera/Datto_RMM/blob/main/Monitoring/Microsoft%20Defender/ASR_Rules/Deploy_ASR_Rules.ps1 "Deploy Microsoft Defender ASR Rules")
- [Report on Microsoft Defender ASR Rules Configuration](https://github.com/madhuperera/Datto_RMM/blob/main/Monitoring/Microsoft%20Defender/ASR_Rules/Report_ASR_Rules.ps1 "Report on Microsoft Defender ASR Rules Configuration")

### Deploy Microsoft Defender ASR Rules
You can use this script to deploy ASR Rules. You will need to create a new component in Datto RMM with the script content and create variables to match like in the image below:
![image](https://user-images.githubusercontent.com/101617608/182069306-ef99a877-68b6-4724-85b2-c63316b2906c.png)

When you run this component as a job, it will populate all variables with the value "AuditMode" to deploy these rules in Audit Mode. If you wish to change them, you can change the value from "AuditMode" to "Enabled" or "Disabled".
![image](https://user-images.githubusercontent.com/101617608/182077960-34a5a6bd-63e9-4cbf-a779-58875f48098e.png)

### Report on Microsoft Defender ASR Rules Configuration
![image](https://user-images.githubusercontent.com/101617608/182078137-52641270-834a-4027-92ab-c8d30ce145c0.png)
