function varargout = myscope(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myscope_OpeningFcn, ...
                   'gui_OutputFcn',  @myscope_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code 
% -----------------------------------------------------------------------
% Executes just before myscope is made visible.
function myscope_OpeningFcn(hObject, eventdata, handles, varargin)
global comport
global RUN
global NPOINTS
RUN = 0;
NPOINTS = 400;

comport = serial('COM5','BaudRate',115200,'FlowControl','none');
fopen(comport)
% Choose default command line output for myscope
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%-----------------------------------------------------------------------
function myscope_OutputFcn(hObject, eventdata, handles, varargin)
%-----------------------------------------------------------------------

function Quit_Button_Callback(hObject, eventdata, handles)
global comport
global RUN
RUN = 0;
fclose(comport)
clear comport
if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind);
end

% use close to terminate program
% use quit to terminate MATLAB
close
%----------------------------------------------------------------------

function Run_Button_Callback(hObject, eventdata, handles)
global comport
global NPOINTS
global RUN

global goal_temp
global duty_cycle;
global current_temp;
global duty_cycle_conv;
global Ki;
global Kd; 
global Kp; 
goal_temp = 12;

%defining the global variables for communicating with IAR 

T = []; 
Tgoal = goal_temp*ones(NPOINTS);
if RUN == 0
  RUN = 1;

  set(handles.Run_Button,'string','STOP')
  while RUN == 1
    % send a single character prompt to the MCU
    fprintf(comport,'%s','A');
    % fetch data as single 8-bit bytes
    d = fread(comport, NPOINTS, 'uint8'); 
    R = [];  %placeholder list to convert to temperature 
     
    for i = 1:400
        d(i) = 3.3*d(i)/255; 
        R(i) = (((9968*3.3)/d(i))-9968)/1000; 
        d(i) = log(R(i)/(32.33))/(-0.045);
    end 
    T = [T,d'];
    Tgoal_append = goal_temp*ones(NPOINTS);
    Tgoal = [Tgoal;Tgoal_append];
    %T = smoothdata(T);
    hold on
    plot(T,'b');    
    plot(Tgoal);
    title('EZ scope');
    xlabel('Time (s)');
    ylabel('T (C)')
    ylim([0,40]);
    hold off
    drawnow
    Kp = 1;
    Ki = 1; 
    Kd = 1;
    
    %sending characters to IAR to tell it to heat or cool
    current_temp = mean(d); 
    duty_cycle_conv = char(duty_cycle);
    if goal_temp > current_temp
        fprintf(comport, '%s','h');
    elseif goal_temp < current_temp
        fprintf(comport, '%s', 'c');
    end
  end 
else
    
  RUN = 0;
  % change the string on the button to RUN
  set(handles.Run_Button,'string','RUN')
end 

fclose(comport);
clear comport;

%----------------------------------------------------------------------



function goal_temp_Callback(hObject, eventdata, handles)
global goal_temp     
goal_temp = str2double(get(hObject,'String'));
% hObject    handle to goal_temp (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goal_temp as text
%        str2double(get(hObject,'String')) returns contents of goal_temp as a double


% --- Executes during object creation, after setting all properties.
function goal_temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goal_temp (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
