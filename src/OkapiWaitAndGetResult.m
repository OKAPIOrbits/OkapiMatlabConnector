function [result, error] = OkapiWaitAndGetResult(OkapiLogin, request, ...
    UrlEndpoint, maxPollTime, resultPartId)
%OkapiWaitAndGetResult() Wait for and get results from OKAPI
%   Inputs
%       OkapiLogin - Struct, containing at least URL, options and Token for 
%       OKAPI:Platform. Can be obtained using OkapiInit().
%       request - struct array containing the request_id and request_type, needed
%       to get the results from Picard.
%       UrlEndpoint - The adress, from which the result is to be retrieved
%       maxPollTime - The maximum time how long a result shall be waited
%       for in seconds. Time measurement is not precise
%       resultPartId - Optional. Use for cases when your result is made
%       of several parts (for example for long propagations)
%
%   Outputs
%       results - struct array, containing the results from all requests
%       sent. NOTE: A result might be partial (check warnings!). In that
%       case, recall the function to get remaining results
%       error - contains the webstatus, error status, and error message

% loop and get result while looping

% check if result_part_id is available
if ~exist('result_part_id','var')
    resultPartId = 0;
end

for counter = 1:maxPollTime    
    [result, error] = OkapiGetResult(OkapiLogin, request, UrlEndpoint, ...
        resultPartId);
    web_status = error.web_status;
    if (web_status ~= 202) 
        break       
    end
    pause(1) 
end


end
