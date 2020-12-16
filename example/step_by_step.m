%% step_by_step example. Documentation can be found here: https://okapiorbits.space/knowledge-base/matlab-connector/
clc; close all; clear all;
%% preparations
% include path with matlab connector
%addpath OkapiMatlabConnector/src
addpath ../src

%% First: Log-in to picard
[PicardLogin, OkapiError] = OkapiInit('https://api.okapiorbits.com/', <your login as string>, <your pw as string>);
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
end
%% Second: Set-up your request. Here, we read it from file
% RequestBody = jsondecode(fileread('pass_prediction_request.json'));

% Alternative: Set it up yourself. Cf. https://okapiorbits.space/api-doc/index.html#
orbitContent = ['1 25544U 98067A   18218.76369510  .00001449  00000-0  29472-4 0  9993' newline '2 25544  51.6423 126.6422 0005481  33.3092  62.9075 15.53806849126382'];
orbit = struct('type', 'tle.txt', 'content', orbitContent);

groundLocationContent = struct('longitude',10.645,'latitude',52.3283,'altitude',0.048);
groundLocation = struct('type', 'ground_loc.json', 'content', groundLocationContent);

timeWindowContent = struct('start','2018-08-07T18:00:00.000Z','end','2018-08-07T20:00:00.000Z');
timeWindow = struct('type', 'tw.json', 'content', timeWindowContent);

RequestBody = struct('orbit', orbit, 'ground_location', groundLocation, 'time_window', timeWindow);

%% Third: Send the request to OKAPI
clc
[request, OkapiError] = OkapiSendRequest(PicardLogin, RequestBody, '/predict-passes/sgp4/requests');
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
end

% Fourth get the result (after waiting a short moment)
pause(2)
[result, OkapiError] = OkapiGetResult(PicardLogin, request, '/predict-passes/sgp4/results/{request_id}/simple');
if (strcmp(OkapiError.status, 'FATAL'))
    % do something about fatal errors
    error(OkapiError.message);
elseif (strcmp(OkapiError.status, 'WARNING'))
    % do something about warnings
    display(OkapiError.message);
    elseif (strcmp(OkapiError.status, 'REMARK'))
    % do something about remarks
    display(OkapiError.message);
end
