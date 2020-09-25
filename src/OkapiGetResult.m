function [result, error] = OkapiGetResult(OkapiLogin, request, UrlEndpoint, ...
    resultPartId)
% OkapiGetResult() Get results from Picard
%
%   Inputs
%       OkapiLogin - Struct, containing at least URL, options and Token for 
%       OKAPI:Platform. Can be obtained using OkapiInit().
%       request - struct array containing the request_id and request_type, needed
%       to get the results from Picard.
%       UrlEndpoint - The adress, from which the result is to be retrieved
%       resultPartId - Optional. Use for cases when your result is made
%       of several parts (for example for long propagations)
%
%   Outputs
%       results - struct array, containing the results from all requests
%       sent.
%       error - contains the webstatus, error status, and error message

import matlab.net.http.*;
result = [];

% check, the content of the input
if ( ~isstruct(request))
    error.message = 'Request was empty.';
    error.status = 'FATAL';
    error.web_status = matlab.net.http.StatusCode(204);
    return
elseif ( ~isfield(request,'request_id'))
    error.message = 'Request was empty (did not contain ID).';
    error.status = 'FATAL';   
    error.web_status = matlab.net.http.StatusCode(204);    
    return
end

% check if result_part_id is available
if ~exist('result_part_id','var')
    resultPartId = 0;
end
    
% set up the url. It should have no leading and no trailing "/"
if (strcmp(UrlEndpoint(1),'/'))
    UrlEndpoint = UrlEndpoint(2:end);   
end
if (strcmp(UrlEndpoint(end),'/'))
    UrlEndpoint = UrlEndpoint(1:end-1);   
end

url = strcat(OkapiLogin.url,UrlEndpoint);

% add the correct requestid in the string
if (resultPartId == 0)
    url = strrep(url, '{request_id}', request.request_id);
else
    url = [strrep(url, '{request_id}', request.request_id), '/', num2str(resultPartId)];
end

% set up a Matlab http request message
message = matlab.net.http.RequestMessage;
message.Method = 'GET';
genericHeader = matlab.net.http.field.GenericField('Authorization', ...
    "Bearer " + OkapiLogin.token.access_token); % This bypasses Matlab value validation
message.Header = genericHeader;
message = addFields(message, 'MediaType', 'application/json');
message = addFields(message, 'Accept', 'application/json');
message = addFields(message, 'token_type', OkapiLogin.token.token_type);
message = addFields(message, 'scope', OkapiLogin.token.scope);

% send the message
web_response = message.send(url);        

% Check for 404
if (web_response.StatusCode == 404)
    error.web_status = web_response.StatusCode;
    error.message = 'Response not found, probably the request has not been processed yet.';
    error.status = 'FATAL';
    return;
end

% get the error messages
error.message = web_response.Body.Data.status.text;
error.status = web_response.Body.Data.status.type;
error.web_status = web_response.StatusCode;

% check for 202
if (web_response.StatusCode == 202)
    return;
end

% get the result
if (~isempty(web_response.Body.Data))
    result = web_response.Body.Data;
end

if (result.next_result_part_foreseen == 1)
    error.message = 'There are more parts of the result available.';
    error.status = 'WARNING';
end