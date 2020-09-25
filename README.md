# OkapiMatlabConnector
Some routines to connect OKAPI:Orbits software with Matlab. 

To get started, simply add the the src folder to your current 
projects, by using Matlab's addpath. Make sure that you use a
connector compatible with the version on the server. The version
in the master is always compatible with the latest version running
on the server. For each relesae, a tagged version of the 
connector is available with the same name as the OKAPI release.

The connector provides three basic routines:
- OkapiInit: Retrieve the token from Auth0 to use OKAPI
- OkapiSendRequest: Send a request to OKAPI
- OkapiGetResult: Get a result from OKAPI.
- OkapiWaitAndGetResult: Wait until a result has been processed and 
                         get the result
- OkapiSendRequestAndWaitForResult: Send and get request in one step

For more information, visit the documentation page on
www.okapiorbits.space/documentation
