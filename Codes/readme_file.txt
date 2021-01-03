MATLAB Codes for the Audinoise Algorithm :

Following is the description of each of the .m files:

    HYbrid_LSTM_Modified - The main implementation/code for training the proposed system with existing dataset.
  
    Hybrid_LSTM_Modified_ModelNet (mat file) - Trained model using proposed Deep Neural Network.
  
    Validation_HybridLSTM_Modified - Code to test the proposed system using Validation and Test Dataset.
  
    CRNN Model - The implementation of a Convolutional Recurrent Neural Network based approach as Baseline model.
    
    noisySpeechGeneration - Function to synthetically generate noisy speech from clean speech, noise and Room Impulse Response (RIR) data for training purpose. 
    
    DataPreparation - Prepare the audio data for synthetic training data generation code. 
    
    Evaluation_DevSet - Code for Evaluating the Baseline (Only NN based) model for performance analysis on Development set.   
    
    Evaluation_DevSet_2 - Code for Evaluating the Proposed Hybrid (Adaptive Filter + DNN) model for performance analysis on Development set.
  
    NameSet, DevSet - Details (Meta data) of the training audio dataset.  
    
    The trained model for CRNN baseline is available here:
    https://www.dropbox.com/s/6rcpb1e1c01z4gi/CRNN_Model.zip?dl=0
    
    
  
