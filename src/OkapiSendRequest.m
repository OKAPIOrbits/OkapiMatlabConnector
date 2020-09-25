function [request, error] = OkapiSendRequest(OkapiLogin, ... 
    RequestBody, UrlEndpoint)
% OkapiSendRequest() Sends requests to Picard
%
%   Inputs
%       PicardLogin - Struct, containing at least URL, options and Token for 
%       Picard. Can be obtained using OkapiInit().
%       RequestBody - Struct containing the request. A struct of 
%       the correct format can be gained by OkapiGetPassPredictionRequest.
%       UrlEndpoint - The adress to which the request is sent
%
%   Outputs
%       request - struct containing the request_id and request_type, needed
%       to get the results from Picard.
%       error - struct containing error states


% init
import matlab.net.http.*;
error.message = 'No messages available';
error.status = 'NONE';
error.web_status = 0;
request = [];

% set up the message
message = matlab.net.http.RequestMessage;
message.Method = 'POST';

genericHeader = matlab.net.http.field.GenericField('Authorization',"Bearer " ...
    + OkapiLogin.token.access_token); % This bypasses Matlab value validation
message.Header = genericHeader;
message = addFields(message, 'MediaType', 'application/json');
message = addFields(message, 'Accept', 'application/json');
message = addFields(message, 'token_type', OkapiLogin.token.token_type);
message = addFields(message, 'scope', OkapiLogin.token.scope);

% create the body
message_body = matlab.net.http.MessageBody;
message_body.Data = RequestBody;

% and add it to the message
message.Body = message_body;

% create the url: Make sure there are only single "/".
% The input url should have no "/" in the beginning and none in the end
if (strcmp(UrlEndpoint(1),'/'))
    UrlEndpoint = UrlEndpoint(2:end);   
end
if (strcmp(UrlEndpoint(end),'/'))
    UrlEndpoint = UrlEndpoint(1:end-1);   
end
url = strcat(OkapiLogin.url,UrlEndpoint);

% send the message to the server
web_response = message.send(url);

% check for 404
if (web_response.StatusCode == 404)
    error.web_status = web_response.StatusCode;
    error.message = 'Server not found. Wrong url?';
    error.status = 'FATAL';
    return;
end

% extract the request
if (isstruct(web_response.Body.Data)) % probably something went wrong
    request = web_response.Body.Data;
else
    request = jsondecode(convertStringsToChars(web_response.Body.Data));
end

% get the errors and the message in case the everything was okay or we got
% a 500 as result (which indicates a wrong input)

error.message = strcat("OkapiSendRequest: ", request.status.text);
error.status = request.status.type;
error.web_status = web_response.StatusCode;

% check for timeouts?
