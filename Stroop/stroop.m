clc;
clear all;
close all;
rng('shuffle');

filename = input('Enter a filename: ','s');

ListenChar(2);
HideCursor();

k1 = 'r';
k2 = 'g';
k3 = 'b';
keyOne = KbName(k1);
keyTwo = KbName(k2);
keyThree = KbName(k3);

background_colour = [0 0 0];
main_colour = [255 255 255];

words = {'red' 'green' 'blue'};
word_colours = [255 0 0; 0 255 0; 0 0 255];

Screen('Preference', 'SkipSyncTests', 1); 
[window, window_size] = Screen('OpenWindow', 0, background_colour, [],32,2);

x_mid = window_size(3)/2;
y_mid = window_size(4)/2;

block_order = [1];
block_order = shuffle(block_order);
number_of_blocks = length(block_order);

trial_order = [1 1 1 1 1 2 2 2 2 2];
trial_order = shuffle(trial_order);
number_of_trials = length(trial_order);

actual_trial_counter = 1;

for block_counter = 1:number_of_blocks

    block_type = block_order(block_counter);

    if block_type == 1
        instructions1a = 'You are going to see a series of coloured words';
        instructions1b = 'Press the letter "r" if the word is in red';
        instructions1c = 'Press the letter "g" if the word is in green';
        instructions1d = 'Press the letter "b" if the word is in blue';    
        instructions1e = 'Remember, you want to press the letter indicating the colour of the word';
        instructions1f = 'but not what the word says';
    end
    Screen(window,'TextFont','Arial');
    Screen(window,'TextSize',20);
    DrawFormattedText(window, instructions1a,'center', y_mid-200, main_colour,[],[],[],2);
    DrawFormattedText(window, instructions1b,'center', y_mid-150, main_colour,[],[],[],2);
    DrawFormattedText(window, instructions1c,'center', y_mid-100, main_colour,[],[],[],2);
    DrawFormattedText(window, instructions1d,'center', y_mid-50, main_colour,[],[],[],2);
    DrawFormattedText(window, instructions1e,'center', y_mid+100, main_colour,[],[],[],2);
    DrawFormattedText(window, instructions1f,'center', y_mid+150, main_colour,[],[],[],2);
    DrawFormattedText(window, 'Press Any Key To Continue','center', y_mid+250, main_colour,[],[],[],2);
    Screen('Flip',window);

    KbPressWait;
    
    Screen(window,'TextFont','Arial');
    Screen(window,'TextSize',20);
    DrawFormattedText(window, ['Get ready!'],'center', 'center', main_colour,[],[],[],2);
    Screen('Flip',window);

    WaitSecs(3);

    for trial_counter = 1:number_of_trials

        if block_type == 1
        end

        trial_type = trial_order(trial_counter);
        
        current_word = randi([1 3],1);
        shown_word = words{current_word};
        
        if trial_type == 1
            drawn_colour = current_word;
            shown_colour = word_colours(drawn_colour,:);
        end
        if trial_type == 2
            while 1
                drawn_colour = randi([1 3],1);
                if drawn_colour ~= current_word
                    shown_colour = word_colours(drawn_colour,:);
                    break
                end
            end
        end
            
        Screen('Flip',window);
        
        random_delay = 0.7 + rand(1)*0.3;
        WaitSecs(random_delay);
        
        KbReleaseWait;
        
        Screen(window,'TextFont','Arial');
        Screen(window,'TextSize',40);
        DrawFormattedText(window, shown_word,'center', 'center', shown_colour,[],[],[],2);
        Screen('Flip',window);

        tic;

        while 1

            [keyIsDown, secs, keyCode] = KbCheck;

            if keyCode(keyOne) == 1
                response_type = 1;
                reaction_time = toc;
                break;
            end
            if keyCode(keyTwo) == 1
                response_type = 2;
                reaction_time = toc;
                break;
            end
            if keyCode(keyThree) == 1
                response_type = 3;
                reaction_time = toc;
                break;
            end

        end
        
        response_correct = 0;

        if drawn_colour == 1 & response_type == 1
            response_correct = 1;
        end
        if drawn_colour == 2 & response_type == 2
            response_correct = 1;
        end
        if drawn_colour == 3 & response_type == 3
            response_correct = 1;
        end
        
        student_data(actual_trial_counter,1) = block_counter;
        student_data(actual_trial_counter,2) = trial_type;
        student_data(actual_trial_counter,3) = trial_counter;
        student_data(actual_trial_counter,4) = drawn_colour;
        student_data(actual_trial_counter,5) = current_word;
        student_data(actual_trial_counter,6) = reaction_time;
        student_data(actual_trial_counter,7) = response_correct;

        actual_trial_counter = actual_trial_counter + 1;

    end
    
end

Screen('Flip',window);
WaitSecs(1);

Screen(window,'TextFont','Arial');
Screen(window,'TextSize',20);
DrawFormattedText(window, ['You are now done the experiment. Thank you.'],'center', 'center', main_colour,[],[],[],2);
Screen('Flip',window);

WaitSecs(3);

Screen('CloseAll');

ListenChar(0);
ShowCursor();

save(filename,'student_data');

clc;

analysis_data = array2table(student_data);
analysis_data.Properties.VariableNames = {'BlockCounter' 'TrialType' 'TrialCounter' 'StimulusSide' 'ResponseType' 'RT' 'Accuracy'};

mean_RT1 = mean(analysis_data.RT(analysis_data.TrialType == 1));
mean_RT2 = mean(analysis_data.RT(analysis_data.TrialType == 2));

mean_ACC1 = mean(analysis_data.Accuracy(analysis_data.TrialType == 1));
mean_ACC2 = mean(analysis_data.Accuracy(analysis_data.TrialType == 2));

subplot(1,2,1);
RTs = [mean_RT1 mean_RT2];
RTs = RTs * 1000;
bar(RTs);
title('Reaction Time');

subplot(1,2,2);
ACCs = [mean_ACC1 mean_ACC2];
ACCs = ACCs * 100;
bar(ACCs);
title('Accuracy');