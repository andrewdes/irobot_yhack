clear all
clc
close all
[serialObject] = RoombaInit(5)
         
% serialObject=Motion_k(a,serialObject)

    FileInfo=dir('C:\Users\andre\PycharmProjects\irobot\RobotWebsite\test.csv');

    TimeStamp2 = FileInfo.date;
       Distance=zeros(50,1);
       MCummulative_Angle_Change=zeros(50,1);
       Md_x=zeros(50,1);
       Md_y=zeros(50,1);
    iteration = 50;
    stateList = zeros(iteration,18);
for i = 1 : iteration 
    
  % Initialize communication

     FileInfo=dir('C:\Users\andre\PycharmProjects\irobot\RobotWebsite\test.csv');
    TimeStamp = FileInfo.date;
  if TimeStamp==TimeStamp2
     pause(0.2)
  else

    
A = csvread('C:\Users\andre\PycharmProjects\irobot\RobotWebsite\test.csv');
forward=A(1);
rotation=A(2);
% Read encoders (provides baseline)
[StartLeftCounts, StartRightCounts] = EncoderSensorsRoomba(serialObject);

%sets forward velocity [m/s] and turning radius [m]
SetFwdVelRadiusRoomba(serialObject, forward, rotation);
pause(1)
SetFwdVelRadiusRoomba(serialObject, 0, 0);
encoderCountList = zeros(80, 18);


  [encL, encR] = EncoderSensorsRoomba(serialObject);
  angle = AngleSensorRoomba(serialObject);
  cliff = CliffSignalStrengthRoomba(serialObject);
  cliff1 = cliff(1);
  cliff2 = cliff(2);
  cliff3 = cliff(3);
  cliff4 = cliff(4);
  [bumpR, bumpL, bumpFront, dropL, dropR] = BumpsWheelDropsSensorsRoomba(serialObject);
  ir = RangeSignalStrengthRoomba(serialObject);
  ir1 = ir(1);
  ir2 = ir(2);
  ir3 = ir(3);
  ir4 = ir(4);
  ir5 = ir(5);
  ir6 = ir(6);

  disp([encL, encR, angle, cliff1, cliff2, cliff3, cliff4, bumpR, bumpL, bumpFront, dropL, dropR, ir1, ir2, ir3, ir4, ir5, ir6])
  stateList(i, : ) = [encL, encR, angle, cliff1, cliff2, cliff3, cliff4, bumpR, bumpL, bumpFront, dropL, dropR, ir1, ir2, ir3, ir4, ir5, ir6];    
    
  FileInfo = dir('C:\Users\andre\PycharmProjects\irobot\RobotWebsite\test.csv');
    TimeStamp2 = FileInfo.date;
     %-----------Kevin-------------------------- 
%%begin running rover
%%rover data input into MATLAB


    %%Real Time Distance Calculations
    if i == 1
        Distance(i) = 0;
        
    elseif i > 1
    
        left_wheel = stateList(i,1) - stateList(i-1,1);
        right_wheel = stateList(i,2) - stateList(i-1,2);
    
        distance = (0.036*2*3.1415926*(left_wheel+right_wheel)/(2*508.8));
   
        Distance(i) = distance;

        end 
    
    %% Real time angle calculations
        step_angle_change = stateList(i,3) * 0.324956;
        MStep_Angle_Change(i) = step_angle_change;
        if i == 1
            MCummulative_Angle_Change(i) = MStep_Angle_Change(i);  
        elseif i >1 
            MCummulative_Angle_Change(i) = MCummulative_Angle_Change(i-1) + MStep_Angle_Change(i); 
        end 
    
    %% Real time velocity of each wheel

    if i == 1
        MLeft_Wheel_Velocity(i) = 0;
        MRight_Wheel_Velocity(i) = 0;
   
    elseif i > 1
        left_wheel = stateList(i,1) - stateList(i-1,1);
        right_wheel = stateList(i,2) - stateList(i-1,2);
    
        left_wheel_distance = (0.036*2*3.1415926*(left_wheel)/(508.8));
        right_wheel_distance = (0.036*2*3.1415926*(right_wheel)/(508.8));
    
        left_wheel_velocity_check = left_wheel_distance / 0.5;
        right_wheel_velocity_check = right_wheel_distance / 0.5;

        if left_wheel_velocity_check > 1
            left_wheel_velocity = 0.35;
        else 
            left_wheel_velocity = left_wheel_velocity_check;
        end 
        
        if right_wheel_velocity_check > 1
           right_wheel_velocity = 0.35;
           right_wheel_velocity = right_wheel_velocity_check;
        end
        
        MLeft_Wheel_Velocity(i) = left_wheel_velocity;
        else 
        MRight_Wheel_Velocity(i) = right_wheel_velocity;

    end
    
    %%Real time encoder counter
    if i == 1
        left_count = 0;
        right_count = 0;
        
       
    elseif i>1 
        left_count = stateList(i,1) - stateList(i-1,1);
        right_count = stateList(i,2) - stateList(i-1,2);
    
    
    MLeft_count(i) = left_count;
    MRight_count(i) = right_count;
    
    Index(i) = i;
    end 
    
    %% Movement Tracking calculations
    if i == 1
        
        Md_x(1) = 0;
        Md_y(1) = 0;
        
    elseif  i >0
        cos_angle_theta = cos((MCummulative_Angle_Change(i) + MCummulative_Angle_Change(i-1))/2);
        sin_angle_theta = sin((MCummulative_Angle_Change(i) + MCummulative_Angle_Change(i-1))/2);
        
        d_x = Distance(i) * cos_angle_theta;
        d_y = Distance(i) * sin_angle_theta;
    
        Md_x(i) = Md_x(i-1) + d_x;
        Md_y(i) = Md_y(i-1) + d_y;
    end 
    
    %% Cliff Sensor calculations    
    Cliff_Sensor1(i) = stateList(i,4);
    Cliff_Sensor2(i) = stateList(i,5);
    Cliff_Sensor3(i) = stateList(i,6);
    Cliff_Sensor4(i) = stateList(i,7);

    if Cliff_Sensor1(i) <2000 | Cliff_Sensor2(i) <2000 | Cliff_Sensor3(i) <2000 | Cliff_Sensor4(i) <2000
        Cliff(i) = 1
    else 
        Cliff(i) = 0
    end 
    %% Bump and Drop Sensor calculations
    Bump_Sensor1(i) = stateList(i,8);
    Bump_Sensor2(i) = stateList(i,9);
    Bump_Sensor3(i) = stateList(i,10);
    Drop_Sensor1(i) = stateList(i,11);
    Drop_Sensor2(i) = stateList(i,12);

    if Bump_Sensor1(i) ==1 | Bump_Sensor2(i) ==1 | Bump_Sensor3(i) ==1 | Drop_Sensor1(i) == 1 | Drop_Sensor2(i) == 1
        Bump_Drop(i) = 1
    else 
        Bump_Drop(i) = 0
    end 
    
    %% Wall Sensor calculations
    Wall_Sensor1(i) = stateList(i,13);
    Wall_Sensor2(i) = stateList(i,14);
    Wall_Sensor3(i) = stateList(i,15);
    Wall_Sensor4(i) = stateList(i,16);
    Wall_Sensor5(i) = stateList(i,17);
    Wall_Sensor6(i) = stateList(i,18);

    if Wall_Sensor1(i) > 50 | Wall_Sensor2(i) > 50 |  Wall_Sensor3(i) > 50 | Wall_Sensor4(i) > 50 |  Wall_Sensor5(i) > 50 |  Wall_Sensor6(i) > 50
        Wall(i) = 1
    else 
        Wall(i) = 0
    end 

   %----------kevin end--------------------------- 
    
    
    
%   FileInfo = dir(lf);
%     TimeStamp2 = FileInfo.date;
%         a = textread(lf)
% 
%                
  pause(0.25)

 end
 
end

for j=1 : 50
    dummy_valueL = 0;
    dummy_valueR = 0;
    for k = 1 : iteration
        if stateList(k,1) == 0
            stateList(k,1) = dummy_valueL;
        elseif stateList(k,1) ~= 0
            dummy_valueL =stateList(k,1);
        end
        if stateList(k,2) == 0
            stateList(k,2) = dummy_valueR;
        elseif stateList(k,2) ~= 0
            dummy_valueR = stateList(k,2);            
        end
    end 
    %%Real Time Distance Calculations
    if j == 1
        Distance(j) = 0;
    elseif j>1
        left_wheel_test = abs(stateList(j,1) - stateList(j-1,1));
        right_wheel_test = abs(stateList(j,2) - stateList(j-1,2));
        if left_wheel_test < 500
            left_wheel = left_wheel_test;
        end
        if right_wheel_test < 500
            right_wheel = right_wheel_test;
    
        distance = (0.036*2*3.1415926*(left_wheel+right_wheel)/(2*508.8));
    
        Distance(j) = distance;
   
    end 
    
    %% Real time angle calculations
        step_angle_change = stateList(j,3) * 0.324956;
    MStep_Angle_Change(j) = step_angle_change;
    if j == 1;
        MCummulative_Angle_Change(j) = 0;  
    else 
        MCummulative_Angle_Change(j) = MCummulative_Angle_Change(j-1) + MStep_Angle_Change(j); 
    end 
    
    %% Real time velocity of each wheel
    if j == 1
        MLeft_Wheel_Velocity(j) = 0;
        MRight_Wheel_Velocity(j) = 0;
   
    elseif j > 1
        left_wheel = abs(stateList(j,1) - stateList(j-1,1));
        right_wheel = abs(stateList(j,2) - stateList(j-1,2));
    
        left_wheel_distance = (0.036*2*3.1415926*(left_wheel)/(508.8));
        right_wheel_distance = (0.036*2*3.1415926*(right_wheel)/(508.8));
    
        left_wheel_velocity = left_wheel_distance / 0.5;
        right_wheel_velocity = right_wheel_distance / 0.5;
    
        MLeft_Wheel_Velocity(j) = left_wheel_velocity;
        MRight_Wheel_Velocity(j) = right_wheel_velocity;

    end 
    
    %%Real time encoder counter
    if j == 1
        left_count = 0;
        right_count = 0;
        
       
    elseif j>1 
        left_count = abs(stateList(j,1) - stateList(j-1,1));
        right_count = abs(stateList(j,2) - stateList(j-1,2));
    
    
    MLeft_count(j) = left_count;
    MRight_count(j) = right_count;
    
    Index(j) = j;
    end 
    
    %% Movement Tracking calculations
    if j == 1
        Md_x(1) = 0;
        Md_y(1) = 0;
        
        
    elseif j > 1 
        cos_angle_theta = cos((MCummulative_Angle_Change(j) + MCummulative_Angle_Change(j-1))/2);
        sin_angle_theta = sin((MCummulative_Angle_Change(j) + MCummulative_Angle_Change(j-1))/2);
        
        d_x = Distance(j) * cos_angle_theta;
        d_y = Distance(j) * sin_angle_theta;
    
        Md_x(j) = Md_x(j-1) + d_x;
        Md_y(j) = Md_y(j-1) + d_y;
    end 
    
    Cliff_Sensor1(j) = stateList(j,4);
    Cliff_Sensor2(j) = stateList(j,5);
    Cliff_Sensor3(j) = stateList(j,6);
    Cliff_Sensor4(j) = stateList(j,7);

    if Cliff_Sensor1(j) <2000 | Cliff_Sensor2(j) <2000 | Cliff_Sensor3(j) <2000 | Cliff_Sensor4(j) <2000
        Cliff(j) = 1
    else 
        Cliff(j) = 0
    end 
    
    Bump_Sensor1(j) = stateList(j,8);
    Bump_Sensor2(j) = stateList(j,9);
    Bump_Sensor3(j) = stateList(j,10);
    Drop_Sensor1(j) = stateList(j,11);
    Drop_Sensor2(j) = stateList(j,12);

    if Bump_Sensor1(j) ==1 | Bump_Sensor2(j) ==1 | Bump_Sensor3(j) ==1 | Drop_Sensor1(j) == 1 | Drop_Sensor2(j) == 1
        Bump_Drop(j) = 1
    else 
        Bump_Drop(j) = 0
    end 
    
    Wall_Sensor1(j) = stateList(j,13);
    Wall_Sensor2(j) = stateList(j,14);
    Wall_Sensor3(j) = stateList(j,15);
    Wall_Sensor4(j) = stateList(j,16);
    Wall_Sensor5(j) = stateList(j,17);
    Wall_Sensor6(j) = stateList(j,18);

    if Wall_Sensor1(j) > 50 | Wall_Sensor2(j) > 50 |  Wall_Sensor3(j) > 50 | Wall_Sensor4(j) > 50 |  Wall_Sensor5(j) > 50 |  Wall_Sensor6(j) > 50
        Wall(j) = 1
    else 
        Wall(j) = 0
    end 
    
    
end 
end 

figure
plot(Index,Distance);
title('Distance moved by rover every 0.5s');

figure
plot(Index, MStep_Angle_Change);
title('Angle change per 0.5 seconds');

figure
plot(Index,MCummulative_Angle_Change);
title('Cummulative angle change');

figure
plot(Index, MLeft_Wheel_Velocity);
title('Left wheel velocity');

figure
plot(Index, MRight_Wheel_Velocity);
title('right wheel velocity');

figure
plot(Index, MRight_count);
title('Right wheel encoder count');

figure
plot(Index,MLeft_count);
title('left wheel encoder count');

figure
plot(Md_x, Md_y); 
title('Real_Time_Movement_Tracking');

figure
plot (Index,Cliff);
title('cliff sensor, if at 1 then at cliff');

figure
plot (Index,Bump_Drop);
title('Bump and Drop sensor, if at 1 then it is bumped or the wheels have falled down');

figure
plot (Index,Wall);
title('Wall sensor, if at 1 then it has detected a wall in front');

save('roomba_integrate.mat', 'stateList');

% stop the robot (turning radius doesn’t matter, inf is straight )
SetFwdVelRadiusRoomba(serialObject, 0, inf);

[FinishLeftCounts, FinishRightCounts] = EncoderSensorsRoomba(serialObject)
Distance = (0.036*2*pi)*((FinishLeftCounts - StartLeftCounts) + ...
                         (FinishRightCounts - StartRightCounts) )/( 2 *508.8);

% Power down when finished,
% note physical power button is disabled

PowerOffRoomba(serialObject)
fclose(serialObject)