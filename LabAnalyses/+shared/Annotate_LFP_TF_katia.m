%%%% save artifacts + seg (data?)

function [gui,data] = Annotate_LFP_TF_katia()
% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all GUI stuff in one structure and all data stuff in another. 
data = createData();
gui = createInterface( data.Files );

%-------------------------------------------------------------------------%
   function data = createData()
      d = dir('*.mat');
      files = {{d.name}'};
      selection = [];
      
      data = struct( ...
         'Directory',pwd, ...
         'Files', files, ...
         'Selection', selection );
   end % createData

%-------------------------------------------------------------------------%
   function gui = createInterface( files )
      % Create the user interface for the application and return a
      % structure of handles for global use.
      gui = struct();
      % Open a window and add some menus
      gui.Window = figure( ...
         'Name', 'Artifact annotater', ...
         'NumberTitle', 'off', ...
         'MenuBar', 'none', ...
         'Toolbar', 'none', ...
         'HandleVisibility', 'off' );
      
      % Arrange the main interface
      mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );
      
      % + Create the panels
      controlPanel = uix.BoxPanel( ...
         'Parent', mainLayout, ...
         'Title', 'Select a file:' );
      gui.ViewPanel = uix.BoxPanel( ...
         'Parent', mainLayout, ...
         'Title', 'Viewing: ???', ...
         'HelpFcn', @onAnnotate );
      gui.ViewContainer = uicontainer( ...
         'Parent', gui.ViewPanel );
      
      % + Adjust the main layout
      set( mainLayout, 'Widths', [350,-2]  );
      
      % + Create the controls
      controlLayout = uix.VBox( 'Parent', controlPanel, ...
         'Padding', 3, 'Spacing', 3 );
      gui.ListBox = uicontrol( 'Style', 'list', ...
         'BackgroundColor', 'w', ...
         'Parent', controlLayout, ...
         'String', files(:), ...
         'Min',0,...
         'Max',numel(data.Files),...
         'Value', data.Selection, ...
         'Callback', @onListSelection);
      gui.VariableList = uicontrol( 'Style', 'list', ...
         'BackgroundColor', 'w', 'Min', 0, 'Max', 10, 'Value', [], ...
         'Parent', controlLayout);
      gui.AnnotateButton = uicontrol( 'Style', 'PushButton', ...
         'Parent', controlLayout, ...
         'String', 'Annotate selection', ...
         'Callback', @onAnnotate );
      gui.ExportButton = uicontrol( 'Style', 'PushButton', ...
         'Parent', controlLayout, ...
         'String', 'Export to workspace', ...
         'Callback', @onExport );
      gui.SaveButton = uicontrol( 'Style', 'PushButton', ...
         'Parent', controlLayout, ...
         'String', 'Save', ...
         'Callback', @onSave );
      set( controlLayout, 'Heights', [-2 -.75 40 40 40] ); % Make the list fill the space
      
      % + Create the view
      p = gui.ViewContainer;
      %gui.ViewAxes = axes( 'Parent', p );
                  
   end % createInterface

%-------------------------------------------------------------------------%
   function onListSelection( src, ~ )
      % Blank variable listing
      gui.VariableList.String = '';
      gui.ViewPanel.Title = '';
      clearAxes();
      
      oldpointer = get(gui.Window, 'pointer');
      set(gui.Window, 'pointer', 'watch');
      drawnow;
      
      % User selected a demo from the list - update "data" and refresh
      data.Selection = get(gui.ListBox, 'Value' );
      file = data.Files{data.Selection};
      info = whos('-file',file);
      
      for i = 1:length(info)
         str{i} = [info(i).name ' - ' mat2str(info(i).size) ' - ' info(i).class];
      end
      gui.VariableList.String = str;
      set(gui.Window, 'pointer',oldpointer);
   end % onListSelection

%-------------------------------------------------------------------------%
   function onAnnotate( src, ~ )
      oldpointer = get(gui.Window, 'pointer');
      set(gui.Window, 'pointer', 'watch');
      drawnow;
      
      % User selected a demo from the list - update "data" and refresh
      data.Selection = get(gui.ListBox, 'Value' );
      data.data = [];
      data.artifacts = [];
      
      file = data.Files{data.Selection};
      s = load(file);      
      set(gui.Window, 'pointer',oldpointer);
      
      gui.h    = subplot(numel(s.dataTF(1).sampledProcess.labels),2,1:2:2*numel(s.dataTF(1).sampledProcess.labels),'Parent', gui.ViewContainer);
      % handle for tf
      gui.h_tf = arrayfun(@(x) subplot(numel(s.dataTF(1).sampledProcess.labels),2,2*x,'Parent', gui.ViewContainer), 1 : numel(s.dataTF(1).sampledProcess.labels));
      
      %data.data = s.data;
      %data.data = [s.seg_tmp.sampledProcess];
      data.data = [s.dataTF.sampledProcess];
      data.s    = s;
      
      % if isfield(s,'artifacts')
      % if ~isempty(s.seg_tmp(1).eventProcess)
      if ~isempty(s.dataTF(1).eventProcess)
         %data.artifacts = s.artifacts;
         %data.artifacts = [s.seg_tmp.eventProcess];
         data.artifacts = [s.dataTF.eventProcess];
      end
      
      if ~isempty(data.artifacts)
         %data.artifacts = annotate(s.data,gui.ViewAxes,data.artifacts);
         data.artifacts = shared.annotate_katia(data.data,gui.h,gui.h_tf,[s.dataTF.spectralProcess],data.artifacts);
      else
         %data.artifacts = annotate(s.data,gui.ViewAxes);
         data.artifacts = shared.annotate_katia(data.data,gui.h,gui.h_tf,[s.dataTF.spectralProcess]);
      end
      
      % add trig channel
      if isfield(s,'trig')
         data.trig = s.trig;
      end
      
      
      gui.ViewPanel.Title = file;
   end % onAnnotate

%-------------------------------------------------------------------------%
   function onExport( src, ~ )
      assignin('base','data',copy(data.data));
      assignin('base','dataTF',data.s.dataTF);
      assignin('base','artifacts',copy(data.artifacts.fix));
   end

%-------------------------------------------------------------------------%
   function onSave( src, ~ )
      filename = data.Files{data.Selection};
      [filename, pathname] = uiputfile('*.mat',...
         'Save as',filename);
      %savestruct.data = copy(data.data);
      savestruct.dataTF = data.s.dataTF;
      savestruct.artifacts = copy(data.artifacts.fix);
      
      % add trig fields
      if isfield(data,'trig')
          savestruct.trig = copy(data.trig);
      end
      
      save(fullfile(pathname,filename),'-struct','savestruct');
      
      updateFilelist();
   end

   function updateFilelist()
      filename = data.Files{data.Selection};
      d = dir('*.mat');
      data.Files = {d.name}';
      ind = strcmp(data.Files,filename);
      data.Selection = find(ind);    
      
      gui.ListBox.String = data.Files(:);
      gui.ListBox.Value = data.Selection;
   end

%-------------------------------------------------------------------------%
   function clearAxes()
      %cla(gui.ViewAxes);
      if isfield(gui,'h')
          cla(gui.h);
          arrayfun(@(x) cla(x), gui.h_tf);
          
          % Clear contextmenus associated with axes
          %h = ancestor(gui.ViewAxes,'Figure');
          h = ancestor(gui.h,'Figure');
          delete(findobj(h,'Type','uicontextmenu'));
          try
              delete(findobj(h,'Tag','ArraySlider'));
              delete(findobj(h,'Tag','ArraySliderTxt'));
          end
          delete(findobj(h,'Tag','RangeSlider'));
          delete(findobj(h,'Tag','LineScaleSlider'));
      end
   end

%-------------------------------------------------------------------------%
%    function onExit( ~, ~ )
%       % User wants to quit out of the application
%       delete( gui.Window );
%    end % onExit

end % EOF