clc;
clear all;
close all;
rng('shuffle');

percentMatch = 0.15;
numberOfBlocks = 1;
numberOfTrials = 26;
blockType = [1 1 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3];
blockType = shuffle(blockType);

fileName = input('Enter a filename: ','s');

%ListenChar(2);
%HideCursor();

k1 = 'space';
keyOne = KbName(k1);

backgroundColour = [0 0 0];
mainColour = [255 255 255];

Screen('Preference', 'SkipSyncTests', 1); 
[window, windowSize] = Screen('OpenWindow', 0, backgroundColour, [0 0 800 600],32,2);

x_mid = windowSize(3)/2;
y_mid = windowSize(4)/2; 

actualTrialCounter = 1;

alphabet = 'abcdefghijklmnopqrstuvwxyz';

for blockCounter = 1:1 %numberOfBlocks
    
    nBak = blockType(blockCounter);
    
    alphabetNumbers = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
    alphabetNumbers = shuffle(alphabetNumbers);
    firstTarget = randi([4 10]);
    secondTarget = randi([12 18]); 
    thirdTarget = randi([20 26]);
    alphabetNumbers(firstTarget) = alphabetNumbers(firstTarget - nBak);
    alphabetNumbers(secondTarget) = alphabetNumbers(secondTarget - nBak);
    alphabetNumbers(thirdTarget) = alphabetNumbers(thirdTarget - nBak);
    targets = [firstTarget secondTarget thirdTarget];
    
    Screen(window,'TextFont','Arial');
    Screen(window,'TextSize',20);
    
    DrawFormattedText(window,'READY?','center', 'center',mainColour,[],[],[],2);
    Screen('Flip',window);
    
    KbPressWait;
    
    DrawFormattedText(window,'RELAX','center', 'center',mainColour,[],[],[],2);
    Screen('Flip',window);
    
    WaitSecs(15);

    instructions1a = 'You are going to see a series of letters';
    instructions1b = ['If the letter ' num2str(nBak) ' letters ago is the same as the current letter'];
    instructions1c = 'Press the space bar';
    instructions1d = 'For example, if this is a 1 back game';    
    instructions1e = 'If you saw: a c t g i i';
    instructions1f = 'You would press the space bar as there was an i 1 digit ago';

    DrawFormattedText(window, instructions1a,'center', y_mid-200, mainColour,[],[],[],2);
    DrawFormattedText(window, instructions1b,'center', y_mid-150, mainColour,[],[],[],2);
    DrawFormattedText(window, instructions1c,'center', y_mid-100, mainColour,[],[],[],2);
    DrawFormattedText(window, instructions1d,'center', y_mid-50, mainColour,[],[],[],2);
    DrawFormattedText(window, instructions1e,'center', y_mid, mainColour,[],[],[],2);
    DrawFormattedText(window, instructions1f,'center', y_mid+50, mainColour,[],[],[],2);
    DrawFormattedText(window, 'Press Any Key To Continue','center', y_mid+200, mainColour,[],[],[],2);
    Screen('Flip',window);

    KbPressWait;
    
    Screen(window,'TextFont','Arial');
    Screen(window,'TextSize',20);
    DrawFormattedText(window, ['READY?'],'center', 'center', mainColour,[],[],[],2);
    Screen('Flip',window);

    WaitSecs(2);
    
    memoryBank(1:numberOfTrials) = 0;
    lastTrial = 0;

    for trialCounter = 1:numberOfTrials
        
        currentNumber = alphabetNumbers(trialCounter);
        checkOutcome = ismember(alphabetNumbers(trialCounter),targets);

        currentLetter = alphabet(currentNumber);
        
        Screen(window,'TextFont','Arial');
        Screen(window,'TextSize',40);
        DrawFormattedText(window, currentLetter,'center', 'center', mainColour,[],[],[],2);
        Screen('Flip',window);
        
        startRT = GetSecs;        
        responseCorrect = 0;
        haveResponded = 0;
        responseTime = 0;

        while 1
            
            [keyIsDown, secs, keyCode] = KbCheck;

            if keyCode(keyOne) == 1 & haveResponded == 0
                responseTime = GetSecs - startRT;
                haveResponded = 1;
                if checkOutcome == 0
                    responseCorrect = -1;
                end
                if checkOutcome == 1
                    responseCorrect = 1;
                end
            end
            if GetSecs - startRT > 0.5
                break;
            end
        end
        
        Screen('Flip',window);
        
        while 1
            
            [keyIsDown, secs, keyCode] = KbCheck;

            if keyCode(keyOne) == 1 & haveResponded == 0
                responseTime = GetSecs - startRT;
                haveResponded = 1;
                if checkOutcome == 0
                    responseCorrect = -1;
                end
                if checkOutcome == 1
                    responseCorrect = 1;
                end
            end
            if GetSecs - startRT > 1.5
                if haveResponded == 0
                    responseCorrect = -2;
                end
                break;
            end
        end
        
        studentData(actualTrialCounter,1) = blockCounter;
        studentData(actualTrialCounter,2) = trialCounter;
        studentData(actualTrialCounter,3) = alphabetNumbers(currentNumber);
        studentData(actualTrialCounter,4) = checkOutcome;
        studentData(actualTrialCounter,5) = responseCorrect;
        studentData(actualTrialCounter,6) = haveResponded;
        studentData(actualTrialCounter,7) = responseTime;

        actualTrialCounter = actualTrialCounter + 1;

    end
    
end

Screen('Flip',window);
WaitSecs(1);

Screen(window,'TextFont','Arial');
Screen(window,'TextSize',20);
DrawFormattedText(window, ['You are now done the experiment. Thank you.'],'center', 'center', mainColour,[],[],[],2);
Screen('Flip',window);

WaitSecs(3);

Screen('CloseAll');

%ListenChar(0);
%ShowCursor();

save(fileName,'studentData');