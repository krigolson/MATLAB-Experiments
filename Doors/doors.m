% Two-armed bandit task for Cognitive Assessment
%
% Author: C. Hassall, A. Norton, modifierd by O. Krigolson
% Version: 5.0
% Date: October 2020


clear all;
close all;
clc;

% clear all variables in memory
clear all;
% close all open matlab files and windows
close all;
% clear the console
clc;
% seed the random number generator
rng('shuffle');

% Practice block parameters
num_practice_blocks = 2;
num_practice_trials = 10;

p_data = [];
win_eeg = [];
lose_eeg = [];


ExitKey = KbName('ESCAPE');
fKey = KbName('f');
jKey = KbName('j');

numberOfBlocks = str2double(configMap('dm_number_blocks'));
trialsPerBlocks = str2double(configMap('dm_trials_per_block'));

length_of_baseline = str2double(configMap('length_of_baseline'));
length_of_erp = str2double(configMap('length_of_erp'));

% * * * Graphical Properties * * *
normal_font_size = 20;
normal_font = 'Arial';

% Physical display properties
viewingDistance = 850; % mm, approximately
screenWidth = 598; % mm
screenHeight = 338; % mm
horizontalResolution = 1920; % Pixels
verticalResolution = 1080; % Pixels
horizontalPixelsPerMM = horizontalResolution/screenWidth;
verticalPixelsPerMM = verticalResolution/screenHeight;

% Screen/stim properties
squareDegrees = 2;
squareMMs = 2 * viewingDistance *tand(squareDegrees/2);
squareHorizontalPixels = horizontalPixelsPerMM * squareMMs;
squareVerticalPixels = verticalPixelsPerMM * squareMMs;
square_thickness = 30;
square_locations = [-squareHorizontalPixels*1.5 squareHorizontalPixels*1.5]; % Relative to center of the window

% Fixation
fixation_colour = [0 0 0];
go_colour = [180 180 180];
fixation_size = 60;

% Text
text_size = 40;
text_colour = [255 255 255];

xmid = rec(3)/2; ymid = rec(4)/2; % Based on the window that was opened
squares = [xmid-squareHorizontalPixels/2+square_locations(1) ymid-squareVerticalPixels/2 xmid+squareHorizontalPixels/2+square_locations(1) ymid+squareVerticalPixels/2;
    xmid-squareHorizontalPixels/2+square_locations(2) ymid-squareVerticalPixels/2 xmid+squareHorizontalPixels/2+square_locations(2) ymid+squareVerticalPixels/2;];

% Task parameters
num_blocks = str2double(configMap('dm_number_blocks')); % 12 blocks total
num_trials = str2double(configMap('dm_trials_per_block')); % 10 trials per block
p_win_1 = str2double(configMap('dm_square1_win_probability')); % P(win) when square 1 is chosen
p_win_2 = str2double(configMap('dm_square2_win_probability')); % P(win) when square 2 is chosen

% Task Variables
total_reward = 0;
best_score = 0;
num_wins = 0;
num_losses = 0;

% Instructions (what the participant sees first)
%instructions = 'In this game you see a series of coloured squares.\nOne of these coloured squares is the target - you are more likely to win and\nearn points if you select the target than if you select the other coloured square.\nYour goal is to figure out which coloured square is the target and select it as many times as possible.\n\nOn each trial of the game you will see a cross in the middle of the screen.\nTry to keep your eyes on the cross in the middle of the screen at all times.\nWhen the cross changes colour, pick the square that you think is the target by pressing either the f key for the left square, or the j key for the right square.\nThroughout the game the squares will change colour. When this happens it means that there is a new target.\nRemember, your goal is to figure out which of the coloured squares is the target and to win as many times as possible.\n\nPress spacebar to proceed.';
if usingMuse
    left_button = 'f key';
    right_button = 'j key';
else
    left_button = 'green button';
    right_button = 'red button';
end
%instructions = sprintf('In this game, you will see pairs of coloured squares. For each block of trials, one of the colours\nhas a better chance of producing a "win" than the other; specifically, one colour will produce a win %s\nof the time, and the other colour will produce a win only %s of the time.\nYour goal is to figure out, in each block, which colour wins more and select it as many times as possible.\nEach block there will be new colours for the two squares, and you will need to figure out which colour\nis better. The same colours may show up in multiple blocks, but each time\nthe percentage chance of winning is reset.\n\nOn each trial of the game you will see a cross in the middle of the screen.\nTry to keep your eyes on the cross in the middle of the screen at all times.\nWhen the cross changes colour, pick the square that you think is the target by pressing either\nthe %s for the left square, or the %s for the right square.\nRemember, your goal is to figure out which of the coloured squares is the target\nand to win as many times as possible.\n\nPress spacebar to proceed.',configMap('dm_square1_win_probability'),configMap('dm_square2_win_probability'),left_button,right_button);
instructions = sprintf('On each trial you are going to see two coloured squares. Try to keep your eyes on the cross in the middle of the display at all times.\nWhen the cross changes colour to grey, choose a square by pressing either the\n f key for the left square or the j key for the right square.\nEach choice results in either a "WIN" or a "LOSS". One of the colours is better than the other\n- choosing it is more likely to produce a "WIN". Sometimes the colours of the squares will change and\nthe better square will have a new colour.\nYour goal: win as often as possible.\n\nThe experimenter will make sure you understand these instructions.\nPress the spacebar to continue.', left_button, right_button);
questions = 'Any questions?\n\nPress spacebar to begin.';

Screen(win,'TextFont',normal_font);
Screen(win,'TextSize',normal_font_size);
DrawFormattedText(win, instructions,'center', 'center', text_colour,[],[],[],2);
Screen('Flip',win);

% Wait until keys are released
[keyIsDown, ~, ~, ~] = KbCheck;
while keyIsDown
    [keyIsDown, ~, ~, ~] = KbCheck;
end
WaitSecs(0.2);

% Wait for space bar press
done_looking = 0;
while ~done_looking
    [~, ~, keyCode, ~] = KbCheck;
    if strcmp(KbName(keyCode),'space')
        done_looking = 1;
    end
end

offset = 10;

% Tell participant we are starting the experiment
Screen(win,'TextFont',normal_font);
Screen(win,'TextSize',normal_font_size);
DrawFormattedText(win, instructions_2,'center', 'center', text_colour,[],[],[],2);
Screen('Flip',win);

% Wait until keys are released
[keyIsDown, ~, ~, ~] = KbCheck;
while keyIsDown
    [keyIsDown, ~, ~, ~] = KbCheck;
end
WaitSecs(0.2);

% Wait for space bar press
done_looking = 0;
while ~done_looking
    [~, ~, keyCode, ~] = KbCheck;
    if strcmp(KbName(keyCode),'space')
        done_looking = 1;
    end
end

for currentBlock = 1:numberBlocks
    
    % Pick two colours at random
    colours(1,:) = round(255 .* rand(1,3)); % Pick a random colour
    colours(2,:) = 255 - colours(1,:); % Use the complement
    
    % Remind the participant that this is a new block with new squares
    if currentBlock ~= 1
        Screen(win,'TextFont',normal_font);
        Screen(win,'TextSize',normal_font_size);
        DrawFormattedText(win, 'New Squares, New Target','center', 'center', text_colour,[],[],[],2);
        Screen('Flip',win);
        WaitSecs(1);
    end
    
    % How often participant chooses the correct square in this block
    performance = 0;
    
    % Trial loop
    for currentTrial = 1:numberTrials

        % Draw crosshairs for 500 ms
        Screen('DrawTexture', win, backgroundImg);
        Screen('TextSize',win,fixation_size);
        DrawFormattedText(win, '+','center', 'center', fixation_colour,[],[],[],2);
        WaitSecs(0.5);
        
        % Randomize the order of square presentation
        if rand < 0.5
            order = [1 2];
        else
            order = [2 1];
        end
        
        % Draw the squares for 500 ms
        Screen('DrawTexture', win, backgroundImg);
        Screen('TextSize',win,fixation_size);
        DrawFormattedText(win, '+','center', 'center', fixation_colour,[],[],[],2);
        Screen('FillRect', win , colours(order(1),:), squares(1,:), square_thickness); % Left
        Screen('FillRect', win , colours(order(2),:), squares(2,:), square_thickness); % Right
        responded_early = 0;
        tic;
        while toc < 0.5
            [keyIsDown, ~, ~, ~] = KbCheck;
            if keyIsDown
                responded_early = 1;
            end
        end
        
        % Change the colour of the fixation cross ("go cue")
        Screen('DrawTexture', win, backgroundImg);
        Screen('TextSize',win,fixation_size);
        DrawFormattedText(win, '+','center', 'center', go_colour,[],[],[],2);
        Screen('FillRect', win , colours(order(1),:), squares(1,:), square_thickness); % Left
        Screen('FillRect', win , colours(order(2),:), squares(2,:), square_thickness); % Right
        
        start_time = GetSecs();
        elapsed_time = 0;
        invalid_response = 1;
        chosen_side = 0;
        
        if ~responded_early
            while 1
                [~, ~, keyCode, ~] = KbCheck;
                
                if keyCode(fKey)
                    chosen_side = 1;
                    invalid_response = 0;
                    elapsed_time = GetSecs() - start_time;
                    break
                elseif keyCode(jKey)
                    chosen_side = 2;
                    invalid_response = 0;
                    elapsed_time = GetSecs() - start_time;
                    break
                elseif keyCode(ExitKey)
                    error('Session ended!')
                    sca;
                end
                if toc > 2
                    break
                end
            end
        end
        
        % Determine outcome
        chosen_square = -1; % invalid
        this_trial_a_winner = -1;
        if ~invalid_response
            chosen_square = order(chosen_side); % [ 1 2 ]
            if chosen_square == 1
                this_trial_a_winner = rand < p_win_1;
                performance = performance + 1;
            elseif chosen_square == 2
                this_trial_a_winner = rand < p_win_2;
            end
        end
        
        % Back to fixation
        Screen('DrawTexture', win, backgroundImg);
        Screen('TextSize',win,fixation_size);
        DrawFormattedText(win, '+','center', 'center', go_colour,[],[],[],2);
        jitter_amount = (rand() - 0.5) / 5;
        WaitSecs(0.3 + jitter_amount);
        
        % Record 200 ms of baseline or wait 200 ms if no Muse
        WaitSecs(length_of_baseline);

        % Display the reward for 1 second
        Screen('DrawTexture', win, backgroundImg);
        Screen('TextSize',win,text_size);
        if responded_early
            DrawFormattedText(win, 'TOO FAST','center', 'center', text_colour,[],[],[],2);
        elseif invalid_response
            DrawFormattedText(win, 'INVALID','center', 'center', text_colour,[],[],[],2);
        elseif this_trial_a_winner
            num_wins = num_wins + 1;
            total_reward = total_reward + 1;
            DrawFormattedText(win, 'WIN','center', 'center', text_colour,[],[],[],2);
        else
            num_losses = num_losses + 1;
            DrawFormattedText(win, 'LOSE','center', 'center', text_colour,[],[],[],2);
        end
        
        WaitSecs(length_of_erp);
        
        WaitSecs(0.2); % Feedback is up for 1000 ms total

        this_data_line = [currentTrial colours(1,:) colours(2,:) order chosen_side chosen_square responded_early invalid_response elapsed_time*1000 this_trial_a_winner performance];
        dlmwrite([participantNumber '_decision_behavioural'],this_data_line,'delimiter', '\t', '-append');
        %p_data = [p_data; this_data_line]; % Not necessary, just an extra copy of the data
        
        [~, ~, keyCode] = KbCheck();
        if keyCode(ExitKey)
            break;
        end
        
    end
    
    % Keep track of best block
    if performance > best_score
        best_score = performance;
    end
    
    % Display block summary
    block_message = ['You picked the correct square ' num2str(performance) ' out of ' num2str(num_trials) ' times!\nBlock Score: ' num2str(performance) '\nBest Score: ' num2str(best_score)];
    Screen(win,'TextFont',normal_font);
    Screen(win,'TextSize',normal_font_size);
    DrawFormattedText(win, block_message, 'center', 'center', text_colour,[],[],[],2);
    Screen('Flip',win);
    [~, ~, keyCode] = KbCheck();
    if keyCode(ExitKey)
        break;
    end
    WaitSecs(2);
end