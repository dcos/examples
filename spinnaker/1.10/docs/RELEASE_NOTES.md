
## DC/OS Spinnaker service 0.2.0-1.4.2

- Spinnaker Framework now comes with the default configuration which uses:
	- Minio as the default backend store. 
	- DC/OS that spinnaker runs in as delivery target. 
- Port definitions and VIPs are added. 
- Ports get auto-assigned. 
- All services except Redis, Echo and Igor can now be scaled 
- All services now deploy in parallel.
- Spinnaker config yml can now be edited from the DC/OS console.     
