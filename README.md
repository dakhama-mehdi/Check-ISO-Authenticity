# CheckISO Trust your ISO before you deploy it.  

CheckISO is an open-source tool available as PowerShell script, Microsoft Store application and API web.

It allows you to verify Microsoft and linux installation sources and automatically calculate ISO hashes using trusted official libraries containing hundreds of known references.

<table>
<tr>
<td>

Supported sources include:

- Windows 10 / 11 & Windows Server
- Linux most distribution  
- SQL Server & Microsoft Office  
- And other Microsoft installation media  

</td>
<td>

<img src="./Pictures/CheckISO.png" width="600">

</td>
</tr>
</table>

[Online Linux Hash DataBase Community ](https://dakhama-mehdi.github.io/Check-ISO-Authenticity/) 

## Why CheckISO?

Security frameworks and software supply chain recommendations require organizations to control the origin and integrity of installation media.

In practice, ISO verification is often manual, inconsistent, or limited to a single source of trust.

CheckISO provides an independent source of verification to help organizations strengthen installation media validation and reduce the risk associated with altered, outdated, or untrusted sources.

Because every deployment starts with a source.

## What CheckISO Does

- Calculates ISO hashes (SHA256)
- Identifies Microsoft and Linux installation media
- Compares hashes against trusted references
- Provides an additional verification source before deployment
- Helps organizations implement software supply chain controls

## Use Cases

- Validate installation media before deployment
- Audit internal ISO repositories
- Verify archived or legacy installation sources
- Support software supply chain and GRC controls
- Improve confidence in deployment workflows

## Availability

- PowerShell Script
* Standalone EXE
* Microsoft Store Application
* Online Hash Database
 
## Credits 
It-connect.fr, Logonit.fr  
Florent C.

![CheckISO Demo](./Pictures/CheckISO.gif)
