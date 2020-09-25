function [result, OkapiError] = OkapiSendRequestAndWaitForResult(OkapiLogin, ... 
    RequestBody, UrlEndpointRequest, UrlEndPointResult, maxPollTime)
%OkapiSendRequestAndWaitForResult() Send request and wait for result
%       OkapiLogin - Struct, containing at least URL, options and Token for 
%       OKAPI:Platform. Can be obtained using OkapiInit().
%       RequestBody - Struct containing the request. A struct of 
%       the correct format can be gained by OkapiGetPassPredictionRequest.
%       UrlEndpointRequest - The adress to which the request is sent
%       UrlEndPointResult - The adress, from which the result is to be retrieved
%       maxPollTime - The maximum time how long a result shall be waited
%       for in seconds. Time measurement is not precise.
%
%   Outputs
%       results - struct array, containing the results from all requests
%       sent. NOTE: A result might be partial (check warnings!). In that
%       case, recall the function to get remaining results
%       error - contains the webstatus, error status, and error message

% get the request
[request, OkapiError] = OkapiSendRequest(OkapiLogin, ... 
    RequestBody, UrlEndpointRequest);
if (strcmp(OkapiError.status, 'FATAL'))
    % Fatal error: Leave the function
    display(OkapiError.message);
    return
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
elseif (strcmp(OkapiError.status, 'REMARK'))
    % do something about remarks
    display(OkapiError.message);
end

[result, OkapiError] = OkapiWaitAndGetResult(OkapiLogin, request, ...
    UrlEndPointResult, maxPollTime);

end

