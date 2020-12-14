clear all;
close all;
clc;
rng('shuffle');

fileName = input('Enter a filename: ','s');

ListenChar(2); %Stop typing in Matlab
HideCursor();   % hide the cursor

doorWin(1) = 0.6;
doorWin(2) = 0.1;
doorTimeDelay = 0.4;
doorTimeDeviation = 0.2;
nBlocks = 2;
nTrials = 15;
% define the screen size
screenSize = [0 0 800 600];
% define default text size
textSize = 24;
% define the text color
textColor = [0 0 0];
% define a key to crash out of the program
exitKey = KbName('Q');
% define a variable to hold behavioural data
experimentData = [];

Screen('Preference', 'SkipSyncTests', 1); 
[window, windowSize] = Screen('OpenWindow', 0, [255 255 255], screenSize,32,2);

d{1} = imread('d1.jpg');
d{2} = imread('d2.jpg');
d{3} = imread('d3.jpg');
d{4} = imread('d4.jpg');
winI = imread('win.jpg');
lossI = imread('loss.jpg');

dTexture{1} = Screen('MakeTexture', window, d{1});
dTexture{2} = Screen('MakeTexture', window, d{2});
dTexture{3} = Screen('MakeTexture', window, d{3});
dTexture{4} = Screen('MakeTexture', window, d{4});
winTexture = Screen('MakeTexture', window, winI);
lossTexture = Screen('MakeTexture', window, lossI);

xMid = windowSize(3)/2;
yMid = windowSize(4)/2;
doorGap = 50;
doorLocations(1,:) = [xMid-doorGap*2.5 yMid-doorGap*2 xMid-doorGap yMid+doorGap*2];
doorLocations(2,:) = [xMid+doorGap yMid-doorGap*2 xMid+doorGap*2.5 yMid+doorGap*2];

% put up the task name in the middle of the screen
DrawFormattedText(window, 'Rapid Doors Task','center', 'center', textColor,[],[],[],2);
Screen('Flip', window);
WaitSecs(5);

% instruction screen one
instructions = ['You are going to see to see two doors on the screen. Win by selecting the door that has more gold behind it!n.\nOne of the doors has more gold than the other. Press A to select the left door and L to select the right door\nSometimes the doors do not pay any gold.\nPress C to continue.'];
DrawFormattedText(window, instructions,'center',yMid-200, textColor,[],[],[],2);
Screen('Flip',window);

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

for blockCounter = 1:nBlocks
    
    % pick new door colors
    door1 = randi(4);
    while 1
        door2 = randi(4);
        if door2 ~= door1
            break
        end
    end
    doorColour{1} = dTexture{door1};
    doorColour{2} = dTexture{door2};

    % block message
    DrawFormattedText(window,['Block ' num2str(blockCounter)],'center',yMid-200,textColor);
    DrawFormattedText(window,'Press C to continue.','center',yMid+200,textColor);
    Screen('Flip',window);
    
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

    DrawFormattedText(window,['Get Ready'],'center','center',textColor);
    Screen('Flip',window);
    WaitSecs(1);
 
    DrawFormattedText(window,['3'],'center','center',textColor);
    Screen('Flip',window);
    WaitSecs(1);

    DrawFormattedText(window,['2'],'center','center',textColor);
    Screen('Flip',window);
    WaitSecs(1);

    DrawFormattedText(window,['1'],'center','center',textColor);
    Screen('Flip',window);
    WaitSecs(1);
    
    Screen('Flip',window);
    WaitSecs(1);    
    
    for trialCounter = 1:nTrials
        
        % randomize door locations
        doorOrder = [1 2];
        doorOrder = Shuffle(doorOrder);
        
        trialWin(1) = doorWin(doorOrder(1));
        trialWin(2) = doorWin(doorOrder(2));
        
        Screen('DrawTexture', window, doorColour{doorOrder(1)}, [], [doorLocations(1,:)]);
        Screen('DrawTexture', window, doorColour{doorOrder(2)}, [], [doorLocations(2,:)]);
        Screen('Flip',window);
        
        startTime = GetSecs;
        currentResponse = 0;
        reactionTime = 0;
        noResponse = 1;
        while noResponse
            [keypressed, ~, keyCode] = KbCheck();
            if keypressed && noResponse
                if keyCode(KbName('A'))
                    currentResponse = 1;
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                end
            end
            if keypressed && noResponse
                if keyCode(KbName('L'))
                    currentResponse = 2;
                    reactionTime = GetSecs - startTime;
                    noResponse = 0;
                end
            end
        end
        
        doorRoll = rand(1);
        outcome = 0;
        if doorRoll < trialWin(currentResponse)
            outcome = 1;
        end
        
        if outcome == 1
            Screen('DrawTexture', window, winTexture, [], [xMid-50 yMid-50 xMid+50 yMid+50]);
        else
            Screen('DrawTexture', window, lossTexture, [], [xMid-50 yMid-50 xMid+50 yMid+50]);
        end
        Screen('Flip',window);
        doorTime = rand(1)*doorTimeDeviation + doorTimeDelay;
        WaitSecs(doorTime);  
        
        experimentData(actualTrialCounter,1) = blockCounter;
        experimentData(actualTrialCounter,2) = trialCounter;
        experimentData(actualTrialCounter,3) = doorOrder(1);
        experimentData(actualTrialCounter,4) = doorOrder(2);
        experimentData(actualTrialCounter,5) = trialWin(1);
        experimentData(actualTrialCounter,6) = trialWin(2);
        experimentData(actualTrialCounter,7) = currentResponse;
        experimentData(actualTrialCounter,8) = reactionTime;        
        experimentData(actualTrialCounter,9) = outcome;
        experimentData(actualTrialCounter,10) = doorRoll;
        experimentData(actualTrialCounter,11) = door1;
        experimentData(actualTrialCounter,12) = door2;
        
        actualTrialCounter = actualTrialCounter + 1;
        
    end
    
end

DrawFormattedText(window, 'Thanks for playing!','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', window);
WaitSecs(5);

sca;
ListenChar(0); % allow typing in Matlab
ShowCursor();  % show the cursor

save(fileName,'experimentData');