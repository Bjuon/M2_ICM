% Abstract Process class 
classdef(Abstract) Process < hgsetget & matlab.mixin.Copyable
   properties
      info@containers.Map % Information about process
   end
   properties(SetAccess = immutable, Hidden)
      timeUnit            % Time representation (TODO)
      clock               % Clock info (drift-correction, TODO)
   end
   properties(Abstract)   % Abstract so subclasses can define set/get
      tStart              % Start time of process
      tEnd                % End time of process
   end
   properties(AbortSet, SetObservable)
      window              % [min max] time window of interest (time re. 0)
   end
   properties(Dependent)
      relWindow           % [min max] time window of interest (time re. cumulative offsets)
      isValidWindow       % Boolean indicating if window(s) within tStart and tEnd
   end
   properties(SetObservable)
      offset              % Time offset relative to window
   end
   properties(SetAccess = protected)
      cumulOffset = 0     % Cumulative offset
   end
   properties(Abstract)   % Abstract so subclasses can define set/get
      Fs                  % Sampling frequency
   end
   properties(Abstract, SetAccess = protected, Dependent) % Abstract so subclasses can define set/get
      dt                  % 1/Fs
   end
   properties(Abstract, SetAccess = protected) % Abstract so subclasses can define set/get
      n                   % # of signals/channels 
   end
   properties
      labels              % Label for each element of non-leading dimension
      quality             % Scalar information for each non-leading dimension
   end
   properties( Transient, GetObservable) % Set acess =protected 
      times = {}          % Current event/sample times
      values = {}         % Current attribute/value associated with each time
   end
   properties(Abstract, SetAccess = protected, Hidden)      
      Fs_                 % Original sampling frequency
   end
   properties(SetAccess = protected, Hidden)
      times_              % Original event/sample times
      values_             % Original attribute/values
      labels_             % Original labels
      quality_            % Original quality
      selection_          % Selection index
      window_             % Original window
      offset_             % Original offset
      reset_ = false      % Reset bit
      running_ = true     % Boolean indicating eager evaluation
   end
   properties
      lazyLoad = false    % Boolean to defer constructing values from values_
   end
   properties(SetAccess = protected)
      isLoaded = true     % Boolean indicates whether values constructed
   end
   properties
      deferredEval = false% Boolean to defer method evaluations (see addToQueue)
   end
   properties(SetAccess = protected)
      queue = {}          % Method evaluation queue/history
   end
   properties(Dependent)
      isRunnable = false  % Boolean indicating if queue contains runnable items
   end
   properties
      history = false     % Boolean indicating add queueable methods (TODO)
   end
   properties(Transient)
      segment@Segment     % Reference to parent Segment
   end
   properties(Abstract)
     trailingInd_         % Cell array for expanding trailing dimension
   end
   properties(SetAccess = protected, Hidden, Transient)
      loadListener_@event.proplistener % lazyLoad listener
      evalListener_@event.listener     % deferredEval listener
   end
   properties(SetAccess = immutable)
      serializeOnSave = false 
      version = '0.10.0'   % Version string
   end
   events
      runImmediately      % trigger queue evaluation
      isSyncing           % sync method executing
   end
   
   %%
   methods(Abstract)
      [s,labels] = extract(self,reqLabels)
      apply(self,fun) % apply applyFunc func?
      plot(self)
      
      % add
      % remove % delete by label
      
      % append
      % prepend
      
      % disp (overload?)
      % head
      % tail
      
      obj = loadobj(S)
      % saveobj
   end
   
   methods(Abstract, Access = protected)
      applySubset(self)
      applyWindow(self)
      applyOffset(self,offset)

      times_ = getTimes_(self)
      values_ = getValues_(self)
   end
   
   methods(Abstract)
      times = undoTimesOffset(self)
   end
   
   methods(Access = protected)
      discardBeforeStart(self)
      discardAfterEnd(self)
      
      labels = checkLabels(self,l)
      quality = checkQuality(self,q)

      addToQueue(self,varargin)
      loadOnDemand(self,varargin)
      evalOnDemand(self,varargin)
      revalOnDemand(self)
      
      disableSegmentListeners(self)
      enableSegmentListeners(self)
   end

   methods            
      function set.window(self,window)
         % Set the window property
         % Window applies to times without offset origin.
         % Note that window is applied without offset so times can be 
         % outside of the window property.
         % For setting window of object arrays, use setWindow.
         %
         % SEE ALSO
         % setWindow, applyWindow

         %------- Add to function queue ----------
         if isQueueable(self)
            addToQueue(self,window);
            if self.deferredEval
               return;
            end
         end
         %----------------------------------------

         self.window = checkWindow(window,size(window,1));
         if ~self.reset_ && ~isempty(self.values_)
            nWindow = size(self.window,1);
            % Rewindow if current and requested # of windows matches
            if isempty(self.window) || (nWindow == size(self.times,1))
               % Reset offset
               if ~all(self.cumulOffset == 0)
                  applyOffset(self,-self.cumulOffset);
               end
               % Expensive, only call when windows are changed (AbortSet=true)
               applyWindow(self);
               if ~all(self.cumulOffset == 0)
                  applyOffset(self,self.cumulOffset);
               end
            else % Different windows are ambiguous, start from original
               % Reset the process
               self.times = self.getTimes_();
               self.values = self.getValues_();
               
               self.cumulOffset = zeros(nWindow,1);
               applyWindow(self);
               self.offset = self.cumulOffset;
            end
         end
      end
      
      function relWindow = get.relWindow(self)
         relWindow = bsxfun(@plus,self.window,self.cumulOffset);
      end
      
      function set.offset(self,offset)
         % Set the offset property
         % For setting offset of object arrays, use setOffset.
         %
         % SEE ALSO
         % setOffset, applyOffset
         
         %------- Add to function queue ----------
         if isQueueable(self)
            addToQueue(self,offset);
            if self.deferredEval
               return;
            end
         end
         %----------------------------------------

         newOffset = checkOffset(offset,size(self.window,1));
         self.offset = newOffset;
         if ~self.reset_ && any(newOffset ~= 0)
            applyOffset(self,newOffset);
            self.cumulOffset = self.cumulOffset + newOffset;
         end
      end
      
      function set.labels(self,labels)
         %------- Add to function queue ----------
         if isQueueable(self)
            addToQueue(self,labels);
            if self.deferredEval
               return;
            end
         end
         %----------------------------------------
         
         labels = checkLabels(self,labels);
         self.labels = labels;
      end
      
      function set.quality(self,quality)
         %------- Add to function queue ----------
         if isQueueable(self)
            addToQueue(self,quality);
            if self.deferredEval
               return;
            end
         end
         %----------------------------------------

         quality = checkQuality(self,quality);
         self.quality = quality;
         % Fix change
         if ~isempty(self.quality_)
            self.quality_(self.selection_) = quality;
         end
      end
      
      function isValidWindow = get.isValidWindow(self)
         isValidWindow = (self.window(:,1)>=self.tStart) & ...
                         (self.window(:,2)<=self.tEnd);
      end
      
      function set.lazyLoad(self,bool)
         assert(isscalar(bool)&&islogical(bool),'Process:lazyLoad:InputFormat','Scalar boolean required.');
         if isempty(self.loadListener_) && bool
            self.loadListener_ = addlistener(self,'values','PreGet',@self.loadOnDemand);
         end

         if ~bool
            loadOnDemand(self);
         end
         self.isLoaded = ~bool;
         self.lazyLoad = bool;
      end
      
      function set.history(self,bool)
         assert(isscalar(bool)&&islogical(bool),'err');
         if ~bool && self.deferredEval
            warning('history not disabled since deferredEval = true');
         else
            self.history = bool;
         end
      end
      
      function set.deferredEval(self,bool)
         assert(isscalar(bool)&&islogical(bool),'Process:deferredEval:InputFormat','Scalar boolean required.');
         if isempty(self.evalListener_) && bool
            self.evalListener_ = addlistener(self,'runImmediately',@self.evalOnDemand);
         end
         
         self.deferredEval = bool;
         if bool
            self.running_ = false;
            self.history = true;
         else
            run(self);
         end
      end
      
      function set.queue(self,queue)
         assert(iscell(queue),'err');
         % TODO size check?
         % TODO, what if queue exists & is not empty or run? clear or flush
         % or add?
         self.queue = queue;
      end
      
      function isRunnable = get.isRunnable(self)
         isRunnable = false;

         if ~isempty(self.queue) && any(~[self.queue{:,3}])
            isRunnable = true;
         end
      end
      
      % Assignment for object arrays
      self = setWindow(self,window)
      self = setOffset(self,offset)

      chop(self,varargin)
      self = subset(self,varargin)
      %self = unsubset(self,varargin)

      bool = isQueueable(self)
      self = clearQueue(self)
      self = disableQueue(self)
      self = enableQueue(self)
      self = run(self,varargin)

      self = setInclusiveWindow(self)
      self = reset(self,n)
      self = undo(self,n)
      
      % 
      self = map(self,func,varargin)
      self = clip(self,value,varargin)
      
      % Keep current data/transformations as original
      self = fix(self,varargin)

      bool = hasLabel(self,label)
      keys = infoKeys(self,flatBool)
      bool = infoHasKey(self,key)
      bool = infoHasValue(self,value,varargin)
      bool = checkVersion(self,req)

      info = copyInfo(self)      
      
      s = sync(self,event,varargin)
      
      obj = new(self)
   end
   
   methods(Hidden)
      s = sync__(self,event,varargin)
   end
end
