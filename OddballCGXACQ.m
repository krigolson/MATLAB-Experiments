
clear all;
close all;
clc;

num_of_blocks = 8; % Determine number of blocks (4) now 2
num_of_trials = 50; %Determine how many trials per block (50)

% 201: Fixation prior to oddball stimulus
% 202: Fixation prior to Control stimulus
% 211: Oddball stimulus
% 212: Control stimulus

%% open cgx stream
s1 = serial('COM6','BaudRate',57600);  %replace COM3 with the actual port number your adapter is assigned to
fopen(s1);

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'ConserveVRAM', 64);
[win, rec] = Screen('OpenWindow', 0  , [166 166 166],[10 10 100 100], 32, 2);

%Setup Parameters
Screen(win,'TextSize', 24);
%ListenChar(2); %Stop typing in Matlab
%HideCursor();   % hide the cursor
xmid = rec(3)/2;
ymid = rec(4)/2;
ExitKey = KbName('Q');
beh_data = [];

DrawFormattedText(win, 'Oddball Task','center', 'center', [255 255 255],[],[],[],2);
Screen('Flip', win);
WaitSecs(5);

%Instructions
instructions1 = ['On each trial, you''re going to see a blue or green circle in the middle of the display\nTry to keep your eyes on the middle of the display at all times\nPress G each time you see a green circle\nYou will complete ' num2str(num_of_blocks) ' blocks of ' num2str(num_of_trials) ' trials\n'];
instructions2 = ['Press F to proceed'];
DrawFormattedText(win, instructions1,'center',ymid-50, [255 255 255],[],[],[],2);
DrawFormattedText(win, instructions2,'center',ymid+250, [255 255 255],[],[],[],2);
Screen('Flip',win);

Wait_for_Response = 1;
while Wait_for_Response
    [keypressed, ~, keyCode] = KbCheck();
    if keypressed
        if keyCode(KbName('F'))
            Wait_for_Response = 0;
        end
    end
end
WaitSecs(.25);

for block = 1:num_of_blocks
    %Block message
    DrawFormattedText(win,['Block ' num2str(block)],'center','center',[255 255 255]);
    Screen('Flip',win);
    WaitSecs(2);
    
    for trial = 1:num_of_trials
        
        %Determine whether oddball or control
        if rand < .25
            colour = [0 255 0];
            marker = 201;
        else
            colour = [0 0 255];
            marker = 202;
        end
        
        %Draw fixation for 300 - 500ms
        DrawFormattedText(win,'+','center','center',[255 255 255]);
        Screen('Flip',win);
        fwrite(s1, [marker], 'uint8');
        
        fixation_interval = rand()*.2 + .3;
        WaitSecs(fixation_interval);
        
        %Draw circle for 800ms
        Screen('FillOval', win , colour, [xmid-30 ymid-30 xmid+30 ymid+30], 8);
        Screen('Flip',win);
        fwrite(s1, [marker+10], 'uint8');
        
        startTime = GetSecs;
        currentTime = GetSecs-startTime;
        notPressed = 0;
        while currentTime < 0.8
            [keypressed, ~, keyCode] = KbCheck();
            if keypressed
                if keyCode(KbName('G')) && notPressed == 0
                    fwrite(s1, [203], 'uint8');
                    notPressed = 1;
                else
                    fwrite(s1, [0], 'uint8');
                end
            end
            currentTime = GetSecs-startTime;
        end
        
        %Crash out of experiment (trials)
        [~, ~, keyCode] = KbCheck();
        if keyCode(ExitKey)
            break;
        end
    end
    
    %Crash out of experiment (blocks)
    [~, ~, keyCode] = KbCheck();
    if keyCode(ExitKey)
        break;
    end
end
fclose(s1); % close the serial port cleanly
sca;
ListenChar(0); %Stop typing in Matlab
ShowCursor();   % hide the cursor