% one response oddball source code
% by Olav Krigolson, October, 2020
% note, to run this game you need to have Psychtoolbox (Version 3) and this
% was built on MALTAB 2019A
% this is designed to very fast and test the unfold toolbox and GLM
% decomposition of overlapped ERPs

% note, only uncomment these two lines (and the one at the end) if you know this will not crash!
%ListenChar(2); %Stop typing in Matlab
%HideCursor();   % hide the cursor

% clear all variables in memory
clear all;
% close all open matlab files and windows
close all;
% clear the console
clc;
% seed the random number generator
rng('shuffle');

% setup Psych sound
% Initialize Sounddriver
InitializePsychSound(1);
% Number of channels and Frequency of the sound
nrchannels = 2;
freq = 48000;
% How many times to we wish to play the sound
repetitions = 1;
% Length of the beep
beepLengthSecs = 0.1;
% Start immediately (0 = immediately)
startCue = 0;
% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;
% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
soundHandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
% Set the volume to half for this demo
PsychPortAudio('Volume', soundHandle, 0.5);
% Make a beep which we will play back to the user
oddBeep = MakeBeep(500, beepLengthSecs, freq);
conBeep = MakeBeep(250, beepLengthSecs, freq);

% define key variables
% what is the chance a trial is an oddball
oddballChance = 0.25;
% define the number of experimental blocks
numberBlocks = 4;
% define the number of experimental trials
numberTrials = 50;
% define the background screen colour
backgroundColor = [166 166 166];
% define the screen size
screenSize = [0 0 800 600];
% define default text size
textSize = 24;
% define the text color
textColor = [255 255 255];
% define a key to crash out of the program
exitKey = KbName('Q');
% define a variable to hold behavioural data
experimentData = [];
% define circle size by its radius
circleRadius = 30;
% fixation mean delay
fixationDelay = 0.4;
% fixation deviation 
fixationDeviation = 0.2;

% skip Psychtoolbox sync tests to avoid sync failure issues
Screen('Preference', 'SkipSyncTests', 1); 
% open a Psychtoolbox drawing window
[win, rec] = Screen('OpenWindow', 0 , backgroundColor, screenSize, 32, 2);
% get the x and y coordinates of the middle of the screen
xmid = rec(3)/2;
ymid = rec(4)/2;

% setup some parameters
Screen(win,'TextSize', textSize);
% determine the target color and the inverse for the control color
targetColor = [randi(255) randi(255) randi(255)];
controlColor = 255-targetColor;

% put up the task name in the middle of the screen
DrawFormattedText(win, 'Rapid Audio Oddball','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

% instruction screen one
instructions = ['You are going to hear a series of beeps. Some with sound different than others.\nTry and count the beeps.\nPress U if you understand.'];
DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
Screen('Flip',win);

waitForResponse = 1;
while waitForResponse
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('U'))
            waitForResponse = 0;
        end
    end
end
WaitSecs(.25);

% instruction screen two
instructions = ['You will be completing ' num2str(numberBlocks) ' sets of ' num2str(numberTrials) ' soundsuccc.\nIf you have any questions please ask the research assistant.\nPress the C key to continue past this screen'];
DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
Screen('Flip',win);

waitForResponse = 1;
while waitForResponse
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('C'))
            waitForResponse = 0;
        end
    end
end
WaitSecs(.25);

actualTrialCounter = 1;

for currentBlock = 1:numberBlocks
    
    % block message
    DrawFormattedText(win,['Block ' num2str(currentBlock)],'center',ymid-200,textColor);
    DrawFormattedText(win,'Press C to continue.','center',ymid+200,textColor);
    Screen('Flip',win);
    
    waitForResponse = 1;
    while waitForResponse
        [keypressed, ~, keyCode] = KbCheck();
        if keypressed
            if keyCode(KbName('C'))
                waitForResponse = 0;
            end
        end
    end
    WaitSecs(.25);

    DrawFormattedText(win,['Get Ready'],'center','center',textColor);
    Screen('Flip',win);
    WaitSecs(1);
 
    DrawFormattedText(win,['3'],'center','center',textColor);
    Screen('Flip',win);
    WaitSecs(1);

    DrawFormattedText(win,['2'],'center','center',textColor);
    Screen('Flip',win);
    WaitSecs(1);

    DrawFormattedText(win,['1'],'center','center',textColor);
    Screen('Flip',win);
    WaitSecs(1);
    
    Screen('Flip',win);
    WaitSecs(1);
    
    for currentTrial = 1:numberTrials
        
        %Determine whether oddball or control trial
        if rand < oddballChance
            PsychPortAudio('FillBuffer', soundHandle, [oddBeep; oddBeep]);
            trialType = 1;
        else
            PsychPortAudio('FillBuffer', soundHandle, [conBeep; conBeep]);
            trialType = 2;
        end
        
        % draw fixation + for random delay
        DrawFormattedText(win,'+','center','center',textColor);
        Screen('Flip',win);
        fixationTime = rand(1)*fixationDeviation + fixationDelay;
        WaitSecs(fixationTime);
        
        % draw the circle
        if trialType == 1
            PsychPortAudio('FillBuffer', soundHandle, [oddBeep; oddBeep]);
        else
            PsychPortAudio('FillBuffer', soundHandle, [conBeep; conBeep]);
        end

        % Start audio playback
        PsychPortAudio('Start', soundHandle, repetitions, startCue, waitForDeviceStart);
        % Wait for the beep to end.
        [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', soundHandle, 1, 1);
        
        % crash out of experiment (trials)
        [~, ~, keyCode] = KbCheck();
        if keyCode(exitKey)
            break;
        end
        
    end
    
    % crash out of experiment (blocks)
    [~, ~, keyCode] = KbCheck();
    if keyCode(exitKey)
        break;
    end
    
end

DrawFormattedText(win, 'Thanks for listening!','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

% Close the audio device
PsychPortAudio('Close', soundHandle);

sca;
ListenChar(0); % allow typing in Matlab
ShowCursor();  % show the cursor