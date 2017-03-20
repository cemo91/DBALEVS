function [model, prediction, accuracy, posterior,sigma] = process_svm(data, label, test_data, test_label, posterior_fit, kernel)
    if posterior_fit == 0
        model = fitcsvm(data, label, 'KernelFunction', kernel);
        [prediction, posterior] = predict(model, test_data);
        accuracy = (sum(prediction == test_label) / size(test_data,1))*100;
        sigma = model.KernelParameters.Scale;
    elseif posterior_fit == 1
        model = fitcsvm(data, label, 'KernelFunction', kernel);
        model = fitSVMPosterior(model);
        [prediction, posterior] = predict(model, test_data);
        accuracy = 0;
        sigma = model.KernelParameters.Scale;
    end
end