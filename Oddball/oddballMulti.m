% multi response oddball source code
% by Olav Krigolson, October, 2020
% note, to run this game you need to have Psychtoolbox (Version 3) and this
% was built on MALTAB 2019A

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
KbName('UnifyKeyNames');

% define key variables
useDataPixx = 1;
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
fixationDelay = 0.3;
% fixation deviation 
fixationDeviation = 0.1;
% how long the circle is up
circleTime = 0.8;
% number of locations
nLocations = 4;
% number of preview trials
nPreviews = 10;

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
DrawFormattedText(win, 'Multi Oddball','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

lineWidth = 5;
lineLength = 100;
circleMiddle = lineLength/2;

% instruction screen one
instructions = ['You are going to see a series of circles that appear and disappear in one of four locations on the screen.\nPress the space bar now to watch a preview.'];
DrawFormattedText(win, instructions,'center','center', textColor,[],[],[],2);
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

for previewCounter = 1:nPreviews
    Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
    Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
    Screen('Flip',win);
    fixationTime = rand(1)*fixationDeviation + fixationDelay;
    WaitSecs(fixationTime);
    Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
    Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
    circleLocation = randi(nLocations);
    switch circleLocation
        case 1
            circleX = xmid-circleMiddle;
            circleY = ymid-circleMiddle;
        case 2
            circleX = xmid+circleMiddle;
            circleY = ymid-circleMiddle;
        case 3
            circleX = xmid-circleMiddle;
            circleY = ymid+circleMiddle;
        otherwise
            circleX = xmid+circleMiddle;
            circleY = ymid+circleMiddle;
    end
    Screen('FillOval', win , targetColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
    Screen('Flip',win);
    WaitSecs(circleTime);
end

instructions = ['If the circle is the colour of the circle below, press the key that\ncorresponds to where the circle appears as shown below.\nPress the key that corresponds to the letter now.'];
DrawFormattedText(win, instructions,'center',ymid-300, textColor,[],[],[],2);
Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
circleLocation = randi(nLocations);
switch circleLocation
    case 1
        circleX = xmid-circleMiddle;
        circleY = ymid-circleMiddle;
    case 2
        circleX = xmid+circleMiddle;
        circleY = ymid-circleMiddle;
    case 3
        circleX = xmid-circleMiddle;
        circleY = ymid+circleMiddle;
    otherwise
        circleX = xmid+circleMiddle;
        circleY = ymid+circleMiddle;
end
Screen('FillOval', win , targetColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
DrawFormattedText(win, 'Q',xmid-circleMiddle,ymid-circleMiddle, textColor,[],[],[],2);
DrawFormattedText(win, 'P',xmid+circleMiddle-10,ymid-circleMiddle, textColor,[],[],[],2);
DrawFormattedText(win, 'A',xmid-circleMiddle,ymid+circleMiddle, textColor,[],[],[],2);
DrawFormattedText(win, 'L',xmid+circleMiddle-10,ymid+circleMiddle, textColor,[],[],[],2);
Screen('Flip',win);
waitForResponse = 1;
currentResponse = 0;
while waitForResponse
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('Q'))
            currentResponse = 1;
        end
        if keyCode(KbName('P'))
            currentResponse = 2;
        end
        if keyCode(KbName('A'))
            currentResponse = 3;
        end
        if keyCode(KbName('L'))
            currentResponse = 4;
        end
    end
    if currentResponse == circleLocation
        waitForResponse = 0;
    end
end
WaitSecs(.25);

for previewCounter = 1:nPreviews

    instructions = ['Lets try a few more.'];
    DrawFormattedText(win, instructions,'center',ymid-300, textColor,[],[],[],2);
    Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
    Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
    Screen('Flip',win);
    fixationTime = rand(1)*fixationDeviation + fixationDelay;
    WaitSecs(fixationTime);
    DrawFormattedText(win, instructions,'center',ymid-300, textColor,[],[],[],2);
    Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
    Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
    circleLocation = randi(nLocations);
    switch circleLocation
        case 1
            circleX = xmid-circleMiddle;
            circleY = ymid-circleMiddle;
        case 2
            circleX = xmid+circleMiddle;
            circleY = ymid-circleMiddle;
        case 3
            circleX = xmid-circleMiddle;
            circleY = ymid+circleMiddle;
        otherwise
            circleX = xmid+circleMiddle;
            circleY = ymid+circleMiddle;
    end
    Screen('FillOval', win , targetColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
    DrawFormattedText(win, 'Q',xmid-circleMiddle,ymid-circleMiddle, textColor,[],[],[],2);
    DrawFormattedText(win, 'P',xmid+circleMiddle-10,ymid-circleMiddle, textColor,[],[],[],2);
    DrawFormattedText(win, 'A',xmid-circleMiddle,ymid+circleMiddle, textColor,[],[],[],2);
    DrawFormattedText(win, 'L',xmid+circleMiddle-10,ymid+circleMiddle, textColor,[],[],[],2);
    Screen('Flip',win);
    waitForResponse = 1;
    currentResponse = 0;
    while waitForResponse
        [keypressed, ~, keyCode] = KbCheck();
        if keypressed
            if keyCode(KbName('Q'))
                currentResponse = 1;
            end
            if keyCode(KbName('P'))
                currentResponse = 2;
            end
            if keyCode(KbName('A'))
                currentResponse = 3;
            end
            if keyCode(KbName('L'))
                currentResponse = 4;
            end
        end
        if currentResponse == circleLocation
            waitForResponse = 0;
        end
    end
    WaitSecs(.25);
    
end

% instruction screen two
instructions = ['If you see a circle with the same color as the circle below, do not respond!\nPress the spacebar key to try a few more practice trials with both colors of circles.'];
DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
Screen('FillOval', win , controlColor, [xmid-circleRadius ymid-circleRadius xmid+circleRadius ymid+circleRadius], 8);
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

keepPracticing = 1;

while keepPracticing

    mistakes = 0;
    corrects = 0;

    for previewCounter = 1:nPreviews

        DrawFormattedText(win, instructions,'center',ymid-300, textColor,[],[],[],2);
        Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
        Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
        Screen('Flip',win);
        fixationTime = rand(1)*fixationDeviation + fixationDelay;
        WaitSecs(fixationTime);
        DrawFormattedText(win, instructions,'center',ymid-300, textColor,[],[],[],2);
        Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
        Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
        circleLocation = randi(nLocations);
        switch circleLocation
            case 1
                circleX = xmid-circleMiddle;
                circleY = ymid-circleMiddle;
            case 2
                circleX = xmid+circleMiddle;
                circleY = ymid-circleMiddle;
            case 3
                circleX = xmid-circleMiddle;
                circleY = ymid+circleMiddle;
            otherwise
                circleX = xmid+circleMiddle;
                circleY = ymid+circleMiddle;
        end
        targetOrNot = randi(10);
        if targetOrNot <= 4
            Screen('FillOval', win , targetColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
        else
            Screen('FillOval', win , controlColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
        end
        DrawFormattedText(win, 'Q',xmid-circleMiddle,ymid-circleMiddle, textColor,[],[],[],2);
        DrawFormattedText(win, 'P',xmid+circleMiddle-10,ymid-circleMiddle, textColor,[],[],[],2);
        DrawFormattedText(win, 'A',xmid-circleMiddle,ymid+circleMiddle, textColor,[],[],[],2);
        DrawFormattedText(win, 'L',xmid+circleMiddle-10,ymid+circleMiddle, textColor,[],[],[],2);
        Screen('Flip',win);
        waitForResponse = 1;
        currentResponse = 0;
        currentTime = 0;
        startTime = GetSecs;
        while currentTime <= circleTime
            while waitForResponse
                [keypressed, ~, keyCode] = KbCheck();
                if keypressed
                    if keyCode(KbName('Q'))
                        currentResponse = 1;
                    end
                    if keyCode(KbName('P'))
                        currentResponse = 2;
                    end
                    if keyCode(KbName('A'))
                        currentResponse = 3;
                    end
                    if keyCode(KbName('L'))
                        currentResponse = 4;
                    end
                    if targetOrNot > 4
                        mistakes = mistakes + 1;
                    else
                        corrects = corrects + 1;
                    end
                end
                if currentResponse == circleLocation
                    waitForResponse = 0;
                end
                currentTime = GetSecs - startTime;
                if currentTime > circleTime
                    break
                end
            end
            currentTime = GetSecs - startTime;
        end
        WaitSecs(.25);

    end
    
    instructions = ['You responded ' num2str(mistakes) ' time when you were not supposed to.\nYou made ' num2str(corrects) ' correct responses.\nIf you have any questions please ask the research assistant.\nPress the space bar key to continue to the game or R to redo the practical trials.'];
    DrawFormattedText(win, instructions,'center',ymid-200, textColor,[],[],[],2);
    Screen('Flip',win);

    waitForResponse = 1;
    while waitForResponse
        [keypressed, ~, keyCode] = KbCheck();
        if keypressed
            if keyCode(KbName('R'))
                waitForResponse = 0;
            end
            if keyCode(KbName('Space'))
                waitForResponse = 0;
                keepPracticing = 0;
            end
        end
    end
    WaitSecs(.25);
    
end
 
% instruction screen two
instructions = ['You will be completing ' num2str(numberBlocks) ' sets of ' num2str(numberTrials) ' circles.\nIf you have any questions please ask the research assistant.\nNote the letters for the target locations will not appear during the real game\nPress the C key to continue past this screen'];
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
    
    flipandmark(win, currentBlock, useDataPixx);
    
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
        Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
        Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
        flipandmark(win, 100, useDataPixx);
        fixationTime = rand(1)*fixationDeviation + fixationDelay;
        WaitSecs(fixationTime);
        
        % draw the circle
        Screen('FillRect', win , [0 0 0], [xmid-lineWidth ymid-lineLength xmid+lineWidth ymid+lineLength], 8);
        Screen('FillRect', win , [0 0 0], [xmid-lineLength ymid-lineWidth xmid+lineLength ymid+lineWidth], 8);
        circleLocation = randi(nLocations);
        switch circleLocation
            case 1
                circleX = xmid-circleMiddle;
                circleY = ymid-circleMiddle;
            case 2
                circleX = xmid+circleMiddle;
                circleY = ymid-circleMiddle;
            case 3
                circleX = xmid-circleMiddle;
                circleY = ymid+circleMiddle;
            otherwise
                circleX = xmid+circleMiddle;
                circleY = ymid+circleMiddle;
        end
        Screen('FillOval', win , drawColor, [circleX-circleRadius circleY-circleRadius circleX+circleRadius circleY+circleRadius], 8);
        if trialType == 1
            flipandmark(win, 102, useDataPixx);
        else
            flipandmark(win, 103, useDataPixx);
        end

        % start a clock to see if they respond and time out if not
        startTime = GetSecs;
        currentTime = GetSecs-startTime;
        currentResponse = 0;
        reactionTime = 0;
        noResponse = 1;
        while currentTime < circleTime
            [keypressed, ~, keyCode] = KbCheck();
            if keypressed && noResponse
                if keyCode(KbName('Q'))
                    sendmarker(104,useDataPixx);
                    currentResponse = 1;
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                end
                if keyCode(KbName('P'))
                    sendmarker(105,useDataPixx);
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                    currentResponse = 2;
                end
                if keyCode(KbName('A'))
                    sendmarker(106,useDataPixx);
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                    currentResponse = 3;
                end
                if keyCode(KbName('L'))
                    sendmarker(107,useDataPixx);
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                    currentResponse = 4;
                end
            end
            currentTime = GetSecs-startTime;
        end

        experimentData(actualTrialCounter,1) = currentBlock;
        experimentData(actualTrialCounter,2) = currentTrial;
        experimentData(actualTrialCounter,3) = trialType;
        experimentData(actualTrialCounter,4) = currentResponse;
        experimentData(actualTrialCounter,5) = circleLocation;
        experimentData(actualTrialCounter,6) = reactionTime;
        
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