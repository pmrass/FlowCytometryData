classdef PMFlowJoDataSource
    %PMFLOWJODATASOURCE For reading .txt files exported from flowjo and for converting data into data-objects that can then be further processed;
    
    properties (Access = private)
        
        GroupRows
        RowTitles
        
        TimeSeriesTitles
        TimePointDataFileName = ''
        
        SelectedGroups % try to eliminate this property
        
        MatchMeansOfDifferentExperiments =      false;
         
    end
    
    properties (Access = private) % specific settings for retrieving specific data
        
        MyDataMatrices
        
        MyGroupRows
        myGroupNames
        
        MyRowTitles
        
        MyNameOfDescription
        
    end
    
    
    properties (Access = private) % for views, this should get its own class;
        NumberOfRows =          4;
        
        
    end
    
    methods % initialization
        
            function obj = PMFlowJoDataSource(varargin)
                %PMFLOWJOGROUPS Construct an instance of this class
                % takes 2 or 3 arguments
                % 1: PMFlowJoGroupIndices
                % 2: PMRowTitles
                % 3: time-series titles (?)
                NumberOfArguments = length(varargin);
                switch NumberOfArguments
                    
                    case 0
                        
                    case 2
                       
                        obj.GroupRows =                 varargin{1};
                        obj.RowTitles =                 varargin{2};
                        
                        obj.TimeSeriesTitles =              ''; 
                        obj.MatchMeansOfDifferentExperiments = true;
                        
                                 
                    case 3
                       
                        obj.GroupRows =                             varargin{1};
                        obj.RowTitles =                             varargin{2};
                        
                        obj.TimeSeriesTitles =                      varargin{3};
                        obj.MatchMeansOfDifferentExperiments =      true;
                        
                    
                    case 4

                        error('Use initializer with 2 arguments.')
                      
                        obj.RowTitles =                     varargin{4}; 
                        obj.TimeSeriesTitles =              ''; 

                        obj.GroupRows =                     PMFlowJoGroupIndices(varargin{1}, 'FlowJoGroupCodes.txt',  varargin{3});


                    case 5
                        error('Use initializer with 3 arguments.')
                        
                        obj.RowTitles =                     varargin{4}; 
                        obj.TimeSeriesTitles =              varargin{5}; 
                        obj.GroupRows =                     PMFlowJoGroupIndices(varargin{1},'FlowJoGroupCodes.txt',  varargin{3});


                    case 6
                        error('Use initializer with 3 arguments.')
                        
                        obj.RowTitles =                         varargin{4}; 
                        obj.TimeSeriesTitles =                  varargin{5}; 
                       
                        obj.GroupRows =                         PMFlowJoGroupIndices(varargin{1},  varargin{6},  varargin{3});
             
                    case 7
                       error('Use initializer with 3 arguments.')
                        obj.RowTitles =                         varargin{4}; 
                        obj.TimeSeriesTitles =                  varargin{5}; 
                     
                        obj.MatchMeansOfDifferentExperiments =  varargin{7};
                      
                         obj.GroupRows = PMFlowJoGroupIndices(varargin{1}, varargin{6},  varargin{3});
              
                    otherwise
                        error('wrong input.')
                end
                
               
            end


            

            function obj  = set.GroupRows(obj, Value)
                 assert(isa(Value, 'PMFlowJoGroupIndices') , 'Wrong input.')

                obj.GroupRows = Value; 


            end


            
            function obj  = set.RowTitles(obj, Value)
                try
                    assert(isa(Value, 'PMRowTitles') && isscalar(Value), 'Wrong input.')
                catch
                    error('test')
                end
                obj.RowTitles = Value; 
            end
            
            function obj = set.MyGroupRows(obj, Value)
                
                 cellfun(@(x)    assert(isvector(x) && iscell(x), 'Group rows must be a vector of numerical cells.'), Value);
            cellfun(@(x)   ...
                 cellfun(@(x) assert(isvector(x) && isnumeric(x), 'Group rows must be a vector of numerical cells.'), x), ...
                 Value ...
                 );
                
             obj.MyGroupRows = Value;
                
            end
         
    end
    
    methods % setter
        
        function obj = setNumberOfRows(obj, Value)
            obj.NumberOfRows = Value; 
        end
         
        function obj = setMatchMeansOfDifferentExperiments(obj, Value)
            obj.MatchMeansOfDifferentExperiments = Value; 
        end
        
        function obj = setSelectedGroups(obj, Value)
            assert(isnumeric(Value) && isvector(Value), 'Wrong input.')
            obj.SelectedGroups = Value; 
        end
        
    end
    
    methods % summary
   
        
        function text = getSourceFileSummary(obj)
            
           FileNames =  obj.getListOfAllSourceFileNames;
           
           text = cell(0, 1);
           for index = 1 : length(FileNames)
               
              text = [text; sprintf('Data series %i.\n', index)];
              
              texts = cellfun(@(x) sprintf('%s.\n', x), FileNames{index}, 'UniformOutput', false);
               text = [text; texts; newline];
               
           end
           
           
           
            
        end
        
        function text = getSummary(obj)
             text{1} = sprintf('\n**** This PMFlowJoDataSource object has the main function to retrieve numerical data stored in spreadsheets that were exported from FloJo.\n');
               text = [text; sprintf('It can conver these datasources into formatted spreadsheets and figures.')];
                text = [text;  sprintf('\nIt has two main linked folders:\n')];
                
                 text = [text; sprintf('\n1) It has a "source-folder" %s.\n', obj.GroupRows.getFileCodes.getDataSourceFolder)];
                 text = [text; sprintf('This source folder contains one or multiple csv files exported from Flow-Jo.\n')];
                 text = [text; sprintf('Each of these files contains a numerical spreadsheet, where each row contains data of a specific sample.\n')];
                 text = [text; sprintf('Each column contains data for a particular parameter (e.g. percentage of CD8+ T cells.)\n')];
                
                
               
                  text = [text; sprintf('\nFrom this file a "RowTitles" object is created, which is used for the creation of spread-sheets.\n');];

 
                 text = [text; sprintf('\nIt also has a PMRowTitles object that contains information about group-rows:\n')];
                 text = [text;  obj.RowTitles.getSummary];
                
                 text = [text; sprintf('The object is linked to the following file-codes:\n')];
                 text = [text;  obj.GroupRows.getFileCodes.getSummary];
               
                 
                if obj.MatchMeansOfDifferentExperiments
                     text = [text; sprintf('Means from series will be matched to the first experiment.\n')];
                else
                     text = [text; sprintf('Means from series will not be matched.\n')];
                end

                 text = [text;  obj.GroupRows.getSummary];
                 text = [text; sprintf('Time-point data filename = %s\n', obj.TimePointDataFileName)];
            
            
        end
        
            function obj = showSummary(obj)
               cellfun(@(x) fprintf('%s', x), obj.getSummary)
            end 
            
    end
    
    methods % GETTERS
        
        function GroupStatisticsSeries =    getGroupStatisticsSeries(obj)
            % GETGROUPSTATISTICSSERIES main method of this class;
            % user gets PMGroupStatisticsSeries as defined by the class properties;
            
            GroupStatisticsLists =              obj.getGroupStatisticsListsForIndices;                
            GroupStatisticsSeries =             PMGroupStatisticsSeries(GroupStatisticsLists);

        end
        
        function GroupStatisticsListArray = getGroupStatisticsListsForIndices(obj, varargin)
            
              switch length(varargin)
               
                case 0
                     Indices = obj.getAllIndices;
                case 1
                    Indices = varargin{1};
                otherwise
                    error('Wrong input.')
                
                
              end
              
              obj = obj.setSettingsForRetrivingForIndices(Indices);
            
              try
               GroupStatisticsListArray =        cellfun(...
                   @(matrix, indices, names) ...
                                                        PMGroupSpreadsheet(...
                                                                        matrix, ...
                                                                        indices, ...
                                                                        names, ...
                                                                        obj.MyNameOfDescription, ...
                                                                        obj.MyRowTitles,...
                                                                        '').getGroupListStatistics, ...
                                                                        obj.MyDataMatrices(:), ...
                                                                        obj.MyGroupRows(:), ...
                                                                        obj.myGroupNames(:) ...
                                                                    );
                                                                
              catch
                  input('Something went wrong.')
              end
                                                                
                             
             %      GroupStatisticsListArray = cellfun(@(x) x.getGroupListStatistics, Spreadsheets);
                
        end
        
        function obj = setSettingsForRetrivingForIndices(obj, Indices)
            % SETSETTINGSFORRETRIVINGFORINDICES
            
             AllFileNames =                  obj.getListOfAllSourceFileNames;
             MyFileNames =                  AllFileNames(Indices);
             
             AllGroupRows =                  obj.GroupRows.getGroupRows;
             obj.MyGroupRows =                  AllGroupRows(Indices);
             
             obj.MyDataMatrices =                 cellfun(@(x) obj.createFlowJoExportForFiles(x), MyFileNames, 'UniformOutput', false);
                    
            if ~isempty(obj.getTimeSeriesTitles)
                warning('To use time series titles is not encouraged.')
                obj.myGroupNames =              obj.getTimeSeriesTitles;
                obj.myGroupNames =              cellfun(@(x) {x}, obj.myGroupNames, 'UniformOutput', false);
                obj.MyNameOfDescription =         {'TimeCourseExperiment'};

            else
                GroupNames =                obj.GroupRows.getGroupNames;
                obj.myGroupNames =              repmat({GroupNames}, length(obj.MyDataMatrices), 1);               
                obj.MyNameOfDescription =         {obj.GroupRows.getFileCodes.getActiveKey};

            end
            
             obj.MyRowTitles  =             obj.RowTitles.getRowTitles;
             
           
           

            
        end

        function columnTitles =             getColumnTitles(obj)
            % GETCOLUMNTITLES gets column titles for spreadsheet;
            % this is a character string that contains the names of the experiments (usually dates) separated by commas (between groups) or semi-colons (within groups);
            cellString =        cellfun(@(x) obj.convertCellStringToCharacter(x), obj.GroupRows.getFileCodes.getPanelTitles, 'UniformOutput', false);
            columnTitles =      obj.connectWithComma(cellString);
        end

        function folder =                   getFileCodes(obj)
            if isempty(obj.TimeSeriesTitles)
                folder = obj.GroupRows.getFileCodes.getFileCodesPerGroup;

            else
                folder = obj.GroupRows.getFileCodes.getFileCodesPerGroup;
                folder = (folder(:))';
                folder = horzcat(folder{:});
                folder = horzcat(folder{:});
                folder = {{folder}};

            end
        end

        function Value =                    getNumberOfRows(obj)
            Value = obj.NumberOfRows; 
        end  

        function Value =                    getPanelTitles(obj)
            % GETPANELTITLES get title-list for each panel
            % returns a cell array vector with the "file-codes" for all the linked files that will be used for data analysis in the different panels;
            if isempty(obj.TimeSeriesTitles)
                Value = obj.GroupRows.getFileCodes.getPanelTitles; 

            else
                Value = (obj.GroupRows.getFileCodes.getPanelTitles)'; 
                Value = horzcat(Value{:});
                Value = {horzcat(Value{:})};
            end
        end

        function two =                      getSourceFolderName(obj)
            folder = obj.GroupRows.getFileCodes.getDataSourceFolder;
            [~, two, ~] = fileparts(folder);

        end

        function key =                      getActiveKey(obj)
            key = obj.GroupRows.getFileCodes.getActiveKey; 
        end

        function folder =                   getSourceFolder(obj)
            folder = obj.GroupRows.getFileCodes.getDataSourceFolder;
        end

        function list = getListOfAllSourceFileNames(obj)
            list = arrayfun(@(x) obj.getSourceFileNamesForIndex(x), obj.getAllIndices , 'UniformOutput', false);
        end
        
        function rowTitles =                getRowTitles(obj)
            % GETROWTITLES gets "row-titles", this is a list of strings with names for each of the different parameters that are analyzed (e.g. ;
            % the data are retrieved with the obj.RowTitles object, which retrieves the "row-titles" from a file;
            % this has the advantage that changes can be made anytime and will be reflected in the final figures immediately;
            rowTitles = obj.RowTitles.getRowTitles;
        end

        function rowTitles =                getTimeSeriesTitles(obj)
            rowTitles = obj.TimeSeriesTitles;
        end

        function structure =                getStructure(obj)

            structure.GroupNames =         obj.GroupRows.getGroupNames;
            structure.GroupRows =          obj.GroupRows.getGroupRows;

            structure.SpreadsheetRowTitles =                    obj.RowTitles.getRowTitles;

            if isempty(obj.getTimeSeriesTitles)
                structure.TimeTitles =      obj.TimeSeriesTitles;
            else

                structure.TimeTitles =                    obj.getTimeSeriesTitles;
            end
        end

       function groups = getSelectedGroups(obj)
           groups  =    obj.SelectedGroups;
       end
            
               
    end
    
    methods (Access = private)
        
            function string = convertCellStringToCharacter(~, Cell)
               string = Cell{1};
                for Index = 1: length(Cell) - 1
                    string = sprintf('%s; %s', string, Cell{Index});
                end
   
            end
            
            function string = connectWithComma(~, Cell)
                string = [Cell{1}, ','];
                for Index = 1:length(Cell)-1
                    string = [string, Cell{Index + 1} , ', '];
                end

            end 

    end
    
    methods (Access = private) % GETTERS SOURCEFILENAMES
       
        function indices = getAllIndices(obj)
            indices = (1:  obj.getNumberOfDataSources)';
        end
        
     

        function fileNames =            getSourceFileNamesForIndex(obj, Index)
         fileNames =       cellfun(@(x) [x, '.csv'], obj.GroupRows.getFileCodes.getFileCodesPerGroup{Index}, 'UniformOutput', false);
        end

        function numberOfFiles =        getNumberOfDataSources(obj)
        numberOfFiles = length(obj.GroupRows.getFileCodes.getFileCodesPerGroup);
        end

    end
    
    methods (Access = private) % GETTERS IMPORT DATA SOURCES FROM FILE
        
         function Matrixx = createFlowJoExportForFiles(obj, FileNames)
             % CREATEFLOWJOEXPORTFORFILES
                FlowJoExportList =          cellfun(@(x) PMFlowJoExport(obj.GroupRows.getFileCodes.getDataSourceFolder, x), FileNames);  
                FlowJoExports =              PMFlowJoExports(FlowJoExportList).setMatchMeansOfDifferentExperiments(obj.MatchMeansOfDifferentExperiments);
                Matrixx =                    FlowJoExports.getSpreadsheetOfData;
            end
        
    end
    
    
end

