function [ X, Y ] = uci_wdbc_read( input_file )
%UCI_WDBC_READ Read data file of the UCI letter data set.
%
%   uci_wdbc_read(input_file) reads the standard UCI wdbc data set.
%
%   Input:
%       - input_file: file name
%
%   Output:
%       - X: data matrix (data points as column vectors)
%       - Y: vector of class labels
%
%   Author: Benjamin Rupprechter
%
%   Created: 17.04.2012
%
    % provided by documentation
    instance_number = 569;
    data_dimension = 30;
    
    % open file
    [fid, err_msg] = fopen(input_file, 'r', 'ieee-le', 'UTF-8');
    assert(fid >= 0, err_msg);
    
    [D, count] = fscanf(fid, '%*d,%c,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f%*c', [data_dimension+1 instance_number]);
    assert(count == instance_number*(data_dimension+1), 'Invalid UCI WDBC file: Wrong number of data.');
    
    X = D(2:end,:);
    Y = char(D(1,:));
    
    % close file
    fclose(fid);
end

% usage:
% [X, Y] = uci_wdbc_read('+data/+UCI/wdbc.data');
