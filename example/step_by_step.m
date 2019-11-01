%% step_by_step example. Documentation can be found here: https://okapiorbits.space/knowledge-base/matlab-connector/
clc; close all; clear all;
%% preparations
% include path with matlab connector
%addpath OkapiMatlabConnector/src
addpath ../src

%% First: Log-in to picard
[PicardLogin, OkapiError] = OkapiInit('http://okapi.ddns.net:34569/', your_username_as_string, your_password_as_string);
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
end
%% Second: Set-up your request. Here, we read it from file
% RequestBody = jsondecode(fileread('pass_prediction_request.json'));

% Alternative: Set it up yourself
groundLocation = struct('longitude',10.645,'latitude',52.3283,'altitude',0.048);
timeWindow = struct('start','2018-08-07T18:00:00.000Z','end','2018-08-07T20:00:00.000Z');
tle = ['1 25544U 98067A   18218.76369510  .00001449  00000-0  29472-4 0  9993' newline '2 25544  51.6423 126.6422 0005481  33.3092  62.9075 15.53806849126382'];
RequestBody = struct('tle',tle, 'simple_ground_location', groundLocation, 'time_window', timeWindow);

%% Third: Send the request to OKAPI
[request, OkapiError] = OkapiSendRequest(PicardLogin, RequestBody, 'pass/prediction/requests');
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
end

%% Fourth get the result (after waiting a short moment)
pause(2)
[result, OkapiError] = OkapiGetResult(PicardLogin, request, 'pass/predictions');
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
end