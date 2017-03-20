function [ X, Y ] = uci_australian_read( input_file )
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
%   Author: Yuxin Chen
%
%   Created: 09.2012
%
    % provided by documentation
    % instance_number = 690;
    % data_dimension = 14;
    
    % open file
    D = load(input_file)';
    
    X = D(1:end-1,:);
    Y = D(end,:)*2-1;
    
end

% usage:
% [X, Y] = uci_australian_read('+data/+UCI/australian.dat');
