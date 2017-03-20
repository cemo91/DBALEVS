function [ X, Y ] = load_dataset( dataset, normalize_data, add_dummy_dimension)
%LOAD_DATASET Load a data set.
%
%   load_dataset(dataset, normalize_data, add_dummy_dimension, synthetic_n) 
%   loads the specified dataset from the '+data/' subdirectory, and can
%   optionally normalize the data so that every dimension has a mean of
%   zero and a standard deviation of 0.5. In addition, it is possible to
%   add a dummy dimension.
%
%   Input:
%       - dataset: the name of the data set to load, possible values are:
%           'wdbc', 'australian'
%       - normalize_data: if data should be normalized
%       - add_dummy_dimension: if dummy dimension should be added
%
%   Output:
%       - X: data set in matrix format, with data points as columns
%       - Y: corresponding class label information for each data point
%
%   Author: Benjamin Rupprechter (Modified by Yuxin Chen)
%
%   Created: 17.04.2012
%

    % load data
    switch dataset
            
        case 'wdbc'
            [X_orig, Y] = data.UCI.uci_wdbc_read('+data/+UCI/wdbc.data');
            Y = double(Y);
            Y(Y == double('M')) = -1;
            Y(Y == double('B')) = +1;
            
        case 'australian'
            [X_orig, Y] = data.UCI.uci_australian_read('+data/+UCI/australian.dat');
            

        otherwise
            error('no or invalid input data selected');
    end

    % standardize data: each feature should have mean 0, standard deviation 0.5
    if normalize_data
        [~, T] = size(X_orig);
        Mean = repmat(mean(X_orig, 2), 1, T);
        Std_inv = repmat(.5 ./ std(X_orig, 1, 2), 1, T);

        X = (X_orig - Mean) .* Std_inv;
    else
        X = X_orig;
    end

    % add dummy feature to enable hyperplanes that do not go through the origin
    if add_dummy_dimension
        X = [X; ones(1, T)];
    end
end
