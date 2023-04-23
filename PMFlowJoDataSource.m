classdef PMFlowJoDataSource
    %PMFLOWJODATASOURCE For reading .txt files exported from flowjo and for converting data into data-objects that can then be further processed;
    
    properties (Access = private)
        
        GroupIndicesObject
        RowTitles

        TimeSeriesTitles

        MatchMeansOfDifferentExperiments =      false;
       
        
         

       
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
                       
                        obj.GroupIndicesObject =                 varargin{1};
                        obj.RowTitles =                 varargin{2};
                        
                        obj.TimeSeriesTitles =              ''; 
                        obj.MatchMeansOfDifferentExperiments = true;
                        
                                 
                    case 3
                       
                        obj.GroupIndicesObject =                             varargin{1};
                        obj.RowTitles =                             varargin{2};
                        
                        obj.TimeSeriesTitles =                      varargin{3};
                        obj.MatchMeansOfDifferentExperiments =      true;
                        
                    
                    case 4

                        error('Use initializer with 2 arguments.')
                      
                        obj.RowTitles =                     varargin{4}; 
                        obj.TimeSeriesTitles =              ''; 

                        obj.GroupIndicesObject =                     PMFlowJoGroupIndices(varargin{1}, 'FlowJoGroupCodes.txt',  varargin{3});


                    case 5
                        error('Use initializer with 3 arguments.')
                        
                        obj.RowTitles =                     varargin{4}; 
                        obj.TimeSeriesTitles =              varargin{5}; 
                        obj.GroupIndicesObject =                     PMFlowJoGroupIndices(varargin{1},'FlowJoGroupCodes.txt',  varargin{3});


                    case 6
                        error('Use initializer with 3 arguments.')
                        
                        obj.RowTitles =                         varargin{4}; 
                        obj.TimeSeriesTitles =                  varargin{5}; 
                       
                        obj.GroupIndicesObject =                         PMFlowJoGroupIndices(varargin{1},  varargin{6},  varargin{3});
             
                    case 7
                       error('Use initializer with 3 arguments.')
                        obj.RowTitles =                         varargin{4}; 
                        obj.TimeSeriesTitles =                  varargin{5}; 
                     
                        obj.MatchMeansOfDifferentExperiments =  varargin{7};
                      
                         obj.GroupIndicesObject = PMFlowJoGroupIndices(varargin{1}, varargin{6},  varargin{3});
              
                    otherwise
                        error('wrong input.')
                end
                
               
            end


            

            function obj  = set.GroupIndicesObject(obj, Value)
                 assert(isa(Value, 'PMFlowJoGroupIndices') , 'Input must be of type PMFlowJoGroupIndices.')
                 obj.GroupIndicesObject = Value; 
            end


            
            function obj  = set.RowTitles(obj, Value)

                try
                    assert(isa(Value, 'PMRowTitles') && isscalar(Value), 'PMRowTitles required.')
                catch ME
                    rethrow(ME)
                   
                end

                obj.RowTitles = Value; 
            end
            
           
    end

    methods % SUMMARY

   
        function obj = showSummary(obj)
           cellfun(@(x) fprintf('%s', x), obj.getSummary)
        end 
       

        
        function text = getSummary(obj)
            text{1} = sprintf('\n**** This PMFlowJoDataSource object has the main function to retrieve numerical data stored in spreadsheets that were exported from FloJo.\n');
            text = [text; sprintf('It can conver these datasources into formatted spreadsheets and figures.')];
            text = [text;  sprintf('\nIt has two main linked folders:\n')];
            
             text = [text; sprintf('\n1) It has a "source-folder" %s.\n', obj.getObjectForFlowCSVFiles.getDataSourceFolder)];
             text = [text; sprintf('This source folder contains one or multiple csv files exported from Flow-Jo.\n')];
             text = [text; sprintf('Each of these files contains a numerical spreadsheet, where each row contains data of a specific sample.\n')];
             text = [text; sprintf('Each column contains data for a particular parameter (e.g. percentage of CD8+ T cells.)\n')];
             text = [text; sprintf('\nFrom this file a "RowTitles" object is created, which is used for the creation of spread-sheets.\n');];
            
             text = [text; sprintf('\nIt also has a PMRowTitles object that contains information about group-rows:\n')];
             text = [text;  obj.RowTitles.getSummary];
             text = [text; sprintf('The object is linked to the following file-codes:\n')];
             text = [text;  obj.getObjectForFlowCSVFiles.getSummary];
            
            if obj.MatchMeansOfDifferentExperiments
                 text = [text; sprintf('Means from series will be matched to the first experiment.\n')];
            else
                 text = [text; sprintf('Means from series will not be matched.\n')];
            end
            
             text = [text;  obj.GroupIndicesObject.getSummary];
                
        end

        function text = getSourceFileSummary(obj)
        
            FileNames =  obj.getAllFlowJoCSVFiles;
            
            text = cell(0, 1);
            for index = 1 : length(FileNames)
            
                text = [text; sprintf('Data series %i.\n', index)];
                
                texts = cellfun(@(x) sprintf('%s.\n', x), FileNames{index}, 'UniformOutput', false);
                text = [text; texts; newline];
            
            end
            
        end

       




    end
    
    methods % SETTERS
        
        function obj = setMatchMeansOfDifferentExperiments(obj, Value)
            obj.MatchMeansOfDifferentExperiments = Value; 
        end
        
  
    end
    
    
    methods % GETTERS
        
        function GroupStatisticsSeries =    getGroupStatisticsSeries(obj)
            % GETGROUPSTATISTICSSERIES main method of this class;
            % user gets PMGroupStatisticsSeries as defined by the class properties;
            
            GroupStatisticsLists =              obj.getGroupStatisticsLists;                
            GroupStatisticsSeries =             PMGroupStatisticsSeries(GroupStatisticsLists);

        end
        
        function GroupStatisticsListArray = getGroupStatisticsLists(obj)
            % GETGROUPSTATISTICSLISTSFORINDICES returns a vector of PMGroupStatisticsList objects;
            % each entry is for a single group (defined by filenames separated by semi-colons in the file-id file), if no semicolons are used, there will be only one entry;
            % groups can be also generated by "splitting" the data of a single data-source by having group-rows with different group entries in the group-indices object;
            % it is recommended to not generate groups with semicolons because this causes unncessary complexity;
            
              try

                    obj = obj.testMatchingOfParametersAndMatrices;
                    obj = obj.testMatchingOfGroupIndicesAndMatrices;


                  % if there is only one group, then there will be only one entry in the cell-arrays;
                  % this is recommended: if there are multiple groups, they should be read separately by creating multiple objects;
                    GroupStatisticsListArray =        cellfun(...
                            @(matrix, indices, names) ...
                                                        PMGroupSpreadsheet(...
                                                                        matrix, ...
                                                                        indices, ...
                                                                        names, ...
                                                                        obj.getDescription, ...
                                                                         obj.RowTitles.getRowTitles,...
                                                                        '').getGroupListStatistics, ...
                                                                        obj.getMatrixListsForAllGroups, ...
                                                                        obj.getGroupRows, ...
                                                                        obj.getGroupNameList...
                                                                    );
                                                                
              catch ME
                  rethrow(ME)
              end
                                                                
                             
           
                
        end
        
    

   
               
    end

    methods % GETTERS: CSV-FILES EXPORTED FROM FLOW-JO

        function columnTitles =             getColumnTitles(obj)
            % GETCOLUMNTITLES gets column titles for spreadsheet;
            % this is a character string that contains the names of the experiments (usually dates) separated by commas (between groups) or semi-colons (within groups);
            cellString =        cellfun(@(x) obj.convertCellStringToCharacter(x), obj.getObjectForFlowCSVFiles.getPanelTitles, 'UniformOutput', false);
            columnTitles =      obj.connectWithComma(cellString);
        end

        function folder =                   getFileCodes(obj)
            % GETFILECODES returns a cell-array with filenames of Flow Jo-exported CSV file;
            if isempty(obj.TimeSeriesTitles)
                folder = obj.getFileNamesOfFlowJoCSVFiles;

            else
                folder = obj.getFileNamesOfFlowJoCSVFiles;
                folder = (folder(:))';
                folder = horzcat(folder{:});
                folder = horzcat(folder{:});
                folder = {{folder}};

            end
        end

        function Value =                    getPanelTitles(obj)
            % GETPANELTITLES get title-list for each panel
            % returns a cell array vector with the "file-codes" for all the linked files that will be used for data analysis in the different panels;
            if isempty(obj.TimeSeriesTitles)
                Value = obj.getObjectForFlowCSVFiles.getPanelTitles; 

            else
                Value = (obj.getObjectForFlowCSVFiles.getPanelTitles)'; 
                Value = horzcat(Value{:});
                Value = {horzcat(Value{:})};
            end
        end

        function two =                      getSourceFolderName(obj)
            folder =                obj.getObjectForFlowCSVFiles.getDataSourceFolder;
            [~, two, ~] =           fileparts(folder);
        end

        function key =                      getActiveKey(obj)
            key = obj.getObjectForFlowCSVFiles.getActiveKey; 
        end

        function folder =                   getSourceFolder(obj)
            folder = obj.getObjectForFlowCSVFiles.getDataSourceFolder;
        end


  


    end

    methods (Access = private) % GETTERS (used to be public, see if they are needed);

        function MyNameOfDescription = getDescription(obj)

              if ~isempty(obj.getTimeSeriesTitles)
                warning('To use time series titles is not encouraged.')
                MyNameOfDescription =       {'TimeCourseExperiment'};

              else       
                MyNameOfDescription =       {obj.getObjectForFlowCSVFiles.getActiveKey};

            end


        end

        function myGroupNames = getGroupNameList(obj)
            % GETGROUPNAMELIST returns cell array with "group-list";
            % this is confusing because their are two-different group types;
            % first each cell contains an array of "internal" groups (to split up indivual Flow-Jo csv files;
            % in addition there each cell is for different "external" groups;
            % they should not be used in combination;
            % external groups are discouraged, they are just kept for backward compatibility;

            if ~isempty(obj.getTimeSeriesTitles)
                warning('To use time series titles is not encouraged.')
                myGroupNames =              obj.getTimeSeriesTitles;
                myGroupNames =              cellfun(@(x) {x}, myGroupNames, 'UniformOutput', false);
               
            else
                GroupNames =                 obj.GroupIndicesObject.getGroupNames;
                myGroupNames =              repmat({GroupNames}, obj.getNumberOfFlowJoCSVDataSources, 1);               
              
            end

            myGroupNames = myGroupNames(:);
            
            
            
        end

  

        function GroupIndicesObject = getGroupRows(obj)
            % GETGROUPROWS returns cell array with group-indices;
            % 

             AllGroupRows =                     obj.GroupIndicesObject.getGroupRows;
        
            GroupIndicesObject =                AllGroupRows(:);
            cellfun(@(x)    assert(isvector(x) && iscell(x), 'Group rows must be a vector of numerical cells.'), GroupIndicesObject);
            cellfun(@(x)   ...
                 cellfun(@(x) assert(isvector(x) && isnumeric(x), 'Group rows must be a vector of numerical cells.'), x), ...
                 GroupIndicesObject ...
                 );
             
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

            structure.GroupNames =              obj.GroupIndicesObject.getGroupNames;
            structure.GroupIndicesObject =      obj.GroupIndicesObject.getGroupRows;

            structure.SpreadsheetRowTitles =            obj.RowTitles.getRowTitles;

            if isempty(obj.getTimeSeriesTitles)
                structure.TimeTitles =                      obj.TimeSeriesTitles;
            else

                structure.TimeTitles =                    obj.getTimeSeriesTitles;
            end
        end

 


    end

    methods (Access = private)

        function obj = testCompatibility(obj)
               



        end

        function obj = testMatchingOfParametersAndMatrices(obj)

              MatrixDimensions =                    obj.getDimensionsOfNonPooledMatrices;
              NumberOfParameters =                  obj.RowTitles.getNumberOfParameters;
         
              NoMatch =                             MatrixDimensions.NumberOfParameters ~= NumberOfParameters;
              AllFileNames =                        obj.getAllFlowJoCSVFiles;
              AllFileNames =                        vertcat(AllFileNames{:});
              NonMatchingFileNames =                AllFileNames(NoMatch);

              if ~isempty(NonMatchingFileNames)
                  fprintf('There is a mismatch in number of parameters (defined in file "%s")\nand column number for the following files:\n',obj.RowTitles.getFileName)
                  cellfun(@(x) fprintf('"%s"\n', x), NonMatchingFileNames)
                  error('Mismatch of matrix column number and number of parameters defined in file "%s".\n', obj.RowTitles.getFileName)

              end

        end

        function obj = testMatchingOfGroupIndicesAndMatrices(obj)


            AllFileNames =      obj.getAllFlowJoCSVFiles;
            AllFileNames =      vertcat(AllFileNames{:});

            MatrixDimensions =                    obj.getDimensionsOfNonPooledMatrices;

            
            AllGroupRows =      obj.GroupIndicesObject.getNonPooledGroupIndices;
            AllGroupRows =      vertcat(AllGroupRows{:});
            AllGroupRows =      vertcat(AllGroupRows{:});
            
            AllGroupRows =      cellfun(@(x, y) [x, y], AllGroupRows(:, 1), AllGroupRows(:, 2), 'UniformOutput', false);
            AllGroupRows =      cellfun(@(x) x(:), AllGroupRows, 'UniformOutput', false);
            MaxSetRows =           cellfun(@(x) max(x), AllGroupRows);

            ExceedingMax =      MaxSetRows > MatrixDimensions.NumberOfSamples;

            NonMatchingFileNames =                AllFileNames(ExceedingMax);

              if ~isempty(NonMatchingFileNames)
                  fprintf('There is a mismatch in number of samples (defined in file "%s")\nand row number for the following files:\n',obj.RowTitles.getFileName)
                  cellfun(@(x) fprintf('"%s"\n', x), NonMatchingFileNames)
                  error('Mismatch of matrix row number and number of samples defined in file "%s".\n', obj.RowTitles.getFileName)

              end



             



        end

        function [Dimensions] = getDimensionsOfNonPooledMatrices(obj)

                MyMatrixListLists =         obj.getNonPooledMatricesForAllGroups;
                MyMatrixListLists =         vertcat(MyMatrixListLists{:});
                
                Dimensions.NumberOfSamples =                   cellfun(@(x) size(x, 1), MyMatrixListLists);
                Dimensions.NumberOfParameters =                    cellfun(@(x) size(x, 2), MyMatrixListLists);

        end

        function obj = testConsistencyForNumberOfRows(obj, NonMatchingFileNames)

            for index = 1 : length(NonMatchingFileNames)
                  cellfun(@(x)  fprintf('There could be a problem with file "%s". \nThe number of columns may not match the number of parameters in the RowTitles file "%s".\n',x, obj.RowTitles.getFileName), NonMatchingFileNames{index});

            end

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
    
    methods (Access = private) % GETTERS CSV-FILES EXPORTED BY FLOW-JO

        function Matrices = getMatrixListsForAllGroups(obj)
            Matrices =               cellfun(@(x) obj.getPooledMatrixForFlowJoCSVFileNames(x), obj.getAllFlowJoCSVFiles, 'UniformOutput', false);
            Matrices =               Matrices(:);
        end

           function Matrixx = getPooledMatrixForFlowJoCSVFileNames(obj, FileNames)
             % CREATEFLOWJOEXPORTFORFILES
                FlowJoExportList =          cellfun(@(x) PMFlowJoExport(obj.getObjectForFlowCSVFiles.getDataSourceFolder, x), FileNames);  
                FlowJoExports =              PMFlowJoExports(FlowJoExportList).setMatchMeansOfDifferentExperiments(obj.MatchMeansOfDifferentExperiments);
                Matrixx =                    FlowJoExports.getSpreadsheetOfData;
           end

           function Matrices = getNonPooledMatricesForAllGroups(obj)
            Matrices =               cellfun(@(x) obj.getNonPooledMatricesForFlowJoCSVFileNames(x), obj.getAllFlowJoCSVFiles, 'UniformOutput', false);
            Matrices =               Matrices(:);

               

           end

           function Matrices = getNonPooledMatricesForFlowJoCSVFileNames(obj, FileNames)
             % CREATEFLOWJOEXPORTFORFILES
                FlowJoExportLists =          cellfun(@(x) PMFlowJoExport(obj.getObjectForFlowCSVFiles.getDataSourceFolder, x), FileNames);  
               
                Matrices =                    arrayfun(@(x) x.getSpreadSheetOfData, FlowJoExportLists, 'UniformOutput',false);
           end



       

        function list = getAllFlowJoCSVFiles(obj)
            % GETLISTOFALLSOURCEFILENAMES returns list of 
            list = arrayfun(@(x) obj.getFlowJoCSVFileNamesForIndex(x), obj.getIndicesOfFlowJoCSVDataSources , 'UniformOutput', false);
        end

         function indices = getIndicesOfFlowJoCSVDataSources(obj)
            indices = (1:  obj.getNumberOfFlowJoCSVDataSources)';
         end

        function numberOfFiles =        getNumberOfFlowJoCSVDataSources(obj)
            numberOfFiles = length(obj.getFileNamesOfFlowJoCSVFiles);
        end

         function fileNames =            getFlowJoCSVFileNamesForIndex(obj, Index)
            fileNames =       cellfun(@(x) [x, '.csv'], obj.getFileNamesOfFlowJoCSVFiles{Index}, 'UniformOutput', false);
         end

         function fileNames = getFileNamesOfFlowJoCSVFiles(obj)
            fileNames = obj.getObjectForFlowCSVFiles.getFileCodesPerGroup;

         end

        function fileIDObject = getObjectForFlowCSVFiles(obj)
            fileIDObject =      obj.GroupIndicesObject.getFileCodes;
        end
       
       

    end
    
  
    
end

