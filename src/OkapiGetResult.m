function [result, error] = OkapiGetResult(PicardLogin, request, UrlEndpoint)
% OkapiGetResult() Get results from Picard
%
%   Inputs
%       PicardLogin - Struct, containing at least URL, options and Token for 
%       Picard. Can be obtained using OkapiInit().
%       request - struct array containing the request_id and request_type, needed
%       to get the results from Picard.
%       UrlEndpoint - The adress, from which the result is to be retrieved
%
%   Outputs
%       results - struct array, containing the results from all requests
%       sent.

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
    
% set up the url. It should have no leading and no trailing "/"
if (strcmp(UrlEndpoint(1),'/'))
    UrlEndpoint = UrlEndpoint(2:end);   
end
if (strcmp(UrlEndpoint(end),'/'))
    UrlEndpoint = UrlEndpoint(1:end-1);   
end
url = [PicardLogin.url,UrlEndpoint,'/', num2str(request.request_id)];

% set up a Matlab http request message
message = matlab.net.http.RequestMessage;
message.Method = 'GET';
message = addFields(message, 'access_token',PicardLogin.token.access_token);
message = addFields(message, 'scope',PicardLogin.token.scope);
    
%result.service = request.service;

% send the message
web_response = message.send(url);        

% Check for 404
if (web_response.StatusCode == 404)
    error.web_status = web_response.StatusCode;
    error.message = 'Response not found, probably the request has not been processed yet.';
    error.status = 'FATAL';
    return;
end

% get the result as char (needed for conversion to json
if (~isempty(web_response.Body.Data))
    result = jsondecode(convertStringsToChars(web_response.Body.Data));
end

% check for 202
if (web_response.StatusCode == 202)
    error.web_status = web_response.StatusCode;
    error.message = 'Result might not be complete.';
    error.status = 'WARNING';            
    return;
end
    
% for simplicity, write the values to error
error.message = 'No messages available';
error.status = 'NONE';

% check if struct or cell
for (i = 1:length(result))
    
    % check if we have the field stateMsg oder stateMsgs
    if (isfield(result(i),'state_msg'))
        if (~strcmp(error.status,'FATAL')) && (~strcmp(result(i).state_msg.type,'NONE'))
            error.message = result(i).state_msg.text;
            error.status = result(i).state_msg.type;
        end
    elseif (isfield(result(i),'state_msgs'))
        for (j = 1:length(result(i).state_msgs))
            if (~strcmp(error.status,'FATAL')) && (~strcmp(result(i).state_msgs(j).type,'NONE'))
                error.message = result(i).state_msgs(j).text;
                error.status = result(i).state_msgs(j).type;
            end
        end    
    elseif (isfield(result{i,1},'state_msgs'))
        for (j = 1:length(result{i,1}.state_msgs))
            if (~strcmp(error.status,'FATAL')) && (~strcmp(result{i,1}.state_msgs(j).type,'NONE'))
                error.message = result{i,1}.state_msgs(j).text;
                error.status = result{i,1}.state_msgs(j).type;
            end
        end
    else
        error('Unexpected error in OkapiGetResult');
    end
end

error.web_status = web_response.StatusCode;                      