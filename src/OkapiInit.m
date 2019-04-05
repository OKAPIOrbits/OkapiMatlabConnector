function [PicardLogin, error] = OkapiInit(url, username, password)
% OkapiInit() Performs the initialization of Picard. By default, all
% possible scopes are requested.
%   
% Inputs:
%   url - The url, where Picard is running.
%   username - the username to access Picard
%   password - the password to access Picard
%
% Outputs:
%   PicardLogin - Struct, containing URL, Token, accessTime, options and
%   success status. PicardLogin.exit == 0 is success
%   error - struct containing error states

% include a check for a secure connection. 

% init
import matlab.net.http.*;
error.message = 'No messages available';
error.status = 'NONE';
error.web_status = 0;
PicardLogin = 0;

% set up the message
message = matlab.net.http.RequestMessage;
message.Method = 'POST';
message = addFields(message, 'MediaType', 'application/json');


% create the body
request_token_payload = struct('grant_type', 'password', ...
    'username', username, ...
    'password', password, ...
    'audience', 'https://api.okapiorbits.space/picard', ...
    'scope', 'neptune_propagation neptune_propagation_request pass_predictions pass_prediction_requests pass_predictions_long pass_prediction_requests_long', ...
    'client_id', 'jrk0ZTrTuApxUstXcXdu9r71IX5IeKD3');
message_body = matlab.net.http.MessageBody;
message_body.Data = request_token_payload;

% and add it to the message
message.Body = message_body;

% send the message
web_response = message.send('https://okapi-development.eu.auth0.com/oauth/token');

% check for some errors
% check for 404
if (web_response.StatusCode == 404)
    error.web_status = web_response.StatusCode;
    error.message = 'Auth0 server not found.';
    error.status = 'FATAL';
    return;
end

if (web_response.StatusCode == 403)
    error.web_status = web_response.StatusCode;
    error.message = ['Error in okapi_init: ', web_response.Body.Data.error,': ', web_response.Body.Data.error_description];
    error.status = 'FATAL';
    return;
end

% set up the token
clearvars PicardLogin
PicardLogin.token = web_response.Body.Data;

% ensure that there is a trailing "/" in the url
if (strcmp(url(end),'/'))
    PicardLogin.url = url;
else
    PicardLogin.url = [url,'/'];
end

PicardLogin.accessTime = now;

end

