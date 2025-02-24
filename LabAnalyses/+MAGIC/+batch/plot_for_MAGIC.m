% MAGIC VERSION OF BRIAN'S LABTOOLS PLOT FUNCTION
% 
% 2022.05.03: Modification of 'refreshPlot_MAGIC' function
%
% 
% PLOT - Plot EventProcess
%
%     plot(EventProcess)
%     EventProcess.plot
%
%     Right clicking (ctrl-clicking) on events displays options for moving or
%     deleting events. Right clicking outside of events allows adding events.
%
%     For an array of EventProcesses, a horizontal scrollbar at the bottom
%     left allows browsing through the array elements.
%
%     All inputs are passed in using name/value pairs. The name is a string
%     followed by the value (described below).
%     The order of the pairs does not matter, nor does the case.

% Modifications done by Angèle Van Hamme for multiple subplot for move event(January 2017)
% Actualise_othersubplots function created in moveEvent function

%
% INPUTS
%     handle  - axis handle, optional, default generates a new axis
%     top     - scalar, optional, default = []
%               Sets the upper limit of patches, if empty, Ylim of axes used
%     bottom  - scalar, optional, default = []
%               Sets the lower limit of patches, if empty, Ylim of axes used
%     overlap - scalar, optional, default = 1
%               Value [-1 1] that determines fraction of the axes patches 
%               will cover. 1 covers from top to bottom. Negative numbers
%               extend the Ylim above top.
%     stagger - logical, optional, default = false
%               If true, events are offset vertically so they do not cover
%               each other
%     alpha   - scalar, optional, default = 0.2
%               Value [0 1] the determines alpha transparency of patches
%
% OUTPUTS
%     h      - Axis handle
%
% EXAMPLES
%     % Create labels for the events (necessary if you want to edit color)
% %     fix = metadata.Label('name','fix');
% %     cue = metadata.Label('name','cue');
% %     button = metadata.Label('name','button');
%     % Create EventProcess array
%     for i = 1:50
%        t = rand;
%        e(1) = metadata.event.Stimulus('tStart',t,'tEnd',t+1,'name',fix);
%        t = 2 + rand;
%        e(2) = metadata.event.Stimulus('tStart',t,'tEnd',t,'name',cue);
%        t = 4 + rand;
%        e(3) = metadata.event.Response('tStart',t,'tEnd',t+.2,'name',button,'experiment',metadata.Experiment);
%        events(i) = EventProcess('events',e);
%     end
%     plot(events)

%     $ Copyright (C) 2016 Brian Lau <brian.lau@upmc.fr> $
%     Released under the BSD license. The license and most recent version
%     of the code can be found on GitHub:
%     https://github.com/brian-lau/Process

% TODO
% o multiple windows
function varargout = plot_for_MAGIC(self,varargin)

%% MAGIC VERSION OF BRIAN'S LABTOOLS PLOT FUNCTION

   p = inputParser;
   p.KeepUnmatched = true;
   p.FunctionName = 'EventProcess plot_for_MAGIC method';
   p.addParameter('handle',[],@(x) isnumeric(x) || ishandle(x));
   p.addParameter('top',[],@isnumeric);
   p.addParameter('bottom',[],@isnumeric);
   p.addParameter('alpha',0.2,@isnumeric);
   p.addParameter('stagger',false,@(x) isnumeric(x) || islogical(x) );
   p.addParameter('all',false,@(x) isnumeric(x) || islogical(x) );
   p.addParameter('overlap',1,@(x) isnumeric(x) || islogical(x) );
   p.addParameter('patchcallback','');
   p.parse(varargin{:});
   par = p.Results;
   
   all_wanted = par.all ;  

   if isempty(par.handle) || ~ishandle(par.handle)
      figure;
      h = subplot(1,1,1);
   else
      h = par.handle;
   end
   hold(h,'on');
   set(h,'tickdir','out','ticklength',[0.005 0.025],'Visible','off');

   % Unique ID to tag objects from this call
   gui.id = char(java.util.UUID.randomUUID.toString);

   gui.alpha = par.alpha;   
   gui.bottom = par.bottom;
   gui.top = par.top;
   gui.overlap = par.overlap;
   gui.stagger = par.stagger;
   gui.patchcallback = par.patchcallback;
   
   if numel(self) > 1
      ah = findobj(h.Parent,'Tag','ArraySlider');
      if isempty(ah)
         gui.arraySlider = uicontrol('Style','slider','Min',1,'Max',numel(self),...
            'SliderStep',[1 5]./numel(self),'Value',1,...
            'Units','norm','Position',[0.01 0.005 .2 .04],...
            'Parent',h.Parent,'Tag','ArraySlider');
         gui.arraySliderTxt = uicontrol('Style','text','String','Element 1/',...
            'HorizontalAlignment','left','Units','norm','Position',[.22 .005 .2 .04]);
         % Use cellfun in the callback to allow adding multiple callbacks later
         set(gui.arraySlider,'Callback',...
            {@(h,e,x) cellfun(@(x)feval(x{:}),x) {{@refreshPlot_MAGIC self h gui.id all_wanted}} } );
      else
         % Adding event plot to existing axis that has slider controls
         % Attach callbacks to existing list, to be evaluated in sequence
         gui.arraySlider = ah;
         f = {@refreshPlot_MAGIC self h gui.id all_wanted};
         ah.Callback{2}{end+1} = f;
      end
   end

   % This slider will be present if handle comes from SampledProcess.plot,
   % in which case, we link a callback to refresh events 
   sh = findobj(h.Parent,'Tag','LineScaleSlider');
   if ~isempty(sh)
      f = {@refreshPlot_MAGIC self h gui.id all_wanted};
      sh.UserData.StateChangedCallback{2}{end+1} = f;
   end
   
   % Stash plot-specific parameters
   if isempty(h.UserData)
      h.UserData = {gui};
   else
      h.UserData = [h.UserData {gui}];
   end
   
   hf = ancestor(h,'Figure');

   % Create top-level menu for Events
   menu = uicontextmenu('Tag',gui.id,'Parent',hf);
   topmenu = uimenu('Parent',menu,'Label','Add event');
   validEventTypes = {'Artifact' 'Stimulus' 'Response' 'Generic'};
   for i = 1:numel(validEventTypes)
      uimenu('Parent',topmenu,'Label',validEventTypes{i},...
         'Callback',{@addEvent_MAGIC self h gui.id validEventTypes{i} all_wanted});
   end
   set(h,'uicontextmenu',menu);
   
   % First draw
   [StartTurnValue, StartWalkValue] = refreshPlot_MAGIC(self,h,gui.id,all_wanted);
   h.Visible = 'on';

   if nargout == 1
      varargout{1} = h;
   end
   if nargout >= 2
      varargout{1} = h;
      varargout{2} = StartTurnValue;
      varargout{3} = StartWalkValue;
   end
end

function [StartTurnValue, StartWalkValue] = refreshPlot_MAGIC(obj,h,id,all_wanted)
   % Extract specific parameters for this ID
   StartTurnValue = 12 ; 
   StartWalkValue =  5 ; 
   flag_exist_T0 = false;
   
   gui = linq(h.UserData).where(@(x) strcmp(x.id,id)).select(@(x) x).toArray;

   if numel(obj) > 1
      ind1 = max(1,round(gui.arraySlider.Value));
   else
      ind1 = 1;
   end
   
   if ind1 > numel(obj)
      delete(findobj(h,'Tag',id));
      return;
   end
   
   if obj(ind1).count == 0
      delete(findobj(h,'Tag',id,'-and','Type','Patch'));
      delete(findobj(h,'Tag',id,'-and','Type','Text'));
      return;
   end
   values = obj(ind1).values{1};
   n = numel(values);
   
   if isempty(gui.bottom)
      bottom = h.YLim(1);
   else
      bottom = gui.bottom;
   end
   if isempty(gui.top)
      top = h.YLim(2);
   else
      top = gui.top;
   end
   
   d = (top - bottom)*(1-gui.overlap);
   if d < 0
      bottom = top;
      top = top - d;
   else
      bottom = bottom + d;
   end
   
   step = (top - bottom)/n;
      
   ph = findobj(h,'Tag',id,'-and','Type','Patch');
   
   % Do we need to draw from scratch, or can we replace data in handles?
   if isempty(ph)
      newdraw = true;
   elseif numel([values.name]) ~= numel([ph.UserData])
      newdraw = true;
   else
      [bool,ind] = ismember([values.name],[ph.UserData]);
      newdraw = any(~bool);
   end
   
   
       
   % Refresh labels
   if newdraw
      delete(findobj(h,'Tag',id,'-and','Type','Text'));
      delete(findobj(h,'Tag',id,'-and','Type','Patch')); clear ph;  %different from above
      for i = 1:n
         try
            color = values(i).name.color;
         catch
            color = [0 0 0];
         end
         left = values(i).time(1);
         right = values(i).time(2);
         
         

         try
            name = values(i).name.name;
         catch
            name = values(i).name;
         end
%             
%          name_saved = name ;

         % Suppress exessive output (left electrodes events on the right side)
         if all_wanted == 5  && (strcmp(name, 'TURN_E') || strcmp(name, 'TURN_S') || strcmp(name, 'FOG_S') || strcmp(name, 'FOG_E') || strcmp(name, 'FC') || strcmp(name, 'FO'))
             name = '';
         end
         if all_wanted == 10 && (strcmp(name, 'TURN_E')      )
             name = '';
         end
         if all_wanted == 998  && (strcmp(name, 'TURN_E') || strcmp(name, 'T0_EMG') || strcmp(name, 'BSL') || strcmp(name, 'FIX') || strcmp(name, 'CUE'))
             name = '';
         end

         if all_wanted > 800 && all_wanted < 899
             if ~strcmp(name, 'BSL')
                 ch = all_wanted - 800 ;
                 win_size_for_reject = 0.25 ; % 0.5
                 times    = obj.segment.spectralProcess.times{1} + obj.segment.spectralProcess.tBlock/2 ; 
                 %idx_start = -1 + find(-win_size_for_reject + values(i).time(1) < times(:),1,"first") ;
                 idx_start = max(1, -1 + find(-win_size_for_reject + values(i).time(1) < times(:), 1, "first"));
                 idx_end   = +1 + find(+win_size_for_reject + values(i).time(2) > times(:),1,"last") ;

                 v = obj.segment.spectralProcess.values{1, 1}  (idx_start:idx_end, 1:40, ch) ;
                 output = round(sum(sum(v)),-1) ;
                 seuil = 5 * size(v,1) * size(v,2) ;

                 name = num2str(output) ;
%                  name = name(1:end-2) ;
                 if output > seuil && output < seuil*2
                     color =  'k' ;
                 elseif output > seuil*2
                     color = 'r';
                 else
                     color = [0.7 0.7 0.7];
                 end
             end

%              if ~strcmp(name, 'BSL')
%                  description = obj(ind1).values{1}(i).description ;
%                  ch = all_wanted - 800 ;
%                  output = MAGIC.batch.Artefact_in_this_event_per_channel(0, 0, 'decode', 0, description, 0, 9979) ;
%                  name = output{ch} ;
%                  if str2num(output{ch}) > 40 && str2num(output{ch}) < 100
%                      color =  'k' ;
%                  elseif str2num(output{ch}) > 100
%                      color = 'r';
%                  else
%                      color = [0.7 0.7 0.7];
%                  end
%              end
         end


         if     strcmp(name, 'TURN_E')
             name = 'ET';            
             color = [1 0.2 0.8];
         elseif strcmp(name, 'TURN_S')
             name = 'ST';            
             color = [1 0.2 0.8];
             StartTurnValue = values(i).time(1) ;
         elseif strcmp(name, 'FOG_S')
             name = 'SF';            
             color = [1 0.2 0.8];
         elseif strcmp(name, 'FOG_E')
             name = 'EF';            
             color = [1 0.2 0.8];
         elseif strcmp(name, 'FC')
             name = '\nabla';            
             color = 'r';
         elseif strcmp(name, 'FO')
             name = '\Delta';            
             color = 'r';
         elseif strcmp(name, 'T0_EMG')
             name = 'M';            
             color = [1 0.2 0.8];
             if ~flag_exist_T0 ; StartWalkValue = values(i).time(1) ; flag_exist_T0 = true ; end
         elseif strcmp(name, 'BSL')          
             name = 'BS'; 
             color = [0.4 0 0.4];
         elseif strcmp(name, 'FIX')          
             name = 'FX'; 
             color = [0.4 0 0.4];
         elseif strcmp(name, 'CUE')          
             name = 'cu'; 
             color = [0.4 0 0.4];
         elseif strcmp(name, 'FO1') || strcmp(name, 'FO2')         
             name = '\Delta';
             color = [1 0.2 0.8];
         elseif strcmp(name, 'FO1')
             if ~flag_exist_T0 ;
                 StartWalkValue = values(i).time(1) ;
             end
         elseif strcmp(name, 'FC1') || strcmp(name, 'FC2')         
             name = '\nabla';
             color = [1 0.2 0.8];
         elseif strcmp(name, 'T0')
             name = 'T0';            
             color = 'r';
             StartWalkValue = values(i).time(1) ;
             flag_exist_T0 = true;
         end

         
         if gui.stagger
            topbottom = bottom + [(i-1)*step i*step i*step (i-1)*step];
         else
            topbottom = [bottom top top bottom];
         end
         ph(i) = fill3([left left right right],topbottom,[10 10 10 10],...
            color,'FaceAlpha',gui.alpha,'EdgeColor','none','Parent',h);
         set(ph(i),'UserData',values(i).name,'Tag',id,'ButtonDownFcn',gui.patchcallback);
         if values(i).duration == 0
            ph(i).EdgeColor = color;
         end

         if gui.stagger
            top2 = bottom + (i)*step;
         else
            top2 = top;
         end
         
         % Attach menus
            hf = ancestor(h,'Figure');
            delete(findobj(h.Parent,'Tag',id,'-and','Type','ContextMenu'));
            eventMenu = uicontextmenu('Parent',hf,'Callback',@patchHittest_MAGIC);
            uimenu('Parent',eventMenu,'Label','Move','Callback',{@moveEvent_MAGIC obj(ind1) h});
            uimenu('Parent',eventMenu,'Label','Delete','Callback',{@deleteEvent_MAGIC obj(ind1) h});
            uimenu('Parent',eventMenu,'Label','Change color','Callback',{@pickColor_MAGIC obj(ind1) h});
            uimenu('Parent',eventMenu,'Label','View properties','Callback',{@editEvent_MAGIC obj(ind1)});
            set(eventMenu,'Tag',id);
            set(ph,'uicontextmenu',eventMenu);
         % Modif AVH
         % If left-click on Event -> Move
            set(ph,'ButtonDownFcn',{@moveEvent_MAGIC obj(ind1) h},'HitTest','on');


         lateralpostition = values(i).time(1)/2 + values(i).time(2)/2 ;
         if ~isempty(name)
            if strcmp(name,'\Delta') || strcmp(name,'\nabla')
                 eText = text(lateralpostition,top2,name,'VerticalAlignment','bottom',...
                   'FontAngle','normal','Color',color,'Parent',h, ...
                   'Interpreter','tex', 'HorizontalAlignment','center','FontSize',7);
                 set(eText,'UserData',values(i).name,'Tag',id);
            else
                 eText = text(lateralpostition,top2,name,'VerticalAlignment','middle',...
                   'FontAngle','normal','Color',color,'Parent',h, ...
                   'Interpreter','none','FontSize',7);
                 set(eText,'Rotation', 90 ,'UserData',values(i).name,'Tag',id);
            end
            
         end
      end
      axis(h,'tight');
   else
      ph = ph(ind);
      for i = 1:n
         left = values(i).time(1);
         right = values(i).time(2);
         
         if gui.stagger
            topbottom = bottom + [(i-1)*step i*step i*step (i-1)*step];
         else
            topbottom = [bottom top top bottom];
         end
         
         ph(i).Vertices = [[left left right right]' topbottom'];
      end
      
      % Ensure that patch handles are ordered like data


      % Attach menus
         hf = ancestor(h,'Figure');
         delete(findobj(h.Parent,'Tag',id,'-and','Type','ContextMenu'));
         eventMenu = uicontextmenu('Parent',hf,'Callback',@patchHittest_MAGIC);
         uimenu('Parent',eventMenu,'Label','Move','Callback',{@moveEvent_MAGIC obj(ind1) h});
         uimenu('Parent',eventMenu,'Label','Delete','Callback',{@deleteEvent_MAGIC obj(ind1) h});
         uimenu('Parent',eventMenu,'Label','Change color','Callback',{@pickColor_MAGIC obj(ind1) h});
         uimenu('Parent',eventMenu,'Label','View properties','Callback',{@editEvent_MAGIC obj(ind1)});
         set(eventMenu,'Tag',id);
         set(ph,'uicontextmenu',eventMenu);
      % Modif AVH
      % If left-click on Event -> Move
         set(ph,'ButtonDownFcn',{@moveEvent_MAGIC obj(ind1) h},'HitTest','on');




      th = findobj(h,'Tag',id,'-and','Type','Text');
      th = th(ind);
      for i = 1:n
         if gui.stagger
            top2 = bottom + (i)*step;
         else
            top2 = top;
         end
         th(i).Position(1) = values(i).time(1);
         th(i).Position(2) = top2;
      end
   end
   
   if gui.overlap < 0
      h.YLim(2) = top + abs((top - bottom)*(1-gui.overlap));
   end
   
   gui.arraySliderTxt.String = ['element ' num2str(ind1) '/' num2str(numel(obj))];
end

function addEvent_MAGIC(~,~,obj,h,id,eventType, all_wanted)
   % Extract specific parameters for this ID
   gui = linq(h.UserData).where(@(x) strcmp(x.id,id)).select(@(x) x).toArray;

   if numel(obj) > 1
      ind1 = min(max(1,round(gui.arraySlider.Value)),numel(obj));
   else
      ind1 = 1;
   end
   
   d = dragRect('xx',[],h);
   g = ancestor(h,'Figure');
   orig = g.WindowKeyPressFcn;
   g.WindowKeyPressFcn = {@keypressEvent_MAGIC};
   
   function keypressEvent_MAGIC(~,~)
      name = inputdlg('Event name:','Event name');
      if isempty(name) % Cancel or no name given
         delete(d);
         g.WindowKeyPressFcn = orig;
         return;
      end
      event = metadata.event.(eventType)('name',metadata.Label('name',name{1}));
      if d.xPoints(1) <= d.xPoints(2)
         event.tStart = d.xPoints(1);
         event.tEnd = d.xPoints(2);
      else
         event.tStart = d.xPoints(2);
         event.tEnd = d.xPoints(1);
      end
      if isa(event,'metadata.event.Artifact')
         p = findobj(h,'Type','Text','-not','Tag',id);
         labels = [p.UserData]; %fliplr([p.UserData]);
         
         [s,v] = listdlg('PromptString','Channels to which event applies',...
            'SelectionMode','multiple','ListString',{labels.name});
         if v
            event.labels = labels(s);
         end
      end
      
      obj(ind1).insert(event);
      refreshPlot_MAGIC(obj,h,id,all_wanted);
      delete(d);
      g.WindowKeyPressFcn = orig;
   end

end

function editEvent_MAGIC(src,~,obj)
   ph = src.Parent.UserData;
   ind = [obj.values{1}.name] == ph.UserData;
   label = ph.UserData;
   event = obj.values{1}(ind);	
   warning('OFF','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
   [h,event] = propertiesGUI(event);
   warning('ON','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
end

function moveEvent_MAGIC(src,~,obj,h)

% modif par AVH pour avoir move directement en cliquant sur l'event
switch src.Type
    case 'uimenu' % cas initial définit par B. Lau
        ph = src.Parent.UserData;
    case 'patch'
        ph = src;
end
ind = [obj.values{1}.name] == ph.UserData;
label = ph.UserData;
event = obj.values{1}(ind);
textLabel = findobj(h,'UserData',ph.UserData,'-and','Type','Text');

% findobj matches structs, so we need to restrict to handle matches
ind2 = [textLabel.UserData] == label;
textLabel(~ind2) = [];
event_ini = event; % on stock cette info pour connaître quel event à MaJ sur autres subplot % AVH

setptr(gcf,'hand'); % ancestor(h,'Figure')
fig.movepatch(ph,'x',@mouseupEvent_MAGIC);

    function mouseupEvent_MAGIC(~,~)
        v = get(ph,'Vertices');
        tStart = v(1,1);
        tEnd = v(3,1);
        event.tStart = tStart;
        event.tEnd = tEnd;
        obj.values{1}(ind) = event;
        obj.times{1}(ind,:) = [tStart tEnd];
        
        textLabel.Position(1) = tStart;
        % HACK - despite nextplot setting, this gets cleared?
        ph.UserData = label;
        
        Actualise_othersubplots_MAGIC(src,v);
    end
end

function Actualise_othersubplots_MAGIC(src,v)
% modif AVH : on trace les events déplacés également sur les autres subplots
ph = findobj(src.Parent.Parent.Children,'Type','patch','-and','UserData',src.UserData);
th = findobj(src.Parent.Parent.Children,'Type','text','-and','UserData',src.UserData);
if numel(ph) > 1 % si on est sur la figure avec tous les subplots
else % on est sur un zoom et on doit aller appeler les ph des la figure avec tous les subplots
fg = figure(1);    
ph2 = findobj(findobj(fg.Children,'Type','axes'),'Type','patch','-and','UserData',src.UserData);
th2 = findobj(findobj(fg.Children,'Type','axes'),'Type','text','-and','UserData',src.UserData);
    ph = [ph;ph2];  th = [th;th2];
end
    for h = ph'
        h.Vertices(:,1) = v(:,1);
    end
    for h = th'
        h.Position(1) = v(1,1);
    end
end


function deleteEvent_MAGIC(src,~,obj,h)
   ph = src.Parent.UserData;
   obj.remove(ph.Vertices(1,1));
   g = findobj(h,'UserData',ph.UserData);
   labels = get(g,'UserData');
   if iscell(labels)
      labels = [labels{:}];
   end
   ind = labels == ph.UserData;
   delete(g(ind));
   setptr(gcf,'arrow');
end

function pickColor_MAGIC(src,~,obj,h)
   ph = src.Parent.UserData;
   event = find(obj,'eventProp','name','eventVal',ph.UserData);
   
   try
      color = event.name.color;
   catch
      error('EventProcess:plot','Event names do not have color properties');
   end

   cc = javax.swing.JColorChooser;
   cp = cc.getChooserPanels;
   cc.setChooserPanels(cp([4 1]));
   cc.setColor(fix(color(1)*255),fix(color(2)*255),fix(color(3)*255));

   mouse = get(0,'PointerLocation');
   d = dialog('Position',[mouse 610 425],'Name','Select color');
   javacomponent(cc,[1,1,610,425],d);
   uiwait(d);
   color = cc.getColor;
   
   event.name.color(1) = color.getRed/255;
   event.name.color(2) = color.getGreen/255;
   event.name.color(3) = color.getBlue/255;
   ph.FaceColor = event.name.color;
   
   textLabel = findobj(h,'UserData',ph.UserData,'-and','Type','Text');
   textLabel.Color = ph.FaceColor;
end

function patchHittest_MAGIC(src,~)
disp('test ok');
   src.UserData = hittest(ancestor(src,'figure'));
end