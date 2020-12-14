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

% define key variables
% what is the chance a trial is an oddball
oddballChance = 0.25;
% define the number of experimental blocks
numberBlocks = 2;
% define the number of experimental trials
numberTrials = 4;
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
fixationDelay = 0.1;
% fixation deviation 
fixationDeviation = 0.1;
% how long the circle is up
circleTime = 0.3;

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
DrawFormattedText(win, 'Rapid Visual Oddball','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

% instruction screen one
instructions = ['You are going to see a series of circles that appear and disappear in the middle of the screen.\nIf you see a circle with the same color as the circle below, press the Space bar as quickly as you can.\nTry this now!'];
DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
Screen('FillOval', win , targetColor, [xmid-circleRadius ymid-circleRadius xmid+circleRadius ymid+circleRadius], 8);
Screen('Flip',win);

waitForResponse = 1;
while waitForResponse
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('Space'))
            waitForResponse = 0;
        end
    end
end
WaitSecs(.25);

% instruction screen two
instructions = ['If you see a circle with the same color as the circle below, do nothing!.\nPress the U key if you understand'];
DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
Screen('FillOval', win , controlColor, [xmid-circleRadius ymid-circleRadius xmid+circleRadius ymid+circleRadius], 8);
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
instructions = ['You will be completing ' num2str(numberBlocks) ' sets of ' num2str(numberTrials) ' circles.\nIf you have any questions please ask the research assistant.\nPress the C key to continue past this screen'];
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
            drawColor = targetColor;
            trialType = 1;
        else
            drawColor = controlColor;
            trialType = 2;
        end
        
        % draw fixation + for random delay
        DrawFormattedText(win,'+','center','center',textColor);
        Screen('Flip',win);
        fixationTime = rand(1)*fixationDeviation + fixationDelay;
        WaitSecs(fixationTime);
        
        % draw the circle
        Screen('FillOval', win , drawColor, [xmid-circleRadius ymid-circleRadius xmid+circleRadius ymid+circleRadius], 8);
        Screen('Flip',win);

        % start a clock to see if they respond and time out if not
        startTime = GetSecs;
        currentTime = GetSecs-startTime;
        currentResponse = 0;
        reactionTime = 0;
        noResponse = 1;
        while currentTime < circleTime
            [keypressed, ~, keyCode] = KbCheck();
            if keypressed && noResponse
                if keyCode(KbName('Space'))
                    currentResponse = 1;
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                end
            end
            currentTime = GetSecs-startTime;
        end

        experimentData(actualTrialCounter,1) = currentBlock;
        experimentData(actualTrialCounter,2) = currentTrial;
        experimentData(actualTrialCounter,3) = trialType;
        experimentData(actualTrialCounter,4) = currentResponse;
        experimentData(actualTrialCounter,5) = reactionTime;
        
        actualTrialCounter = actualTrialCounter + 1;
        
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

DrawFormattedText(win, 'Thanks for playing!','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

sca;
ListenChar(0); % allow typing in Matlab
ShowCursor();  % show the cursor